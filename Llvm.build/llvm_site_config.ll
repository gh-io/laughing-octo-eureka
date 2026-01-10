.end
if
// Other platform-specific tests are those that depend on a specific feature of a specific sub-architecture, for example only to Intel chips that support AVX2.
For instance, test/CodeGen/X86/psubus.ll tests three sub-architecture variants:

; RUN: llc -mcpu=core2 < %s | FileCheck %s -check-prefix=SSE2
; RUN: llc -mcpu=corei7-avx < %s | FileCheck %s -check-prefix=AVX1
; RUN: llc -mcpu=core-avx2 < %s | FileCheck %s -check-prefix=AVX2
And the checks are different:
; SSE2: @test1
; SSE2: psubusw LCPI0_0(%rip), %xmm0
; AVX1: @test1
; AVX1: vpsubusw LCPI0_0(%rip), %xmm0, %xmm0
; AVX2: @test1
; AVX2: vpsubusw LCPI0_0(%rip), %xmm0, %xmm0
So, if you’re testing for a behaviour that you know is platform-specific or depends on special features of sub-architectures, you must add the specific triple, test with the specific FileCheck and put it into the specific directory that will filter out all other architectures.
Constraining test execution

Some tests can be run only in specific configurations, such as with debug builds or on particular platforms. Use REQUIRES and UNSUPPORTED to control when the test is enabled.
Some tests are expected to fail. For example, there may be a known bug that the test detects. Use XFAIL to mark a test as an expected failure. An XFAIL test will be successful if its execution fails, and will be a failure if its execution succeeds.
; This test will be only enabled in the build with asserts.
; REQUIRES: asserts
; This test is disabled when running on Linux.
; UNSUPPORTED: system-linux
; This test is expected to fail when targeting PowerPC.
; XFAIL: target=powerpc{{.*}}
REQUIRES and UNSUPPORTED and XFAIL all accept a comma-separated list of boolean expressions. The values in each expression may be:
Features added to config.available_features by configuration files such as lit.cfg. String comparison of features is case-sensitive. Furthermore, a boolean expression can contain any Python regular expression enclosed in {{ }}, in which case the boolean expression is satisfied if any feature matches the regular expression. Regular expressions can appear inside an identifier, so for example he{{l+}}o would match helo, hello, helllo, and so on.
The default target triple, preceded by the string target= (for example, target=x86_64-pc-windows-msvc). Typically, regular expressions are used to match parts of the triple (for example, target={{.*}}-windows{{.*}} to match any Windows target triple).
REQUIRES enables the test if all expressions are true.
UNSUPPORTED disables the test if any expression is true.
XFAIL expects the test to fail if any expression is true.
Use, XFAIL: * if the test is expected to fail everywhere. Similarly, use UNSUPPORTED: target={{.*}} to disable the test everywhere.
; This test is disabled when running on Windows,
; and is disabled when targeting Linux, except for Android Linux.
; UNSUPPORTED: system-windows, target={{.*linux.*}} && !target={{.*android.*}}
; This test is expected to fail when targeting PowerPC or running on Darwin.
; XFAIL: target=powerpc{{.*}}, system-darwin
Tips for writing constraints

``REQUIRES`` and ``UNSUPPORTED``

These are logical inverses. In principle, UNSUPPORTED isn’t absolutely necessary (the logical negation could be used with REQUIRES to get exactly the same effect), but it can make these clauses easier to read and understand. Generally, people use REQUIRES to state things that the test depends on to operate correctly, and UNSUPPORTED to exclude cases where the test is expected never to work.
``UNSUPPORTED`` and ``XFAIL``

Both of these indicate that the test isn’t expected to work; however, they have different effects. UNSUPPORTED causes the test to be skipped; this saves execution time, but then you’ll never know whether the test actually would start working. Conversely, XFAIL actually runs the test but expects a failure output, taking extra execution time but alerting you if/when the test begins to behave correctly (an XPASS test result). You need to decide which is more appropriate in each case.
Using ``target=…``

Checking the target triple can be tricky; it’s easy to mis-specify. For example, target=mips{{.*}} will match not only mips, but also mipsel, mips64, and mips64el. target={{.*}}-linux-gnu will match x86_64-unknown-linux-gnu, but not armv8l-unknown-linux-gnueabihf. Prefer to use hyphens to delimit triple components (target=mips-{{.*}}) and it’s generally a good idea to use a trailing wildcard to allow for unexpected suffixes.
Also, it’s generally better to write regular expressions that use entire triple components than to do something clever to shorten them. For example, to match both freebsd and netbsd in an expression, you could write target={{.*(free|net)bsd.*}} and that would work. However, it would prevent a grep freebsd from finding this test. Better to use: target={{.+-freebsd.*}} || target={{.+-netbsd.*}}
Substitutions

