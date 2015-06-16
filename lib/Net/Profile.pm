# ABSTRACT: library to interact with API of social networks
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

has userpic_width => (
    is      => 'ro',
    isa     => 'Int',
    default => 80,
);

has userpic_height => (
    is      => 'ro',
    isa     => 'Int',
    default => 80,
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

sub download_image ($url) {
    my $res = $ua->get($url);
    croak "failed to download $url: " . $res->status_line
      if !$res->is_success;
    return Imager->new( data => $res->decoded_content )
      || croak Imager->errstr;
}

sub build_userpic ($self) {
    my $url = $self->userpic_url || return undef;
    my $img = download_image($url);
    return $img
      if $img->getwidth == $self->userpic_width
      && $img->getheight == $self->userpic_height;
    my $userpic = $img->scale(
        xpixels => $self->userpic_width,
        ypixels => $self->userpic_height,
        type    => 'nonprop',
    ) || croak $img->errstr;
    return $userpic;
}

1;

__END__

=head1 SYNOPSIS

    my $profile = Net::Profile::VK->new( access_token => '...' );
    
    say $profile->user_id;
    say $profile->name;
    say $profile->url;

    my $userpic = $profile->userpic; # Imager object
    $userpic->write( file => '/srv/foo/bar/userpic.png' );

=head1 INSTALL

    cpanm Net::Profile -M http://cpan.linuxprofy.net/public
