# PC-FX_Programming_Notes

Shorthand and reference materials specifically for programming the PC-FX machine.


## About this Repository

There is a lot of information scattered around the internet about PC-FX programming, but
many points are easily forgotten or need to be collected from disparate locations.  This
repository is intended to gather a lot of that into a central location, so that new
programmers and multi-system programmers can have quick access to various quick-lookup
questions they may have.  The repository is intended to start small and grow over time.


## Development Tools

While the PC-FXGA board and tools were originally created in 1996 to promote development, very
few of these are in the hands of developers today, and the tools generally require a 1996-era
computer to run on.  This is not the focus of this repository, but there may eventually be a
separate section devoted to the use of PC-FXGA for development.

The modern tools which will be referenced in this repository are:
These can be found here:\
[https://github.com/jbrandwood/v810-gcc](https://github.com/jbrandwood/v810-gcc)\
[https://github.com/jbrandwood/pcfxtools](https://github.com/jbrandwood/pcfxtools)\
[https://github.com/jbrandwood/liberis](https://github.com/jbrandwood/liberis)\
[https://github.com/pcfx-devel/PC-FX_Programming_Tools](https://github.com/pcfx-devel/PC-FX_Programming_Tools)

Some of the above tools are not currently held by the pcfx-devel organization, but
may soon be available here - either due to transfer, or by fork.

### Building the Build Environment

 1. Create an executable folder (i.e. $(HOME)/devel/pcfx/bin ), and put this in your path
 2. Clone the v810-gcc repository to your local development machine and performe a build based on the included instructions.
 3. Once it builds successfully, the output files will be in the "(v810-gcc_repository)/v810-gcc" folder; move this into the binary folder above.
(Following the above example, it would be $(HOME)/devel/pcfx/bin/v810-gcc )
 4. Clone the pcfxtools repository locally and build it with "make". In order to put the outputs into the same executable folder, you will need to
run "make install" with the "DSTDIR" variable set. This can be set in the command line with:
```
make --eval=DSTDIR=$(HOME)/devel/pcfx/bin install
```
OR, you can use the **pcfxtools-build.sh** script in this repoistory. This script has been placed in this repository to build pcfxtools, and to place the outputs in library locations.
   * Download this script
   * Update the key environment variables at the top of the script
   * Run the script from the parent folder of the pcfxtools repository (i.e. if pcfxtools is '$(HOME)/devel/pcfxtools', then run the script from '$(HOME)/devel')
 5. Clone the liberis repository locally. This makefile has many separate operations, and it will require some external variables to be set in order to do most of them.
The **liberis-build.sh** script has been placed in this repository to build liberis and to place the outputs in library locations, and to build all the examples.
   * Download this script
   * Update the key environment variables at the top of the script
   * Run the script from the parent folder of the liberis repository (i.e. if liberis is '$(HOME)/devel/liberis', then run the script from '$(HOME)/devel')


### Notes About Programming on PC-FX

If you are a programmer on embedded systems, a lot of the following information will probably sound familiar to you.  However, if
you normally program computers on Windows or Linux, you may need to adjust your expectations of certain things.

 1. There is no Operating System; everything runs on the "bare metal".  What does this mean ?
    - There is no operating system to detect abnormal situations and provide dumps.
    - There is no pre-emptive multitasking.
    - There is no multi-threading.  In fact, there is no concept of a "process" due to having no operating system.
    - There is no filesystem, per se - although backup memory may share some characteristics with a filesystem.
    - There is no console, per se - although some development tools may provide you with the capability of primitve communication
with the outside world.

 2. POSIX functions and libraries ARE provided, via newlib ( https://sourceware.org/newlib/ ), included with the v810-gcc compiler
package.  Some POSIX functionality may however be limited, due to the lack of an Operating System.

 3. You would do well to understand each of the hardware pieces, AT LEAST to the level of being able to initialize them,
EVEN IF YOU DON'T PLAN TO USE THEM.  Uninitialized hardware can behave in unexpected ways, which may interfere with your
program's behaviour.

 4. Although the library may attempt to provide some high-level functions to access the hardware, you will not be able to use
the hardware to the limit of its capabilities without understanding hardware in detail.

 5. This is not a modern machine. The PC-FX is a 32-bit processor with many opcodes which may execute in 1-2 cycles, but
don't make assumptions.
    - The CPU runs at roughly 21MHz, and many interfaces to other hardware (such as KRAM) are able to "block" writes/reads,
potentially slowing down your program.  You will need to anticipate what is the best time to attempt reads/writes.
    - Math is slow.  Multiplication is slow.  Division is probably a LOT slower than you think.
    - The processor does have floating point support, but stay away from it if you value your cycles. It's even slower than division.
    - There is no 3D on the base PC-FX, and 3D support is not scheduled for implementation into the library
as there are very few PC-FXGA boards which contain the 3D chip. No emulators currently support 3D either.




## V810 CPU and the GNU Compiler

### Alignment

#### Code Alignment

Code alignment: "Bit 0 of the PC is fixed to 0, and execution cannot branch to an odd address. The contents of
the PC is initialized to FFFFFFF0H at reset."

This means that all code must aligned to half-word or full-word boundaries.

#### Data Alignment

Data alignment: "With the V810 family, word data must be aligned at the word boundary (with the lower 2 bits of the address
being 0), and half word data must be aligned at the halfword boundary (with the lower 1 bit of the address being
0). Unless aligned, the lower bit(s) (2 bits in the case of word data and 1 bit in the case of halfword data) is
automatically masked 0 for access."

Because of this, misaligned reads and writes (usually in assembler, to variables with improperly-deifned alignment,
may provide confusing results which are incorrect but may appear "nearly" correct.

### Hardware Register Usage and Conventions

For an overview of how HARDWARE uses the V810's 32 registers, first look at the 
[V810 Manual](Manuals/V810_Users_Manual.pdf), Chapter 2, "Register Set" (starting on page 6).

This outlines that:

 - r0 = Zero Register (always zero)
 - r1-r5 = used by hardware
 - r6-r25 = available (But subject to software conventions)
 - r26-r30 = used by special opcodes
 - r31 = Link Pointer (return address for subroutines)

### GNU gcc 'C' Compiler Parameter Conventions:

The following refers to code generated by the gcc 'C' compiler, and may have differences from
the Hudson compiler in the PC-FXGA kit.

When 'C' passses paramters from function to function, the first 4 parameters are passed by
register, with any remaining parameters being pushed onto the stack; together with the fact
that the Link Pointer (return address) is passed by register, this creates the environment
for small subroutines to completely avoid stack usage.

In the following scenario:

x = function(a, b, c, d, e);

 - r6 receives the value of 'a'
 - r7 recieves the value of 'b'
 - r8 recieves the value of 'c'
 - r9 recieves the value of 'd'
 - the value of 'e' is pushed onto the stack
 - the value in r10 is used as a return value, and is assigned back to 'x'

### GNU gcc 'C' Compiler Register Allocation

Notwithstanding the above for parameter-passing, some registers are BY CONVENTION 'scratch'
variables and each function is free to destroy them, without pushing them on the stack - so
it is the calling function's responsibility to push them on the stack if needed.
 - r6-r19, and r30 are "caller saved"

Some regiaters are BY CONVENTION preserved, meaning that called functions are obligated to
push them on the stack if they are used within the function.
 - r20-r29 are "callee saved"


### Including/Embedding/Linking a binary file into your project

[Linking with a binary object file](https://pcengine.proboards.com/post/16767)

### Making an Executable Program

Liberis contains two two key pieces of the puzzle to make programs which can be run like other software on the system:
a linker script and a startup stub program.

#### Linker Script

The linker script is $(LIBERIS)/ldscripts/v810.x . It defines what sections are relevant to the program, and where to
position them in memory. As this is a large and complex topic, the reader should look into the gcc link process further
before considernig making any changes.

#### Startup Stub

The startup stub program is $(LIBERIS)/src/crt0.S .  This program executes as a startup, prior to executing your
program's main().  crt0.S sets up the stack pointer and clears memory in preparation to start main() .

Note that at present, crt0.S (and the link script) are set up for single program loading (i.e. not programs loaded
in sequence as a game progresses).

#### "Chained Execution" Programs

Although no examples of chained-execution programs exist (i.e. one program which loads another program from disc, then
executes it), this will eventually be made available.

The current "pcfx-cdlink" program (in pcfxtools) doesn't support multiple programs.

The "isolink" disc assembly program used by HuC (for PC Engine) will eventually replace this. "isolink" can assemble
a series of executable programs in sequence on disc, and maintain references to each of them in the second sector of the
disc's data track.  crt0.S does take action to preserve this index, but doesn't currently support loading of additional
programs, or handing off of data from one program to the next.


## PCFX Memory Map

### Internal Main Memory

| From Address | To Address | Contents |
|:------------:|:----------:|:--------|
| 0x00000000 | 0x001FFFFF | 2MB RAM; program start/user memory is normally at 0x8000 |
| 0x00000000 | 0x00007BFF | -- RAM (general-purpose)  |
| 0x00007C00 | 0x00007DFF | -- RAM (reserved for 'isolink' directory use)  |
| 0x00007E00 | 0x00007FFF | -- RAM (reserved for BIOS use )  |
| 0x00008000 | 0x001FFFFF | -- RAM (program load area)  |
| 0x00200000 | 0x7FFFFFFF | (Reserved) |
| 0x80000000 | 0x8FFFFFFF | Alternate to Ports at 0x00000000 - see below |
| 0x90000000 | 0x9FFFFFFF | (Reserved) |
| 0xA0000000 | 0xA3FFFFFF | HuC6261 - To be documented separately |
| 0xA4000000 | 0xA7FFFFFF | HuC6270(#0) - To be documented separately |
| 0xA8000000 | 0xABFFFFFF | HuC6270(#1) - To be documented separately |
| 0xAC000000 | 0xAFFFFFFF | HuC6272 - To be documented separately |
| 0xB0000000 | 0xB3FFFFFF | HuC6261 - To be documented separately |
| 0xB4000000 | 0xB7FFFFFF | HuC6270(#0) - To be documented separately |
| 0xB8000000 | 0xBBFFFFFF | HuC6270(#1) - To be documented separately |
| 0xBC000000 | 0xBFFFFFFF | HuC6272 - To be documented separately |
| 0xC0000000 | 0xDFFFFFFF | (Reserved) |
| 0xE0000000 | 0xEBFFFFFF | Backup memory - only uses every second byte |
| 0xE0000000 | 0xE000FFFF | -- INTERNAL (32KB) PC-FX internal backup memory |
| 0xE0010000 | 0xE7FFFFFF | -- INTERNAL Unused (some could have been used for more internal memory) |
| 0xE8000000 | 0xE8FFFFFF | -- EXTERNAL (8MB) FX-BMP memory |
| 0xE9000000 | 0xE9FFFFFF | -- EXTERNAL FX-BMP memory, but not usable - key address line not on bus |
| 0xEA000000 | 0xEBFFFFFF | -- EXTERNAL FX-BMP battery (bit 0 = '0' for low battery) |
| 0xEC000000 | 0xFFEFFFFF | (Reserved) |
| 0xFFF00000 | 0xFFFFFFFF | PC-FX BIOS ROM (1MB) |
| 0xFFFFFE00 | 0xFFFFFFFF | Interrupt Handler Table (within ROM) |


### I/O Map

In addition to memory-mapped I/O, the V810 also provides for I/O channels which have their own map which
also has a 32-bit address range.

In truth, most of the memory-mapped I/Os also have I/O map alias addresses. These can be more convenient,
as the port addresses are generally closer to 0x00000000, and may simply be accessed as 16-bit offset from
the r0 "zero" register.

(I/O address 0x00000000 is the same as memory address 0x80000000)

| From Address | To Address | Contents |
|:------------:|:----------:|:---------|
| 0x00000000 | 0x000000FF | K Port (for controllers) - To be documented separately |
| 0x00000100 | 0x000001FF | HuC6230 - To be documented separately |
| 0x00000200 | 0x000002FF | HuC6271 - To be documented separately |
| 0x00000300 | 0x000003FF | HuC6261 - To be documented separately |
| 0x00000400 | 0x000004FF | HuC6270(#0) - To be documented separately |
| 0x00000500 | 0x000005FF | HuC6270(#1) - To be documented separately |
| 0x00000600 | 0x000006FF | HuC6272 - To be documented separately |
| 0x00000700 | 0x000007FF | Miscellaneous Onboard Register - To be documented separately |
| 0x00000800 | 0x00000BFF | (Reserved) |
| 0x00000C00 | 0x00000C43 | HuC6270(#0 & #1) - To be documented separately |
| 0x00000C80 | 0x00000C83 | Backup Memory Access control - To be documented separately |
| 0x00000CC0 | 0x00000CC3 | Gate Array Version Register - To be documented separately |
| 0x00000E00 | 0x00000EFF | Interrupt Controller - To be documented separately |
| 0x00000F00 | 0x00000FFF | Timer - To be documented separately |
| 0x00001000 | 0x003FFFFF | (Reserved) |
| 0x00400000 | 0x004000FF | Expansion I/O (No information found as yet) |
| 0x00400100 | 0x004FFFFF | Expansion I/O (Reserved) |
| 0x00500000 | 0x005FFFFF | HuC6273 (only on PC-FXGA) - To be documented separately |
| 0x00600000 | 0x007FFFFF | Expansion I/O (Reserved) |
| 0x00800000 | 0xFFFFFFFF | (Reserved) |




## External Links

- [Daifukkat.su](http://daifukkat.su/pcfx/) - This is a translation of technical data from Buppu's PC-FXGA pages (a Japanese site)
- [Buppu's PC-FXGA page](https://hp.vector.co.jp/authors/VA007898/pcfxga/) - Originals of the above
- [Matej Horvat's site](https://matejhorvat.si/en/pcfx/index.htm) - Various information including a homebrew game
- [Thread discussing SCSI commands](https://pcengine.proboards.com/thread/1228/pce-pc-scsi-rom-commands)


### Japanese PC-FX and PC-FXGA pages:

- [fenix.ne.jp/~fez](http://www.fenix.ne.jp/~fez/soft/fxga/)
- [FX-ron](https://www2s.biglobe.ne.jp/tetuya/FXHP/fxron.html)
- [MIX2AVI](https://web.archive.org/web/20210128020037/http://hwbb.gyao.ne.jp/soltin/mix2avi.html)