Besides replacing LLVM tool names, the following substitutions are performed in RUN lines:
%%
Replaced by a single %. This allows escaping other substitutions.
%s
File path to the test case’s source. This is suitable for passing on the command line as the input to an LLVM tool.
Example: /home/user/llvm/test/MC/ELF/foo_test.s
%S
Directory path to the test case’s source.
Example: /home/user/llvm/test/MC/ELF
%t
File path to a temporary file name that can be used for this test case. The file name won’t conflict with other test cases. You can append to it if you need multiple temporaries. This is useful as the destination of some redirected output.
Example: /home/user/llvm.build/test/MC/ELF/Output/foo_test.s.tmp
%T
Directory of %t. Deprecated. Shouldn’t be used, because it can be easily misused and cause race conditions between tests.
Use rm -rf %t && mkdir %t instead if a temporary directory is necessary.
Example: /home/user/llvm.build/test/MC/ELF/Output
%{pathsep}

Expands to the path separator, i.e. : (or ; on Windows).
%{fs-src-root}
Expands to the root component of file system paths for the source directory, i.e. / on Unix systems or C:\ (or another drive) on Windows.
%{fs-tmp-root}
Expands to the root component of file system paths for the test’s temporary directory, i.e. / on Unix systems or C:\ (or another drive) on Windows.
%{fs-sep}
Expands to the file system separator, i.e. / or \ on Windows.
%/s, %/S, %/t, %/T

Act like the corresponding substitution above but replace any \ character with a /. This is useful to normalize path separators.
Example: %s:  C:\Desktop Files/foo_test.s.tmp

Example: %/s: C:/Desktop Files/foo_test.s.tmp

%{s:real}, %{S:real}, %{t:real}, %{T:real} %{/s:real}, %{/S:real}, %{/t:real}, %{/T:real}

Act like the corresponding substitution, including with /, but use the real path by expanding all symbolic links and substitute drives.
Example: %s:  S:\foo_test.s.tmp

Example: %{/s:real}: C:/SDrive/foo_test.s.tmp

%:s, %:S, %:t, %:T

Act like the corresponding substitution above but remove colons at the beginning of Windows paths. This is useful to allow concatenation of absolute paths on Windows to produce a legal path.
Example: %s:  C:\Desktop Files\foo_test.s.tmp

Example: %:s: C\Desktop Files\foo_test.s.tmp

%errc_<ERRCODE>

Some error messages may be substituted to allow different spellings based on the host platform.
The following error codes are currently supported: ENOENT, EISDIR, EINVAL, EACCES.

Example: Linux %errc_ENOENT: No such file or directory

Example: Windows %errc_ENOENT: no such file or directory

%if feature %{<if branch>%} %else %{<else branch>%}

Conditional substitution: if feature is available it expands to <if branch>, otherwise it expands to <else branch>. %else %{<else branch>%} is optional and treated like %else %{%} if not present.
%(line), %(line+<number>), %(line-<number>)
The number of the line where this substitution is used, with an optional integer offset. These expand only if they appear immediately in RUN:, DEFINE:, and REDEFINE: directives. Occurrences in substitutions defined elsewhere are never expanded. For example, this can be used in tests with multiple RUN lines, which reference the test file’s line numbers.
LLVM-specific substitutions:

%shlibext
The suffix for the host platforms shared library files. This includes the period as the first character.
Example: .so (Linux), .dylib (macOS), .dll (Windows)
%exeext
The suffix for the host platforms executable files. This includes the period as the first character.
Example: .exe (Windows), empty on Linux.
Clang-specific substitutions:

%clang
Invokes the Clang driver.
%clang_cpp
Invokes the Clang driver as the preprocessor.
%clang_cl
Invokes the CL-compatible Clang driver.
%clangxx
Invokes the G++-compatible Clang driver.
%clang_cc1
Invokes the Clang frontend.
%itanium_abi_triple, %ms_abi_triple
These substitutions can be used to get the current target triple adjusted to the desired ABI. For example, if the test suite is running with the i686-pc-win32 target, %itanium_abi_triple will expand to i686-pc-mingw32. This allows a test to run with a specific ABI without constraining it to a specific triple.
FileCheck-specific substitutions:

