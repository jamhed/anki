#!/usr/bin/perl -w
use strict;

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request;
use JSON qw( decode_json encode_json );
# use open IO => ':locale';

my ($login, $pass) = @ARGV;
unless ($pass) {
    print "Usage: $0 login password\n";
    exit;
}

my ($browser, $response);

$browser = LWP::UserAgent->new;
$browser->agent('Opera/7.50');
$browser->cookie_jar( HTTP::Cookies->new() );
$response = $browser->get("https://accounts.google.com/ServiceLogin");

$response->content =~ m/GALX.*?value=\"(.*?)\"\>/gms ;
my $galx = $1;

$response = $browser->post("https://accounts.google.com/ServiceLoginAuth",
    [
        GALX => $galx,
        Email => $login,
        Passwd => $pass,
        PersistentCookie => 'yes',
        continue => 'https://translate.google.com'
    ]
);

$response->content =~ /href=\"(.*)\"/gmsi;
my $redirect = $1;

$response = $browser->get($redirect);

$browser->agent('Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36');
$response = $browser->get('https://translate.google.com');
$response->content =~ /USAGE\='(.+?)'/gmsi;
my $google_key = $1;

$response = $browser->post('https://translate.google.com/translate_a/sg?client=t&cm=g&hl=en&xt=' . $google_key)->content;
# [137,,[["NZ3y7Uc4quY","en","ru","brook","ручей",1366570265428123]
$response =~ s/,,/,"",/gms; # json fix?
my $re = decode_json($response);
my $fmt = [];
foreach (@{$re->[2]}) {
    my ($uid, $from, $to, $word1, $word2, $ts) = @$_;
    push @$fmt, ["$from-$to", $word1, $word2];
}

print encode_json($fmt);
