#!/usr/bin/perl -w
use strict;
use Google;
use JSON;
use open IO => ':locale';

my ($from, $to, $word) = @ARGV;
unless ($word) {
    print "Usage: $0 from to word\n";
    exit;
}

my $g = Google->new();

my $tr = $g->get_tr($from, $to, $word);

print JSON->new->pretty(1)->encode($tr);
