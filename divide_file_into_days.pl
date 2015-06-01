use strict;
use warnings;
#ファイルを日付ごとに分割します
#ファイル形式例　↓↓
=put
2012-11-20T0:15:27Z,34.678958,133.906297
2012-11-20T0:15:57Z,34.678380,133.906760
2012-11-20T0:16:35Z,34.678400,133.906773
2012-11-20T0:17:05Z,34.678403,133.906793
2012-11-20T0:18:02Z,34.678500,133.906658
2012-11-20T0:18:47Z,34.678517,133.906725
2012-11-20T0:19:29Z,34.678485,133.906750
2012-11-20T0:20:00Z,34.678475,133.906658
2012-11-20T0:30:34Z,34.678175,133.907108
2012-11-20T0:34:42Z,34.678182,133.907092
2012-11-20T0:35:29Z,34.678637,133.906532
2012-11-20T0:35:59Z,34.678570,133.906563
2012-11-20T0:36:45Z,34.678488,133.906612
2012-11-20T0:37:15Z,34.678432,133.906757
2012-11-20T0:37:45Z,34.678240,133.906877
2012-11-20T0:38:15Z,34.678252,133.906862
2012-11-20T0:38:45Z,34.678298,133.906833
2012-11-20T0:40:49Z,34.678390,133.906822
2012-11-20T0:41:21Z,34.678317,133.906827
2012-11-20T0:41:53Z,34.678213,133.906853
=cut
#分割したファイルは（日付.txt）の名前で出力されます
#################標準時に直したデータを日付ごとに抽出#######################
      open(FP1,"file0.txt") or die("cannot open the file");  #ファイル名は任意に変更
      
      #open(FP2,">file$file_num.txt")or die("cannot open the file");
      my @year_month_day;
      my @day;
      my @time_lat_lon;
      my @one_is_h_m_s;
      my $logdata_num=0;

      my @year;
      my @data;
       while(my $line = <FP1>){
          push(@data,$line);          
          @year_month_day=();

          chomp($line);
          @time_lat_lon = split(/,/,$line);
          @one_is_h_m_s = split(/T/,$time_lat_lon[0]);

          push(@year_month_day,split(/-/,$one_is_h_m_s[0]));
          push(@year,join("",@year_month_day));
          push(@day,$year_month_day[2]);
          $logdata_num++;
       }
       #print "test @day\n";
       #print "@data\n";
       my $top_data;
       print "year @year\n";
       my $file_name = shift(@year);
       open(FP2,">$file_name.txt")or die("cannot open the file");
       for(my $i = 0; $i < $logdata_num-1; $i++){
          if($day[$i]  == $day[$i+1]){
             my $top_data;
             $top_data = shift(@data);
             print FP2 "$top_data";
             shift(@year);
          }else{
              $top_data = shift(@data);
              print FP2 "$top_data";
              $file_name = shift(@year);
              open(FP2,">$file_name.txt")or die("cannot open the file");
          }
       }