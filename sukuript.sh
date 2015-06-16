#!/bin/csh

#idoubunkatu 1 移動状態を分割せずにおこない，最後に滞在地を除去，2　移動状態に分割してからおこなう
#prm　1~15までのコストパラメータ

read -p "username: " name
read -p "idoubunkatu: " idoubunkatu
read -p "paramater: " prm
read -p "Hexsize: " size


#export $name 
export user_name="$name" 


#perl -e 'print "$ENV{hoge}";'



#滞在
#笠井プログラムnew_dwell.pl start
printf "________________________________________________________________\n"

printf "new_dwell.pl start\n"
printf "input  gpxfile\n"
cd kasai_program

echo $user_name |perl new_dwell.pl 

printf "output  stay_$name.csv  move_$user_name.csv \n"
printf "new_dwell.pl end\n"
printf "________________________________________________________________\n"




#カウントcode_count_times.pl
printf "________________________________________________________________\n"
printf "code_count_times.pl start\n"
printf "input  stay_$user_name.csv\n"
cd ..
cd spot_times

echo -e "$user_name\n$size\n" |perl code_count_times.pl 

printf "output  new_hex_spot_times_$user_name.txt\n"
printf "code_count_times.pl  end\n"
printf "________________________________________________________________\n"






#マージmerge_spot.pl
printf "________________________________________________________________\n"
printf "merge_spot.pl start\n"
printf "input  new_hex_spot_times_$user_name.txt\n"


echo -e "$user_name\n$size\n" |perl merge_spot.pl 

printf "output  merge2_hex_spot_times_filter_$user_name.txt\n"
printf "merge_spot.pl  end\n"
printf "________________________________________________________________\n"





#滞在kml
printf "________________________________________________________________\n"
printf "polygon_for_hex.pl start\n"
printf "input  merge2_hex_spot_times_filter_$user_name.txt\n"
cd ..
cd hex_plot
 
echo -e "$user_name\n1\n1\n$prm\n$size\n" | perl polygon_for_hex.pl  


printf "output  spot_$user_name.kml\n"
printf "polygon_for_hex.pl   end\n"
printf "________________________________________________________________\n"





if test $idoubunkatu -eq 1 ; then
#移動
#すべてのGPXデータconvertGM2TK-ver2
printf "________________________________________________________________\n"
printf "convertGM2TK-ver2\n"
printf "input  gpxfile\n"
cd ..

echo $user_name | perl convertGM2TK_ver2.pl 


printf "output  GM2TKfile0.txt\n"
printf "convertGM2TK-ver2  end\n"
printf "________________________________________________________________\n"
fi




#直線補間linear_interpolation_v3.pl
printf "________________________________________________________________\n"
printf "linear_interpolation_v5.pl start\n"
printf "input  GM2TKfile0.txt move_$user_name.csv\n"

 
echo -e "$user_name\n$idoubunkatu\n$size\n" | perl linear_interpolation_v5.pl 


printf "output li_$user_name.txt   bunkatu_li_$user_name.txt\n"
printf "linear_interpolation_v5.pl  end\n"
printf "________________________________________________________________\n"




#移動カウントhex_move_times_count_ver2.pl
printf "________________________________________________________________\n"
printf "hex_move_times_count_ver2.pl start\n"
printf "input  li_$user_name.txt   bunkatu_li_$user_name.txt\n"
cd move_times

 
echo -e "$user_name\n$idoubunkatu\n$size\n20000\n " | perl hex_move_times_count_ver2.pl 


printf "output idou_$user_name.txt    bunkatu_idou_$user_name.txt\n"
printf "hex_move_times_count_ver2  end\n"
printf "________________________________________________________________\n"



#移動kml
printf "________________________________________________________________\n"
printf "polygon_for_hex.pl start\n"
printf "input  merge2_hex_spot_times_filter_$user_name.txt\n"
cd ..
cd hex_plot
 
#echo -e "$user_name\n 2\n $idoubunkatu\n $prm\n $size\n" | perl polygon_for_hex.pl  
 echo -e "$user_name\n2\n$idoubunkatu\n$prm\n$size\n" | perl polygon_for_hex.pl  

printf "output  spot_$user_name.kml\n"
printf "polygon_for_hex.pl   end\n"
printf "________________________________________________________________\n"



#生活圏移動
printf "________________________________________________________________\n"
printf "route_edit_ver3.pl start\n"
printf "input idou_$user_name.txt    bunkatu_idou_$user_name.txt\n"
#cd move_times
cd ..



echo -e "$user_name\n$idoubunkatu\n$prm\n$size\n" | perl route_edit_ver3.pl 


printf "output gn$prm-result_route_$user_name.txt        bunkatu_gn$prm-result_route_$user_name.txt\n"
printf "route_edit_ver3 end\n"
printf "________________________________________________________________\n"




#生活移動kml
printf "________________________________________________________________\n"
printf "polygon_for_hex.pl start\n"
printf "input  merge2_hex_spot_times_filter_$user_name.txt\n"
#cd ..
cd hex_plot
 
echo -e "$user_name\n3\n$idoubunkatu\n$prm\n$size\n" | perl polygon_for_hex.pl  


printf "output  spot_$user_name.kml\n"
printf "polygon_for_hex.pl   end\n"
printf "________________________________________________________________\n"