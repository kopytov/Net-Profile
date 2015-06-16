package Net::Profile::OK;
use Moose;
use namespace::autoclean;
use extreme;
use Carp;
use Digest::MD5 'md5_hex';
use JSON::XS;
use LWP::UserAgent;
use URI;

extends 'Net::Profile';

our $ua = LWP::UserAgent->new;

has app_public => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has app_secret => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has me => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => 'build_me',
    lazy    => 1,
);

sub sign ( $query, $app_secret ) {
    my $sign_string  = '';
    my $access_token = delete $query->{access_token};
    my $secret_key   = lc md5_hex("$access_token$app_secret");
    for my $key ( sort keys $query ) {
        $sign_string .= "$key=$query->{$key}";
    }
    $sign_string .= $secret_key;
    $query->{sig}          = lc md5_hex($sign_string);
    $query->{access_token} = $access_token;
}

sub build_me ($self) {
    my $uri   = URI->new('http://api.ok.ru/api/users/getCurrentUser');
    my $query = {
        format          => 'JSON',
        access_token    => $self->access_token,
        application_key => $self->app_public,
        fields          => 'uid,name,photo_id,pic190x190',
    };
    sign( $query, $self->app_secret );
    $uri->query_form($query);
    my $res = $ua->get($uri);
    croak $res->status_line if !$res->is_success;
    my $me = decode_json( $res->decoded_content );
    croak $me->{error_msg} if exists $me->{error_msg};
    return $me;
}

sub build_user_id ($self) { $self->me->{uid} }
sub build_name ($self)    { $self->me->{name} }
sub build_url ($self)     { 'http://ok.ru/profile/' . $self->user_id }

sub build_userpic_url ($self) {
    $self->me->{photo_id} ? $self->me->{pic190x190} : undef;
}

1;
