 #!/usr/bin/perl
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use Data::Dumper;  # Data構造表示用モジュールの読み込み
use strict;
use warnings;
use IO::File;
use List::Util qw(max);
require 'sub_get_next_zone_ver3.pl';

print "user_name ";
    my $user_name = <STDIN>;
     chomp($user_name);
   
    print "input paramater=>";
    my $prm = <STDIN>;
    chomp($prm);

    #Hexのサイズを変更
    print "input size=>";
    my $size = <STDIN>;
    chomp($size);

#範囲内のHex
our %ALL_HEX;
#待ち行列
our @Q_HEX;
#家のHexコード
our $HOME="XM5321347555"; #鎌田
# our $HOME="XM5321346873"; #林さん
# our $HOME="XM5321341673"; #笠井さん
#範囲の一番外側のHex
our $END_HEX;
#生活圏のHex
our %MOVE;
#ステップ数を格納する
our @STEP;
our $MAX_STEP;
#移動Hexの格納
sub move_data{
	my $code=$_;
	chomp($code);
	$MOVE{$code}=1;
	push(@STEP,hex_step($HOME,$code));#最大のステップステップ数を求めるためにステップ数を配列に格納
	
}	

#距離関数
sub distance{
	   my($lat_a, $lon_a, $lat_b, $lon_b) = @_;
           my $lat_sec = ($lat_a-$lat_b)*111263.283;
           my $lon_sec = ($lon_a-$lon_b)*91158.84;
           return sqrt(($lat_sec*$lat_sec)+($lon_sec*$lon_sec));
	}
#Hexを入力とする距離関数
sub hex_dis{
	my ($s,$t) = @_;
	my ($lat1,$lon1)=geohex2latlng($s);
	my ($lat2,$lon2)=geohex2latlng($t);
	return distance($lat1,$lon1,$lat2,$lon2);
}


#引数の値が大きいほうを返す
sub comp{
	my($a,$b)=@_;
	if($a>$b) {return $a;}
	else{ return $b;}
}	

#ステップ数を求める関数
sub hex_step{
	my($geo1,$geo2)=@_;
	
	#この関数は入力をHexコードとして、いろいろな値をもつハッシュのキーを返す
	#例えば{qw /lat}とかにすあれば経度が返ってくる。もちろん{qw /lat lon}とかにすれば経度緯度が返ってくる。複数を受け取る場合はもちろん配列で受け取ること！！
	#複数受け取った場合は配列の先頭から順番に格納される
	#下の例で@latllon={qw /lat lon}でうけとれば$latlon[0]=緯度　$latlon[1]=経度　みたいな感じ
	$_ = geohex2zone($geo1);
	
	my $x1=$_->{qw /x/ };
	my $y1=$_->{qw /y/ };
	$_ = geohex2zone($geo2);
	my $x2=$_->{qw /x/ };
	my $y2=$_->{qw /y/ };
	return comp(abs($x1-$x2),abs($y1-$y2));
}	

#ステップ数でフィルターをかける
sub step_filter{
	my @hex;
	while(my $code=shift(@_)){

		if(hex_step($code,$HOME)<=$MAX_STEP){
			push(@hex,$code);
		}
	}		

	return @hex;
}
#範囲内のHexを格納	
sub add2area{
	my @hex=@_;
	while(@hex){
		$_=shift(@hex);
		#一回追加したHexは待ち行列にいれたら駄目
		unless(exists($ALL_HEX{$_})){
			push(@Q_HEX,$_);
			$ALL_HEX{$_}=1;
			#範囲の一番外側のHexを記憶
			$END_HEX=$_;
		}	
	}
	


}


