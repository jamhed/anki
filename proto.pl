#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request;
use IO::Compress::Gzip qw(gzip);
use JSON qw( encode_json decode_json );
use File::Temp qw( tempfile );
use DBI;

# Constants
sub _base { "https://ankiweb.net" }
sub _b  { 'Anki-sync-boundary' };
sub _bb { "--" . _b() };
sub _p  { join("/", _base, @_) } 

my ($login, $pass) = @ARGV;
unless ($pass) {
    print "Usage: $0 login password\n";
    exit;
}


sub vars ($$) {
    my ($h, $f) = @_;
    $h->{c} = 1; # Always compressed
    my ($buf, $gz);
    open(F, ">", \$buf);
    while (my ($k,$v) = each %$h) {
        print F _bb, "\r\n";
        print F "Content-Disposition: form-data; name=\"$k\"\r\n\r\n$v\r\n";
    }
    if ($f) {
        print F _bb, "\r\n";
        print F "Content-Disposition: form-data; name=\"data\"; filename=\"data\"\r\n";
        print F "Content-Type: application/octet-stream\r\n\r\n";
        gzip \$f, \$gz;
        print F $gz;
        print F "\r\n", _bb, "\r\n";
    }
    close F;
    return $buf;
}

sub req ($$) {
    my ($uri, $s) = @_;
    my $r = HTTP::Request->new(POST => _p($uri)); 
    $r->header('Content-Type' => sprintf("multipart/form-data; boundary=%s", _b));
    $r->header('Content-Length' => length($s));
    $r->content($s);
    return $r;
}

my ($browser, $response);

sub io ($) {
    my ($rs, $v);
    eval {
        $rs = $browser->request(shift)->content;
        $v = decode_json($rs);
    };
    if ($@) {
        print "bad content: ", $rs;
    }
    return $v;
}

sub raw_io ($) {
    return $browser->request(shift)->content;
}

$browser = LWP::UserAgent->new;
$browser->agent('Opera/7.50');
$browser->cookie_jar(HTTP::Cookies->new());

my $r = io req "sync/hostKey", vars {}, encode_json({ u => $login, p => $pass });
my $key = $r->{key};

$r = io req "msync/begin", vars { k => $key }, encode_json({});
my $skey = $r->{data}->{sk};

# {"mod":1413592669883,"scm":1413492756372,"uname":"ip@ncom-ufa.ru","msg":"","usn":8,"musn":0,"ts":1413627965,"cont":true}
my $meta = io req "sync/meta", vars { k => $key, s => $skey }, encode_json({ v => 8, cv => 'ankidesktop,2.0.29,lin:debian:jessie/sid' });

my $db = raw_io req "sync/download", vars { k => $key, s => $skey }, encode_json({});
my ($tmp_fh, $tmp_name) = tempfile(DIR => './');
print $tmp_fh $db;
close $tmp_fh;

my $dbh = DBI->connect("dbi:SQLite:dbname=$tmp_name","","");
my $refs = $dbh->selectall_arrayref("SELECT sfld FROM notes");
my %words = map { $_->[0] => 1 } @$refs;


# Clean-up 
print $tmp_name, "\n";
unlink $tmp_fh;
