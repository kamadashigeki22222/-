 #!/usr/bin/perl
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use Data::Dumper;  # Data構造表示用モジュールの読み込み
use File::Path;
use strict;
use warnings;
use Math::Trig;
use Path::Class;
use IO::File;
use Time::HiRes;  

our %cut_spot;
require 'nextzone\sub_get_next_zone.pl';

#ユーザ名,パラメータ（いわゆる,論文のｔ）を入力
print "input user name =>";
my $user_name = <STDIN>;
chomp($user_name);
print "input paramater=>";
my $prm = <STDIN>;
chomp($prm);
print "idoubunkatu ";
my $idoubunkatu = <STDIN>;
chomp($idoubunkatu);
print "hexsize ";
my $hexsize = <STDIN>;
chomp($hexsize);





#require 'perl_pl\linear_inerpolation\sub_azimuth.pl';
#２地点のキョリ
sub distance{
	   my($lat_a, $lon_a, $lat_b, $lon_b) = @_;
           my $lat_sec = ($lat_a-$lat_b)*111263.283;
           my $lon_sec = ($lon_a-$lon_b)*91158.84;
           return sqrt(($lat_sec*$lat_sec)+($lon_sec*$lon_sec));
	}

#隣接Hexの配列を返す
	
sub get_all_next_zone{
	   my ($geohex_code) = @_; 
	   #my $level = 11;
	   my $level = $hexsize+1;
	   my @code=();
	   my @next_hex=();
	   my $next;
	   #print "test2_geo = $geohex_code\n";
	   my $element = substr($geohex_code,$level,1);
	   $next = &up_left_zone($element,$level,$geohex_code,@code);
	   push(@next_hex,$next);
	   $next = &up_zone($element,$level,$geohex_code,@code);
	   push(@next_hex,$next);
	   $next = &up_right_zone($element,$level,$geohex_code,@code);
	   push(@next_hex,$next);
	   $next = &down_right_zone($element,$level,$geohex_code,@code);
	   push(@next_hex,$next);	   
	   $next = &down_zone($element,$level,$geohex_code,@code);
	   push(@next_hex,$next);
	   $next = &down_left_zone($element,$level,$geohex_code,@code);
	   push(@next_hex,$next);	   
	  return @next_hex;
	 }

sub all_get_next{
	my ($geo,@spot) = @_;
	my @next_hex=();
	$cut_spot{$geo}=1; 
        @next_hex = &get_all_next_zone($geo);
        while(@next_hex){
        	$geo = shift(@next_hex);
        	if(!grep {$_ eq $geo} @spot){next;}
        	if($cut_spot{$geo}){next;}
        	$cut_spot{$geo}=1; 
        	@_ =&get_all_next_zone($geo);
        	push @next_hex,@_;
        	#print "@next_hex\n";
        	#<STDIN>;
        	
        }
        }
#=put


#=cut 	
	  

#ターゲットHexを頻度が多い順にソート	
#いわゆる、この部分が最良優先探索の根幹 
sub sort_hex{
	#my ($bp,$move_hash,$sh,$score_hash,$close,$home,$d,$hex,$s_v) = @_;
	my ($bp,$move_hash,$sh,$score_hash,$close,$home,$d,$hex) = @_;
	my @spot_hex =@$sh;
	my @next = @$hex;
	my %move_hex = %$move_hash;
	my %score = %$score_hash;
	my @sort_hex=();
	my %close_list = %$close;
	#my %tmp_sort = ();


	#my ($lat1,$lon1) = geohex2latlng($target_hex)
	foreach $_ (@next){
		my $st_code = $_; 

		if((&dis_filter($d,$st_code,$home))){$close_list{$st_code} = 0; next;}
		if($move_hex{$st_code}){
			if($score{$st_code}){
				if((($score{$st_code}->{score})) > $score{$bp}->{score}){
					$score{$st_code} = {
						before => $bp,
						score => 1/$move_hex{$st_code} + $score{$bp}->{score}
					};
			
				}
			}else{
				$score{$st_code} = {
					before => $bp,
					score => 1/$move_hex{$st_code} + $score{$bp}->{score}
				};

			}
			#<STDIN>;	
			#push(@new_hex,$st_code);
			#$tmp_sort{$st_code} = $score{$st_code}->{score};
		}		
		elsif(grep {$_ eq $st_code} @spot_hex){
			if($score{$st_code}){
				if((($score{$st_code}->{score})) > $score{$bp}->{score}){
					$score{$st_code} = {
						before => $bp,
						score => $score{$bp}->{score}
						};
					}

				}else{
					$score{$st_code} = {
					before => $bp,
					score => $score{$bp}->{score}
					};

				}
			#$tmp_sort{$st_code} = $score{$st_code}->{score};	
		}else{	
		$close_list{$st_code} = 0;#(@close_list,$st_code);
		}
		
	}
	$close_list{$bp} = 0;#push(@close_list,$bp);
=put	
	foreach my $geohex (sort {$tmp_sort{$a} <=> $tmp_sort{$b}}(keys %tmp_sort)){
		unless( grep {$_ eq $geohex} @close_list ){
		push(@sort_hex,$geohex);
		}
	}
	if(@sort_hex){
		if($s_v){$tmp_sort{$s_v} = $score{$s_v}->{score};
			if($tmp_sort{$sort_hex[0]} < $tmp_sort{$s_v}){

				return (\@sort_hex,\%score,\@close_list);
			}
		}
	}
=cut

	@sort_hex = ();	
	foreach my $geohex (sort {$score{$a}->{score} <=> $score{$b}->{score}}(keys %score)) {
		unless(exists($close_list{$geohex})){#grep {$_ eq $geohex} @close_list ){
		push(@sort_hex,$geohex);
		#print "last\n";
		last;
		}
		#print "continue\n";
	}


	return (\@sort_hex,\%score,\%close_list,);
}

