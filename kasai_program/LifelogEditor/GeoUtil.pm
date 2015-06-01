#!/usr/bin/perl
#
# Utilities for Geo/GIS
#
# Copyright (c) 2013 Sunao Hara, ABELAB, Okayama University
#
package LifelogEditor::GeoUtil;

use strict;
use warnings;
use Math::Trig qw/ deg2rad asin /;
#use Time::Piece;
use DateTime;
use DateTime::Duration;
use DateTime::Format::RFC3339;
use XML::Simple;

use utf8;
use JSON;
use Time::Piece;
use DateTime;
use Math::Trig qw/pi deg2rad rad2deg/;

# filenameで指定したファイルはあらかじめ作っておく必要がある．
sub save_csvfile{
	#my $filename = shift;
	my $out = shift;
	my $out2 = shift;
	my $data = shift;
	
	my $staytext = "";
	my $movetext = "";
	my $lp;
	my $size;
	
	my $lines = 0;
	my $staylines = 0;
	my $movelines = 0;

	#my $buffer = "";
	#open $out, "<", "./result/".$filename || die "Error: OpenW: $filename";
	#while (sysread $out, $buffer, 4096) {
	#  $lines += ($buffer =~ tr/\n//);
	#}
	#close $out;


#ifの括弧書きを消したら滞在，移動全て表示，ifの！の無いほうは滞在地のみ，ifの!のあるほうは移動のみ
	foreach my $hash (@$data){
		#if(defined($hash->{'address'}) && $hash->{"dwell_time"} > 0)
		if((defined($hash->{'address'}) && $hash->{"dwell_time"} > 0))
		{
			$staytext .= $staylines . "," . $hash->{"st_time_UNIX"} . "Z,";
			$staytext .= $hash->{"ed_time_UNIX"} . "Z,";
			$staytext .= $hash->{"loc_ave"}[1] . "," . $hash->{"loc_ave"}[0] . ",";
			$staytext .= ($hash->{"ed_time"} - $hash->{"st_time"}) . "\n";
			$staylines++;
		}
		else{
			my @array = @{$hash->{'loc_detail'}};
			my $size = scalar(@array);
			for(my $lp = 0; $lp < $size; $lp++){#time_UNIX
				$movetext .= $hash->{'loc_detail'}[$lp]->{'time_UNIX'}. "Z,";
				#$movetext .= "," . $hash->{'loc_detail'}[$lp]->{'loc'}[1];
				$movetext .= $hash->{'loc_detail'}[$lp]->{'loc'}[1];
				$movetext .= "," . $hash->{'loc_detail'}[$lp]->{'loc'}[0];
				$movetext .= "\n";
			}
			$movelines++;
		}

		
	}

	#open $out, ">>", "./result/stay_".$filename || die "Error: OpenW: $filename";
	print $out $staytext;

	#open $out2, ">>", "./result/move_".$filename || die "Error: OpenW: $filename";
	print $out2 $movetext;

	#close $out;
	#close $out2;
}
	
## Command Line: TEST FUNCTION
if($0 eq __FILE__) {

	&_test_get_distance;

	latlon2xy_rel(34.689669,133.921521 => 34.666041,133.918533 => 35.681248,139.766393 => 34.666345,133.918566);


	print sprintf("%f\n", get_distance(34.67,133.8 => 34.68,133.8));
	print sprintf("%f\n", get_distance(34.69,133.8 => 34.68,133.8));
	print sprintf("%f\n", get_distance(34.68,133.80 => 34.68,133.81));
	print sprintf("%f\n", get_distance(34.78,133.80 => 34.78,133.81));

	exit 0;
}

