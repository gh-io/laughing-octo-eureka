ReadMe.txt for Unicode Bidirectional Algorithm Reference Implementation

Version 14.0.0 (for UBA Version 14.0.0)

Code Release Date: September 23, 2021 

Documentation Update: September 23, 2021

Author: Ken Whistler

# © 2021 Unicode®, Inc.
# For terms of use, see https://www.unicode.org/terms_of_use.html

The UBA Reference Implementation is furnished in three forms:

1. A generic Windows 64-bit executable (bidiref.exe).

2. Platform-independent source code, which can be compiled for an
   executable to run on almost any modern platform.

3. A compiled Windows 64-bit library (libbidir.lib) and a short public 
   header file (bidiref.h) defining a simple API.

The executable form can be used as a means of testing UBA implementations
for conformance, in a context where the developers of such implementations
are prohibited from viewing source code which is under Open Source or other
open licenses.

The source code is distributed, under the general Unicode Character
Database terms of use (see https://www.unicode.org/copyright.html), both
for the purpose of enabling compilation on any required platform and
as a general model for other implementations, to assist in correct
interpretation of the rather complicated steps of the specification
of the Unicode Bidirectional Algorithm in UAX #9.

The API can be used to execute the UBA reference algorithm on a
single input string and check the results. This may be useful in
building test frameworks which systematically compare another implementation
against this reference implementation, or for applications which simply
want to check or illustrate behavior in particular cases.

The source code for this reference implementation is written in C, and is
intended to complement the independent Java implementation
of the Unicode Bidirectional Algorithm:

https://www.unicode.org/Public/PROGRAMS/BidiReferenceJava/ 

These two reference implementations sponsored by the Unicode Consortium have been
developed completely independently, by engineers with no access to
each others' source code. The fact that these two, independent 
implementations in different programming languages are known
to produce identical output for identical input and to pass all current
conformance tests for the Unicode Bidirectional Algorithm is a confidence
measure for the correctness of the algorithm and of the reference
implementations themselves.

This bidiref implementation is deliberately didactic and non-optimized.
No attempt has been made to use compact data structures or to piggyback
or shortcircuit rules in clever ways to save space or increase performance.
The emphasis is on literal, step-by-step implementation of the rules of
the UBA, so that the relationship between each rule in the specification
and its implementation in code is as clear as possible. Although
this reference implementation does not attempt to be particularly
compact or efficient, it is architected in such a way as to minimize
superfluous reallocations and copying of data, in part to point the way
to implementation strategies which *would* be more efficient.

The bidiref implementation supports multiple versions of UBA rules, 
and an effort has been made to keep the expression of each version
as parallel as possible. In particular the explicit differences
between UBA 6.2.0 and UBA 6.3.0, which are structurally significant,
are highlighted in the implementation. Where the logic of the rule application does
not differ in principle, the actual implementation in code is
abstracted, so that the shared rule logic is also a shared function
in the code for each version. Where rules are distinct in their
logic, the rule tracing makes it obvious where UBA 6.3.0-specific (or later)
rules are distinct from their UBA 6.2.0 analogues.

The 6.3.0 version of the bidiref implementation was augmented
for Unicode 7.0, to enable testing with the Unicode 7.0 UCD data
files and conformance test files. UBA 7.0.0 makes use of an identical
rule set as for UBA 6.3.0, as the specification did not change between
Version 6.3.0 and Version 7.0.0.

Further augmentations have also been made for Unicode 8.0. In
UBA 8.0.0, there are significant changes to a number of rules,
to deal with edge cases in the algorithm. However, these do not
change the overall structure of the algorithm, and so are generally
specified simply with branches inside the rule implementations
for UBA 6.3.0. Subsequent versions use the same rule set as for
UBA 8.0.0, but update the repertoire to cover the corresponding
versions of the Unicode Standard.

Tracing and debug output is provided, particularly for the more difficult
and complex rules that involve stack handling in the specification.
This makes it easier to visualize how the rules are applied, step-by-step,
in complicated cases.

=======================================================================

Using bidiref.exe

The bidiref reference algorithm is written as a command line utility program.
This enables use for scripting in test harnesses of various sorts.

The reference algorithm supports fully conformant UBA implementations,
for all versions from UBA 6.2.0 through UBA 14.0.0.

Command line flags currently supported are:

-v   The -v flag prints the version string and quits.

-h   The -h flag prints out a concise summary of command line usage and quits.

-unn The -u flag allows choice of which UBA version to run (and which
     version data files to read). Valid values are -u62, -u63, -u70, -u80, -u90,
     -u100, -u110, -u120, -u130, and -u140.
     bidiref version 14.0 defaults to UBA 14.0.0 rules and data.

-p path\  The -p flag, followed by a path string (after a space), sets a directory path
     which will be used for both property files and for test input files.
     If not set, bidiref will use the current directory for all files.
     The processing is not smart about appending a trailing path separator,
     so the trailing path separator should be explicitly included in the
     parameter string. The path can support either a fully-qualified
     path, or a relative path from the current directory.

-x   The -x flag sets the program to follow UBA 6.3.0 rules.
     (Equivalent to -u63. This flag is retained for compatibility
     with earlier revisions of the bidiref code.)

-dn  The -d flag allows setting of various levels of debug output.
     This value defaults to -d0, for no debug output. Additional
     levels supported are -d1, -d2, -d3, -d4, with each higher level
     providing more debug output.

-c   The -c flag turns on a continue-on-error flag, which enables
     continuation of processing to the next test case after a
     test case fails to match expected results. This flag defaults
     to off, in which case bidiref will terminate execution after
     the first test failure.

-z   The -z flag instructs the program to take an internally defined
     static string as input. This option is primarily intended as support for
     program development and testing, but can also be used as a simple way of
     producing sample output showing application of the UBA rules
     at various levels of debug output, to help in gaining an
     understanding of how that output works.

If the -z flag is not specified, bidiref defaults to an input file named
"BidiRefTest.txt", and attempts to read bidi test cases from that
input file. Such test cases will be interpreted as using the
test case format defined in BidiCharacterTest.txt in the UCD
(see below). If the test cases do not follow that format, bidiref 
will report a parsing error and quit.

When the -z flag is not specified, a fully qualified file name can
be provided on the command line for an input file. bidiref will
then attempt to read bidi test cases from that input file.

Two distinct input file formats are supported. If an input file
starts with the substring "BidiTest", then the file format is
interpreted as the test case format of BidiTest.txt in the UCD.
That test format does not use code points, but instead specifies
test cases as vectors of Bidi_Class values, and uses an abbreviation
scheme with @-variables to specify expected levels and reordering
results for grouped sets of test cases. (See BidiTest.txt in
the UCD for full details.)

If the input file has any other name not starting with the substring
"BidiTest", then the file format is interpreted as the
test case format of BidiCharacterTest.txt in the UCD. That format
expresses test cases by sequences of Unicode code points, and puts
each test case on a single line, using semicolon-delimited fields
to separate the input string from the expected results fields.

When using the format of BidiCharacterTest.txt, test
case strings are explicitly represented as sequences of
*code points*, in 4-6 hex digit format. They should not be
expressed as UTF-16 code units, using surrogate pairs to represent
supplementary characters. For example, input data such as:

0041 D800 DC00 0041;...

would be interpreted as four code points <U+0041, U+D800, U+DC00, U+0041>,
rather than as <U+0041, U+10000, U+0041>. To test input with
supplementary characters, simply express the code points for them
directly:

0041 10000 0041;...

The bidiref implementation will not reject ill-formed input
strings containing isolated surrogate code points, but users
of the reference implementation should be aware that such
data would be explicitly testing the behavior of UBA for
ill-formed Unicode strings, and the reference implementation
does not try to "guess" that the data is misrepresented UTF-16
sequences.

Note that bidiref does not read version information internal
to the test case files, nor does it attempt to guess specific
versions of UBA heuristically, based on test case data. This
behavior is deliberate, to allow the program to be run using
any UBA version against exactly the
same input test cases, without changing the input. This can
facilitate comparison of results for interesting edge cases
for which different UBA versions behave distinctly.

Examples of usage:

% bidiref

Parse BidiRefTest.txt and run the UBA 14.0.0 rules on each
test case, printing out results only, with no debug output.

% bidiref -u63 -d1

Parse BidiRefTest.txt and run the UBA 6.3.0 rules on each
test case, printing out results plus minimal debug output.

% bidiref -x -d1

Equivalent to -u63 -d1, for backward compatibility.

% bidiref -u70 -d1

Parse BidiRefTest.txt and run the UBA 7.0.0 rules (identical
to UBA 6.3.0 rules) on each
test case, printing out results plus minimal debug output,
using Unicode 7.0 UCD data files, instead of Unicode 6.3 data.

% bidiref -u80 -c

Parse BidiRefTest.txt and run the UBA 8.0.0 rules on each
test case, printing out results without debug output,
using Unicode 8.0 UCD data files, instead of Unicode 6.3 data.
If a test case fails, continue processing through all of
the test cases.

% bidiref -u63 -z -d2

Run the UBA 6.3.0 rules on the static string input test
case and print out the results with medium debug output,
showing the intermediate results of the application of
each successive rule.

% bidiref BidiTest.txt

Parse BidiTest.txt and run the UBA 14.0.0 rules on each
test case, printing out a summary of results only.

% bidiref -u63 BidiTest.txt

Parse BidiTest.txt and run the UBA 6.3.0 rules on each
test case, printing out a summary of results only.

Note that the BidiTest.txt conformance test files are
very large, containing hundreds of thousands of individual
test cases. Running bidiref on that data with any debugging level
greater than zero will produce very voluminous output, indeed! Use
sparingly. If you want to examine particular test cases
in more detail, it is generally advisable to excerpt
them out of BidiTest.txt into a separate smaller input
file and then use that small file as input for bidiref.

% bidiref -u63 -d2 BidiTestSmallSet2.txt

Parse BidiTestSmallSet2.txt, using the format of
BidiTest.txt, run the UBA 6.3.0 rules on each test
case, printing out the results with medium debug
output, showing the intermediate results of the application
of each successive rule.

% bidiref -u100 -d3 BidiCharacterTest.txt

Parse BidiCharacterTest.txt, using the format for test
cases defined in that file, run the UBA 10.0.0 rules on each
test case, printing out the results with a high level of
debug output.

% bidiref -d4 MyOwnTestCases.txt

Parse MyOwnTestCases.txt, using the format specified for
BidiCharacterTest.txt, run the (default) UBA 14.0.0 rules on each
test case, printing out the results with the most verbose
level of debug output.

% bidiref -d4 -p c:\test\100test\ MyOwnTestCases.txt

Parse MyOwnTestCases.txt, using the format specified for
BidiCharacterTest.txt, run the (default) UBA 14.0.0 rules on each
test case, printing out the results with the most verbose
level of debug output. Bidiref will look for
UnicodeData.txt and BidiBrackets.txt in the c:\test\100test\
directory, and will also look for MyOwnTestCases.txt in
that same directory.

% bidiref -u110 -p mytest\ MyOwnTestCases.txt

Parse MyOwnTestCases.txt, using the format specified for
BidiCharacterTest.txt, run the UBA 11.0.0 rules on each
test case, printing out only the testresults. Bidiref will look for
UnicodeData-11.0.0.txt and BidiBrackets-11.0.0.txt in the .\mytest\
directory, and will also look for MyOwnTestCases.txt in
that same directory.

Trace Flags and Debug Levels

bidiref has a number of trace flags built in. These are used
to specify particular kinds of output. Currently, there
is no support for turning on or off particular
trace flags via command line arguments, but there are 
internal program functions which
can do so. The trace flags supported (as of Version 14.0) are:

Trace0   /* On by default: print UBA version and final test results */
Trace1   /* Trace main algorithm function entry. */
Trace2   /* Trace initialization code function entry. */
Trace3   /* Trace stack handling in X1-X8 */
Trace4   /* Additional debug output for X1-X8 */
Trace5   /* Trace run and sequence handling in X10 */
Trace6   /* Trace stack handling in N0 */
Trace7   /* Additional debug output for N0 */
Trace8   /* Trace reordering in L2 */
Trace9   /* Additional debug output for P2/P3 */
Trace10  /* Trace property file parsing. */
Trace11  /* Display all intermediate UBA results */
Trace12  /* Additional debug output for test parsing */
Trace13  /* Explicitly list each PASS result for tests */
Trace14  /* Omit vacuous rule application from display */
Trace15  /* On by default: print error messages */

Currently those trace flags are automatically associated
with the following debug levels:

Debug Level   Trace Flags

0             Trace0, Trace15
1             Trace1, Trace2
2             Trace11
3             Trace3, Trace5, Trace6, Trace8
4             Trace4, Trace7, Trace9, Trace12

Higher debug levels retain the trace flag settings of all lower
debug levels.

Test Case Limitations

The longest test case input string currently supported is 200
characters long. (The longest length needed for any of the
test cases in BidiTest.txt or BidiCharacterTest, as of
Unicode 14.0, is 130 characters, but the longer input string
length is provided to enable testing of arbitrary input
for deeply embedded levels or deeply nested parenthesis
pairs, for example.)

UCD Property File Requirements

The bidiref implementation does not make use of any library
code (other than the standard C runtime library). In order to
support UBA 6.3.0 (or later) rules and the BidiCharacterTest.txt format
for test cases, the program needs access to UCD character properties.

If a specific version is given on the command line, bidiref requires 
the following data files to be present.

For UBA 6.2.0:

UnicodeData-6.2.0.txt   (renamed from Version 6.2.0 of UnicodeData.txt)

For UBA 6.3.0:

UnicodeData-6.3.0.txt   (renamed from Version 6.3.0 of UnicodeData.txt)
BidiBrackets-6.3.0.txt  (renamed from Version 6.3.0 of BidiBrackets.txt)

For UBA 7.0.0:

UnicodeData-7.0.0.txt   (renamed from Version 7.0.0 of UnicodeData.txt)
BidiBrackets-7.0.0.txt  (renamed from Version 7.0.0 of BidiBrackets.txt)

For UBA 8.0.0:

UnicodeData-8.0.0.txt   (renamed from Version 8.0.0 of UnicodeData.txt)
BidiBrackets-8.0.0.txt  (renamed from Version 8.0.0 of BidiBrackets.txt)

For UBA 9.0.0:

UnicodeData-9.0.0.txt   (renamed from Version 9.0.0 of UnicodeData.txt)
BidiBrackets-9.0.0.txt  (renamed from Version 9.0.0 of BidiBrackets.txt)

For UBA 10.0.0:

UnicodeData-10.0.0.txt  (renamed from Version 10.0.0 of UnicodeData.txt)
BidiBrackets-10.0.0.txt (renamed from Version 10.0.0 of BidiBrackets.txt)

For UBA 11.0.0:

UnicodeData-11.0.0.txt  (renamed from Version 11.0.0 of UnicodeData.txt)
BidiBrackets-11.0.0.txt (renamed from Version 11.0.0 of BidiBrackets.txt)

For UBA 12.0.0:

UnicodeData-12.0.0.txt  (renamed from Version 12.0.0 of UnicodeData.txt)
BidiBrackets-12.0.0.txt (renamed from Version 12.0.0 of BidiBrackets.txt)

For UBA 13.0.0:

UnicodeData-13.0.0.txt  (renamed from Version 13.0.0 of UnicodeData.txt)
BidiBrackets-13.0.0.txt (renamed from Version 13.0.0 of BidiBrackets.txt)

For UBA 14.0.0:

UnicodeData-14.0.0.txt  (renamed from Version 14.0.0 of UnicodeData.txt)
BidiBrackets-14.0.0.txt (renamed from Version 14.0.0 of BidiBrackets.txt)

Technically speaking, you only need the versions of these data
files for the particular version of UBA you specify when starting
bidiref, as the program only reads the one particular set of files
for that version at the time of program invocation.

If a datapath directory is specified on the command line, then bidiref
will look for the corresponding UCD data files in the datapath directory
instead of in the current directory.

If the UBA version is not specified on the command line, but is
allowed to default to the current (UBA 14.0.0) version, then the
data files that will be loaded will be ones without the version-specific
suffixes:

UnicodeData.txt
BidiBrackets.txt

If the datapath directory is specified on the command line, bidiref
will also search for its test case input file in that same directory.

Note that because bidiref does not make use of a library to
obtain character property information, each invocation of bidiref
from the command line parses the relevant property files
(UnicodeData-6.2.0.txt when invoked for UBA 6.2.0, and
UnicodeData-6.3.0.txt and BidiBrackets-6.3.0.txt when invoked
for UBA 6.3.0, and so forth), to build up the internal tables
of character properties required for running the UBA rules.
As a result, if bidiref is to be used for validating
many test cases, it is more efficient to stack all those test
cases together into a single test case input file, rather than
to invoke bidiref repeatedly at the command line for each individual
test case.

[Note: This architecture may be adjusted in a future revision of
bidiref, to enable bidiref to cache all require property information
in a precompiled set of tables, and to bypass the need to parse input
data on each invocation.]

===================================================================

Using the API

The bidiref reference implementation is documented in the
public header file bidiref.h.

To build an application using this API, include bidiref.h in
your source code, and then add a link to the static libbidir
library. 

A compiled 64-bit version of the static library is provided for the
Windows platform: libbidir.lib. This compilation is currently
done with MSVC Version 12. If used to link with executables
compiled with different compiler versions, it may be simpler to
simply recompile the library from source.

The API is very simple. An application must first call br_Init()
*or* br_InitWithPath() [to set an explicit datapath]
once (and only once) to set the UBA version and initialize
the character property tables. If an explicit datapath is
provided, the character property tables
files will be sought in that specific location.

Once the initialization call is done, an application can call
br_ProcessOneTestCase() and/or br_QueryOneTestCase() as many
times as it needs. There is no cleanup call necessary or
provided. The initialization works with all static data
structures built into the library, while the test case APIs
automatically allocate and then deallocate any internal data
structures they need on a per test case basis. All test data
is passed in via one or the other of these API calls. No file
parsing is done, and the application is responsible for
setting up and marshaling the test data and accumulating
any test results.

Note: This API is *not* multithread safe,
so a testing application should not attempt to multithread
it for performance.

Control over trace flags is also provided in the API via
the calls TraceOn and TraceOff, using trace flags defined
in bidiref.h. The API br_ProcessOneTestCase honors
individual trace flags, so its execution can be tailored
to show more or less output illustrating the steps and
details of the processing. The API br_QueryOneTestCase
also honors individual trace flags. To execute
br_QueryOneTestCase without any console output, call
TraceOffAll() first. This can be done to execute
br_QueryOneTestCase repeatedly through a long list of
test cases, without producing overwhelming amounts of
output logging.

===============================================================

Using the API Demo Program: bidirefdemo.exe

A small demo program, bidirefdemo, is provided both in
source code and compiled for Windows. This demo program
illustrates how to use the API, using a single test case
example. The source code can be used to compile the demo for
any platform.

To use bidirefdemo, simply execute it at a command
line prompt with no arguments. It will print out output
demonstrating br_ProcessOneTestCase with some program
tracing on, and then print out a line indicating the
successful execution of br_QueryOneTestCase, with no
other output.

Note that currently bidirefdemo has the same requirements
as the bidiref program for the presence (and names) of
the UnicodeData and BidiBracket property files in the
current directory where it is executed (see above).

===============================================================

Build Notes

To build the bidiref executable from the source code, one
can simply compile each of the source modules and link them
all together. The basic dependency rule is just:

bidiref : bidiref.c brinput.c brutils.c brtable.c brtest.c brrule.c

To build the library to support use of the API, one can
compile and link the last four modules into a static library.
The basic dependency rule is just:

libbidir : brutils.c brtable.c brtest.c brrule.c

Then to build the bidiref executable, compile the first
two modules and link them to the library:

bidiref : bidiref.c brinput.c libbidir

to build the bidiref1 executable, compile the bidiref1.c
source and link it to the library:

bidiref1 : bidiref1.c libbidir

[The bidiref1 executable is a small support program intended
for use with Java modules underlying the Bidi utility demonstration
page at https://util.unicode.org/UnicodeJsps/bidic.jsp
The bidi C reference implementation supports the "bidi-c"
demonstration option on that page.]

To build the bidirefdemo executable, compile the bidirefdemo.c
source and link it to the library:

bidirefdemo : bidirefdemo.c libbidir

Similar approaches can then be taken to building your own
test framework which makes use of the library API.

Of course, it is also possible to build libbidir as a dynamic
link library on most platforms, but that requires definition
of the exports from the library. Note that bidiref.exe makes
use of a number of exports which are not part of the publicly
disclosed API defined in bidiref.h, so definition of all the correct
exports is not as simple as it might seem. For the purposes
to which this reference implementation would usually be put,
it is simpler to just build and use static libraries.
