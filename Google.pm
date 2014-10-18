package Google;
use strict;

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request;
use JSON qw( decode_json encode_json );

# name, pass
sub new {
    my ($class, %args) = @_;
    my $self = bless( \%args, $class ); 
    $self->set_browser();
    return $self;
}

sub set_browser {
    my ($self) = @_;
    $self->{browser} = LWP::UserAgent->new;
    $self->{browser}->agent('Opera/7.50');
    $self->{browser}->cookie_jar( HTTP::Cookies->new() );
    return $self->{browser};
}

sub auth {
    my ($self) = @_;
    my $r = $self->{browser}->get("https://accounts.google.com/ServiceLogin");
    $r->content =~ m/GALX.*?value=\"(.*?)\"\>/gms ;
    $self->{galx} = $1;

    $r = $self->{browser}->post("https://accounts.google.com/ServiceLoginAuth",
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
    $self->{browser}->get($redirect);
    return $self;
}

sub get_key {
    my ($self) = @_;
    $self->{browser}->agent('Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36');
    my $r = $self->{browser}->get('https://translate.google.com');
    $r->content =~ /USAGE\='(.+?)'/gmsi;
    $self->{google_key} = $1;
    return $self;
}

sub get_pb {
    my ($self) = @_;
    my $r = $self->{browser}->post('https://translate.google.com/translate_a/sg?client=t&cm=g&hl=en&xt=' . $self->{google_key})->content;
    $r =~ s/,,/,"",/gms; # json fix?
    return decode_json($r);
}

1;