sub _test_get_distance {
	# 岡大工1号館　34.689669,133.921521
	# 岡大工4号館　34.689947,133.923399
	# 東京駅 35.681248, 139.766393  /  +35° 40' 52.49", +139° 45' 59.01"
	# 岡山駅 34.666345, 133.918566?  /  +34° 39' 58.84", +133° 55' 6.84"
	my $d1 = get_distance(34.689669,133.921521 => 34.689947,133.923399);
	my $d2 = get_distance(34.689669,133.921521 => 34.666345,133.918566);
	my $d3 = get_distance(35.681248,139.766393 => 34.666345,133.918566);

	if(abs($d1 - 174.4) < 1.0) {
		print STDERR "TEST2: OK: $d1 ~= 174.4\n";
	} else {
		print STDERR "TEST2: NG: $d1 != 174.4\n";
	}

	if(abs($d2 - 2607.4) < 1.0) {
		print STDERR "TEST1: OK: $d2 ~= 2607.4\n";
	} else {
		print STDERR "TEST1: NG: $d2 != 2607.4\n";
	}

	# http://vldb.gsi.go.jp/sokuchi/surveycalc/bl2stf.html
	# 35°40′52.49″, 139°45′59.01″ -> 34°39′58.84″, 133°55′06.84″ = 544,383.649(m)
	if(abs($d3 - 544383.649) / 544383.649 < 1.0e-2) {
		print STDERR "TEST3: OK: ";
	} else {
		print STDERR "TEST3: NG: ";
	}
	print STDERR sprintf("abs(%f - 544383.649) / 544383.649 = %g <=> 1.0e-2\n", $d3, abs($d3 - 544383.649) / 544383.649);
}

##
## Get distance(meter unit) between (lat1, lon1) -> (lat2, lon2)
##   The Haversine Formula
##   See: http://www.codecodex.com/wiki/Calculate_Distance_Between_Two_Points_on_a_Globe#Perl
##
sub get_distance {
	# degree to radian
	my($lat1, $lon1, $lat2, $lon2) = map {deg2rad($_)} @_;

	#print STDERR sprintf("DEBUG: %f, %f, %f, %f\n", @_);
	#print STDERR sprintf("DEBUG: %f, %f, %f, %f\n", $lat1, $lon1, $lat2, $lon2);

	# $lat1 and $lon1 are the coordinates of the first point in radians
	# $lat2 and $lon2 are the coordinates of the second point in radians
	my $a = sin(($lat2 - $lat1)/2.0);
	my $b = sin(($lon2 - $lon1)/2.0);
	my $h = ($a*$a) + cos($lat1) * cos($lat2) * ($b*$b);

	# distance in radians
	my $theta = 2 * asin(sqrt($h));

	# in order to find the distance, multiply $theta by the radius of the earth, e.g.
	# $theta * 6,372.7976 = distance in kilometres (value from http://en.wikipedia.org/wiki/Earth_radius)

	# 国土地理院の計算式とデータを利用する
	my $distance = _get_radius( ($lat1 + $lat2) * 0.5 ) * $theta;

	#print STDERR sprintf("DEBUG: %f,%f -> %f,%f = %f\n", $lat1, $lon1, $lat2, $lon2, $distance);

	return $distance;
}

##
## 先頭の点を原点とする相対的なxy座標に変換する関数。
##   get_distanceの結果からは若干誤差が含まれてしまうことに注意。
##
sub latlon2xy_rel {
	my @latlon = map {deg2rad($_)} @_;
#	my @latlon = @_;
	my @xy;

	my $lat_origin = $latlon[0];
	my $lon_origin = $latlon[1];

	my $R = _get_radius($lat_origin);

	for(my $i=0; $i<=$#latlon; $i+=2 ) {
		my $lat = $latlon[$i] - $lat_origin;
		my $lon = $latlon[$i+1] - $lon_origin;
		print STDERR sprintf("%f,%f\t", $lat, $lon);
		print STDERR sprintf("%f,%f -> %f\n", $R * $lat, $R * $lon, sqrt(($R * $lat) ** 2 + ($R * $lon) ** 2));

		push @xy, ($lon,$lat);
	}

	return @xy;
}

## 緯度から地球の平均半径を計算する
##   国土地理院の計算式とデータ
##   http://vldb.gsi.go.jp/sokuchi/surveycalc/algorithm/ellipse/ellipse.htm
##   > 地球の形状におよび大きさについて，
##   > 世界測地系（測地成果2000）に基づく計算は，
##   > 測量法施行令第2条の2に定める楕円体の値による．
##   > a: 長半径、b: 短半径、f: 扁平率、psi: 緯度
sub _get_radius {
	my $lat = shift;

	my $G_a = 6378137.0;
	my $G_f = 1.0 / 298.257222101;
	my $G_b = $G_a * (1.0 - $G_f);
	my $G_e_sq = 2.0 * $G_f - $G_f ** 2;

	my $sin_psi_sq = sin($lat) ** 2;
	my $g_W  = 1.0 - $G_e_sq * $sin_psi_sq;
	my $R = $G_b / $g_W;

	return $R;

}

