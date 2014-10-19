package Google;
use strict;
use parent 'Browser';
use JSON qw( decode_json encode_json );
use Encode qw( decode_utf8 encode_utf8 );

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

# phrasebook as json blob
sub get_pb {
    my ($self) = @_;
    my $r = $self->_post('https://translate.google.com/translate_a/sg?client=t&cm=g&hl=en&xt=' . $self->{google_key})->content;
    $r =~ s/,,/,"",/gms; # json fix?
    return decode_json($r);
}

# translation as json blob
sub get_tr {
    my ($self, $from, $to, $word) = @_;
    my $r = decode_utf8($self->_post("https://translate.google.com/translate_a/single?client=t&sl=$from&tl=$to&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qc&dt=rw&dt=rm&dt=ss&dt=t&dt=at&dt=sw&ie=UTF-8&oe=UTF-8&prev=bh&ssel=0&tsel=0&q=$word")->content);
    $r =~ s/,,/,"",/g; # json fix?
    $r =~ s/,,/,"",/g;
    JSON->new->utf8(0)->decode($r);
}

# parse translation json blob
sub parse_tr {
    my ($self, $tr) = @_;
    my $n = {};
    $n->{examples} = [ map { $_->[0] } @{ $tr->[13]->[0] } ];
    $n->{variants} =    $tr->[1]->[0]->[1];
    $n->{translation} = $tr->[0]->[0];
    # $n->{synonyms} =    $tr->[11];
    $n->{pos} =         $tr->[12]->[0]->[0];
    $n->{definition} =  $tr->[12]->[0]->[1]->[0]->[0];
    $n->{example} =     $tr->[12]->[0]->[1]->[0]->[2];
    return $n;
}

# parse phrasebook blob
sub parse_pb {
    my ($self, $pb) = @_;
    my $fmt = [];
    foreach (@{$pb->[2]}) {
        my ($uid, $from, $to, $word1, $word2, $ts) = @$_;
        push @$fmt, ["$from-$to", $word1, $word2];
    }
    return $fmt;
}

1;
