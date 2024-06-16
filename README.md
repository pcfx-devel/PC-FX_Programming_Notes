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

 1. Create an executable folder (i.e. ~/devel/pcfx/bin ), and put this in your path
 2. Clone the v810-gcc repository to your local development machine and performe a build based on the included instructions.
 3. Once it builds successfully, the output files will be in the "(v810-gcc repository)/v810-gcc" folder; move this into the binary folder above.
(Following the above example, it would be ~/devel/pcfx/bin/v810-gcc )
 4. Clone the pcfxtools repository locally and build it with "make". In order to put the outputs into the same executable folder, you will need to
run "make install" with the "DSTDIR" variable set. This can be set in the command line with:
```make --eval=DSTDIR=~/devel/pcfx/bin install
```
OR, you can use the script in this repoistory. A script has been built and placed in this repository to build pcfxtools, and to place the outputs in library locations.
   * Download this script
   * Update the key environment variables at the top of the script
   * Run the script from the parent folder of the pcfxtools repository (i.e. if pcfxtools is '~/devel/pcfxtools', then run the script from '~/devel')
 5. Clone the liberis repository locally. This makefile has many separate operations, and it will require some external variables to be set in order to do most of them.
A script has been built and placed in this repository to build liberis, all the examples, and to place the outputs in library locations.
   * Download this script
   * Update the key environment variables at the top of the script
   * Run the script from the parent folder of the liberis repository (i.e. if liberis is '~/devel/liberis', then run the script from '~/devel')


## Hardware Register Usage and Conventions

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
 - r6-r19 are "caller saved"

Some regiaters are BY CONVENTION preserved, meaning that called functions are obligated to
push them on the stack if they are used within the function.
 - r20-r29 are "callee saved"


### Including/Embedding/Linking a binary file into your project

[Linking with a binary object file](https://pcengine.proboards.com/post/16767)


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


## Memory Map

### Internal Memory

| From Address | To Address | Contents |
|:------------:|:----------:|:--------|
| 0x00000000 | 0x00007FFF | RAM (reserved for what use ? )  |
| 0x00000000 | 0x001FFFFF | 2MB RAM; program start/user memory is normally at 0x8000 |
| 0x00200000 | 0xDFFFFFFF | (**To Be Documented**) |
| 0xE0000000 | 0xE000FFFF | (32KB) PC-FX internal backup memory; would be 64KB, only uses every second byte |
| 0xE0010000 | 0xE7FFFFFF | Unused - but some could have been allocated for more internal memory |
| 0xE8000000 | 0xE8FFFFFF | (8MB) FX-BMP memory; would be 16MB, but only uses every second byte |
| 0xE9000000 | 0xE9FFFFFF | FX-BMP memory, but not usable - key address line not on bus |
| 0xEA000000 | 0xEBFFFFFF | FX-BMP battery (bit 0 = '0' for low battery) |
| 0xEC000000 | 0xFFEFFFFF | (**To Be Documented**) |
| 0xFFF00000 | 0xFFFFFFFF | PC-FX BIOS ROM (1MB) |
| 0xFFFFFE00 | 0xFFFFFFFF | Interrupt Handler Table (within ROM) |


### I/O Map

In addition to memory-mapped I/O, the V810 also provides for I/O channels which have their own map which
also has a 32-bit address range.

In truth, most of the memory-mapped I/Os also have I/O map alias addresses. These can be more convenient,
as the port addresses are generally closer to 0x00000000, and may simply be accessed as 16-bit offset from
the r0 "zero" register.

| From Address | To Address | Contents |
|:------------:|:----------:|:--------:|
| 0x00000000 | 0xFFFFFFFF | (**To Be Documented**) |


## External Links

- [Daifukkat.su](http://daifukkat.su/pcfx/) - This is a translation of technical data from Buppu's PC-FXGA pages (a Japanese site)
- [Buppu's PC-FXGA page](https://hp.vector.co.jp/authors/VA007898/pcfxga/) - Originals of the above
- [Matej Horvat's site](https://matejhorvat.si/en/pcfx/index.htm) - Various information including a homebrew game
- [Thread discussing SCSI commands](https://pcengine.proboards.com/thread/1228/pce-pc-scsi-rom-commands)


### Japanese PC-FX and PC-FXGA pages:

- [fenix.ne.jp/~fez](http://www.fenix.ne.jp/~fez/soft/fxga/)
- [FX-ron](https://www2s.biglobe.ne.jp/tetuya/FXHP/fxron.html)
- [MIX2AVI](https://web.archive.org/web/20210128020037/http://hwbb.gyao.ne.jp/soltin/mix2avi.html)