## GPX形式のファイルを読み込む
## 時間のフォーマットはGMTで書かれている前提で、
## 返り値として得られる時間はJSTに変換されているとする。
sub load_gpxfile {
	my $filename_or_xmltext = shift;
    my @tracks;

	# my $xmlobj = XML::Simple->new(ForceArray => ['trkseg', 'trkpt']);
	my $xmlobj = XML::Simple->new();
	my $tree = $xmlobj->XMLin($filename_or_xmltext);

	my $fmt = DateTime::Format::RFC3339->new();
	my $tz = DateTime::TimeZone->new(name => 'Asia/Tokyo');	

	foreach my $key(sort(keys($tree->{'trk'}))){
		my @array;
		if($key eq "DG-100 GPS tracklog data"){next;}
		if($key eq "trkseg"){
			if (exists($tree->{'trk'}->{'trkseg'}->{'trkpt'})){
				@array = @{$tree->{'trk'}->{'trkseg'}->{'trkpt'}};
			}
		}
		else{
			if($key eq "desc" || $key eq "name"){next;}
			if (exists($tree->{'trk'}->{$key}->{'trkseg'}->{'trkpt'})){
				@array = @{$tree->{'trk'}->{$key}->{'trkseg'}->{'trkpt'}};
			}
		}

		  foreach my $trkpt (@array) {
		  		my $lat = $trkpt->{'lat'};
		        my $lon = $trkpt->{'lon'};
		        my $time_str = $trkpt->{'time'};

		        if($lat+0 > 90 || $lat+0 < -90){
		        	next;
				}
				if($lon+0 > 180 || $lon+0 < -180){
		        	next;
				}
				# 2000~2029年までの指定の形式のみ
				unless($time_str =~ /2\d[0-2]\d-\d\d-\d\dT\d\d:\d\d:\d\dZ/){
		        	next;
				}

		        my $t = $fmt->parse_datetime($time_str)->set_time_zone($tz);

		        #$t += 9 * 3600; # Z->JST
		        push @tracks, {
		          'time' => $t->datetime,
		          'lat'  => $lat,
		          'lon'  => $lon
		        };
		  }
	}
    return @tracks;
}

## time lat lon が格納されたハッシュから日付ごとに新しいGPXファイルを作成
sub gpxhash_to_newgpxfile {
	my $self = shift;
	my $uid = shift;
	my $tracks = shift;
	my $log_dir = shift;
	my $daily_dir = shift;

	my @dayTracks = ();

	my $date = "";
	my $st_epoch;
	my $ed_epoch;

	foreach my $trk ( @$tracks ) {
		if($date eq ""){
			my $time = Time::Piece->strptime($trk->{"time"}, '%Y-%m-%dT%T');
			$date = $time->ymd;
			$trk->{"time_epoch"} = $time->epoch;
			push @dayTracks, $trk;
			$st_epoch = $time->epoch;
			$ed_epoch = $st_epoch;
			next;
		}
		my $time = Time::Piece->strptime($trk->{"time"}, '%Y-%m-%dT%T');
		if($date eq $time->ymd){
			$trk->{"time_epoch"} = $time->epoch;
			push @dayTracks, $trk;
			$ed_epoch = $time->epoch;
		}
		else{
			LifelogEditor::MainDB::db_insert_originalData($self, $uid, \@dayTracks, $st_epoch, $ed_epoch);

			my $epochTime = Time::Piece->strptime($date, '%Y-%m-%d');
			my $newfile_fullpath = "data/$uid/dailyGPX/$date.gpx";  #join('/', $log_dir, $uid, $daily_dir, $date.".gpx");
			my $originalData = LifelogEditor::MainDB::db_search_originalData($self, $uid, $epochTime->epoch, $epochTime->epoch+86399);
			save_gpxfile($newfile_fullpath, $originalData);

			@dayTracks = ();
			$trk->{"time_epoch"} = $time->epoch;
			push @dayTracks, $trk;
			$date = $time->ymd;
			$st_epoch = $time->epoch;
			$ed_epoch = $st_epoch;
		}
	}

	if(@dayTracks){
		LifelogEditor::MainDB::db_insert_originalData($self, $uid, \@dayTracks, $st_epoch, $ed_epoch);

		my $epochTime = Time::Piece->strptime($date, '%Y-%m-%d');
		my $newfile_fullpath = join('\\', $log_dir, $uid, $daily_dir, $date.".gpx");
		my $originalData = LifelogEditor::MainDB::db_search_originalData($self, $uid, $epochTime->epoch, $epochTime->epoch+86399);
		save_gpxfile($newfile_fullpath, $originalData);
	}

}

