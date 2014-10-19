#!/usr/bin/perl -w
use strict;
use open IO => ':locale';
use AnkiREST;
use AnkiWeb;
use Google;
use File::Temp qw( tempfile );
use DBI;
use Encode qw( is_utf8 encode_utf8 decode_utf8 );

my ($anki_login, $anki_pass, $google_login, $google_pass) = @ARGV;
unless ($google_pass) {
    print "Usage: $0 anki_login anki_password google_login google_password\n";
    exit;
}

my $anki = AnkiREST
                ->new(login => $anki_login, pass => $anki_pass)
                ->get_hk()
                ->get_sk();


my $db = $anki->get_db();

# save tmp sqlite database for word list
my ($tmp_fh, $tmp_name) = tempfile(DIR => './');
print $tmp_fh $db;
close $tmp_fh;

# get words already in database
my $dbh = DBI->connect("dbi:SQLite:dbname=$tmp_name","","");
my $refs = $dbh->selectall_arrayref("SELECT sfld FROM notes");
my %words = map { decode_utf8($_->[0]) => 1 } @$refs;

# retrieve google phrasebook
my $re = Google
            ->new( login => $google_login, pass => $google_pass )
            ->auth()
            ->get_key()
            ->get_pb();

my $ankiweb = AnkiWeb
                ->new( login => $anki_login, pass => $anki_pass )
                ->auth()
                ->get_mid();


foreach (@{$re->[2]}) {
    my ($uid, $from, $to, $word1, $word2, $ts) = @$_;
    unless($words{$word1}) {
        print join " ", "sync:", "$from-$to", $word1, $word2, " ... ";
        print $ankiweb->add_card( "$from-$to", $word1, $word2 );
        print "\n";
    }
}

# Clean-up 
unlink $tmp_name;
