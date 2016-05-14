#!/usr/bin/perl -w
use strict;
use open IO => ':locale';
use AnkiREST;
use AnkiWeb;
use Google;
use File::Temp qw( tempfile );
use DBI;
use Encode qw( is_utf8 encode_utf8 decode_utf8 );
use Cfg;
use JSON qw( encode_json );

$SIG{__DIE__} = \&cleanup;

my $cfg = Cfg->std;

my ($model, $fromto) = @ARGV;
unless ($fromto) {
    print "Usage: $0 model from-to\n";
    exit;
}

my $ankiweb = AnkiWeb
                ->new(login => $cfg->{anki}{login}, pass => $cfg->{anki}{password})
                ->auth()
                ->set_model($model);


my $anki = AnkiREST
                ->new(login => $cfg->{anki}{login}, pass => $cfg->{anki}{password})
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
# retrieve google phrasebook
my $re = Google
            ->new( login => $cfg->{google}{login}, pass => $cfg->{google}{password} )
            ->auth()
            ->get_key()
            ->get_pb();

my $google_tr = Google->new();

sub _v ($) {
    my ($_v) = @_;
    my $v = $_v->{variants};
    return join(", ", @$v);
#    return sprintf("%s, %s", @$v) if ($v->[1]);
#    return $v->[0];
}

sub _num {
    my ($p) = @_;
    my $ex = $p->{examples};
    my $i = 1;
    my @ret;
    foreach (@$ex) {
        push @ret, "$i. $_";
        $i++;
    }
    return join("<br>", @ret);
}

foreach (@{$re->[2]}) {
    my ($uid, $from, $to, $word1, $word2, $ts) = @$_;
    print "$word1\n";
    unless($words{$word1}) {
        next unless $fromto eq "$from-$to";
        print join " ", "get:", "$from-$to", $word1, $word2, "\n";
        
        # retranslate
        my $raw = $google_tr->get($from, $to, $word1);
        my $_tr = $google_tr->decode($raw);
        my $tr = $google_tr->parts( $_tr );

        print "put: $model-$from-$to\n";
        foreach (keys %$tr) {
            my $part = $tr->{$_};
            my $seen;
            foreach (@{$part->{pairs}}) {
                print " ", join " - ",  $word1, _v $part, $_->{example}, $_->{definition}, " ... ";
                print $ankiweb->add_card("$model-$from-$to", $word1, _v $part, $_->{example}, $_->{definition}, _num($part))? "ok" : "fail";
                print "\n";
                $seen = 1;
            }
            unless ($seen) {
                print " ", join " - ",  $word1, _v $part, " ... ";
                print $ankiweb->add_card("$model-$from-$to", $word1, _v $part, "", "", "")? "ok" : "fail";
                print "\n";
            }
        }
        print "\n";
    }
}

# Clean-up 
sub cleanup {
    if ($tmp_name) {
        unlink $tmp_name;
    }
}

END {
    cleanup();
}

