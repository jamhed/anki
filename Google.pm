package Google;
use strict;
use parent 'Browser';
use JSON qw( decode_json encode_json );

sub auth {
    my ($self) = @_;
    my $r = $self->_get("https://accounts.google.com/ServiceLogin");
    $r->content =~ m/GALX.*?value=\"(.*?)\"\>/gms ;
    $self->{galx} = $1;

    $r = $self->_post("https://accounts.google.com/ServiceLoginAuth",
        [
            GALX             => $self->{galx},
            Email            => $self->{login},
            Passwd           => $self->{pass},
            PersistentCookie => 'yes',
            bgresponse       => 'js_disabled',
            continue         => 'https://translate.google.com'
        ]
    );

    $r->content =~ /href=\"(.*)\"/gmsi;
    my $redirect = $1;
    # confirm login
    $self->_get($redirect);
    return $self;
}

sub get_key {
    my ($self) = @_;
    $self->{browser}->agent('Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36');
    my $r = $self->_get('https://translate.google.com');
    $r->content =~ /USAGE\='(.+?)'/gmsi;
    $self->{google_key} = $1;
    return $self;
}

sub get_pb {
    my ($self) = @_;
    my $r = $self->_post('https://translate.google.com/translate_a/sg?client=t&cm=g&hl=en&xt=' . $self->{google_key})->content;
    $r =~ s/,,/,"",/gms; # json fix?
    return decode_json($r);
}

1;
