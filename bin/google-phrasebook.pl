#!/usr/bin/perl -w
use strict;
use Google;
use JSON qw( encode_json );
use Cfg;
use open IO => ':locale';

my $cfg = Cfg->std;

my $g = Google
            ->new( login => $cfg->{google}{login}, pass => $cfg->{google}{password} )
            ->auth()
            ->get_key();

my $pb = $g->get_pb();

my $fmt = $g->parse_pb($pb);

print JSON->new->pretty(1)->encode($fmt);
