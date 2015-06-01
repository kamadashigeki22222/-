
#!/usr/bin/perl
use strict;
use warnings;
use Math::Trig;
use constant RAD => pi / 180;
use constant  R => 6378137;
sub relative_azimuth{
	my ($lat1, $lon1, $lat2, $lon2, $direction )= @_;

        my $rad_azimuth = atan2($lat2-$lat1,$lon2-$lon1);
        
	my $relative_angle = $rad_azimuth - $direction ;
	    

return $relative_angle;
}
1       