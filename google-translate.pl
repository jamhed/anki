#!/usr/bin/perl -w
use strict;
use Google;
use JSON qw( encode_json decode_json );
use open IO => ':locale';

my ($login, $pass, $from, $to, $word) = @ARGV;
unless ($pass) {
    print "Usage: $0 login password from to word\n";
    exit;
}

my $g = Google
            ->new( login => $login, pass => $pass )
            ->auth()
            ->get_key();


my $tr = $g->get_tr($from, $to, $word);

my $p = $g->parse_tr( $tr );

print JSON->new->pretty(1)->encode($p);
