#!/usr/bin/perl -w
use strict;
use Cfg;
use Google;
use JSON;

my ($from, $to, $word) = @ARGV;
unless ($word) {
    print "Usage: $0 from to word\n";
    exit;
}

my $cfg = Cfg->std;

my $g = Google->new->get_tkk;

my $tr = $g->get($from, $to, $word);
print $tr, "\n";
