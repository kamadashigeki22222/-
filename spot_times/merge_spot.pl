#merge
#とりあえず頻度順に並び替えた滞在Hex群のファイルをぶちこめ
use strict;
use warnings;
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
require 'sub_get_next_zone_ver3.pl';

our %geohex;
our %close;
our %already;
print "user_name ";
my $user_name = <STDIN>;
chomp($user_name);
#47行目のファイル名をを決める際に使用
print "input size=>";
my $size = <STDIN>;
chomp($size);



my $file = IO::File->new();
my $input = 'code/new_hex_spot_times_'.$user_name.''.$size.'.txt';


#my $input = ' code/new_hex_spot_times_kamada.txt';
$file ->open("<$input") or die("cannot open the file");
sub get_all_next_zone{
	   my ($geohex_code,$cont) = @_; 
	   my @next_hex=();
	   my @next_zone=();
           @next_hex = &next_zone($geohex_code);
           foreach $_(@next_hex){
              if(a_in_hash($_)){unless(exists$close{$_}){push(@next_zone,$_);$cont+=$geohex{$_};}}
              $close{$_} = 1;
          }
	   
	   #print "@next_hex\n";
	  return ($cont,@next_zone);
	 }
	  
sub a_in_hash{
 my ($a) = shift;
 if(exists($geohex{$a})){return 1;}
 else{return 0;}
}

#output
open(FP2, "> merge/merge2_hex_spot_times_filter_$user_name$size.txt") or die("cannot open the file");

my @geo=();
 
while($_ = <$file>){
	chomp($_);
	my ($hex,$times) = split(/,/,$_);
	$geohex{$hex} = $times;
	push(@geo,$hex);
}

foreach $_(@geo){
	if(exists($already{$_})){next;}

  my $count = $geohex{$_};
  my $count2 = $geohex{$_};
  my @next_hex=();	
  push(@next_hex,$_);
  my @all_hex=();
  push(@all_hex,$_);
  $close{$_}=1;
  while(@next_hex){
    $_ = shift(@next_hex);
    ($count,@_) = &get_all_next_zone($_,$count);
    push @next_hex,@_;
    push @all_hex,@_;
    $_ = @all_hex;
	
  }
	
   foreach $_(@all_hex){
         #print FP2 "$_,$count2\n"; merge ver
         $already{$_} = $count;
   }
   %close=();
 }
 
 	foreach  $_ (sort {$already{$b}<=> $already{$a}}(keys %already)) {
              print FP2 "$_,$already{$_}\n"; #merge2 ver
	}