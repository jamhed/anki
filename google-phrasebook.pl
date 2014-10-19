#!/usr/bin/perl -w
use strict;
use Google;
use JSON qw( encode_json );
use open IO => ':locale';

my ($login, $pass) = @ARGV;
unless ($pass) {
    print "Usage: $0 login password\n";
    exit;
}

my $g = Google
            ->new( login => $login, pass => $pass )
            ->auth()
            ->get_key();

my $pb = $g->get_pb();

my $fmt = $g->parse_pb($pb);

print JSON->new->pretty(1)->encode($fmt);
