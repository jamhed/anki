#!/usr/bin/perl -w
use strict;
use AnkiWeb;
use JSON qw( encode_json decode_json );

my ($login, $pass, $file) = @ARGV;
unless ($file) {
    print "Usage: $0 login password file\n";
    exit;
}

open (my $f, $file) or die "Can't open words file: $file\n$!";
my $data;
read($f, $data, 512*1024);
close $f;
my $words = decode_json($data);


my $anki = AnkiWeb
                ->new( login => $login, pass => $pass )
                ->auth()
                ->get_mid();

my $id = 0;
my $total = scalar(@$words);
foreach (@$words) {
    my ($dict, $word1, $word2) = @$_;
    $id++;
    my $ok = $anki->add_card( $dict, $word1, $word2 );
    print "$id/$total $ok\n";
}
