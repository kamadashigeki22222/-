 #!/usr/bin/perl
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use Data::Dumper;  # Data構造表示用モジュールの読み込み
use File::Path;
use strict;
use warnings;
use Math::Trig;
use Path::Class;

require 'nextzone\sub_get_next_zone.pl';
require 'nextzone\sub_azimuth2.pl';

##########distance of 2 points###############
  sub distance{
	   my($lat_a, $lon_a, $lat_b, $lon_b) = @_;
           my $lat_sec = ($lat_a-$lat_b)*111263.283;
           my $lon_sec = ($lon_a-$lon_b)*91158.84;
           return sqrt(($lat_sec*$lat_sec)+($lon_sec*$lon_sec));
	}
#############################################

sub switch{
	   my ($azi,$geohex_code) = @_; 
	   my $level=11;
	   my @code;
	   my $element = substr($geohex_code,$level,1);
	   if($azi > 120 ){
	   	#print "up_left\n";
	   	return &up_left_zone($element,$level,$geohex_code,@code);
	   }elsif($azi > 60){
	   	#print "aaa=$azi\n";
	   	#print "up\n";
	   	return &up_zone($element,$level,$geohex_code,@code); 
	   }elsif($azi > 0){
	   	#print "up_right\n";
	   	return &up_right_zone($element,$level,$geohex_code,@code);
	   }elsif($azi > -60){
	   	#print "down_right\n";
	   	return &down_right_zone($element,$level,$geohex_code,@code);	
	   }elsif($azi > -120){
	   	#print "down\n";
	   	return &down_zone($element,$level,$geohex_code,@code);
	   }else{
	   	#print "down_left\n";
	   	return &down_left_zone($element,$level,$geohex_code,@code);
	   }
	 }
	 
sub dis_more_n_push{
	my($lat_a,$lon_a,$lat_b,$lon_b,$geo,$dis,@hex) = @_;
	my $level = 10;
	while($dis > 100){			
	        #<STDIN>;   	
	   	$lat_b = ($lat_a+$lat_b)/2;
	   	$lon_b = ($lon_a+$lon_b)/2;
	   	$geo = latlng2geohex($lat_b,$lon_b,$level);
	   	push(@hex,$geo);
	   	$dis = &distance($lat_a,$lon_a,$lat_b,$lon_b);
	   }
	        return @hex;	        
	 }	
		
##########from year month day time to time(sec)####
sub return_sec{
             my($line1,$line2) = @_;

             my @one_is_h_m_s = split(/T/,$line1);
             my @one_is_h_m_s2 = split(/T/,$line2);
      if($one_is_h_m_s[0] eq $one_is_h_m_s2[0]){          #同日での時間の差
             my @zero_is_h_m_s = split(/Z/,$one_is_h_m_s[1]);
             my @h_m_s1 = split(/:/,$zero_is_h_m_s[0]);

             my @zero_is_h_m_s2 = split(/Z/,$one_is_h_m_s2[1]);
             my @h_m_s2 = split(/:/,$zero_is_h_m_s2[0]);

             return (3600*$h_m_s1[0]+60*$h_m_s1[1]+$h_m_s1[2])-(3600*$h_m_s2[0]+60*$h_m_s2[1]+$h_m_s2[2]);
       }else{                                             #異なる日での時間の差
             my @zero_is_h_m_s = split(/Z/,$one_is_h_m_s[1]);
             my @h_m_s1 = split(/:/,$zero_is_h_m_s[0]);

             my @zero_is_h_m_s2 = split(/Z/,$one_is_h_m_s2[1]);
             my @h_m_s2 = split(/:/,$zero_is_h_m_s2[0]);
             # return (3600*$h_m_s1[0]+60*$h_m_s1[1]+$h_m_s1[2])+(3600*(24-$h_m_s2[0])+60*(60-$h_m_s2[1])+(60-$h_m_s2[2]));
             return (3600*(24+$h_m_s1[0])+60*$h_m_s1[1]+$h_m_s1[2])-(3600*($h_m_s2[0])+60*($h_m_s2[1])+($h_m_s2[2]));
        }

}	


