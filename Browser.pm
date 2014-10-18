package Browser;
use strict;

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request;

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

sub _post {
    my ($self, @args) = @_;
    $self->{browser}->post( @args );
}

sub _get {
    my ($self, @args) = @_;
    $self->{browser}->get( @args );
}

1;