#ファイルポインタを受け取りカンマで分割した文字列を返す
sub split_from_fp{
	my $file = shift;
	my $line = <$file>;
	#print "line = $line\n";
	if(defined $line){
		chomp($line);
		my ($line1,$line2) = split(/,/,$line);
		return ($line1,$line2);
	}else{
		return (0,0);
	}
}
=put
#要素sが配列にあるか確認
sub check_s_in_array{
	my ($s,@array) = @_;
	if((grep {$_ eq $s} @array)) {return 1;}
	else {return 0;}
}

sub a_exist_b{
	my ($a,$b,$c) = @_;
	my @exist;
	my $element;
	while(@$c){
		$element=shift(@$c);	
		if((grep{$_ eq $element}@$a)||(grep{$_ eq $element}@$b)){
			push(@exist,$element);
		}
	}
	return @exist;
}
=cut
#配列bにある要素のうち配列aにある要素以外の配列を返す
sub make_unique_array{
	my ($a,$b) = @_;
	my @unique;
	my $element;
	while(@$b){
		$element=shift(@$b);	
		unless(grep{$_ eq $element}@$a){
			push(@unique,$element);
		}
	}
	return @unique;
}

#Hexを入力としキョリを返す
sub hex_dis{
	my ($s,$t) = @_;
	my ($lat1,$lon1)=geohex2latlng($s);
	my ($lat2,$lon2)=geohex2latlng($t);
	return &distance($lat1,$lon1,$lat2,$lon2);
}

#Hex間の距離が元のキョリの1.5倍になれば終了合図を返す
sub dis_filter{
	my ($d,$s,$t) = @_;
	my $d2 = &hex_dis($s,$t);
	if(($d*1.5) < $d2) {return 1;}	
	return 0;
}

#Hex間の距離が20km以上は除外
sub remove_hex{
	my ($s,$t) = @_;
	my $dis = &hex_dis($s,$t);
	if($dis > 20000){return 1;}
	return 0;	
}

sub ret_spot_array{
	my ($file)=@_;
	my @ret_array=();
	my $home;

#自宅Hexを入力
#上から順にUserA,B,C
#自宅Hexは手動で探しました
	#my $home = "XM5321346873"; #H_K
	#my $home = "XM5321341673"; #K_A
	#my $home = "XM5321308285"; #S_R
	#my $home = "XM5321347558"; #K_M

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

	#print "home= $home\n";
	#push(@ret_array,$home);
	while(my $line = <$file>){
		chomp($line);
		my ($line1,$line2) = split(/,/,$line);
		if(&remove_hex($home,$line1)){next;}
		push(@ret_array,$line1);

	}
	#print "m=@m\n";
	return ($home,\@ret_array);
}

sub ret_move_hash{
	my ($file)=@_;
	my %ret_hash=();
	#print "home= $home\n";
	while(my $line = <$file>){
		chomp($line);
		my ($line1,$line2) = split(/,/,$line);
		$ret_hash{$line1} = $line2;
	}
	#print "m=@m\n";
	return %ret_hash;
}


##ここから
#main関数　ファイル操作など


print "$user_name\n";
#出力ファイル名
#open(FP2, ">./auto_count_result/$user_name/merge/gn$prm-result_route_$user_name.txt") or die("cannot open the file");