## CSVファイルを読み込む
sub load_csvfile {
	my $filename = shift;
    my @tracks;

	open(my $fh, "<", $filename) or die "Cannot open $filename for read: $!";

	my $recs = []; 
	while (my $line = <$fh>) {
	    chomp $line;

	    my $items = []; 
	    @$items = split(/,/, $line); 
	    push @tracks, $items;
  	}

	close $fh; 
    return @tracks;
}

sub save_gpxfile {
	my $filename = shift;
	my $data = shift;

	my $out;
	my $newtext = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<gpx 
version="1.1" 
creator="DG100.exe" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns="http://www.topografix.com/GPX/1/1" 
xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
EOF

	$newtext .= "<trk>\n<trkseg>\n";

	while (my $hash = $data->next) {
		$newtext .= sprintf("<trkpt lat=\"%f\" lon=\"%f\">\n", $hash->{'lat'}, $hash->{'lon'});
		$newtext .= sprintf(" <time>%s</time>\n", $hash->{'time'});
		$newtext .= "</trkpt>\n";
	}

	$newtext .= <<EOF;
</trkseg>
</trk>
</gpx>
EOF
	open $out, ">", $filename || die "Error: OpenW: $filename";
	print $out $newtext;
	close $out;
}

## GPX形式のファイルを読み込む
## 時間のフォーマットはEpoch秒で書かれている前提で、
## 返り値として得られる時間はJSTに変換されているとする。
sub load_tsvfile {
	my $tsvfile = shift; # '../data/hara/20130403_000007~20130403_092021.gpx';

	my @tracks = ();
	my $fmt = DateTime::Format::RFC3339->new();
	my $tz = DateTime::TimeZone->new(name => 'Asia/Tokyo');

	my $fp;
	open $fp, '<', $tsvfile;
	while ( <$fp> ) {
		chomp;

		#my($etime,$lat,$lon) = split(/\t/, $_);
#		my $t = Time::Piece->strptime($etime, "%s"); # %s => Epoch to Time-object
#		push @tracks, {'time' => $t->strftime("%Y-%m-%dT%H:%M:%S%z"), 'lat' => $lat, 'lon' => $lon};
		my($unixtime,$time_str,$lat,$lon) = split(/\t/, $_);

		if($time_str eq "") {
			my $t = DateTime->from_epoch( epoch => $unixtime, 'time_zone' => $tz);
			push @tracks, {'time' => $t, 'lat' => $lat, 'lon' => $lon};
		} else {
	        my $t = $fmt->parse_datetime($time_str)->set_time_zone($tz);
			push @tracks, {'time' => $t, 'lat' => $lat, 'lon' => $lon};
		}


	}
	close($fp);

	return @tracks;
}

sub save_tsvfile {
	my $filename = shift;
	my @tracks = @_;

	my $fout;
	my $fmt = DateTime::Format::RFC3339->new();
	my $tz = DateTime::TimeZone->new(name => 'Asia/Tokyo');

	open $fout, ">", $filename || die "Error: OpenW: $filename";
	foreach my $pt ( @tracks ) {
#		my $unixtime = get_unixtime($pt->{time};
#		my $time_str = $fmt->format_datetime($pt->{'time'}->set_time_zone('Asia/Tokyo'));
		my $time_str = $fmt->format_datetime($pt->{'time'}->set_time_zone($tz));
		my $unixtime = $pt->{time}->epoch;

#		print $fout join("\t", $unixtime, $pt->{'lat'}, $pt->{'lon'}) . "\n";
		print $fout join("\t", $unixtime, $time_str, $pt->{'lat'}, $pt->{'lon'}) . "\n";

	}
	close $fout;
}

