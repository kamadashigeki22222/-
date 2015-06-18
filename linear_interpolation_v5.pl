 #!/usr/bin/perl
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use Data::Dumper;  # Data構造表示用モジュールの読み込み
use File::Path;
use strict;
use warnings;
use Math::Trig;
use Path::Class;

require 'sub_get_next_zone_ver3.pl';

##########distance of 2 points###############
  sub distance{
	   my($lat_a, $lon_a, $lat_b, $lon_b) = @_;
           my $lat_sec = ($lat_a-$lat_b)*111263.283;
           my $lon_sec = ($lon_a-$lon_b)*91158.84;
           return sqrt(($lat_sec*$lat_sec)+($lon_sec*$lon_sec));
	}
sub hex_dis{
	my ($geo1,$geo2) = @_;
	my ($lat1,$lon1) = geohex2latlng($geo1);
	my ($lat2,$lon2) = geohex2latlng($geo2);
	return &distance($lat1,$lon1,$lat2,$lon2);
}	
#############################################
	 

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

sub split_line{
	$_ = shift;
	my($a,$b,$c) = split(/,/,$_);
	return ($a,$b,$c);
}

sub ret_cst_hex{
	my ($geo1,$geo2) = @_;
	my %rk_hex_dis=();
	@_ = &next_zone($geo1);

	while(@_){
		$_ = shift(@_);
		$rk_hex_dis{$_} = &hex_dis($geo2,$_);
	}	
	my @tmp=();

	foreach(sort {$rk_hex_dis{$a} <=> $rk_hex_dis{$b}} keys %rk_hex_dis){
		push(@tmp,$_);
	}
	#print @tmp;
	#<STDIN>;
	return $tmp[0];
}	
		
	print "user_name ";
   	my $user_name = <STDIN>;
    chomp($user_name);
    print "idoubunkatu ";
   	my $idoubunkatu = <STDIN>;
    chomp($idoubunkatu);
    print "hexsize ";
   	my $level = <STDIN>;
    chomp($level);


#直線補間のソース
#my $level = 9;
print "running\n";
my $n = 0;

my $outfile;
#my $out = file("result.txt");
#$outfile=$out;
#open(FP1,"GM2TKfile0.txt")or die("cannot open the file");	
#print "$outfile\n"; 


	if($idoubunkatu == 1){
		open(FP1,"gpxfile/$user_name/result/GM2TKfile0.txt") or die("cannot open the file");
		my $out = file("move_times/linear/$user_name/li_$user_name$level.txt");
		#my $out = file("move_times/linear/test2.txt");
		$outfile=$out;
		
		
	}elsif($idoubunkatu == 2){
		open(FP1,"kasai_program/result/move_$user_name.txt") or die("cannot open the file");
		my $out = file("move_times/linear/$user_name/bunkatu_li_$user_name$level.txt");
		$outfile=$out;	
	}
	


my $writer = $outfile->open('w') or die $!;
	#一つ目のデータ	
my $line = <FP1>;
my($time1,$lat1,$lon1) = &split_line($line);
my $geo1 = latlng2geohex($lat1,$lon1,$level);
$writer->print  ("$geo1,1\n");
while($line = <FP1>){
	my($time2,$lat2,$lon2) = &split_line($line);
	my $sec = &return_sec($time2,$time1);

	if(($sec) >31){
		if($line = <FP1>){
			($time1,$lat1,$lon1) = &split_line($line);
			$geo1 = latlng2geohex($lat1,$lon1,$level);

			next;
		}else{
			last;
		}		
	}	
	my $geo2 = latlng2geohex($lat2,$lon2,$level);
	my $tmp_hex=0;
	#print "$geo1,$geo2\n";
	while($geo1 cmp $geo2){
		$geo1 = &ret_cst_hex($geo1,$geo2);
		#print "1 $geo1\n";
		#print "2 $geo2\n";
		$writer->print  ("$geo1,0\n");
	}
	$time1 = $time2;
	#<STDIN>;
	$writer->print  ("$geo2,1\n");
}	