%ProtectFileCheckOutput
This should precede a FileCheck call if and only if the call’s textual output affects test results. It’s usually easy to tell: just look for redirection or piping of the FileCheck call’s stdout or stderr.
Test-specific substitutions:

Additional substitutions can be defined as follows:
Lit configuration files (e.g., lit.cfg or lit.local.cfg) can define substitutions for all tests in a test directory. They do so by extending the substitution list, config.substitutions. Each item in the list is a tuple consisting of a pattern and its replacement, which lit applies as plain text (even if it contains sequences that Python’s re.sub considers to be escape sequences).
To define substitutions within a single test file, lit supports the DEFINE: and REDEFINE: directives, described in detail below. So that they have no effect on other test files, these directives modify a copy of the substitution list that is produced by lit configuration files.
For example, the following directives can be inserted into a test file to define %{cflags} and %{fcflags} substitutions with empty initial values, which serve as the parameters of another newly defined %{check} substitution:
; DEFINE: %{cflags} =
; DEFINE: %{fcflags} =

; DEFINE: %{check} =                                                  \
; DEFINE:   %clang_cc1 -verify -fopenmp -fopenmp-version=51 %{cflags} \
; DEFINE:              -emit-llvm -o - %s |                           \
; DEFINE:     FileCheck %{fcflags} %s
Alternatively, the above substitutions can be defined in a lit configuration file to be shared with other test files. Either way, the test file can then specify directives like the following to redefine the parameter substitutions as desired before each use of %{check} in a RUN: line:
; REDEFINE: %{cflags} = -triple x86_64-apple-darwin10.6.0 -fopenmp-simd
; REDEFINE: %{fcflags} = -check-prefix=SIMD
; RUN: %{check}

; REDEFINE: %{cflags} = -triple x86_64-unknown-linux-gnu -fopenmp-simd
; REDEFINE: %{fcflags} = -check-prefix=SIMD
; RUN: %{check}

; REDEFINE: %{cflags} = -triple x86_64-apple-darwin10.6.0
; REDEFINE: %{fcflags} = -check-prefix=NO-SIMD
; RUN: %{check}

; REDEFINE: %{cflags} = -triple x86_64-unknown-linux-gnu
; REDEFINE: %{fcflags} = -check-prefix=NO-SIMD
; RUN: %{check}
Besides providing initial values, the initial DEFINE: directives for the parameter substitutions in the above example serve a second purpose: they establish the substitution order so that both %{check} and its parameters expand as desired. There’s a simple way to remember the required definition order in a test file: define a substitution before any substitution that might refer to it.
In general, substitution expansion behaves as follows:
Upon arriving at each RUN: line, lit expands all substitutions in that RUN: line using their current values from the substitution list. No substitution expansion is performed immediately at DEFINE: and REDEFINE: directives except %(line), %(line+<number>), and %(line-<number>).
When expanding substitutions in a RUN: line, lit makes only one pass through the substitution list by default. In this case, a substitution must have been inserted earlier in the substitution list than any substitution appearing in its value in order for the latter to expand. (For greater flexibility, you can enable multiple passes through the substitution list by setting recursiveExpansionLimit in a lit configuration file.)
While lit configuration files can insert anywhere in the substitution list, the insertion behavior of the DEFINE: and REDEFINE: directives is specified below and is designed specifically for the use case presented in the example above.
Defining a substitution in terms of itself, whether directly or via other substitutions, should be avoided. It usually produces an infinitely recursive definition that cannot be fully expanded. It does not define the substitution in terms of its previous value, even when using REDEFINE:.
The relationship between the DEFINE: and REDEFINE: directive is analogous to the relationship between a variable declaration and variable assignment in many programming languages:
DEFINE: %{name} = value

This directive assigns the specified value to a new substitution whose pattern is %{name}, or it reports an error if there is already a substitution whose pattern contains %{name} because that could produce confusing expansions (e.g., a lit configuration file might define a substitution with the pattern %{name}\[0\]). The new substitution is inserted at the start of the substitution list so that it will expand first. Thus, its value can contain any substitution previously defined, whether in the same test file or in a lit configuration file, and both will expand.

REDEFINE: %{name} = value