# unused
# sub get_unixtime {
# 	my $time_str = shift;
# 	my $unixtime = -1;

# 	eval {
# 		my $t = Time::Piece->strptime($time_str, '%FT%T%Z');
# 		$unixtime = $t->epoch;
# 		$unixtime -= 9 * 3600 if($time_str =~ /JST$/ || $time_str =~ /\+09/);
# 	};

# 	if($@) {
#         warn "WARNING: Check Time format: " . $time_str . "\n";
# 	}

# 	return $unixtime;
# }

## load_gpxfileの返り値を元に1secごとのサンプルとしてリサンプリングする
## 先にmedian_filterをかけたほうが良い。
sub track_resample {
	my @tracks = @_;
	my @newtracks = ();

	for(my $n=1; $n<=$#tracks; ++$n) {
#		my $st = Time::Piece->strptime($tracks[$n-1]->{time}, '%FT%T%z');
#		my $et = Time::Piece->strptime($tracks[$n]->{time}, '%FT%T%z');
#		my $diff = $et - $st;
		my $st = $tracks[$n-1]->{time};
		my $et = $tracks[$n]->{time};
		my $diff = ($et - $st)->in_units('seconds');

		push @newtracks, $tracks[$n-1];
		# 時間差が大きすぎるときは処理をしない
		next if($diff > 600);

		for(my $m = 1; $m < $diff; ++$m) {
			my $newlat = $tracks[$n]->{lat} * ((0.0+$m)/$diff) + $tracks[$n-1]->{lat} * (1.0-(0.0+$m)/$diff);
			my $newlon = $tracks[$n]->{lon} * ((0.0+$m)/$diff) + $tracks[$n-1]->{lon} * (1.0-(0.0+$m)/$diff);
			#print 'DST: ' . join("\t", $st++->datetime, $newlat, $newon) . "\n";  #debug
			push @newtracks, {
#				'time' => ($st+$m)->strftime("%Y-%m-%dT%H:%M:%S%z"),
				'time' => $st->clone->add('seconds'=>$m),
				'lat' => $newlat,
				'lon' => $newlon
			};
		} 
		#last if($n > 10); #debug
	}
	return @newtracks;
}

## メディアンフィルタをかける
sub median_filter {
	my $win_length = shift; # 5
	my @tracks = @_;

	my $winh_length = ($win_length - 1) / 2;

	my @newtracks = @tracks;
	for(my $c = $winh_length; $c <= $#tracks - $winh_length; ++$c) {
#		my $st = Time::Piece->strptime($tracks[$c-$winh_length]->{time}, '%FT%T%z');
#		my $et = Time::Piece->strptime($tracks[$c+$winh_length]->{time}, '%FT%T%z');
		my $st = $tracks[$c-$winh_length]->{time};
		my $et = $tracks[$c+$winh_length]->{time};

		# 時間差が大きすぎるときは処理をしない
#		next if( ($et - $st) > 600);
		next if( ($et - $st)->in_units('seconds') > 600);

		my @track_latsort = sort {$a->{'lat'} <=> $b->{'lat'}} @tracks[$c-$winh_length .. $c+$winh_length];
		my @track_lonsort = sort {$a->{'lon'} <=> $b->{'lon'}} @tracks[$c-$winh_length .. $c+$winh_length];

		$newtracks[$c] = {
			'time' => $tracks[$c]->{'time'},
			'lat' => $track_latsort[$winh_length]->{'lat'},
			'lon' => $track_lonsort[$winh_length]->{'lon'}
			};
		#print 'MED: ' . join("\t", $newtracks[$c]->{'time'}, $newtracks[$c]->{'lat'}, $newtracks[$c]->{'lon'}) . "\n";  #debug

		#last if($c > 10); #debug
	}

	return @newtracks;
}

1;