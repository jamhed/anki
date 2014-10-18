#!/usr/bin/perl -w
use strict;
use Google;
use JSON qw( encode_json );

my ($login, $pass) = @ARGV;
unless ($pass) {
    print "Usage: $0 login password\n";
    exit;
}

my $re = Google
            ->new( login => $login, pass => $pass )
            ->auth()
            ->get_key()
            ->get_pb();

my $fmt = [];
foreach (@{$re->[2]}) {
    my ($uid, $from, $to, $word1, $word2, $ts) = @$_;
    push @$fmt, ["$from-$to", $word1, $word2];
}

print encode_json($fmt);
