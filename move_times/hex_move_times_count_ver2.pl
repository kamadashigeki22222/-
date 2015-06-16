#滞在HEX以外のHEXの頻度を計算しソート

 #!/usr/bin/perl
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use strict;
use warnings;

#my $dis;





sub distance_filter{
	my ($s,$t,$u) = @_;
	my $dis = &hex_dis($s,$t);
	if($dis > $u){return 1;}
	return 0;	
}

sub hex_dis{
	my ($s,$t) = @_;
	my ($lat1,$lon1)=geohex2latlng($s);
	my ($lat2,$lon2)=geohex2latlng($t);
	return &distance($lat1,$lon1,$lat2,$lon2);
}

sub distance{
	   my($lat_a, $lon_a, $lat_b, $lon_b) = @_;
           my $lat_sec = ($lat_a-$lat_b)*111263.283;
           my $lon_sec = ($lon_a-$lon_b)*91158.84;
           return sqrt(($lat_sec*$lat_sec)+($lon_sec*$lon_sec));
	}
	
sub split_from_fp{
	my $file = shift;
	my $line = <$file>;
	#print "line = $line\n";
	if(defined $line){
		chomp($line);
		my ($line1,$line2) = split(/,/,$line);
	}
	
}	


 	print "user_name ";
   my $user_name = <STDIN>;
    chomp($user_name);
    print "idoubunkatu ";
   	my $idoubunkatu = <STDIN>;
    chomp($idoubunkatu);
     print "hexsize ";
   	my $hexsize = <STDIN>;
    chomp($hexsize);
    my $home;



#滞在Hexのデータを入力
open(FP1, "../spot_times/merge/merge2_hex_spot_times_filter_$user_name$hexsize.txt") or die("cannot open the file");
#open(FP1, "../spot_times/merge/merge2_hex_spot_times_filter_kamada.txt") or die("cannot open the file");



my @spot_hex=();
#if ($user_name == 1) {
    if($hexsize == 10 ){

    	$home = "XM5321347558";
    }elsif($hexsize == 9){

    	$home = "XM532134755";
    }elsif($hexsize == 8){

        $home = "XM53213475";
    }elsif($hexsize == 7){

     $home = "XM5321347";
    }elsif($hexsize == 6){

  $home = "XM532134";
    }elsif($hexsize == 5){

  $home = "XM53213";
    }elsif($hexsize == 4){

 $home = "XM5321";
    }elsif($hexsize == 3){

  $home = "XM532";
    }elsif($hexsize == 2){

    $home = "XM50";
    }     
        
  
        #}






#my $home = "XM5321346873"; #H_K
#my $home = "XM5321341673"; #K_A
#my $home = "XM5321308285"; #S_R
#my $home = "XM5321347558"; #K_M



while(my $line = <FP1>){
	my ($code) = split(/,/,$line);
	push(@spot_hex,$code);
}
print "@spot_hex\n";
#自宅との距離が何m以上ならば除外するか
printf "input remove hex dis =";
my $filter = <STDIN>;
my %move_hex=();
 %move_hex =();
 #input csv形式

 if($idoubunkatu == 1){
open(FP3, " linear/li_$user_name$hexsize.txt") or die("cannot open the file");
open(FP4, "> idou/idou_$user_name$hexsize.txt") or die("cannot open the file");

}elsif($idoubunkatu == 2){
	open(FP3, " linear/bunkatu_li_$user_name$hexsize.txt") or die("cannot open the file");
	open(FP4, "> idou/bunkatu_idou_$user_name$hexsize.txt") or die("cannot open the file");

}

while(my $line = <FP3>){
	#$test_count1++;
	my($code,$flag) = split(/,/,$line);
	if(&distance_filter($home,$code,$filter)){next;}
	if((!grep {$_ eq $code} @spot_hex)){
		#$test_count2++;

		if (exists($move_hex{$code})){
			if($move_hex{$code}->{flag} == 1){
				$move_hex{$code}->{count}++;
			}else{	
				if($flag == 1){
				$move_hex{$code}->{count} = $move_hex{$code}->{count}*2;
				$move_hex{$code}->{flag} = 1;
				}else{
					$move_hex{$code}->{count} =  $move_hex{$code}->{count}+0.5;
				}
			}
		} else{
			$move_hex{$code}={
				flag=>$flag,
				hex=>$code,
				count => 0,
			};
			if($flag == 1){
				$move_hex{$code}->{count}++;
			}else{
				$move_hex{$code}->{count} =  0.5;
			}		
		}
	}
}
foreach my $key (sort{$move_hex{$b}->{count} <=> $move_hex{$a}->{count}}keys %move_hex){
        print FP4 "$key,$move_hex{$key}->{count} \n";
        }     
