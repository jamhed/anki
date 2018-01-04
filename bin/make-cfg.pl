#!/usr/bin/perl -w
use JSON;
use strict;

my ($gn, $gp, $an, $ap) = @ARGV;
unless ($ap) {
    print "Usage: $0 google_login google_password anki_login anki_password\n";
    exit 1;
}

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
