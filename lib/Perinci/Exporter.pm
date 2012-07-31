package Perinci::Exporter;

use 5.010;
use strict;
use warnings;

# VERSION


1;
# ABSTRACT: Rinci-metadata-aware Exporter

=head1 SYNOPSIS

 package YourModule;
 # most of the time, you only need to do this
 use Perinci::Exporter;


=head1 DESCRIPTION

Perinci::Exporter is an exporter which can utilize information from L<Rinci>
metadata. If your package has Rinci metadata, consider using this exporter for
convenience and flexibility.

Features of this module:

=over 4

=item * List exportable routines from Rinci metadata

All functions which have metadata are assumed to be exportable, so you do not
have to list them again via @EXPORT or @EXPORT_OK.

=item * Read tags from Rinci metadata

The exporter can read tags from your function metadata. You do not have to
define export tags again.

=item * Export to different name

See the 'as', 'prefix', 'suffix' import options of the install_import()
function.

=item * Export wrapped function

This allows importer to get additional/modified behavior. See
L<Perinci::Sub::Wrapper> for more about wrapping.

=item * Export differently wrapped function to different importers

See some examples in L</"FAQ">.

=item * Warn/bail on clash with existing function

For testing or safety precaution.

=item * Read @EXPORT and @EXPORT_OK

Perinci::Exporter reads these two package variables, so it is quite compatible
with L<Exporter> and L<Exporter::Lite>. In fact, it is basically the same as
Exporter::Lite if you do not have any metadata for your functions.

=back


=head1 EXPORTING

Most of the time, to set up exporter, you only need to just use() it in your
module:

 package YourModule;
 use Perinci::Exporter;

Perinci::Exporter will install an import() routine for your package. If you need
to pass some exporting options:

 use Perinci::Exporter default_wrap=>0, default_on_clash=>'bail';

See install_import() for more details.


=head1 IMPORTING

B<Default exports>. Your module users can import functions in a variety of ways.
The simplest form is:

 use YourModule;

which by default will export all functions marked with C<:default> tags. For
example:

 package YourModule;
 use Perinci::Exporter;
 our %SPEC;
 $SPEC{f1} = { v=>1.1, tags=>[qw/default a/] };
 sub   f1    { ... }
 $SPEC{f2} = { v=>1.1, tags=>[qw/default a b/] };
 sub   f2    { ... }
 $SPEC{f3} = { v=>1.1, tags=>[qw/b c/] };
 sub   f3    { ... }
 1;

YourModule will by default export f1 and f2. If there are no functions tagged
with C<default>, there will be no default exports. You can also supply the list
of default functions via the C<default_exports> argument:

 use Perinci::Exporter default_exports => [qw/f1 f2/];

or via the @EXPORT package variable, like in Exporter.

B<Exporting individual functions>. Users can import individual functions:

 use YourModule qw(f1 f2);

Each function can have import options, specified in a hashref:

 use YourModule f1 => {wrap=>0}, f2=>{as=>'bar', args_as=>'array'};
 # imports f1, bar

B<Exporting groups of functions by tags>. Users can import groups of individual
functions using tags. Tags are collected from function metadata, and written
with a C<:> prefix (to differentiate them from function names). Each tag can
also have import options:

 use YourModule 'f3', ':a' => {prefix => 'a_'}; # imports f3, a_f1, a_f2

B<Exporting to a different name>. As can be seen from previous examples, the
'as' and 'prefix' (and also 'suffix') import options can be used to import
subroutines using into a different name.

B<Bailing on name clashes>. By default, importing will override existing names
in the target package. To warn about this, users can set '-on_clash' to 'bail':

 use YourModule 'f1', f2=>{as=>'f1'}, -on_clash=>'bail'; # dies, imports clash

 use YourModule 'f1', -on_clash=>'bail'; # dies, f1 already exists
 sub f1 { ... }

B<Customizing wrapping options>. Users can specify custom wrapping options when
importing functions. The wrapping will then be done just for them (as opposed to
wrapped functions which are wrapped using default options, which will be shared
among all importers not requesting custom wrapping). See some examples in
L</"FAQ">.

See do_export() for more details.


=head1 FUNCTIONS

=head2 install_import(%args)

The routine which installs the import() routine to caller package.

Arguments:

=over 4

=item * into => STR (default: caller package)

Explicitly set target package to install the import() routine to.

=item * default_wrap => 1 | 0 | HASH (default: 1)

Set defaut wrapping behavior. See 'wrap' import options in do_export().

=item * default_on_clash => 'force' | 'bail' (default: 'force')

