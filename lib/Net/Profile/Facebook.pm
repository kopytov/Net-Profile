# ABSTRACT: library to interact with Facebook API
package Net::Profile::Facebook;

use Moose;
use namespace::autoclean;
use extreme;
use Carp;
use JSON::XS;
use LWP::UserAgent;
use URI;

extends 'Net::Profile';

our $ua = LWP::UserAgent->new;

has me => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => 'build_me',
    lazy    => 1,
);

sub build_me ($self) {
    my $uri = URI->new('https://graph.facebook.com/me');
    $uri->query_form( access_token => $self->access_token );
    my $res = $ua->get($uri);
    croak "failed to download $uri: " . $res->status_line
      if !$res->is_success;
    my $me = decode_json( $res->decoded_content );
    croak $me->{error}{message} if exists $me->{error};
    return $me;
}

sub build_user_id ($self) { $self->me->{id} }
sub build_name ($self)    { $self->me->{name} }
sub build_url ($self)     { $self->me->{link} }

sub build_userpic_url ($self) {
    my $uri = URI->new('https://graph.facebook.com/me/picture');
    $uri->query_form(
        access_token => $self->access_token,
        redirect     => 'false',
        width        => 80,
        height       => 80,
    );
    my $res = $ua->get($uri);
    croak "failed to download $uri: " . $res->status_line
      if !$res->is_success;
    my $pic = decode_json( $res->decoded_content );
    croak $pic->{error}{message} if exists $pic->{error};
    return if $pic->{data}{is_silhouette};
    return $pic->{data}{url};
}

1;
