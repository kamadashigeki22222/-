 #!/usr/bin/perl
use strict;
use warnings;
use XML::Simple;  
use Data::Dumper;  # Data構造表示用モジュールの読み込み
use LifelogEditor::GPXEdit;
use LifelogEditor::GeoUtil;

my $out;
my $out2;

print "user_name ->";
my $user_name = <STDIN>;
chomp($user_name);
my $newfile_fullpath = './gpxfile/'.$user_name.'/*.gpx';

open $out, ">", "./result/stay_$user_name.csv" || die "Error: OpenW: ";
open $out2, ">", "./result/move_$user_name.txt" || die "Error: OpenW: ";

while(my $filename = glob($newfile_fullpath)){
  print "$filename\n";
  #GPXファイルを緯度経度時間のハッシュに変換
  my @tracks = LifelogEditor::GeoUtil::load_gpxfile($filename);	#データ抽出

  # ハッシュから滞在と移動に分類されたハッシュ配列に
  my @item = LifelogEditor::GPXEdit::gpx_to_DBcollection(\@tracks);

  #print "--------------------------------\n";
  
  #csv形式で保存
  LifelogEditor::GeoUtil::save_csvfile($out, $out2, \@item);

}

close $out;
close $out2;
