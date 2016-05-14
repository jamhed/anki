package Cfg;
use strict;

use JSON qw( decode_json encode_json );

sub STD { "config.json" }

sub load {
    my ($self, $file) = @_;
    open(my $fh, $file);
    my @data = <$fh>;
    close $fh;
    return decode_json(join("", @data));
}

sub std {
    my ($self) = @_;
    my $cfg = {};

    if (-e STD) {
        $cfg = $self->load(STD);
    }
    unless($cfg->{"google"}) {
        printf "Please create %s file in this folder, and specify google and anki credentials.\n", STD;
        exit;
    }
    return $cfg;
}

1;
