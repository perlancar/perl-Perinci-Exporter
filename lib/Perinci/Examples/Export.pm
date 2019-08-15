package Perinci::Examples::Export;

# DATE
# VERSION

# be lean
#use strict;
#use warnings;

use Perinci::Exporter;

our %SPEC;

our @EXPORT_OK = qw(f7);
our @EXPORT = qw(f1 f2);

$SPEC{f1} = { v => 1.1, tags => [qw/a b export:default/] };
sub   f1 { [200, "OK", "f1"] }

$SPEC{f2} = { v => 1.1, tags => [qw/b export:default/] };
sub   f2 { [200, "OK", "f2"] }

$SPEC{f3} = { v => 1.1, tags => [qw/a export:default/] };
sub   f3 { [200, "OK", "f3"] }

$SPEC{f4} = { v => 1.1, tags => [qw/export:default/] };
sub   f4 { [200, "OK", "f4"] }

$SPEC{f5} = { v => 1.1, tags => [qw/a b/] };
sub   f5 { [200, "OK", "f5"] }

$SPEC{f6} = { v => 1.1, tags => [qw/a/] };
sub   f6 { [200, "OK", "f6"] }

$SPEC{f7} = { v => 1.1, tags => [qw/b/] };
sub   f7 { [200, "OK", "f7"] }

$SPEC{f8} = { v => 1.1, tags => [qw//] };
sub   f8 { [200, "OK", "f8"] }

$SPEC{f9} = { v => 1.1, tags => [qw/a b export:never/] };
sub   f9 { [200, "OK", "f9"] }

1;
# ABSTRACT: Examples for exporting

=head1 DESCRIPTION
