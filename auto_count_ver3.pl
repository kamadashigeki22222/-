 #!/usr/bin/perl
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use Data::Dumper;  # Data構造表示用モジュールの読み込み
use File::Path;
use strict;
use warnings;
use Math::Trig;
use Path::Class;
use IO::File;

require 'perl_pl\nextzone\sub_get_next_zone.pl';
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
	   my $geohex_code = shift; 
	   my $level = 11;
	   my @code=();
	   my @next_hex=();
	   #print "test2_geo = $geohex_code\n";
	   my $element = substr($geohex_code,$level,1);
	   push(@next_hex,&up_left_zone($element,$level,$geohex_code,@code));
	   push(@next_hex,&up_zone($element,$level,$geohex_code,@code));
	   push(@next_hex,&up_right_zone($element,$level,$geohex_code,@code));
	   push(@next_hex,&down_right_zone($element,$level,$geohex_code,@code));
	   push(@next_hex,&down_zone($element,$level,$geohex_code,@code));
	   push(@next_hex,&down_left_zone($element,$level,$geohex_code,@code));
	   #print "@next_hex\n";
	  return @next_hex;
	 }
	 
#ターゲットHexにキョリが近い順にソート	 
sub sort_hex{
	my ($target_hex,@hex) = @_;
	my %key_hex_val_dis=();
	my @sort_hex;
	#my ($lat1,$lon1) = geohex2latlng($target_hex);
	while(@hex){
		my $st_code = shift(@hex); 	 	 
		#my ($lat2,$lon2) = geohex2latlng($st_code);
		#my $dis = &distance($lat1,$lon1,$lat2,$lon2);
		my $dis= &hex_dis($target_hex,$st_code);
		$key_hex_val_dis{$st_code} = $dis;
	}
	foreach my $geohex (sort {$key_hex_val_dis{$a} <=> $key_hex_val_dis{$b}}(keys %key_hex_val_dis)) {
		push(@sort_hex,$geohex);
	}	 
	return @sort_hex;
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
=cut
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

#Hex間の距離が元のキョリの2倍になれば終了合図を返す
sub dis_filter{
	my ($d,$s,$t) = @_;
	my $d2 = &hex_dis($s,$t);
	if(($d*2) < $d2) {return 1;}	
	return 0;
}

#Hex間の距離が20km以上は除外
sub remove_hex{
	my ($s,$t) = @_;
	my $dis = &hex_dis($s,$t);
	if($dis > 20000){return 1;}
	return 0;	
}

#待ちリストの作成
#1.隣接Hex取得
#2.ターゲットとキョリが近い順にHexをソート
#3.すでに探索済みのHexを削除（省くと∞ループ）
#4.現在の待ちリストに先頭に新たなリスト（現在探索Hexの隣接Hex）を結合
#どのHexから探索するか逐次的に変更する手法
###################################################
sub make_q_array{
	my ($s,$t,$array_a,$array_b,$array_c,$array_d) = @_;
	my @new_array=();
	@new_array = &get_all_next_zone($t);
	@new_array = &sort_hex($s,@new_array);
	@new_array = &a_exist_b(\@$array_c,\@$array_d,\@new_array);
	@new_array = &make_unique_array(\@$array_a,\@new_array);
	unshift @$array_b,@new_array;
	return @$array_b;
}
####################################################
	
sub ret_move_array{
	my ($file,$n,$m)=@_;
	my $count=0;
	#print "file=$file\n";
	unless(<$file>){
		print "move_over\n";
		return 0;}
	my $line = <$file>;
	chomp($line);
	while($count<$n){
		if(defined $line){
		
		#print "lile=$line\n";
		my ($line1,$line2) = split(/,/,$line);
		push(@$m,$line1);
		$count++;
		$line = <$file>;
		}
		else{
			return 0;
		}
	}
	#print "m=@m\n";
	return $m;
}

sub ret_spot_array{
	my ($file)=@_;
	my @ret_array1=();
	my @ret_array2=();
	my $line=<$file>;
	chomp($line);
	my($home,$count1)=split(/,/,$line);
	
	#print "home= $home\n";
	push(@ret_array1,$home);
	while($line = <$file>){
		chomp($line);
		my ($line1,$line2) = split(/,/,$line);
		push(@ret_array1,$line1);
		if(&remove_hex($home,$line1)){next;}
		push(@ret_array2,$line1);
	}
	#print "m=@m\n";
	return ($home,\@ret_array1,\@ret_array2);
}

##　ここから##
#このソースはいわゆる滞在地を抽出するためのもの
#ただし,滞在Hexと移動Hex数の関係をグラフ化できるものであり
#抽出自体はその結果から手動でデータを作る必要がある
#滞在Hex,頻度　の形式のファイル（頻度順にソートしておくこと）
my $file = IO::File->new();
#移動Hex,頻度　の形式のファイル（頻度順にソートしておくこと）
my $file2 = IO::File->new();
my $file3 = IO::File->new();
$file ->open("<./spot_times/merge2_new_hex_spot_times_kasai_filter.txt") or die("cannot open the file");
$file2->open("./move_times/new_hex_move_times_kasai_ver2.txt",'r') or die("cannot open the file");
#$file3->open("../spot_label/stay_kasai_seikai.txt",'r') or die("cannot open the file");
#open(FP3, ">./auto_count_result/result_kasai_test.txt") or die("cannot open the file");
open(FP4, ">./auto_count_result/s_t_m_t_kasai.csv") or die("cannot open the file");
#open(FP5, ">test6_2.txt") or die("cannot open the file");
my @seikai;
=put
while(my $line = <$file3>){
	chomp($line);
	push(@seikai,$line);
}
=cut
my @move_data=();
my @spot_data=();
my @tmp_data=();
my @tmp_hex=();
my @already_check;
my ($home,$a,$b)= &ret_spot_array($file);

#自宅Hexを入力
#上から順にUserA,B,C
#自宅Hexは手動で探しました
	#my $home = "XM5321346873"; #H_K
	my $home = "XM5321341673"; #K_A
	#my $home = "XM5321308285"; #S_R
@spot_data = @$a;
@tmp_data = @$b;
#print FP3 "$home,1\n";
print "@spot_data\n";
my $k = 0;
my $max_loop=0;
my $fin_goal;
$_=&ret_move_array($file2,100,\@move_data);
@move_data = @$_;
my $n=100;
my @already_write=();
my $flag = 1;
mugen:while(1){
	if($flag){
	unless($fin_goal = shift(@tmp_data)){last mugen;}
	}
	#unless(grep {$_ eq $fin_goal} @seikai){next;}
	@already_check=();
	my $goal = $fin_goal;	
	my @q_hex=();
	my $dis = &hex_dis($home,$goal);

	while($goal ne $home){
		@q_hex = &make_q_array($home,$goal,\@already_check,\@q_hex,\@move_data,\@spot_data);
		@q_hex = &sort_hex($home,@q_hex);
	
		unless(@q_hex){
			@tmp_hex=();
			$flag=0;
			last;
		}
		$goal = shift(@q_hex);
		push(@already_check,$goal);
		if(&dis_filter($dis,$home,$goal)){
			@tmp_hex=();
			$flag=0;
			last;
		}
		if($home eq $goal){
			push(@tmp_hex,$goal);
			$flag=1;
			last;
		}	
		#print "@q_hex\n";
		#<STDIN>;
		push(@tmp_hex,$goal);	
	}
	if($flag == 1){
		#@tmp_hex = &make_unique_array(\@already_write,\@tmp_hex);
		#unshift @already_write,@tmp_hex;
		#while(@tmp_hex){
		#	my $true_hex = shift(@tmp_hex);
	#		if(grep {$_ eq $true_hex} @spot_data){
		#	print FP3 "$true_hex,1\n";
			#print FP5 "$true_hex,1\n";
		#	}else{
		#	print FP3 "$true_hex,0\n";
			#print FP5 "$true_hex,0\n";
		#	}		
		#}
		#print FP3 "$fin_goal,1\n";
		#print FP5 "$fin_goal,1\n";
		print FP4 "$k,$n\n";
		print "$k end\n";
		$k++;
		$max_loop=0;
		#unless($fin_goal = shift(@tmp_data)){last;}
		#push(@spot_data,$line);
	}else{  
		$flag = 0;
		print "n = $n\n";
		if($_=&ret_move_array($file2,100,\@move_data)){
		@move_data = @$_;	
		$n = $n+100;
		#ここのコメントをはずせば,移動Hex数が大きく上がるところまで番号（$k）がFP4に抽出される
		#その後,$file0 に読み込んだファイルに対して手動で$k番目までの滞在Hexをコピペすれば
		#この手法で滞在Hexを抽出できる
		#詳しくはプログラムの手順参照
		#自動化するならばがんばって
		#コメントをはずさなければ,滞在Hex数と移動Hex数との関係をグラフにするためのファイルが作成できる(FP4　を参照)
		#$max_loop++;
		#	if($max_loop > 100){
		#		last mugen;
		#	}
		}else{	
			$flag=1;
			next;
		}
	}
	
}

 print "end!\n";
