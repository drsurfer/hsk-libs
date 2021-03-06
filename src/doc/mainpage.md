\cond USER
\mainpage HSK XC878 µC Library Users' Manual

\section preface Preface

Welcome to the High Speed Karlsruhe (HSK) XC878 microcontroller (µC) users'
manual. This document is intended for those who want to use the libraries
for their own µC applications.

This document contains all the availabe library header documentation.

@see [PDF Version](hsk-libs-user.pdf)
\endcond

\cond DEV
\mainpage HSK XC878 µC Library Developers' Manual

\section preface Preface

Welcome to the High Speed Karlsruhe (HSK) XC878 microcontroller (µC)
developers' manual. This document is intended for those who want to perform
library development.

This document contains all the library header and code documentation.

@see [PDF Version](hsk-libs-dev.pdf)
\endcond



\section documentation About This Document

This document is work in progress, so far the documentation for the libraries
is mostly complete. Documentation of implemented applications is less so
and like the applications still subject to a lot of change.

\subsection documentation_layout Project Layout

- `LICENSE.md`
  - ISCL and 3rd party licensing
- `Makefile`
  - Makefile to invoke the SDCC and doxygen toolchain
- `Makefile.local`
  - Local non-revisioned Makefile for overriding default parameters
- `README.md`
  - Repository README
- `uVisionupdate.sh`
  - Updates the µVision project's overlaying instructions
- `bin.c51/`
  - C51 toolchain output produced by Keil µVision (safe to delete)
- `bin.sdcc/`
  - SDCC compiler output (safe to delete)
- `conf/`
  - Project configuration files
- `conf/doxygen.common`
  - Basic doxygen settings
- `conf/doxygen.dbc`
  - Doxygen setting changes to create documentation from DBC headers
- `conf/doxygen.dev`
  - Doxygen setting changes to create the developer documentation
- `conf/doxygen.scripts`
  - Doxygen setting changes to create the scripts documentation
- `conf/doxygen.user`
  - Doxygen setting changes to create the user documentation
- `conf/sdcc`
  - SDCC configuration, contains basic `CFLAGS` and invokes version
    specific platform hacks
- `doc/`
  - Documentation build directory
- `gen/`
  - Generated code e.g. the `.mk` files with build instructions
