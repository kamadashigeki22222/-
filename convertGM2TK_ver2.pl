#!/usr/bin/perl
use XML::Simple;  # XML::Simpleモジュールの読み込み
use Data::Dumper;  # Data構造表示用モジュールの読み込み
use strict;
use warnings;

#グリニッジ標準時から東京標準時に直す
   print "user_name＞";
   my $user_name = <STDIN>;
   chomp($user_name);
   # my $user_name = 'hayashi';

   my $dir_name = './gpxfile/'.$user_name.'/'; 
   my $search = $dir_name.'*.gpx';
##########if the year is leap year return 1. not leap year return 0####
sub isleap{
          my ($year) = @_;
          #print "$year\n";
          if(($year%4 == 0 && $year%100 != 0) || $year%400 == 0){return 1;}else{return 0;}
          
       }
###################################################
   print "run...\n";
   my $filenum = 0;
   open(FP,">./gpxfile/"."$user_name"."/result/GM2TKfile"."$filenum.txt");
   while(my $filename = glob($search)){
    my $rData = XMLin($filename); # XMLデータ読み込み
    my $rMember = $rData->{trk}->{trkseg}->{trkpt};
    my $rData_num = $#{$rData->{trk}->{trkseg}->{trkpt}};
    #print "$rData_num\n";
    #print Dumper($rData);
              
      
      for(my $i=0;$i<=$rData_num;$i++){
          my $data_i = $rMember->[$i];
             
          my @ymd_hms = split(/T/,$data_i->{"time"});
          my @ymd = split(/-/,$ymd_hms[0]);     # $ymd[0] is year, [1] is month, [2] is day
          my @hms = split(/:/,$ymd_hms[1]);    # $hms[0] is hour, [1] is minute, [2] is second
         if(($ymd[1] ne "") &&1<=$ymd[1] && $ymd[1]<=12 && 1<=$ymd[2] && $ymd[2]<=31 && 0<=$hms[0] && $hms[0]<=24 && 0<=$hms[1] && $hms[1]<=60){

          my $newyear = -1;
          my $newmonth = -1;
          my $newday = -1;

             
          my $newhour = $hms[0]+9;
          if($newhour >= 24){
             $newhour -= 24;
                  # print "$ymd[1],$ymd[2]\n";
             if(($ymd[1]==1 || $ymd[1]==3 || $ymd[1]==5 || $ymd[1]==7 || $ymd[1]==8 || $ymd[1]==10) && $ymd[2] == 31){
                             $newyear = $ymd[0];
                             $newmonth = $ymd[1]+1;
                             $newday = 1;
             }elsif(($ymd[1]==4 || $ymd[1]==6 || $ymd[1]==9 || $ymd[1]==11) && $ymd[2] == 30){
                             $newyear = $ymd[0];
                             $newmonth = $ymd[1]+1;
                             $newday = 1;
                             # print "$newyear,$newmonth,$newday\n";
             }elsif($ymd[1]==12 && $ymd[2] == 31){
                             $newyear = $ymd[0]+1;
                             $newmonth = 1;
                             $newday = 1;
             }elsif($ymd[1]==2 && $ymd[2] == 28){
                            my $leap = &isleap($ymd[0]);
                            if($leap == 1){
                                 $newyear = $ymd[0];
                                 $newmonth = $ymd[1];
                                 $newday = $ymd[2]+1;
                            }else{
                                 $newyear = $ymd[0];
                                 $newmonth = $ymd[1]+1;
                                 $newday = 1;
                            }
             }elsif($ymd[1]==2 && $ymd[2] == 29){
                             $newyear = $ymd[0];
                             $newmonth = $ymd[1]+1;
                             $newday = 1;
             }else{
                             $newyear = $ymd[0];
                             $newmonth = $ymd[1];
                             $newday = $ymd[2]+1;
             }
 
    }else{
                             $newyear = $ymd[0];
                             $newmonth = $ymd[1];
                             $newday = $ymd[2];
}
my $lat = $data_i->{"lat"};
my $lon = $data_i->{"lon"};
 $newmonth += 0;
 $newday += 0;
if((1 <= $newmonth) && ($newmonth <= 9)){$newmonth = "0$newmonth";}
if((1 <= $newday) && ($newday <= 9)){$newday = "0$newday";}
print FP "$newyear-$newmonth-$newday","T","$newhour:$hms[1]:$hms[2],$lat,$lon\n";                  
}#end of if(1<=$ymd[1] && $ymd[1]<=12 && 1<=$ymd[2] && $ymd[2]<=31)          
}
    

#$filenum++;
#print "$filenum\n";

}#end of while
print "end\n";  

