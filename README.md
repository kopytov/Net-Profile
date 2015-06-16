# NAME

Net::Profile - library to interact with API of social networks

# VERSION

version 0.001

# SYNOPSIS

    my $profile = Net::Profile::VK->new( access_token => '...' );
    
    say $profile->user_id;
    say $profile->name;
    say $profile->url;

    my $userpic = $profile->userpic; # Imager object
    $userpic->write( file => '/srv/foo/bar/userpic.png' );

# AUTHOR

Dmitry Kopytov <kopytov@webhackers.ru>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Webhackers.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# SOURCE

The development version is on github at [http://github.com/kopytov/Net-Profile](http://github.com/kopytov/Net-Profile)
and may be cloned from [git://github.com/kopytov/Net-Profile.git](git://github.com/kopytov/Net-Profile.git)
