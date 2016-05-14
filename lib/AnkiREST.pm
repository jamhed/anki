package AnkiREST;
use strict;
use parent 'Browser';

use IO::Compress::Gzip qw(gzip);
use JSON qw( encode_json decode_json );

# Constants
sub _base { join("/", "https://ankiweb.net", @_) }
sub _b  { 'Anki-sync-boundary' };
sub _bb { "--" . _b() };

sub vars ($$) {
    my ($h, $_f) = @_;
    $h->{c} = 1; # Always compressed
    my ($buf, $gz);
    open(F, ">", \$buf);
    while (my ($k,$v) = each %$h) {
        print F _bb, "\r\n";
        print F "Content-Disposition: form-data; name=\"$k\"\r\n\r\n$v\r\n";
    }
    if ($_f) {
        my $f = encode_json($_f);
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
    my $r = HTTP::Request->new(POST => _base($uri)); 
    $r->header('Content-Type' => sprintf("multipart/form-data; boundary=%s", _b));
    $r->header('Content-Length' => length($s));
    $r->content($s);
    return $r;
}

sub io ($$) {
    my ($self, $req) = @_;
    my ($rs, $v);
    eval {
        $rs = raw_io($self, $req);
        $v = decode_json($rs);
    };
    if ($@) {
        print "bad content: ", $rs;
    }
    return $v;
}

sub raw_io ($$) {
    my ($self, $req) = @_;
    return $self->{browser}->request($req)->content;
}

# API

sub get_hk {
    my ($self) = @_;
    my $r = io $self, req "sync/hostKey", vars {}, { u => $self->{login}, p => $self->{pass} };
    $self->{hk} = $r->{key};
    return $self;
}

sub get_sk {
    my ($self) = @_;
    my $r = io $self, req "msync/begin", vars { k => $self->{hk} }, {};
    $self->{sk} = $r->{data}->{sk};
    return $self;
}

# {"mod":1413592669883,"scm":1413492756372,"uname":"ip@ncom-ufa.ru","msg":"","usn":8,"musn":0,"ts":1413627965,"cont":true}
sub get_meta {
    my ($self) = @_;
    io $self, req "sync/meta", vars { k => $self->{hk}, s => $self->{sk} }, { v => 8, cv => 'ankidesktop,2.0.29,lin:debian:jessie/sid' };
}

sub get_db {
    my ($self) = @_;
    raw_io $self, req "sync/download", vars { k => $self->{hk}, s => $self->{sk} }, {};
}

1;
