#!/usr/bin/perl -w
use strict;

use AnkiREST;

my ($login, $pass, $dbfile) = @ARGV;
unless ($dbfile) {
    print "Usage: $0 login password dbfile\n";
    exit;
}

my $anki = AnkiREST
                ->new(login => $login, pass => $pass)
                ->get_hk()
                ->get_sk();


my $db = $anki->get_db();

open(my $fh, ">:raw", $dbfile);
print $fh $db;
close $fh;