#生活圏の輪郭を抽出する
sub outside_filter{
	my $skip_count=0;
	my %exist;
	while(my $code=shift(@Q_HEX)){
		#生活圏の輪郭を抽出	
		unless(exists($MOVE{$code})){
			$ALL_HEX{$code}=0;
			#隣接とってステップでフィルター
			@_=next_zone($code);
			@_=step_filter(@_); 
   
			#さらにこっからめんどくさい条件分岐で無限ループにならんようにする。要するに探索済みのおんなじHexを何回も探索せーへんようにせいってことや
			while($_=shift(@_)){
				#まずは範囲内のHexか確かめて、そのHex探索済みじゃないかチェック
				if(exists($ALL_HEX{$_}) and ($ALL_HEX{$_}==1)){
					#さらにそのHexが待ち行列に追加されてないかチェック
					unless(exists($exist{$_})) {push @Q_HEX,$_;}
				}
				#待ち行列に追加したHexは忘れずに１を代入して追加済みとわかるようにする
				$exist{$_}=1;
			}
		} 

	}	
}

#生活圏のHexを取り除く。
sub move_filter{
	foreach my $_(keys(%MOVE)){
		$ALL_HEX{$_}=0;
	}
}	

sub get_next_zone{
	my $code=shift;
	my $step=hex_step($code,$HOME);
	if($step<=$MAX_STEP){
		if($step%2==0){
			@_=next_zone($code);
		}elsif(!@Q_HEX){
			@_=next_zone($code);
		}	
	}	
	return @_;		
	
}








	
#######################ここからスタート############################################
use Time::HiRes;  
my $start_time = Time::HiRes::time;  

#基本的に大文字の変数、配列、ハッシュはグローバル変数
#自宅のHexはそれぞれのレベルに合わせたコードをべた書きしてるから、随時書き換えること(13行目）



#入力ファイル読み込み
my $file = IO::File->new();
$file ->open("hexsize/$user_name/gn$prm/bunkatu_gn$prm-result_route_$user_name$size.txt") or die("cannot open the file");
#出力ファイル設定
#出力するのは穴のHex全部
open(FP, ">ana/$user_name/gn$prm/$prm-ana_$user_name$size.txt") or die("cannot open the file");



#自宅からの距離を範囲に設定するからスタートは自宅から
push(@Q_HEX,$HOME);
#生活圏のデータを読み込む
while($_=<$file>){
	move_data($_);
}	
#リストの最大値を返す
#use List::Util qw(max);が必要　ちなみに最小値の場合は　qw{min}
$MAX_STEP = max @STEP;
$MAX_STEP++;
my $skip_count=0;
#範囲内のHexを読み込む
while(my $code=shift(@Q_HEX)){
	@_=get_next_zone($code);

	@_=step_filter(@_);
	add2area(@_);
}	
	
print "add OK\n"; #いちお進捗を標準出力でチェック。
#この初期化重要。待ち行列は２回、それぞれ別の用途で使うから念のためにクリア
@Q_HEX=();
#今度のスタートは範囲の一番外からスタート
push(@Q_HEX,$END_HEX);

outside_filter;	
print "outside OK\n"; #いちお進捗を標準出力でチェック。
move_filter;

print "move OK\n"; #いちお進捗を標準出力でチェック。


# ＊＊
our %nakami_HEX;

#最後に穴の部分だけ出力しましょう
foreach my $_(keys(%ALL_HEX)){
	if($ALL_HEX{$_}==1){
		print FP "$_\n";
		$nakami_HEX{$_}=1;
	}
}

my $count1 = 0;
# 中身をカウント
foreach my $hex (keys(%nakami_HEX)){
	
	
	if($nakami_HEX{$hex} == 0){next;}
	
	$nakami_HEX{$hex} = 0;
	
	my $count = 1;
	
	
	our @do_HEX;
	push @do_HEX, $hex;

	while(my $code=shift(@do_HEX)){
		@_=next_zone($code);
		@_=step_filter(@_); 
		

		while(my $hex2=shift(@_)){
			if(exists($nakami_HEX{$hex2}) and ($nakami_HEX{$hex2}==1)){
				$count++;
				push @do_HEX, $hex2;
				$nakami_HEX{$hex2} = 0;
			}
		}
		
	}
	$count1++;
	print "start ".$hex ."= $count \n";
	
}
print "$count1 \n";
#print FP "$END_HEX\n";	#外側から探索をはじめるときの開始地点を確認するためのやつ
#処理時間を計算して小数点以下を3桁に丸めて表示  
printf("%0.3f\n",Time::HiRes::time - $start_time);  

#count;
print "count1 OK\n";