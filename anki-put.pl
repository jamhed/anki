#!/usr/bin/perl -w
use strict;

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request;
use JSON qw( encode_json decode_json );
# use open IO => ':locale';

my $base = "https://ankiweb.net";
        
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

my ($browser, $response);

$browser = LWP::UserAgent->new;
$browser->agent('Opera/7.50');
$browser->cookie_jar(HTTP::Cookies->new());

$response = $browser->post($base,
    [
        username => $login,
        password => $pass
    ]
);

$response = $browser->get($base . "/edit/");

$response->content =~ m/curModelID\s+\=\s+\"(\d+?)\"/;
my $mid = $1;

my $id = 0;
my $total = scalar(@$words);
foreach (@$words) {
    my ($dict, $word1, $word2) = @$_;

    my $ok = $browser->post($base . "/edit/save",
        [
            data => sprintf('[["%s","%s"],""]', $word1, $word2),
            mid  => $mid,
            deck => $dict
        ]
    )->content;
    $id++;
    print "$id/$total $ok\n";
}
