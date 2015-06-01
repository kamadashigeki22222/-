
#!/usr/bin/perl
use strict;
use warnings;
use Math::Trig;
my $A = 6378137; #赤道の直径
my $RAD = pi/180;

sub azimuth{
	my ($lat1, $lon1, $lat2, $lon2) = @_;
	# 度をラジアンに変換
	$lat1 *= $RAD;
	$lon1 *= $RAD;
	$lat2 *= $RAD;
	$lon2 *= $RAD;

	my $lat_c = ($lat1 + $lat2) / 2;					# 緯度の中心値
	my $dx = $A * ($lon2 - $lon1) * cos($lat_c);
	my $dy = $A * ($lat2 - $lat1);

	if ($dx == 0 && $dy == 0) {
		return 0;	# dx, dyともに0のときは強制的に0とする。
	}#elsif((atan2($dy, $dx) / $RAD) < 0){
#		return atan2($dy, $dx) / $RAD+360;
	#}
	else {
		return atan2($dy, $dx) / $RAD;	# 結果は度単位で返す
	}
}
1