Set defaut -on_clash behavior when exporting. See '-on_clash' options in
do_export().

=back

=head2 do_export(@args)

The routine which implements the exporting. Will be called from the import()
routine. @args is the same as arguments passed during import: a sequence of
function name or tag name (prefixed with C<:>), function/tag name and export
option (hashref), or option (prefixed with C<->).

Example:

 do_export('f1', ':tag1', f2 => {import option...}, -option => ...);

Import options:

=over 4

=item * as => STR

Export a function to a new name. Will die if new name is invalid. Inapplicable
for tags.

Example:

 use YourModule func => {as => 'f'};

=item * prefix => STR

Export function/tag with a prefix. Will die on invalid prefix.

Example:

 use YourModule ':default' => {prefix => 'your_'};

This means, C<foo>, C<bar>, etc. will be exported as C<your_foo>, C<your_bar>,
etc.

=item * suffix => STR

Export function/tag with a prefix. Will die on invalid suffix.

Example:

 use YourModule ':default' => {suffix => '_s'};

This means, C<foo>, C<bar>, etc. will be exported as C<foo_s>, C<bar_s>, etc.

=item * wrap => 0 | 1 | HASH (default: 1)

The default is export the wrapped functions. Can be set to 0 to disable
wrapping, or a hash containing custom wrap arguments (to be passed to
L<Perinci::Sub::Wrapper>'s wrap_sub()).

Examples:

 use YourModule foo => {}; # export wrapped, with default wrap options
 use YourModule foo => {wrap=>0}; # export unwrapped
 use YourModule foo => {args_as=>'array'}; # export with custom wrap

Note that when set to 0, the exported function might already be wrapped anyway,
e.g. when your module adds this at the bottom:

 Perinci::Sub::Wrapper->wrap_all_subs;

Default can be setup via install_import()'s 'default_wrap'.

=item * args_as => STR

This is a shortcut for specifying:

 wrap => { convert => { args_as => STR } }

=item * curry => STR

This is a shortcut for specifying:

 wrap => { convert => { curry => STR } }

=back

Options:

=over 4

=item * -on_clash => 'force' | 'bail' (default: 'force')

If importer tries to import 'foo' when it already exists, the default is to
force importing, without any warnings, like Exporter. Alternatively, you can
also bail (dies), which can be more reliable/safe.

Default can be setup via install_import()'s 'default_on_clash'.

=back


=head1 FAQ

=head2 Why use this module as my exporter?

If you are fine with Exporter, Exporter::Lite, or L<Sub::Exporter>, then you
probably won't need this module.

This module is particularly useful if your subs have Rinci metadata, in which
case you'll get some nice features. Some examples of the things you can do with
this exporter:

=over 4

=item * Change calling style from argument to positional

 use YourModule func => {args_as=>'array'};

Then instead of:

 func(a => 1, b => 2);

your function is called with positional arguments:

 func(1, 2);

Note: this requires that the function's argument spec puts the 'pos'
information. For example:

 $SPEC{func} = {
     v => 1.1,
     args => {
         a => { pos=>0 },
         b => { pos=>1 },
     }
 };

=item * Set timeout

 use YourModule ':all' => {wrap=>{convert=>{timeout=>10}}};

This means all exported functions will be limited to 10s of execution time.

Note: Perinci::Sub::property::timeout is needed for this.

=item * Set retry

 use YourModule ':default' => {wrap=>{convert=>{retry=>3}}};

This means all exported functions can autoretry up to 3 times.

Note: Perinci::Sub::property::retry is needed for this.

=item * Currying

Sub::Exporter supports this. Perinci::Exporter does too:

 use YourModule f => {as=>'f_a10', wrap=>{convert=>{curry=>{a=>10}}}};

This means:

 f_a10();             # equivalent to f(a=>10)
 f_a10(b=>20, c=>30); # equivalent to f(a=>10, b=>20, c=>30)
 f_a10(a=>5);         # error, a is already set

Note: L<Perinci::Sub::property::curry> is needed for this.

=back

=head2 What happens to functions that do not have metadata?

They can still be exported if you list them in @EXPORT or @EXPORT_OK.


=head1 TODO/IDEAS

=over 4

=item * Support combining tags?

 use YourModule qw(not(:tag1));
 use YourModule qw(and(:tag1,:tag2));
 use YourModule qw(or(:tag1,and(:tag2,:tag3)));

=item * Export variables, etc.

=back


=head1 SEE ALSO

L<Perinci>

L<Perinci::Sub::Wrapper>

=cut
