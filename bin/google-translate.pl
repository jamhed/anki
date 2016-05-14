#!/usr/bin/perl -w
use strict;
use Google;
use JSON;
use open IO => ':locale';
use Encode qw( decode_utf8 encode_utf8 );

my ($from, $to, $word) = @ARGV;
unless ($word) {
    print "Usage: $0 from to word\n";
    exit;
}

my $g = Google->new();
my $raw;

eval {
    $raw = $g->get($from, $to, $word);

    my $tr = $g->decode($raw);

    print JSON->new->pretty(1)->encode( $g->parts( $tr ) );

};
if ($@) {
    print $@, "\n";
    print decode_utf8($raw);
    print "\n";
}