#main 

#my $dir_name = './rand_60day/';
#my $search = $dir_name.'*.txt';
#my @file = glob($search);
#print "file = @file\n";
#直線補間のソース
my $level = 10;
print "running\n";
my $n = 0;
#while(@file){		
#	my $file_name = shift(@file);
#	my @tmpfile = split(/\//,$file_name);
#	print "@tmpfile\n";
#	open(FP1,"<$file_name") or die("cannot open the file");
	#ファイル形式例　2012-11-20T0:15:27Z,34.678958,133.906297
	#滞在地のHexを除外したほうがいいかもしれない・・・
		

	print "user_name ";
   	my $user_name = <STDIN>;
    chomp($user_name);


	#input
	#open(FP1,"gpxfile/$user_name/result/GM2TKfile0.txt") or die("cannot open the file");
	#open(FP1,"idou3_kamada.csv") or die("cannot open the file");
	open(FP1,"kasai_program/result/move_$user_name.txt") or die("cannot open the file");
	

	my $outfile = file("move_times/linear/li211111_$user_name.txt");
	print "$outfile\n"; 
	my $writer = $outfile->open('w') or die $!;
	#一つ目のデータ	
	my $line = <FP1>;
	my($time1,$lat1,$lon1) = split(/,/,$line);
	print "$lat1\n";
my $geo1 = latlng2geohex($lat1,$lon1,$level);
	
	$writer->print  ("$geo1,1\n");
	
	my @hex;
	my $tmp_geo;
	
	
	while($line = <FP1>){
		my $ret_code =0;
		my($time2,$lat2,$lon2) = split(/,/,$line);
		my $sec = &return_sec($time2,$time1);
		if(abs($sec) > 31){
		#<STDIN>;
			#print  "$time1,$time2\n";
			if($line = <FP1>){
				($time1,$lat1,$lon1) = split(/,/,$line);
				#$lat1 = $lat2;
				#$lon1 = $lon2;
				$geo1 = latlng2geohex($lat1,$lon1,$level);
				next;
			}else{
				last;
			}
		}
		my $geo2 = latlng2geohex($lat2,$lon2,$level);
		push(@hex,$geo2);
		my $dis = &distance($lat1,$lon1,$lat2,$lon2);

		@hex = &dis_more_n_push($lat1,$lon1,$lat2,$lon2,$geo2,$dis,@hex);


		my $t_lat;
		my $t_lon;

		while(@hex){
	   	#print "test\n";
			$tmp_geo = $hex[-1];
	   	#print "tmp = $tmp_geo\n";
			($t_lat,$t_lon) = geohex2latlng($tmp_geo);
			$dis = &distance($lat1,$lon1,$t_lat,$t_lon);
			if($dis > 100){
			@hex = &dis_more_n_push($lat1,$lon1,$t_lat,$t_lon,$tmp_geo,$dis,@hex);
			#print "@hex\n";
			$tmp_geo = $hex[-1];
			($t_lat,$t_lon) = geohex2latlng($tmp_geo);
			#<STDIN>;	   		   	
			}else{
				pop(@hex);
			}
			my $azi =  &azimuth($lat1,$lon1,$t_lat,$t_lon);
			while($ret_code ne $tmp_geo){ 	
			#print "test\n";	
				$ret_code = &switch($azi,$geo1);
		      #<STDIN>;	
		      #print"ret = $ret_code\n";
				if($ret_code eq $geo2){
					$writer->print("$ret_code,1\n");
				}else{
					$writer->print("$ret_code,0\n");
				}
				$geo1 = $ret_code;
				($lat1,$lon1) = geohex2latlng($geo1);
				$azi = &azimuth($lat1,$lon1,$t_lat,$t_lon);		      
			}
		}
	@hex = ();

	   
	$lat1 = $t_lat;
	   
	$lon1 = $t_lon;
	$geo1 = latlng2geohex($lat1,$lon1,$level);
	$time1 = $time2;
	#print "1roop\n";
	   
	}
	$n++;
# }
print "success!\n";	   