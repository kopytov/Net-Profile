# ABSTRACT: library to interact with VK.com API
package Net::Profile::VK;

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
    my $uri = URI->new('https://api.vk.com/method/users.get');
    $uri->query_form(
        access_token => $self->access_token,
        fields       => 'screen_name,photo_100,photo_id',
    );
    my $res = $ua->get($uri);
    croak "failed to download $uri: " . $res->status_line
      if !$res->is_success;
    my $me = decode_json( $res->decoded_content );
    croak $me->{error}{error_msg} if exists $me->{error};
    return $me->{response}[0];
}

sub build_user_id ($self) { $self->me->{uid} }

sub build_name ($self) {
    $self->me->{first_name} . q{ } . $self->me->{last_name};
}

sub build_url ($self) {
    $self->me->{screen_name}
      ? 'http://vk.com/' . $self->me->{screen_name}
      : 'http://vk.com/id' . $self->user_id;
}

sub build_userpic_url ($self) {
    $self->me->{photo_id} ? $self->me->{photo_100} : undef;
}

1;