if($idoubunkatu == 1){
open(FP2, ">./auto_count_result/$user_name/merge/gn$prm-result_route_$user_name$hexsize.txt") or die("cannot open the file");

}elsif($idoubunkatu == 2){
	open(FP2, ">./auto_count_result/$user_name/merge/bunkatu_gn$prm-result_route_$user_name$hexsize.txt") or die("cannot open the file");

}

	my $file = IO::File->new();
	#$file ->open("<../spot_label/$_/new_stay_seikai_$_.txt") or die("cannot open the file");
	#滞在Hex,頻度　のデータを入力　使うのは滞在Hex名のみです（ただし,この形式で入力しないと読み込むときに警告が連発します。気にしないのであるばOKです）
	#ここで入力したファイルにある滞在Hexと自宅間を移動経路で連結できます。つまり正解の滞在Hexを読み込むか抽出した滞在Hexを用いるかで単体評価と総合評価に用いる結果が得られます
	$file ->open("< ./spot_times/seikatutaizai/merge2_result_$user_name$hexsize.txt") or die("cannot open the file");
	

	my $file2 = IO::File->new();
	#移動Hex,頻度　の形式のファイル（頻度順にソートしておくこと） 滞在Hex抽出で用いたものと同じです
	#$file2 ->open("< ./move_times/idou/idou333_$user_name.txt") or die("cannot open the file");
	
if($idoubunkatu == 1){
$file2 ->open("< ./move_times/idou/idou_$user_name$hexsize.txt") or die("cannot open the file");


}elsif($idoubunkatu == 2){
	$file2 ->open("< ./move_times/idou/bunkatu_idou_$user_name$hexsize.txt") or die("cannot open the file");
}
	my $file3 = IO::File->new();
	#滞在Hex抽出で用いた　移動Hex,頻度　の形式のファイル　を入力してください
	#これがない場合,∞の探索に陥る場合があります
	$file3 ->open("< ./spot_times/merge/merge2_hex_spot_times_filter_$user_name$hexsize.txt") or die("cannot open the file");
	


	my ($home,$a) = &ret_spot_array($file);
	my @spot_data = @$a;
	my ($home,$b) = &ret_spot_array($file3);
	my @original_data = @$b;
	my $st;
	my $count = 0;
	my ($hash_ref,$array_ref);	
	my %move_hex = &ret_move_hash($file2);
	#$hexが滞在Hex
	foreach my $hex(@spot_data)
	{
		print "$hex\n";
		#↓二行は高速化のため。まぁなくても動くかな
		if($cut_spot{$hex}){print FP2 $hex."\n";print "skip\n";next;}
		&all_get_next($hex,@spot_data);
		my %count_hex=();
		my %move_data=();
		%move_data = %move_hex;
		my %culc_score=();
		my @q_hex;
		my %close_list=();
		print "$count end\n";
		my $d = &hex_dis($home,$hex);
		$st = $hex;
		$culc_score{$st} = {
			score =>0,
			before => $hex
		};
		my $flag = 0;
		my $score = 10;
		my $hash_num=0;
		my $new_hash_num = 0;
		while(1){
			$hash_num = keys %count_hex;
			my @next_zone = &get_all_next_zone($st);

			($_,$hash_ref,$array_ref) = &sort_hex($st,\%move_data,\@original_data,\%culc_score,\%close_list,$home,$d,\@next_zone);#,$second_hex);

			@q_hex = @$_;%culc_score = %$hash_ref;%close_list = %$array_ref;

			unless(@q_hex){last;}
			$st = shift(@q_hex);

			@next_zone=();
			if($culc_score{$st}->{score}>$score*$prm){ print "score_over\n";last;}
			if($home eq $st){
				%close_list = ();
				unless($flag){
				$score = $culc_score{$st}->{score};
				print "$score\n";
				#これをいれとかないと$scoreが0になった場合まずいことになるからいちお.高速化の処理をいれたからなくてもだいじょうぶかも。要検証
				if($score < 0.01){
					last;
				}
				$flag = 1;
				}
				while($hex ne $culc_score{$st}->{before}){
					$count_hex{$st} = 1;
					print FP2 $culc_score{$st}->{before}."\n";
					if($move_data{$culc_score{$st}->{before}}){
						$move_data{$culc_score{$st}->{before}}=$move_data{$culc_score{$st}->{before}}/2;
					}
					$st = $culc_score{$st}->{before};
				}
				%culc_score=();	
				$st = $hex;
				$culc_score{$st} = {
				score =>0,
				before => $hex
				};
				$count_hex{$hex} = 1;
				print FP2 $hex."\n";

			}


		}

	

		$count++;

	}
	 