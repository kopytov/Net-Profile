package Net::Profile;
use Moose;
use namespace::autoclean;
use extreme;
use Carp;
use LWP::UserAgent;
use Imager;

has access_token => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has user_id => (
    is      => 'ro',
    isa     => 'Str',
    builder => 'build_user_id',
    lazy    => 1,
);

has name => (
    is      => 'ro',
    isa     => 'Str',
    builder => 'build_name',
    lazy    => 1,
);

has url => (
    is      => 'ro',
    isa     => 'Str',
    builder => 'build_url',
    lazy    => 1,
);

has userpic_url => (
    is      => 'ro',
    isa     => 'Str|Undef',
    builder => 'build_userpic_url',
    lazy    => 1,
);

has userpic => (
    is      => 'ro',
    isa     => 'Object|Undef',
    builder => 'build_userpic',
    lazy    => 1,
);

sub build_user_id     {...}
sub build_name        {...}
sub build_url         {...}
sub build_userpic_url {...}

our $ua = LWP::UserAgent->new;

sub make_image ( $url, $width, $height, $type = 'nonprop' ) {
    my $res = $ua->get($url);
    croak "failed to download $url: " . $res->status_line
      if !$res->is_success;
    my $data = $res->decoded_content;
    my $img = Imager->new( data => \$data ) or croak Imager->errstr;
    return $img if $img->getwidth == $width && $img->getheight == $height;
    my $scaled
      = $img->scale( xpixels => $width, ypixels => $height, type => $type )
      || croak $img->errstr;
    return $scaled;
}

sub build_userpic ($self) {
    my $url = $self->userpic_url;
    return $url ? make_image( $url, 80, 80 ) : undef;
}

1;
