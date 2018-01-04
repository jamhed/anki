#!/usr/bin/perl -w
use strict;
use AnkiREST;
use Cfg;

my $cfg = Cfg->std;

my ($dbfile) = @ARGV;
unless ($dbfile) {
    print "Usage: $0 dbfile\n";
    exit;
}

my $anki = AnkiREST
                ->new( login => $cfg->{anki}{login}, pass => $cfg->{anki}{password} )
                ->get_hk()
                ->get_sk();


my $db = $anki->get_db();

open(my $fh, ">:raw", $dbfile);
print $fh $db;
close $fh;
