#!/usr/bin/perl -w
use JSON;
use strict;

my ($gn, $gp, $an, $ap) = @ARGV;

my $cfg = {
    google => {
        login => $gn,
        password => $gp
    },
    anki => {
        login => $an,
        password => $ap
    }
};

print JSON->new->pretty(1)->encode( $cfg );