This directive assigns the specified value to an existing substitution whose pattern is %{name}, or it reports an error if there are no substitutions with that pattern or if there are multiple substitutions whose patterns contain %{name}. The substitution’s current position in the substitution list does not change so that expansion order relative to other existing substitutions is preserved.

The following properties apply to both the DEFINE: and REDEFINE: directives:
Substitution name: In the directive, whitespace immediately before or after %{name} is optional and discarded. %{name} must start with %{, it must end with }, and the rest must start with a letter or underscore and contain only alphanumeric characters, hyphens, underscores, and colons. This syntax has a few advantages:
It is impossible for %{name} to contain sequences that are special in Python’s re.sub patterns. Otherwise, attempting to specify %{name} as a substitution pattern in a lit configuration file could produce confusing expansions.
The braces help avoid the possibility that another substitution’s pattern will match part of %{name} or vice-versa, producing confusing expansions. However, the patterns of substitutions defined by lit configuration files and by lit itself are not restricted to this form, so overlaps are still theoretically possible.
Substitution value: The value includes all text from the first non-whitespace character after = to the last non-whitespace character. If there is no non-whitespace character after =, the value is the empty string. Escape sequences that can appear in Python re.sub replacement strings are treated as plain text in the value.
Line continuations: If the last non-whitespace character on the line after : is \, then the next directive must use the same directive keyword (e.g., DEFINE:) , and it is an error if there is no additional directive. That directive serves as a continuation. That is, before following the rules above to parse the text after : in either directive, lit joins that text together to form a single directive, replaces the \ with a single space, and removes any other whitespace that is now adjacent to that space. A continuation can be continued in the same manner. A continuation containing only whitespace after its : is an error.
recursiveExpansionLimit:

As described in the previous section, when expanding substitutions in a RUN: line, lit makes only one pass through the substitution list by default. Thus, if substitutions are not defined in the proper order, some will remain in the RUN: line unexpanded. For example, the following directives refer to %{inner} within %{outer} but do not define %{inner} until after %{outer}:
; By default, this definition order does not enable full expansion.

; DEFINE: %{outer} = %{inner}
; DEFINE: %{inner} = expanded

; RUN: echo '%{outer}'
DEFINE: inserts substitutions at the start of the substitution list, so %{inner} expands first but has no effect because the original RUN: line does not contain %{inner}. Next, %{outer} expands, and the output of the echo command becomes:
%{inner}
Of course, one way to fix this simple case is to reverse the definitions of %{outer} and %{inner}. However, if a test has a complex set of substitutions that can all reference each other, there might not exist a sufficient substitution order.
To address such use cases, lit configuration files support config.recursiveExpansionLimit, which can be set to a non-negative integer to specify the maximum number of passes through the substitution list. Thus, in the above example, setting the limit to 2 would cause lit to make a second pass that expands %{inner} in the RUN: line, and the output from the echo command would then be:
expanded
To improve performance, lit will stop making passes when it notices the RUN: line has stopped changing. In the above example, setting the limit higher than 2 is thus harmless.
To facilitate debugging, after reaching the limit, lit will make one extra pass and report an error if the RUN: line changes again. In the above example, setting the limit to 1 will thus cause lit to report an error instead of producing incorrect output.
Options

The llvm lit configuration allows some things to be customized with user options:
llc, opt, …
Substitute the respective llvm tool name with a custom command line. This allows to specify custom paths and default arguments for these tools. Example:
% llvm-lit “-Dllc=llc -verify-machineinstrs”
run_long_tests
Enable the execution of long running tests.
llvm_site_config
Load the specified lit configuration instead of the default one.
Other Features

To make RUN line writing easier, several helper programs are available. These helpers are in the PATH when running tests, so you can just call them using their name. For example:
not
This program runs its arguments and then inverts the result code from it. Zero result codes become 1. Non-zero result codes become 0.
To make the output more useful, lit will scan the lines of the test case for ones that contain a pattern that matches PR[0-9]+. This is the syntax for specifying a PR (Problem Report) number that is related to the test case. The number after “PR” specifies the LLVM Bugzilla number. When a PR number is specified, it will be used in the pass/fail reporting. This is useful to quickly get some context when a test fails.
Finally, any line that contains “END.” will cause the special interpretation of lines to terminate. This is generally done right after the last RUN: line. This has two side effects:
it prevents special interpretation of lines that are part of the test program, not the instructions to the test case, and
it speeds things up for really big test cases by avoiding interpretation of the remainder of the file.
.end
if