- `gen/dbc/`
  - C headers generated from Vector DBCs (via `scripts/dbc2c.awk)`
- `gh-pages/`
  - Project documentation, published at
    https://lonkamikaze.github.io/hsk-libs
- `gh-pages/contrib/`
  - This directory contains 3rd party documentation
- `gh-pages/contrib/ICM7228.pdf`
  - Intersil ICM7228 8-Digit, LED Display Decoder Driver data sheet
- `gh-pages/contrib/Microcontroller-XC87x-Data-Sheet-V15-infineon.pdf`
  - Data sheet for the Infineon XC87x series
- `gh-pages/contrib/XC878_um_v1_1.pdf`
  - Infineon XC878 User Manual Version 1.1
- `hacks/`
  - Storage directory for hacks that are pulled in depending on
    platform parameters like the SDCC version
- `img/`
  - Pictures included in this documentation
- `inc/`
  - 3rd party headers
- `scripts/`
  - Contains build scripts used by the `Makefile,` this folder is
    documented in the a dedicated document
- `src/`
  - The project source code
- `src/doc/`
  - This directory contains general documentation that is not specific
    to a library, application or a file, i.e. this chapter of the
    documentation
- `src/hsk_.../`
  - Directories with this prefix contain library code
- `uVision/`
  - ARM Keil µVision project files

\page platform The XC878 8-Bit Microcontroller Platform

The XC878 is an Intel 8051/8052 compatible µC architecture. This entails strong
memory limitations with severe implications to writing code.

The strength of the architecture is that the controller contains many
specialized modules that, once set up, perform many tasks without intense
interaction.

Critical for this project are the following kinds of modules:
- 10-Bit AD conversion channels
- Timers that can be triggered by external signals or perform PWM
- CAN controller

\see XC878 Reference Manual: <a href="../contrib/XC878_um_v1_1.pdf">XC878_um_v1_1.pdf</a>
\see ARM Keil Infineon XC878-16FF page: <a href="http://www.keil.com/dd/chip/4480.htm">http://www.keil.com/dd/chip/4480.htm</a>
\see Infineon XC87x Series Overview: <a href="http://www.infineon.com/cms/en/product/microcontrollers/8-bit/xc800-a-family-automotive/xc87x-series/channel.html?channel=db3a304323b87bc20123dcee653f7007&tab=2">http://www.infineon.com/cms/en/product/microcontrollers/8-bit/xc800-a-family-automotive/xc87x-series/channel.html?channel=db3a304323b87bc20123dcee653f7007&tab=2</a>
\see 8051 Basics Tutorial: <a href="http://www.8052.com/tut8051">http://www.8052.com/tut8051</a>

\section platform_registers Registers and Paging

The XC878 functions and modules are controlled through so called Special
Function Registers (SFRs).

Due to the number of modules and functions of the controller a lot more
registers are present than the 128 that can be addressed. These 128 register
addressed in the upper dirctly addressable address range from `0x80` to
`0xFF.`

To circumvent the 128 register limit each functional block of registers has
a paging register that can be used to access different Pages of registers.
In C code this is done using the SFR_PAGE() macro defined in the
Infineon/XC878.h header file that is provided by Keil µVision, the IDE used
for this project or the headers can directly be
<a href="http://www.keil.com/dd/docs/c51/infineon/xc878.h">downloaded from ARM</a>.

Paging only affects code that directly interacts with the hardware. One of
the benefits of *using* these libraries is that paging is not an issue in the
logical code.

Each section of the <a href="../contrib/XC878_um_v1_1.pdf">XC878 Reference Manual</a>
has a Register Overview that contains a table of pages and registers.

\section platform_memory Memory Limitations

The 8051 platform offers 128 bytes of `data` memory in the address range
0x00-0x7F in front of the SFR address range.
Because 128 bytes are insufficient, the 8051 architecture knows several kinds
of memory that are accessed in different manners and thus quicker or slower to
access.

The 8052 has an additional 128 bytes of indirectly addressable memory. This
memory is accessed through the key word `idata`. Access to `idata` is slower
than to `data`. The syntax for declaring a variable in `idtata` memory is:
\code
<type> idata <identifier> [= <value>];
\endcode

The additional `idata` memory is located in the upper half of the address
range. The lower half accesses `data` memory. Any `data` access to a
pointer actually is `idata` access. This is why SFRs cannot be accessed
with pointers. They are masked by `idata` memory.

The slowest kind of memory used by this library is the `xdata`
memory. The `xdata` memory makes 3kb of additional memory available and
the libraries place all large data structures in them.

Variables are declared in `xdata` with the following syntax:
\code
<type> xdata <identifier> [= <value>];
\endcode

The first 256 bytes of `xdata` memory are also accessible as 8 bit addressed
`pdata`. Using `pdata` is faster than `xdata`. The `p` in `pdata`
stands for paged. Historically the 8052 family of µCs used register `P2`
for paging. The XC878 instead provides an SFR named XADDRH.

However current 8051 C compilers don't support paging. I.e. one would have to
ensure that structs and buffers do not cross page borders and update `XADDRH`
manually. So instead of making the code more complicated and messing with the
linkers `XADDRH` is fixed to the first `xdata` page and `pdata` is simply
used as an additional 256 bytes of relatively fast memory.

There also is a 128 bits wide memory range of `bit` variables, which is used
by single bit variables of the type `bool`.

In contrast to the small amount of available RAM, 64k of ROM are available
to hold executable code. Thus a program well designed to the XC878 is one
that produces a lot of static code to reduce the required amount of runtime
memory use.

Code resides in its own address range, the `code` block. The µC can be run
from code residing in `xdata` as well, to bootstrap the µC. Constants can
also be placed in the `code` block.

\subsection platform_memory_overlaying Overlaying

In order to mitigate the memory limitations of the platform the C51 and SDCC
compilers perform an optimisation called overlaying.

The compilers build a call graph, much like the one in the documentation of
main(). The call graph is a directed graph and functions (i.e. their local
variables and parameters) may occupy the same space in memory, provided they
cannot reach each other in the graph.

E.g. main() can reach both init() and run(), thus main() may not occupy the
same memory as init() and run(). However run() and init() cannot reach each
other, so they may store their data in the same memory.

This reduces the use of the stack, which is expensive in terms of runtime
(this statement is not generally true, it just applies to the 8051 family
of µCs).

Functions may not be called more than once at a time. I.e. they may not
be recursive or called from regular code and interrupts both. Both compilers
provide a `reentrant` keyword to make functions operate on the stack. Its
use should be avoided if possible.

Both C51 and SDCC do not track function pointers. Thus creating a function
pointer results in a false call in the call tree. A call through a function
pointer is not added to the call tree.

The C51 tool chain offers \ref toolchain_lx51_misc "call tree manipulations" and SDCC
provides the \ref sdcc_interrupts "nooverlay pragma" to mitigate this.

The section about \ref memory_overlay lists best practices to
optimize code for overlaying.

\section platform_pointers Pointers

Due to the existence of different kinds of memory, pointers come in two
variations, generic pointers and memory-specific pointers. Generic pointers
take 3 bytes of memory and are by far the slowest to process.
Memory-specific pointers take 1 byte for `data`, `idata` or `pdata` and
2 bytes for `xdata` or `code`. They are also faster to process.

Note that the `data` keyword needs to be explicitely specified for `data`
pointers. Pointers declared without explicit mention of the memory type always
result in generic pointers.

Pointers can be stored in different kinds of memory than the memory they
point to:
\code
<type> <ptr_target_mem> * <ptr_mem> <identifier>;
\endcode

The following example creates an `idata` pointer to a struct in `xdata`
memory:
\code
struct foo xdata * idata p_foo;
\endcode

\page toolchain C51 Compiler Toolchain Setup

This section describes the necessary compiler toolchain setup based on the
Keil µVision IDE.

\section toolchain_device Device

It is critical for device flashing and programming to select the
correct version of the µC. This dialogue also allows you to select the
extended linker and assembler. Doing so is imperative to perform the
necessary link time optimisations to fit the libraries into the limited
memory of the device.

\image html img/keil_options_Device.png "Keil µVision Device options dialogue"
\image latex img/keil_options_Device.png "Keil µVision Device options dialogue" width=10cm

\section toolchain_target Target

The target dialogue lets you select several CPU architecture and memory layout
settings.

The following options need to be set:
- Xtal (MHz):
  - This needs to be set to your external oscillator frequency,
    otherwise flashing and debugging might be unreliable
- Memory Model: Small
  - This setting means that variables are by default assigned
    to the first 128 bytes of directly addressable RAM, variables
    can still be mapped to different memory sections manaully as
    described in \ref platform_memory
- Code ROM Size: Large: 64K program
  - This setting allows up to 64k of program data to be written to
    the device
- Use On-chip ROM
- Use On-chip XRAM
- Use multiple DPTR registers
  - This allows the compiler to reduce address writes of reoccuring
    pointer targets by using multiple pointer registers
- Safe address extension SFR in interrupts
  - XRAM/xdata access is not atomic. Thus interrupts using XRAM
    can interrupt and corrupt XRAM access of functions. This setting
    preserves the XRAM address registers and thus protects them from
    corruption

\image html img/keil_options_Target.png "Keil µVision Target options dialogue"
\image latex img/keil_options_Target.png "Keil µVision Target options dialogue" width=10cm

\section toolchain_c51 C51

The C51 is the C compiler configuration dialogue. The following settings
are not obligatory for use of the HSK libraries, but recommended.

- Preprocessor Symbols
  - Define: `__xdata`, `__pdata`, `__idata`
    - This input field allows passing on preprocessor definitions
      to the preprocessor
    - The empty `__xdata`, `__pdata`, `__idata` defines allow
      C51 to ignore SDCC style memory assignments, this is
      useful to make such assignments where C51 does not
      support them
- Code Optimization
  - Level: 11: Reuse Common Exit Code
    - The highest level of optimisation, allowing the compiler the
      largest reduction of memory use
    - Select `4` or lower for debugging, all the common code
      eliminations prevent the debugger from mapping large chunks
      of C code to assembler code, making the program flow
      difficult to follow
  - Emphasis: Favor speed
    - Surprisingly this often produces smaller code than the
      `favor size` setting
  - Global Register Coloring
    - This setting allows the compiler to optimise register use
      throughout the entire application, reducing memory use and
      improving performance
  - Linker Code Packing
    - Activates a link time optimisation, after linking the
      application, the linker will replace long distance jumps
      with short jumps where applicable
- Warnings: Warninglevel 2
- Enable ANSI integer promotion rules

\image html img/keil_options_C51.png "Keil µVision C51 options dialogue"
\image latex img/keil_options_C51.png "Keil µVision C51 options dialogue" width=10cm

\section toolchain_lx51_locate LX51 Locate

LX51 is the extended linker of the C51 compiler tool chain, the Locate
dialogue is used to map memory ranges. The form can also be used to assign
portions of code to fixed addresses.

- User Memory Layout from Target Dialog
  - This option assigns the XC878 memory types to the appropriate
    address ranges
- User Classes: PDATA (X:0xF000-X:0xF0FF)
  - This option maps the `pdata` memory into the first 256 bytes of
    `xdata`

\image html img/keil_options_LX51_Locate.png "Keil µVision LX51 Locate options dialogue"
\image latex img/keil_options_LX51_Locate.png "Keil µVision LX51 Locate options dialogue" width=10cm

\section toolchain_lx51_misc LX51 Misc

The Misc dialogue holds the remaining linker settings.

- Overlay
  - This field can be used to add calls through function pointers to the
    call tree as is necessary for callback functions, the syntax is
    described in the µVision Help section OVERLAY Linker Directive
  - Manually filling this field can be avoided by running the
    `uVisionupdate`.sh script
- Misc controls: REMOVEUNUSED
  - This linker flag saves memory by discarding unused functions

\image html img/keil_options_LX51_Misc.png "Keil µVision LX51 Misc options dialogue"
\image latex img/keil_options_LX51_Misc.png "Keil µVision LX51 Misc options dialogue" width=10cm

\section toolchain_inline_asm Inline Assembler

Inline assembler has to be activated for Groups or single files individually.
The Group Options can be found in the context menu of a Group.

To activate an option in this menu it needs to be unchecked and checked again.

- Generate Assembler SRC File
  - This option causes the compiler to generate assembler code instead
    of an object file
- Assemble SRC File
  - This option causes the compiler to assemble the generated assembler
    code

\image html img/keil_options_Group.png "Keil µVision Group options dialogue"
\image latex img/keil_options_Group.png "Keil µVision Group options dialogue" width=10cm


\section toolchain_program Device Programming and Debugging

To program or debug the device via On Chip Debug Support (OCDS) the Infineon
Direct Access Server (DAS), a hardware access middleware, is required.
The programming and debugging options can also be selected from the target
options. Use the following settings in the Utilities tab:

- Use Target Driver for Flash Programming
  - Infineon DAS Client for XC800

\image html img/keil_options_Utilities.png "Keil µVision LX51 Utilities options dialogue"
\image latex img/keil_options_Utilities.png "Keil µVision LX51 Utilities options dialogue" width=10cm

\see Infineon DAS Tool Interface website: <a href="http://www.infineon.com/das/">http://www.infineon.com/das/</a>

Select `Settings` to enter the "Infineon XC800 DAS Driver Setup". The default
options are mostly fine. Make sure of the following options:

- DAS Server: UDAS
- Target Debug Options
  - Miscellaneous Options
    - Disable Interrupts during Steps
      - Frequently occuring interrupts like timer interrupts
        make step by step debugging completely useless

\image html img/DAS_Driver_Setup.png "Keil µVision Infineon XC800 DAS Driver Setup"
\image latex img/DAS_Driver_Setup.png "Keil µVision Infineon XC800 DAS Driver Setup" width=10cm

The Debug tab of the target options can be used to choose between in-simulator
debugging and on-chip debugging.


\page sdcc Using the Small Device C Compiler (SDCC)

This section describes how to compile code for the XC878 with the Small
Device C Compiler. SDCC is an open source compiler supporting several
8 bit architectures.

This section is about using the compiler and maintaining \ref toolchain "C51"
compatibility. Refer to \ref make to build this project using SDCC.

\see SDCC project: http://sdcc.sf.net
\see Small Device C Compiler Manual: <a href="http://sdcc.sourceforge.net/doc/sdccman.pdf">sdccman.pdf</a>

\section sdcc_arch Processor Architecture

The 8051 architecture is selected with the parameter `-mmcs51`. Additionally
the compiler needs to be invoked with the correct memory architecture,
XRAM starts at addres 0xF000 and is 3kb wide. For this the parameters
`--xram-loc` and `--xram-size` are provided:
\verbatim
-mmcs51 --xram-loc 0xF000 --xram-size 3072
\endverbatim

\section sdcc_header SDCC Header File for XC878

This projects includes the file Infineon/XC878.h in the inc/ directory,
which contains the SFR definitions for the XC878.
It is a modified version of the XC878.h file proivided by Keil µVision,
which in turn is a Dave generated file.

The modification is an <tt>\#ifdef SDCC</tt> block, with some compatibility
glue to allow using the C51 code mostly unmodified.

To make the header available to `sdcc` the inc/ should be added to the
include search path with the `-I` parameter:
\verbatim
-mmcs51 --xram-loc 0xF000 --xram-size 3072 -I inc/
\endverbatim

\section sdcc_compiling Compiling Code

Code is compiled using the `-c` parameter:
\verbatim
sdcc -mmcs51 --xram-loc 0xF000 --xram-size 3072 -I inc/ -o builddir/ -c example.c
\endverbatim

The compiler will generate a number of files in builddir, among them
`example.asm` and `example.rel,` the object file.

Instead of the build dir the output parameter `-o` can also take the name of
the object file as a parameter.

SDCC can only compile one .c file at a time, thus every .c file must
be compiled separately and linked in a separate step later.

\section sdcc_linking Linking

Linking can be done by giving all required object files as parameters.
The output file name will be based on the first input file or can
explicitely be stated:

\verbatim
sdcc -mmcs51 --xram-loc 0xF000 --xram-size 3072 -I inc/ -o builddir/ -c example.rel lib1.rel lib2.rel
\endverbatim

The output file would be `builddir/example.ihx` (Intel HEX).
`-o` `builddir/example.hex` can be used to change the filename suffix to
`.hex`, which is more convenient when using XC800_FLOAD to flash the µC.

\section sdcc_programming Programming

Whereas µVision as an IDE covers flashing, SDCC users need a separate tool
to do so. One such tool is Infineon's XC800_FLOAD. FLOAD also requires DAS.

The use of FLOAD is very straightforward, make the following settings:
- Protocol: JTAG/SPD
- Physical Interface: UDAS/JTAG over USB
- Target Device: XC87x-16FF

\image html img/XC800_FLOAD.png "XC800_FLOAD Flash Programming Tool"
\image latex img/XC800_FLOAD.png "XC800_FLOAD Flash Programming Tool" width=8cm

The important functions of FLOAD are:
- Open: Open a HEX file for programming
- Download: Download the program to the µC flash
- Flash Erase: Clear the µC flash memory

\see FLOAD download: <a href="http://www.infineon.com/cms/en/product/microcontrollers/development-tools,-software-and-kits/xc800-development-tools,-software-and-kits/software-downloads/channel.html?channel=db3a304319c6f18c011a0b54923431e5">http://www.infineon.com/cms/en/product/microcontrollers/development-tools,-software-and-kits/xc800-development-tools,-software-and-kits/software-downloads/channel.html?channel=db3a304319c6f18c011a0b54923431e5</a>
\see Infineon DAS Tool Interface website: <a href="http://www.infineon.com/das/">http://www.infineon.com/das/</a>

\section sdcc_memory Memory Usage Compatibility

In order to write compatible code, the compatiblity glue in the
Infineon/XC878.h header maps keywords like `data`, `idata`, `xdata` etc.
to their SDCC equivalents `__data`, `__idata` and `__xdata`.

Starting with SDCC 3.x C51 `code` and SDCC `__code` are largely
interchangeable. This wasn't always the case, which results in two different
styles for using `code`.

E.g. putting a variable into `code` space, C51 style:
\code
ubyte code foo = 0x2A;
\endcode

SDCC style:
\code
const ubyte foo = 0x2A;
\endcode

The C51 style is consistent with other variable space assignments and
portable (it did not work with SDCC 2.x, but works with 3.x).
The SDCC style is more logical in terms of writing code that communicates
what one intends to do. The recommendation within this project is to use a
redundant style, which also worked with SDCC 2.x with some C macro magic:
\code
const ubyte code foo = 0x2A;
\endcode

**Function pointers** are a special case. To SDCC all function pointers
refer to `code`, C51 uses (slower, larger) generic pointers if the `code`
keyword is missing. Unfortunately there is no compatible syntax to place
`code` in a function pointer declaration. This can be circumvented with
preprocessor instructions:
\snippet examples sdcc funcptr workaround open

A function pointer declaration may look like this:
\code
void (code *foo)(void);
\endcode

Take care to restore `code` before the end of a `.h` file:
\snippet examples sdcc funcptr workaround close

\section sdcc_interrupts Interrupts

The most significant difference between interrupt handling in SDCC and C51
is that prototypes for the interrupts must be visible in the context of the
main() function.

These prototypes can be enclosed in an <tt>\#ifdef</tt>:
\include hsk_isr.isr

\cond DEV
In this project the issue is solved by placing the prototypes in a dedicated
file with the file name suffix .isr. It is then included in the relevant headers in
the following fashion:
\snippet examples sdcc isr propagate

By not placing the ISR prototypes directly in the header file, unwanted
and otherwise unnecessary inclusion of headers can be avoided. Only the
small file with the ISR prototypes needs to be included in header files
of ISR using code.
\endcond

According to the SDCC manual functions called by ISRs must be reentrant or
protected from memory overlay. This is done with a compiler instruction:
\code
#pragma save
#pragma nooverlay
void isr_callback(void) using 1 {
	[...]
}
#pragma restore
\endcode

Unfortunately this causes a compiler warning when using C51:
\verbatim
..\src\main.c(49): warning C245: unknown #pragma, line ignored
\endverbatim

This can be avoided by making nooverlay conditional:
\snippet examples sdcc isr callback

\page make The Project Makefile

The project Makefile offers access to all the UNIX command line facilities
of the project. The file is written for the FreeBSD make, which is a
descendant of PMake. Some convenience and elegance was sacrificed to make
the Makefile GNU Make compatible.

\section make_doxygen Generating the Documentation

The Makefile can invoke Doxygen with the `make` targets `html` and `pdf:`
\verbatim
# make html pdf
Searching for include files...
Searching for example files...
Searching for images...
[...]
\endverbatim

The `html` target creates the directories html/user/ and html/dev/, which
contain the HTML version of this documentation.

The `pdf` target creates the directory pdf/ with the PDF versions of this
documentation.

The targets create a Users' and a Developers' Manual. The first only includes
documentation for public interfaces (i.e. headers). The second also includes
the documentation of the implementation and some additional tidbits in this
chapter that are only of interest when developing the libraries instead of
building applications with them.

\subsection make_doxygen_dependencies Dependencies

In order to build the documentation the following tools need to be installed
on the system:
- Doxygen
- GraphViz (for creating dependency graphs)
- teTeX (for pdflatex)

\section make_build Building

The Makefile uses SDCC to build. This can be changed in the first lines of
the Makefile. The default target `build` builds all the .c files. Each .c file
containing a main() function will also be linked, resulting in a .hex file:
\verbatim
# make
sdcc -mmcs51 [...] -o bin.sdcc/hsk_adc/hsk_adc.rel -c src/hsk_adc/hsk_adc.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_boot/hsk_boot.rel -c src/hsk_boot/hsk_boot.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_can/hsk_can.rel -c src/hsk_can/hsk_can.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_wdt/hsk_wdt.rel -c src/hsk_wdt/hsk_wdt.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_icm7228/hsk_icm7228.rel -c src/hsk_icm7228/hsk_icm7228.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_isr/hsk_isr.rel -c src/hsk_isr/hsk_isr.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_pwc/hsk_pwc.rel -c src/hsk_pwc/hsk_pwc.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_pwm/hsk_pwm.rel -c src/hsk_pwm/hsk_pwm.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_timers/hsk_timer01.rel -c src/hsk_timers/hsk_timer01.c
sdcc -mmcs51 [...] -o bin.sdcc/hsk_flash/hsk_flash.rel -c src/hsk_flash/hsk_flash.c
sdcc -mmcs51 [...] -o bin.sdcc/main.rel -c src/main.c
sdcc -mmcs51 [...] -o bin.sdcc/main.hex bin.sdcc/hsk_timers/hsk_timer01.rel [...]
\endverbatim

All compiler output is dumped into the bin.sdcc/ directory. All the .c files
are built, independent of whether they are linked into a .hex file.

\cond DEV
\section make_details Implementation Details

The Makefile consits of three parts:
- Building
- Documentation building
- Cleaning

\subsection make_details_building Building

The Makefile declares the target `build` first to make it the default target.
None of the build targets are manually defined. Instead with every invocation
of `make` the script `scripts/build.sh` is invoked to regenerate the file
build.mk.

The `build.sh` script searches the source directory for `.c` files and
runs `scripts/depends.awk` in `-compile` mode to generate a dependency tree.

In the next stage `build.sh` generates the build instructions for each
`.c` file.

The last step is to create the linking instructions. For that the script
searches for `.c` files that appear to contain a main() function. The
`scripts/depends.awk` script in `-link` mode is used to determine all the
libraries that have to be linked with each of the main() containing 
`.c` files.

\subsection make_details_doxygen Documentation

The targets `doc` and `doc-private` build the user and the developer
documentation. The `html` target simply copies them to the html/ directory.

The `pdf` target copies the PDF versions of the manuals to pdf/, but first
a PDF needs to be generated by running `make` in the doc/latex/ and
doc-private/latex/ directories, which is done by the respective targets.

\subsection make_details_clean Clean

The `clean-doc` target removes the directory doc/, the `clean-doc-private`
target removes the directory doc-private/ and the target `clean-build` removes
the directory `BUILDDIR`, which defaults to bin.sdcc/.

The meta-target `clean` invokes all these targets.
\endcond

\section make_cygwin Cygwin

Using a combination of native Binaries and Cygwin, the complete set of
build and generator facilities can be used from Microsoft Windows.

The followin downloads are required:
- GIT: https://git-scm.com/downloads
- SDCC: https://sourceforge.net/projects/sdcc/files/
- Cygwin installer: http://cygwin.com/install.html

Additionally to the defaults the following Cygwin packages have to be
installed:
- Devel: gcc-core
- Devel: libiconv
- Devel: make

After the installation the PATH variable should reference SDCC and Cygwin:
\image html img/cygwin_PATH.png "Cygwin and SDCC PATH environment"
\image latex img/cygwin_PATH.png "Cygwin and SDCC PATH environment" height=10cm

The libraries provide simple batch files to execute `uVisionupdate.sh`
and call `make`. For ease of use the table of `make` targets is
displayed:
\image html img/cygwin_cygwin-make.png "Make and available targets in Cygwin"
\image latex img/cygwin_cygwin-make.png "Make and available targets in Cygwin" height=10cm

\page requirements Code Requirements

To use these libraries the utilizing code must meet a small number of
requirements.

\section requirements_pages SFR Pages

All public functions expect all pages set to 0 and reset all pages they
touch to 0 before they exit.

All public functions also expect RMAP 0.

\section requirements_isrs ISRs

The \ref hsk_isr.h documentation lists the rules that need to be obeyed when
implementing ISRs and callback functions:
- \ref isr_pages
- \ref isr_banks

\section requirements_mem Memory

In order to access `pdata` and `xdata` the `hsk_boot` library must be
linked.


\page memory Variables and Memory

The Infineon/XC878.h header defines some unsigned data types:
- bool (1 bit)
- ulong (32 bits)
- uword (16 bits)
- ubyte (8 bits)

Signed types should only be used when necessary, floating point arithmetic
should be avoided if in any way possible.

The correct place to store a variable depends on four factors:
- Size
- Lifetime
- Frequency of use during lifetime
- Overlay possibility

Size, and frequency are the most obvious, considering \ref platform_memory.
It is desireable to use fast memory for frequently accessed variables.
Large data structures like buffers, arrays and structs simply use too much
of the precious memory space to put them anywhere but `xdata`.

Both the C51 and SDCC compilers use a technique called overlay to fit all
variables into memory. A stack is only used in reentrant functions. Only
`data/idata` variables can be stacked with `push/pop` instructions. Stacking
`xdata` is emulated in software and thus very slow.

The overlay approach is to build a call graph and thus decide which variables
are never used at the same time. These variables are mapped to the same
fixed memory addresses.

Variables with a long lifetime are locals in the main() function, static
variables and global variables. These variables have to keep their state
during the entire runtime. Thus they use memory space that cannot be shared
with other variables.

ISRs and functions called by ISRs also cannot share memory, because there
is no sensible way to make sure that a given function is not running when
an interrupt occurs. In technical terms, each ISR is the root node of its
own call graph.

The following table lists recommended memory types:

| Context       | Size          | Critical      | Memory       |
|---------------|---------------|---------------|--------------|
| *             | bool          | *             | bit          |
| parameter     | *             | *             | data         |
| const         | *             | *             | code         |
| local         | byte, word    | *             | data, idata  |
|               | >= long       | no            | xdata        |
|               |               | ISR/blocking  | pdata, xdata |
| static/global | *             | no            | xdata        |
|               |               | ISR/blocking  | pdata, xdata |

`ISR/blocking` refers to memory accessed by ISRs, functions called back by
ISRs and sections of code that block an interrupt.

\section memory_overlay Implications of Overlaying

First and foremost, \ref platform_memory_overlaying is only performed for
the default memory. This project is built around the small memory model,
i.e. only `data` memory is overlaid by SDCC and C51.

The `data` memory is only 128 bytes minus the used register banks large.
With three register banks that means only 104 bytes of `data` memory are
available. Thus non-overlayable variables should be placed in `idata` in
order to use `data` memory for well overlayable variables.

Furthermore SDCC does not build a complete call tree, so it cannot eliminate
unused functions like C51/LX51 and only overlays leaf functions.
I.e. only functions that call no other functions are overlaid.

For SDCC overlaying ISRs is not possible, that is why locals of ISRs should
in most cases be placed in `idata`, despite the performance impact.

A limitation of C51/LX51 is that it ignores explicit memory assignments
in function parameters and always places them in the default memory, if they
cannot be passed in registers. This limitation does not appear to be
documented, but it was reported by an ARM support employee in case #530915.

SDCC does not share this limitation, it can place function parameters in
all kinds of memory. Because such assignments are ignored by C51/LX51,
parameter memory type should be optimised for SDCC.
Explicit memory assignments prevent parameters from being passed in
registers. SDCC only passes the first non-`bool` parameter in registers,
so optimizations should be performed on the non-overlayable arguments
following it.

For single use functions like `init` and `enable` functions, it might make
sense to pass parameters in `xdata`. In such cases the SDCC memory assignment
style should be used, to give the C51 preprocessor the chance to remove the
assignments.
\code
void hsk_can_init(const ubyte pins, const ulong __xdata baud);
\endcode

If an application runs out of `data` space locals should be put into
`idata` memory. Variables accessed by ISRs/ISR callbacks should be
placed in `pdata` or `idata`. If that suffices the code should be checked
for frequently accessed variables. The most frequent ones should be assigned
to the default memory type if possible.

Both SDCC and C51 provide detailed information about memory use. The effects
of relocating variables are often counter-intuitive, because it may interfere
with several compiler and linker optimizations. This it is necessary to
make use of this information in order to make sure that changes have the
desired effect.

For SDCC check the assembler output for the `DSEG` area
(search regex `/\\\.area DSEG/`):
\code
;--------------------------------------------------------
; internal ram data
;--------------------------------------------------------
	.area DSEG    (DATA)
_hsk_adc_init_resolution_1_71:
	.ds 1
_hsk_adc_init_ctc_1_72:
	.ds 1
_hsk_adc_init_sloc0_1_0:
	.ds 2
_hsk_adc_init_sloc1_1_0:
	.ds 2
\endcode

The `.map` file lists the complete memory layout produced by the
linker (search regex `/^DSEG/`):
\code
Area                     Addr        Size        Decimal Bytes (Attributes)
-----------------        ----        ----        ------- ----- ------------
DSEG                 00000000    00000080 =         128. bytes (REL,CON)

      Value  Global                              Global Defined In Module
      -----  --------------------------------   ------------------------
     00000018  _hsk_pwm_init_PARM_2               hsk_pwm
     0000001C  _hsk_pwm_channel_set_PARM_2        hsk_pwm
     0000001E  _hsk_pwm_channel_set_PARM_3        hsk_pwm
     00000025  _hsk_icm7228_writeDec_PARM_2       hsk_icm7228
     00000027  _hsk_icm7228_writeDec_PARM_3       hsk_icm7228
     00000028  _hsk_icm7228_writeDec_PARM_4       hsk_icm7228
...
\endcode

In µVision the `.map` file can be accessed by double clicking the
project in the project tree view (search string `"D A T A"`):
\code
START     STOP      LENGTH    ALIGN  RELOC    MEMORY CLASS   SEGMENT NAME
=========================================================================

* * * * * * * * * * *   D A T A   M E M O R Y   * * * * * * * * * * * * *
000000H   000007H   000008H   ---    AT..     DATA           "REG BANK 0"
000008H   00000FH   000008H   ---    AT..     DATA           "REG BANK 1"
000010H   000017H   000008H   ---    AT..     DATA           "REG BANK 2"
000018H   00001BH   000004H   BYTE   UNIT     IDATA          _IDATA_GROUP_
00001CH.0 00001FH.7 000004H.0 ---    ---      **GAP**
000020H.0 000020H.4 000000H.5 BIT    UNIT     BIT            _BIT_GROUP_
000020H.5 000020H.5 000000H.1 BIT    UNIT     BIT            ?BI?HSK_CAN
000020H.6 000020H   000000H.2 ---    ---      **GAP**
000021H   00003FH   00001FH   BYTE   UNIT     DATA           _DATA_GROUP_
000040H   000040H   000001H   BYTE   UNIT     IDATA          ?STACK
\endcode

@see Overlaying in the SDCC manual
@see Global Registers used for Parameter Passing in the SDCC manual


\cond DEV
\page conventions Coding Conventions and Guidelines

This section describes the coding style used in these libraries.

The term \a member in this section applies to functions, globals, structs,
unions, typedefs and defines of the current library.

\section conventions_indent Code/Comment Indention and Formatting

Use 8 spaces wide real tabs for indention. Don't put spaces before a
tab, even in comments, unless it is in a code or verbatim section.

In the following example tabs are symbolised by `<tab>` and the
beginning of a line by `^`:
\snippet examples conventions spaces

Formatting on the other hand should be done using spaces. This way, no
matter the displayed tab width, formatted code and comments will always
look as intended.

The values assigned to preprocessor defines should be aligned. The
recommended indention is 4 spaces behind the longest identifier in the
file. All other defines should be aligned to the same column.

In the next example `FOOBAR` is the longest identifier and thus
dictates the formatting of all values:
\code
#define FOO       1
#define BAR       2
#define FOOBAR    3
#define ZOOM      4
\endcode

\image html img/keil_configuration_Editor.png "Keil µVision Editor tab of the configuration dialogue"
\image latex img/keil_configuration_Editor.png "Keil µVision Editor tab of the configuration dialogue" width=10cm

\section conventions_comments General Comment Guidlines

Every member is to be documented in one of the following manners:
\snippet examples member doc brief
\snippet examples member doc long

- `<brief>`
  - A short, single sentence description of the member
- `<description>`
  - A detailed description of the member

\subsection conventions_comments_lists List Formatting
Descriptions may contain syntactical sugar such as lists:
\verbatim
This is a list:
- List entry 0
- List entry 1 is a little wider than 80 characters and thus needs to cover
  multiple lines
  - List entry 1.0
- List entry 2
\endverbatim

List entries are started with a dash. Every sublevel is indented by
1 tab per level. In multiple line entries the successive lines are indented
2 additional spaces to align them with the previous line.

Unless it is a keyword the first word of a list entry needs to be a capital
letter. List entries do not end with a full stop.

\subsection conventions_comments_tables Tables

The syntax for tables is:
\verbatim
| Heading 0    | Heading 1    |
|--------------|--------------|
| Row 0, col 0 | Row 0, col 1 |
| Row 1, col 0 | Row 1, col 1 |
\endverbatim

The resulting table looks like this:

| Heading 0    | Heading 1    |
|--------------|--------------|
| Row 0, col 0 | Row 0, col 1 |
| Row 1, col 0 | Row 1, col 1 |


Use a colons in the seperator row to align columns:
\verbatim
| Heading Left | Heading Centre | Heading Right |
|:-------------|:--------------:|--------------:|
| Left         | Centre         | Right         |
\endverbatim

| Heading Left | Heading Centre | Heading Right |
|:-------------|:--------------:|--------------:|
| Left         | Centre         | Right         |

\note
Take care to obey the \ref conventions_indent guidelines, using the wrong
tab width looks especially disturbing in the plain text version of a table.

\subsection conventions_comments_inline Inline Comments

Inline comments not intended to appear in the documentation can take one of
the following shapes.\n
Compact:
\snippet examples inline compact

Multiline compact:
\snippet examples inline long

Significant:
\snippet examples inline significant

\section conventions_functions Function Documentation

Every parameter of a member function and the return value if present need
JavaDoc style `@param` and `@return` documentations in their descriptions:
\snippet examples function doc

\subsection conventions_functions_return Return Values

Use `@retval` to document return values with logical instead of numerical
meanings:
\verbatim
@retval 0
  The operation failed
@retval 1
  The operation succeeded
\endverbatim

The resulting documentation takes the following appearance:
@retval 0
  The operation failed
@retval 1
  The operation succeeded

\subsection conventions_functions_scope Public and Private Functions

The documentation to public functions belongs into the `.h` file.
All functions that have a prototype in the header file are considered public,
private functions are those, which are only used internally in the `.c`
file.

If a function is public additional documentation may be placed in the
`.c` file, it will only show up in the developers' manual.

Inline comments within functions may appear in JavaDoc style, in that case they
are also appended to the function documentation of the developers' manual.

Private functions should be marked with `@private` at the end of their
documentation block.

\section conventions_groups Grouping Documentation

In some cases a set of documented members belong together, such as a set
of defines for a certain function parameter. In such a cases the members
can be grouped:
\snippet examples group doc

Groups are listed in the Modules chapter.

\section conventions_files File Naming and Documentation

Three different file type suffixes are used in the construction of these
libraries, `.c` for C files, `.h` for header files and
`.isr` for headers that only contain ISR prototypes.

The following naming conventions exist for each file:
\verbatim
hsk_<category>/hsk_<name>.<suffix>
\endverbatim

- `<category>`
  - The library category, often identical to name, but not necessarily so
- `<name>`
  - The name of the library
- `<suffix>`
  - The file type suffix

\subsection conventions_files_headers Headers

Be greedy. Only members, which are required to use a library should be listed
in header files.

Header files in this project should avoid including other headers. There
are two exceptions to that rule, headers containing a define to generate
code might have to include headers for the generated code and headers.
The second exception are \ref conventions_files_isr.

Every header file begins with a JavaDoc style comment:
\snippet examples header doc

- `<brief>`
  - A descriptive title such as "Analog Digital Conversion"
    this description appears in the file list, nouns, verbs and
     adjectives in the brief should start with capital letters
- `<description>`
  - A text containing all the necessary information to
    use the provided functions
- `<author tag>`
  - A short author tag from \ref authors
- `<iso date>`
  - The ISO 8601 date (YYYY-MM-DD) of the last edit

The next block contains the traditional header opening:
\snippet examples header open

- `<FILE>`
  - The file name with the following translation '[:lower:].'
    '[:upper:]_', e.g. hsk_isr.h becomes HSK_ISR_H

The <tt>\#ifndef</tt> block is closed at the end of the header file with:
\snippet examples header close

Prototypes etc. belong within the block.

\subsection conventions_files_c C Files

Like header files every C file starts with a JavaDoc style comment:
\snippet examples code doc

- `<brief>`
  - Should be the same title as in the header file
- `<description>`
  - Instead of how to use the library this should make mention
    of all things of interest, when working on the implementation
- `<author tag>`
  - A short author tag from \ref authors

The first include in a C file is the Infineon/XC878.h header, followed
by the own header file. The next (optional) include block contains all the
required C library headers. The final include block includes the headers of
other libraries. The following example is from hsk_adc.c:
\snippet examples code includes

Comments for public members of a C file do not need to be copied from the
header.

\subsection conventions_files_isr ISR Headers

The ISR headers exist solely for an oddity of SDCC. All interrupts must be
visible from the context of the main() function.

Every implementation providing an interrupt has has to provide a .isr file.
The file should just contain a very plain list of prototypes, the following
examples is from hsk_timer01.isr:
\include hsk_timer01.isr

The `.isr` file should be included from the header file of the library
providing it as well as from the header files of all libraries using that
library.

The file should be included in the following manner:
\snippet examples isr header include

\section conventions_members Member Naming Conventions

All members except defines and statics have the same structure of context
prefix.
Contexts can be nested, each level of context is separated by an underscore.
Member names following the underscore separated context are camel case.
The root context is always the library, subcontexts need to have a central
concept or data structure that defines them.

Defines are always specified in capitals. Thus all separation in the names of
defines is done by underscore. Public defines have the library name without

Statics are considered private within the context and thus do not require a
prefix.

`HSK` as a prefix.

\subsection conventions_members_public Public Example

This subsection explains the naming conventions in public scope (i.e. in a
header file) using the example of the hsk_can library.
\dontinclude src/hsk_can/hsk_can.h

Public defines are provided to interpret return values or to specify possible
parameters:
\skipline CAN_ERROR
\skipline CAN0_IO_
\skipline CAN1_IO_

Typedefs give primitive data types a meaningful name for use in a certain
context. This library has functions that work on CAN nodes and functions
that work on message objects:
\skipline typedef ubyte hsk_can_node
\skipline typedef ubyte hsk_can_msg

The CAN nodes are the central structure of the library. Functions in the
`hsk_can` context always take a node as the first parameter:
\skip void hsk_can_init
\until ;
\skip void hsk_can_enable
\until ;

Other functions work around the concepts of messages and message data,
which are represented in their context prefixes:
\skip void hsk_can_msg
\until ;
\skip void hsk_can_data
\until ;

\subsection conventions_members_defines Defines

In the private context only a few rules apply to naming defines.

If defines are named after registers or bits from the µC manual, their
original spelling should be preserved, even if it means including non-capital
letters:
\dontinclude src/hsk_can/hsk_can.c
\skipline NBTRx

Apart from that special naming conventions for defines only apply to register
bits. Every register bit definition is prefixed by `BIT`. Bit fields also
specify a count:
\skipline BIT_RXSEL
\skipline CNT_RXSEL

\endcond


\page authors Authors

Authors use short tags in the code, this is the complete list of authors
and the aliases they use.

\author kami\n
        Dominic Fandrey <dominic.fandrey@highspeed-karlsruhe.de>\n
        kamikaze <kamikaze@bsdforen.de>\n
        Head of Electronics Development season 2010/2011, 2011/2012
