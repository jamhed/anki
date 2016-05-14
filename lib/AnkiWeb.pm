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

sub get_models {
    my ($self) = @_;
    my $r = $self->_get( _base("edit/") );
    $r->content =~ m/editor.models\s+=\s+(.*?\])\;/;
    return { map { $_->{name} => $_->{id} } @{decode_json($1)} };
}

sub set_model {
    my ($self, $model) = @_;
    my $models = $self->get_models;
    $self->{mid} = $models->{$model};
    unless ($self->{mid}) {
        print "No mid for name: $model\n";
        print "Available models: \n";
        foreach (keys %$models) {
            print $_, "\n";
        }
        exit;
    }
    return $self;
}


sub add_card {
    my ($self, $dict, @data) = @_;
    my $ok = $self->_post( _base("edit/save"),
        [
            data => encode_json([[@data], ""]), # sprintf('[["%s","%s"],""]', $word1, $word2),
            mid  => $self->{mid},
            deck => $dict
        ]
    )->content;
    return $ok;
}

1;
