package AnkiWeb;
use parent 'Browser';
use strict;

use JSON qw( decode_json encode_json );

sub _base { join("/", "https://ankiweb.net", @_) }

sub auth {
    my ($self) = @_;
    $self->_post( _base, [ username => $self->{login}, password => $self->{pass} ] );
    return $self;
}

sub get_mid {
    my ($self) = @_;
    my $r = $self->_get( _base("edit/") );
    $r->content =~ m/curModelID\s+\=\s+\"(\d+?)\"/;
    $self->{mid} = $1;
    return $self;
}

sub add_card {
    my ($self, $dict, $word1, $word2) = @_;
    my $ok = $self->_post( _base("edit/save"),
        [
            data => sprintf('[["%s","%s"],""]', $word1, $word2),
            mid  => $self->{mid},
            deck => $dict
        ]
    )->content;
    return $ok;
}

1;
