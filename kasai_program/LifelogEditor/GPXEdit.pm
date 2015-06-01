#!/usr/bin/perl
#
# Editing GPX
#
# gpx_to_DBcollection　
# 引き数：($self, $user_name, $hashList)
# 返り値：MongoDB用のコレクション(JSON)
#
# 引き数のハッシュリスト例
# [{time => "2014-01-01T10:10:10", lat => 34.684967, lon => 133.921780} ...]
#
# 返却コレクション例
# ・滞在
# [{address => "岡山県岡山市北区津島中１丁目", place => "岡山大学", st_time => 1389541000,
#	st_time_UNIX => "2014-01-12T15:00:00", ed_time => 1389551000, ed_time_UNIX => "2014-01-12T18:00:00"
#	dwell_time => 9000, loc_ave => [133.921, 34.684], taskType => "その他"
#	loc_detail => [[time => 1389541000, time_UNIX => 2014-01-12T15:00:00, loc => [133.9216, 34.6849]] ...]} ...]
# ・移動
#　[{st_time => 1389541000, st_time_UNIX => "2014-01-12T15:00:00", 
#	ed_time => 1389551000, ed_time_UNIX => "2014-01-12T18:00:00",
#	loc_detail => [[time => 1389541000, time_UNIX => 2014-01-12T15:00:00, loc => [133.9216, 34.6849]] ...]} ...]
#
#
# Copyright (c) 2013 Akinori Kasai, ABELAB, Okayama University
#
package LifelogEditor::GPXEdit;


use strict;
use warnings;

use utf8;
use JSON;
use Time::Piece;
use DateTime;
use Math::Trig qw/pi deg2rad rad2deg/;

########################      GLOBAL      ########################

my $gpx_Border_SPS = 0.5;		# 指定メートル/秒以上であれば「移動」に分類
my $gpx_Border_Dis = 250;		# （おおまかな分類）滞在リストの中で指定メートル以上離れたものは別の滞在地
my $gpx_Border_DisMin = 50;		# （細かな分類）
my $gpx_Border_Time = 300;		# 指定秒以上経過しているものを「滞在」とする
my $gpx_Border_Move = 1800;		# 指定秒以上経過した移動は別の移動に分類
my $gpx_Border_OutTime = 32; 	# この値以上の移動は信用が薄いとして削除
my $gpx_Border_StopToMove = 10;	# 同じ滞在地でも指定個数以上の移動があれば別の滞在地にする
my $gpx_Border_StayMoveDis = 500;	# 点の消失を考慮して

my $gpx_Detail_Cut = 10;	# 滞在や移動の詳細情報を何分の１にするか
my $gpx_Detail_Max = 10;	# 最大詳細を何件表示するか

##################################################################

# GPXデータを受け取り、MongoDB用のcollectionに分ける
sub gpx_to_DBcollection{
	my $hashList = shift;
	my $self = "";
	my $user_name = "";

	## 滞在と移動のリストに分ける
	(my $stayList, my $moveList) = divide_stay_move($hashList);
	# print "DEBUG divide_stay_move COMPLETE\n";
	
	## 滞在中の飛び値を除去する
	($stayList, $moveList) = remove_outliers($stayList, $moveList);
	# print "DEBUG remove_outliers COMPLETE\n";
	
	## 滞在リストから一定時間以上のまとまったリストに
	(my $stopPointList, $moveList) = stay_to_stop($self, $user_name, $stayList, $moveList);
	# print "DEBUG stay_to_stop COMPLETE\n";
	
	## 一定時間のリストと移動リストからコレクション用のリストに
	my $collectionList = join_stop_move($stopPointList, $moveList);
	# print "DEBUG join_stop_move COMPLETE\n";

	## 仕上げ
	$collectionList = confirm_list($collectionList);
	# print "DEBUG confirm_list COMPLETE\n";

	## くっつけ
	#$collectionList = confirm_list2($self, $user_name, $collectionList);
	#print "DEBUG confirm_list2 COMPLETE\n";
	
	## テスト用編集無しコレクション + 仮フィルター
	# my ($aveList, $list) = test_filter_gpx($hashList);
	# my $newList = test_filter2_gpx($aveList, $list);
	# my $collectionList = test_noedit_gpx($aveList);
	# my $collectionList = test_noedit_gpx($hashList);
	
	# Listが0個だった時用の暫定対応
	unless(ref($collectionList) eq "ARRAY") {
		my @tesArray = ();
		return @tesArray;
	}
	if (scalar(@$collectionList) == 0){
		my @tesArray = ();
		$collectionList = @tesArray; 
	}
	return @$collectionList;
}


## ２点間速度から滞在リストと移動リストに分ける
## その際、時間はエポック秒に変換する
sub divide_stay_move{

	my $hashList = shift;

	my @stayList = ();
	my @moveList = ();
	
	my $src_time;		# 点の時間
	my $target_time;	# １つ先の点の時間
	my $dwell_time;		# 二点間の時間
	my $ptp_dis;		# 二点間の距離
	my $stay_flag = 0;	# 滞在中のフラグ 0=移動　1=滞在
	my $stay_lon = 0;
	my $stay_lat = 0;

	# リストなし
	if(scalar(@$hashList) == 0){
		return (\@stayList, \@moveList);
	}
	# １つだけのリスト
	elsif(scalar(@$hashList) == 1){
		push(@moveList, $$hashList[0]);
		return (\@stayList, \@moveList);
	}

	$src_time = Time::Piece->strptime($$hashList[0]->{"time"}, '%Y-%m-%dT%T');

	for(my $loop = 0; $loop < scalar(@$hashList)-1; $loop++){

		$target_time = Time::Piece->strptime($$hashList[$loop+1]->{"time"}, '%Y-%m-%dT%T');
		$dwell_time = $target_time-$src_time;
		if($dwell_time < 0){
			print $dwell_time . " $target_time $src_time\n";
			next;
		}
		$$hashList[$loop]->{"time"} = $src_time->epoch;
		$$hashList[$loop]->{"time_UNIX"} = $src_time->datetime;
		# 距離計算
		$ptp_dis = calc_distance($$hashList[$loop]->{"lon"}, $$hashList[$loop]->{"lat"}, 
									$$hashList[$loop+1]->{"lon"}, $$hashList[$loop+1]->{"lat"});
		my $SPS = ($ptp_dis != 0) ? $ptp_dis/$dwell_time : 0;


		# 次の点との速度がボーダーより小さい時は「滞在」
		# ただし，移動に移る直前も「滞在」に追加し、フラグを「移動」へ
		if($SPS <= $gpx_Border_SPS || $stay_flag == 1){
			push(@stayList, $$hashList[$loop]);
			$stay_flag = 1;
			if($SPS <= $gpx_Border_SPS){
				$stay_lon = $$hashList[$loop]->{"lon"};
				$stay_lat = $$hashList[$loop]->{"lat"};
			}
			else{
				$stay_flag = 0;
			}
		}
		# 次の点との速度がボーダーより大きい場合は「移動」
		# ただし、信用のある値gpx_Border_OutTime以下の場合だけ
		# 信用無くて　$gpx_Border_Dis　以内は滞在
		else{
			if($stay_lon != 0){
				my $ptp_dis2 = calc_distance($stay_lon, $stay_lat, 
									$$hashList[$loop]->{"lon"}, $$hashList[$loop]->{"lat"});
				if($ptp_dis2 < $gpx_Border_Dis){
					$dwell_time = 100000;
					$ptp_dis = 0;
				}
			}
			if($dwell_time <= $gpx_Border_OutTime){
				push(@moveList, $$hashList[$loop]);
			}
			elsif($ptp_dis < $gpx_Border_Dis){
				push(@stayList, $$hashList[$loop]);
			}
		}

		$src_time = $target_time;	# 次の点へ
	}

	# 最後の点
	$$hashList[scalar(@$hashList)-1]->{"time"} = $src_time->epoch;
	$$hashList[scalar(@$hashList)-1]->{"time_UNIX"} = $src_time->datetime;
	if($stay_flag == 1){ push(@stayList, $$hashList[scalar(@$hashList)-1]); }
	else{ push(@moveList, $$hashList[scalar(@$hashList)-1]); }
	
	return (\@stayList, \@moveList);
}


# 同じ滞在中の移動(飛び値)を削除する
sub remove_outliers{
	my $stList = shift;
	my $mvList = shift;
	
	# リストが空だった場合
	if(!@$stList || !@$mvList){
		return ($stList, $mvList);
	}

	my $src_time;		# A点の時間
	my $tar_time;		# B点の時間
	my $src_lat;		# A点の緯度
	my $src_lon;		# A点の経度
	my $tar_lat;		# B点の緯度
	my $tar_lon;		# B点の経度
	my $ptp_dis;		# A-B間の距離
	
	my $moveIndex = 0;		# 移動リストの見ている点
	my $moveSpotCount = 0;	# 滞在点間にあった移動点（同じ場所に２回滞在した場合への考慮）

	$src_time = $$stList[0]->{'time'};
	$src_lat = $$stList[0]->{'lat'};
	$src_lon = $$stList[0]->{'lon'};
	
	for(my $loop = 0; $loop < scalar(@$stList)-1; $loop++){
	
		$tar_lat = $$stList[$loop+1]->{"lat"};
		$tar_lon = $$stList[$loop+1]->{"lon"};

		$ptp_dis = calc_distance($src_lon, $src_lat, $tar_lon, $tar_lat);	# 距離計算
	
		# 同じ滞在地の場合
		if($ptp_dis < $gpx_Border_Dis){
			$tar_time = $$stList[$loop+1]->{'time'};	

			# 現在見ている滞在まで移動リストを進める	
			if($moveIndex >= $#$mvList){last;}
			while($$mvList[$moveIndex]->{'time'} <= $src_time){
				$moveIndex++;
				if($moveIndex >= $#$mvList){last;}
			}

			# 滞在点間の移動数をカウント
			if($moveIndex >= $#$mvList){last;}
			while($$mvList[$moveIndex]->{'time'} <= $tar_time){
				$moveIndex++;
				$moveSpotCount++;
				if($moveIndex >= $#$mvList){last;}
			}
			
			# 飛び値を削除
			if($moveSpotCount < 5){
				for(my $i=$moveSpotCount; $i>0; $i--){
					splice @$mvList, $moveIndex-1, 1;
					$moveIndex--;
				}
			}
			$moveSpotCount = 0;
		}

		$src_time = $tar_time;
		$src_lon = $tar_lon;
		$src_lat = $tar_lat;
	}

	return ($stList, $mvList);
}


# 滞在リストを一定時間以上のリストにする
# 
sub stay_to_stop{
	my $self = shift;
	my $user_name = shift;
	my $stayList = shift;
	my $moveList = shift;
	
	## 滞在リストが無い場合
	if(!@$stayList){
		return $stayList;
	}
	
	my @retStayList;
	my @onePointHash;
	
	my $st_time = $$stayList[0]->{'time'};
	my $ed_time = $st_time;
	my $lat_ave = $$stayList[0]->{'lat'};
	my $lon_ave = $$stayList[0]->{'lon'};
	my $aveCount = 1;
	#my $

	my @locate = ["$$stayList[0]->{'lon'}","$$stayList[0]->{'lat'}"];
	my %hash = (time_UNIX => $$stayList[0]->{'time_UNIX'}, time => $$stayList[0]->{'time'},  loc=>@locate);
	push(@onePointHash, \%hash );
	
	for(my $loop = 1; $loop <= $#$stayList; $loop++){
		my $dis = calc_distance($lon_ave/$aveCount, $lat_ave/$aveCount, $$stayList[$loop]->{"lon"}, $$stayList[$loop]->{"lat"});
		
		# 距離が一定値以内(同じ滞在地)
		if($dis < $gpx_Border_Dis){
			$ed_time = $$stayList[$loop]->{'time'};
			$lat_ave = $lat_ave + $$stayList[$loop]->{'lat'};
			$lon_ave = $lon_ave + $$stayList[$loop]->{'lon'};
			$aveCount++;
			my @locate = ["$$stayList[$loop]->{'lon'}","$$stayList[$loop]->{'lat'}"];
			my %hash = (time_UNIX => $$stayList[$loop]->{'time_UNIX'}, time => $$stayList[$loop]->{'time'},  loc=>@locate);
			push(@onePointHash, \%hash);#gpx_Border_DisMin
		}
		else{
			# 滞在に分類するもの   ※lonとlatの順番に注意
			if($ed_time - $st_time > $gpx_Border_Time){
				my $lon = $lon_ave / $aveCount;
				my $lat = $lat_ave / $aveCount;
				my @loc_ave = [$lon, $lat];
				my @loc_detail = cutdown_gpx(\@onePointHash);	# 滞在地の詳細が多い場合は削る # 削らずに表示側で制御が望ましい
				my $dwell_time = $ed_time - $st_time;
				###
				#	ここで中心点の緯度経度から住所を取得する
				#	個人ごとの地名DBに登録(家、職場など)があればそちらを採用
				##
				my $address = "";#LifelogEditor::GeoCording::latlon2address($lat, $lon);
				my $place = "";
				my $taskType = "";
				my %stayHash = (st_time => $st_time,  ed_time=>$ed_time, dwell_time=>$dwell_time, loc_ave=>@loc_ave, loc_detail=>\@loc_detail, address=>$address, place=>$place, taskType=>$taskType);
				push(@retStayList, \%stayHash);

			}
			# 滞在でないものは移動に再分類
			else{
				for(my $loop2 = 0; $loop2 < scalar(@onePointHash); $loop2++){
					my %hash2 = (time_UNIX => $onePointHash[$loop2]->{'time_UNIX'}, time => $onePointHash[$loop2]->{'time'},
						lon => $onePointHash[$loop2]->{'loc'}[0], lat => $onePointHash[$loop2]->{'loc'}[1]);
					push(@$moveList, \%hash2);
				}

			}
			
			# 新しい滞在地を設定
			$st_time = $$stayList[$loop]->{'time'};
			$ed_time = $st_time;
			$lat_ave = $$stayList[$loop]->{'lat'};
			$lon_ave = $$stayList[$loop]->{'lon'};
			$aveCount = 1;
			@onePointHash = ();
			my @locate = ["$$stayList[$loop]->{'lon'}","$$stayList[$loop]->{'lat'}"];
			my %hash = (time_UNIX => $$stayList[$loop]->{'time_UNIX'}, time => $$stayList[$loop]->{'time'},  loc=>@locate);
			push(@onePointHash, \%hash );
		}
	}
	
	# ループ後の処理
	if($ed_time - $st_time > $gpx_Border_Time){
		my $lon = $lon_ave / $aveCount;
		my $lat = $lat_ave / $aveCount;
		my @loc_ave = [$lon, $lat];
		my @loc_detail = cutdown_gpx(\@onePointHash);
		my $dwell_time = $ed_time - $st_time;
		###
		#	ここで中心点の緯度経度から住所を取得する
		##
		my $address = "";#LifelogEditor::GeoCording::latlon2address($lat, $lon);
		my $place = "";
		my $taskType = "";
		my %hash = (st_time => $st_time,  ed_time=>$ed_time, dwell_time=>$dwell_time, loc_ave=>@loc_ave, loc_detail=>\@loc_detail, address=>$address, place=>$place, taskType=>$taskType);
		push(@retStayList, \%hash);
	}
	else{
		for(my $loop2 = 0; $loop2 < scalar(@onePointHash); $loop2++){
			my %hash2 = (time_UNIX => $onePointHash[$loop2]->{'time_UNIX'}, time => $onePointHash[$loop2]->{'time'},
				lon => $onePointHash[$loop2]->{'loc'}[0], lat => $onePointHash[$loop2]->{'loc'}[1]);
			push(@$moveList, \%hash2);
		}
	}
	
	@$moveList = sort {$a->{"time"} <=> $b->{"time"}} @$moveList;
	return (\@retStayList, $moveList);

}


# 滞在リストと移動リストの整合を取り、コレクション用のリストを作る
sub join_stop_move{
	my $stayList = shift;
	my $moveList = shift;

	my $stayListVal = 0;
	my $moveListVal = 0;
	if (ref($stayList) eq "ARRAY") {$stayListVal = scalar(@$stayList);}
	else{my @list = (); $stayList = \@list;}
	if (ref($moveList) eq "ARRAY") {$moveListVal = scalar(@$moveList);}
	else{my @list = (); $moveList = \@list;}

	my @retList;
	my $moveIndex=0;

	## どちらも無い場合 不具合
	if(!@$stayList && !@$moveList){
		#Qprint "dottimonai!!!!!\n"; 
		return;
	}
	
	## 滞在リストが無い場合
	if(!@$stayList || $stayListVal == 0){
		my $st_time = $$moveList[0]->{'time'};
		my $ed_time = $st_time;
		my @moveHash;
		
		for(my $loop = 0; $loop < $moveListVal; $loop++){
			#my $lat
			my @locate = ["$$moveList[$loop]->{'lon'}","$$moveList[$loop]->{'lat'}"];
			my %hash = (time_UNIX => $$moveList[$loop]->{'time_UNIX'}, time => $$moveList[$loop]->{'time'},  loc=>@locate);
			push(@moveHash, \%hash);
			$ed_time = $$moveList[$loop]->{'time'};
		}
		#my $loc_detail = cutdown_gpx(\@moveHash);
		my $st_UNIX = Time::Piece->strptime($st_time, '%s');
		my $ed_UNIX = Time::Piece->strptime($ed_time, '%s');
		my %hash = ('ed_time'=>$ed_time, 'st_time'=>$st_time, 'st_time_UNIX'=>$st_UNIX->datetime, 'ed_time_UNIX'=>$ed_UNIX->datetime, 'loc_detail'=>\@moveHash);
		push(@retList, \%hash);	# 移動データを入れる
		return \@retList;
	}

	## 移動リストが無い場合
	if(!@$moveList || $moveListVal == 0){
		for(my $loop = 0; $loop < $stayListVal; $loop++){
			my $st_UNIX = Time::Piece->strptime($$stayList[$loop]->{'st_time'}, '%s');
			my $ed_UNIX = Time::Piece->strptime($$stayList[$loop]->{'ed_time'}, '%s');
			$$stayList[$loop]->{'st_time_UNIX'} = $st_UNIX->datetime;
			$$stayList[$loop]->{'ed_time_UNIX'} = $ed_UNIX->datetime;
			push(@retList, @$stayList[$loop]);	# 滞在データを入れる
		}
		return \@retList;
	}
	
	# 滞在データごとに間に移動データがあるかどうか判別して入れる
	# その際、移動の中心点が滞在データに近い場合は飛び値として滞在に含める ※要検討
	# エポック秒から通常UNIX時間に戻したものも格納
	for(my $loop = 0; $loop < $stayListVal; $loop++){
		
		# 各滞在地より前に移動データがある場合
		if($moveIndex != $moveListVal){
			if($$moveList[$moveIndex]->{'time'} < $$stayList[$loop]->{'st_time'}){
				my $st_time = $$moveList[$moveIndex]->{'time'};
				my $ed_time = $st_time;
				my $lat_ave = 0;
				my $lon_ave = 0;
				my $aveCount = 0;
				my @moveHash;
				
				# 移動と滞在が近ければ繋げる
				if($loop != 0){
					my $dis_MoveStay = calc_distance($$moveList[$moveIndex]->{'lon'}, $$moveList[$moveIndex]->{'lat'}, $$stayList[$loop-1]->{"loc_ave"}[0], $$stayList[$loop-1]->{"loc_ave"}[1]);
					if($dis_MoveStay < $gpx_Border_Dis && ($$moveList[$moveIndex]->{'time'}-$$stayList[$loop-1]->{"st_time"}) < $gpx_Border_Move){
						my @locate = [$$stayList[$loop-1]->{"loc_ave"}[0], $$stayList[$loop-1]->{"loc_ave"}[1]];
						my %hash = (time_UNIX => $$stayList[$loop-1]->{'loc_detail'}[0]->{'time_UNIX'}, time => $$stayList[$loop-1]->{"st_time"},  loc=>@locate);
						push(@moveHash, \%hash);
					}
				}
				
				while($$moveList[$moveIndex]->{'time'} <= $$stayList[$loop]->{'st_time'}){
					if(($$moveList[$moveIndex]->{'time'} - $ed_time) > $gpx_Border_Move){

						my $st_UNIX = Time::Piece->strptime($st_time, '%s');
						my $ed_UNIX = Time::Piece->strptime($ed_time, '%s');
						my @mv = @moveHash;
						my %hash = ('ed_time'=>$ed_time, 'st_time'=>$st_time, 'st_time_UNIX'=>$st_UNIX->datetime, 'ed_time_UNIX'=>$ed_UNIX->datetime, 'loc_detail'=>\@mv);
						push(@retList, \%hash);
						$st_time = $$moveList[$moveIndex]->{'time'};
						$ed_time = $st_time;
						$lat_ave = 0;
						$lon_ave = 0;
						$aveCount = 0;
						@moveHash = ();
					}
					
					my @locate = ["$$moveList[$moveIndex]->{'lon'}","$$moveList[$moveIndex]->{'lat'}"];
					my %hash = (time_UNIX => $$moveList[$moveIndex]->{'time_UNIX'}, time => $$moveList[$moveIndex]->{'time'},  loc=>@locate);
					push(@moveHash, \%hash);
					$ed_time = $$moveList[$moveIndex]->{'time'};
					$lat_ave = $lat_ave + $$moveList[$moveIndex]->{'lat'};
					$lon_ave = $lon_ave + $$moveList[$moveIndex]->{'lon'};
					$aveCount++;
					$moveIndex++;

					if($moveIndex == $moveListVal){
						last;	# moveListの最後
					}
				}
				
				# 移動と滞在が近ければ繋げる
				my $dis_MoveStay = calc_distance($$moveList[$moveIndex-1]->{'lon'}, $$moveList[$moveIndex-1]->{'lat'}, $$stayList[$loop]->{"loc_ave"}[0], $$stayList[$loop]->{"loc_ave"}[1]);
				if($dis_MoveStay < $gpx_Border_Dis && ($$stayList[$loop]->{"st_time"}-$$moveList[$moveIndex-1]->{'time'}) < $gpx_Border_Move){
					my @locate = [$$stayList[$loop]->{"loc_ave"}[0], $$stayList[$loop]->{"loc_ave"}[1]];
					my %hash = (time_UNIX => $$stayList[$loop]->{"loc_detail"}[0]->{'time_UNIX'}, time => $$stayList[$loop]->{"st_time"},  loc=>@locate);
					push(@moveHash, \%hash);
				}
				
				# ※要検討　前後の滞在に含まれるか
				#my $dis_b = calc_distance($lon_ave/$aveCount, $lat_ave/$aveCount, $$stayList[$loop]->{"loc_ave"}[0], $$stayList[$loop]->{"loc_ave"}[1]);
				#my $dis_a = $gpx_Border_Dis + 1;
				#if($loop + 1 < $stayListVal){
				#	$dis_a = calc_distance($lon_ave/$aveCount, $lat_ave/$aveCount, $$stayList[$loop+1]->{"loc_ave"}[0], $$stayList[$loop+1]->{"loc_ave"}[1]);
				#}
				
				#if($dis_b > $gpx_Border_Dis && $dis_a > $gpx_Border_Dis){
					#print "move!\n";
					#my $loc_detail = cutdown_gpx(\@moveHash);
					my $st_UNIX = Time::Piece->strptime($st_time, '%s');
					my $ed_UNIX = Time::Piece->strptime($ed_time, '%s');
					my @mv2 = @moveHash;
					my %hash = ('ed_time'=>$ed_time, 'st_time'=>$st_time, 'st_time_UNIX'=>$st_UNIX->datetime, 'ed_time_UNIX'=>$ed_UNIX->datetime, 'loc_detail'=>\@mv2);
					push(@retList, \%hash);	# 移動データを入れる
				#}
				#else{
				#	print "stay!!\n";
				#}
			}
		}
		
		my $st_UNIX = Time::Piece->strptime($$stayList[$loop]->{'st_time'}, '%s');
		my $ed_UNIX = Time::Piece->strptime($$stayList[$loop]->{'ed_time'}, '%s');
		$$stayList[$loop]->{'st_time_UNIX'} = $st_UNIX->datetime;
		$$stayList[$loop]->{'ed_time_UNIX'} = $ed_UNIX->datetime;
		push(@retList, @$stayList[$loop]);	# 滞在データを入れる


		
	}
	
	# 残った移動データ
	if($moveIndex != $moveListVal){
		my $st_time = $$moveList[$moveIndex]->{'time'};
		my $ed_time = $st_time;
		my $lat_ave = 0;
		my $lon_ave = 0;
		my $aveCount = 0;
		my @moveHash;
		for(my $loop = $moveIndex; $loop <= $#$moveList; $loop++){
			# 時間経過が長ければ別の移動としてpush
			if(($$moveList[$loop]->{'time'} - $ed_time) > $gpx_Border_Move){
				my $st_UNIX = Time::Piece->strptime($st_time, '%s');
				my $ed_UNIX = Time::Piece->strptime($ed_time, '%s');
				my @mv3 = @moveHash;
				my %hash = ('ed_time'=>$ed_time, 'st_time'=>$st_time, 'st_time_UNIX'=>$st_UNIX->datetime, 'ed_time_UNIX'=>$ed_UNIX->datetime, 'loc_detail'=>\@mv3);
				push(@retList, \%hash);
				$st_time = $$moveList[$loop]->{'time'};
				$ed_time = $st_time;
				$lat_ave = 0;
				$lon_ave = 0;
				$aveCount = 0;
				@moveHash = ();
			}
			$lat_ave = $lat_ave + $$moveList[$moveIndex]->{'lat'};
			$lon_ave = $lon_ave + $$moveList[$moveIndex]->{'lon'};
			$aveCount++;
			my @locate = ["$$moveList[$loop]->{'lon'}","$$moveList[$loop]->{'lat'}"];
			my %hash = (time_UNIX => $$moveList[$loop]->{'time_UNIX'}, time => $$moveList[$loop]->{'time'},  loc=>@locate);
			push(@moveHash, \%hash);
			$ed_time = $$moveList[$loop]->{'time'};
		}
		
		# my $dis = calc_distance($lon_ave/$aveCount, $lat_ave/$aveCount, $$stayList[$#$stayList]->{"loc_ave"}[0], $$stayList[$#$stayList]->{"loc_ave"}[1]);
		# my $sam1 = $lon_ave/$aveCount;
		# my $sam2 = $lat_ave/$aveCount;
		# my $sam3 = $#$stayList;
		#if($dis > $gpx_Border_Dis){
			#print "move!! $dis  $sam1  $sam2  $sam3\n";
			#my @loc_detail = cutdown_gpx(\@moveHash);
			my $st_UNIX = Time::Piece->strptime($st_time, '%s');
			my $ed_UNIX = Time::Piece->strptime($ed_time, '%s');
			my %hash = ('ed_time'=>$ed_time, 'st_time'=>$st_time, 'st_time_UNIX'=>$st_UNIX->datetime, 'ed_time_UNIX'=>$ed_UNIX->datetime, 'loc_detail'=>\@moveHash);
			push(@retList, \%hash);	# 移動データを入れる
		#}else{
		#	print "stay!! $dis   $sam1  $sam2  $sam3\n";
		#}
	}
	
	return \@retList;
}

sub confirm_list{
	my $List = shift;

	unless(ref($List) eq "ARRAY") {print "no List"; return $List;}

	# 前後の移動とくっつける
	for(my $loop = 0; $loop < scalar(@$List); $loop++){
		if(defined($$List[$loop]->{'address'})){
			if($loop == 0 ){next;}
			if(!defined($$List[$loop-1]->{'address'})){
				my $move = $$List[$loop-1]->{'loc_detail'};
				my $moveSize = scalar(@$move)-1;
				my $ptp_dis = calc_distance($$List[$loop]->{"loc_ave"}[0], $$List[$loop]->{"loc_ave"}[1], 
											$$move[$moveSize]->{"loc"}[0]+0, $$move[$moveSize]->{"loc"}[1]+0);
				if($ptp_dis < $gpx_Border_StayMoveDis){
					$$List[$loop]->{'st_time'} = $$move[$moveSize]->{"time"};
					$$List[$loop]->{'st_time_UNIX'} = $$move[$moveSize]->{"time_UNIX"};
					$$List[$loop]->{'dwell_time'} = $$List[$loop]->{'ed_time'} - $$List[$loop]->{'st_time'};
				}
			}
			if($loop == (scalar(@$List)-1) ){next;}
			if(!defined($$List[$loop+1]->{'address'})){
				my $move = $$List[$loop+1]->{'loc_detail'};
				my $ptp_dis = calc_distance($$List[$loop]->{"loc_ave"}[0], $$List[$loop]->{"loc_ave"}[1], 
											$$move[0]->{"loc"}[0]+0, $$move[0]->{"loc"}[1]+0);
				if($ptp_dis < $gpx_Border_StayMoveDis){
					$$List[$loop]->{'ed_time'} = $$move[0]->{"time"};
					$$List[$loop]->{'ed_time_UNIX'} = $$move[0]->{"time_UNIX"};
					$$List[$loop]->{'dwell_time'} = $$List[$loop]->{'ed_time'} - $$List[$loop]->{'st_time'};
				}
			}
		}
		
	}

	# 短すぎる移動を削除
	for(my $loop = scalar(@$List)-1; 0 <= $loop; $loop--){
		if(!defined($$List[$loop]->{'address'})){
			my $time = $$List[$loop]->{'ed_time'} - $$List[$loop]->{'st_time'};
			if($time < 90){
				splice @$List, $loop, 1;
			}
		}
	}

	# 前後の滞在をくっつける
	my @del = ();
	for(my $loop = 0; $loop < scalar(@$List)-1; $loop++){
		if(defined($$List[$loop]->{'address'})){
			my $i = 1;
			while(defined($$List[$loop+$i]->{'address'})){
				#print  ($loop . ":" . $i). " : " .scalar(@$List) . "\n";
				my $ptp_dis = calc_distance($$List[$loop]->{"loc_ave"}[0], $$List[$loop]->{"loc_ave"}[1], 
												$$List[$loop+$i]->{"loc_ave"}[0], $$List[$loop+$i]->{"loc_ave"}[1]);
				if($ptp_dis < 50){
					$$List[$loop]->{'ed_time'} = $$List[$loop+$i]->{'ed_time'};
					$$List[$loop]->{'ed_time_UNIX'} = $$List[$loop+$i]->{"ed_time_UNIX"};
					$$List[$loop]->{'dwell_time'} = $$List[$loop]->{'ed_time'} - $$List[$loop]->{'st_time'};
					my @array = @$List[$loop+$i]->{'loc_detail'};
					my $size = scalar(@array);
					for(my $lp = 0; $lp < $size; $lp++){
						#print "$size $lp desu!\n";
						push $$List[$loop]->{'loc_detail'}, $$List[$loop+$i]->{'loc_detail'}[$lp];
					}
					#push $$List[$loop]->{'loc_detail'}, $$List[$loop+$i]->{'loc_detail'};
					push @del, ($loop+$i);
					$i++;
				}
				else{
					last;
				}
				
				if(($loop+$i) == scalar(@$List)){last;}
				#print "$i dayo\n";
			}
			#print "$i only\n";
		}
		#print  $loop. " , " .scalar(@$List) . "\n";
	}
	#print "lp2\n";
	for(my $loop = scalar(@$List)-1; 0 <= $loop; $loop--){
		foreach my $i (@del) {
		  if($i == $loop){
		  	splice @$List, $loop, 1;
		  	last;
		  }
		}

	}

	return $List;

}

sub confirm_list2{
	my $self = shift;
	my $user_name = shift;
	my $List = shift;

	unless(ref($List) eq "ARRAY") {print "no List"; return $List;}

	#電波消失のフォロー
	my @retList = ();
	my $time = $$List[0]->{"ed_time"};
	push @retList, $$List[0]; 
	for(my $loop = 1; $loop < scalar(@$List); $loop++){
		if($$List[$loop]->{"st_time"} - $time > $gpx_Border_Time){
			if(defined($$List[$loop-1]->{'address'})){
				$$List[$loop-1]->{'ed_time'} = $$List[$loop]->{"st_time"} - 1;
				my $ed_time = Time::Piece->strptime($$List[$loop]->{"st_time"} - 1, '%s');
				$$List[$loop-1]->{'ed_time_UNIX'} = $ed_time->datetime;
			}
			else{

				my $move = $$List[$loop-1]->{'loc_detail'};
				my $moveSize = scalar(@$move)-1;
				my $lon = $$move[$moveSize]->{"loc"}[0]+0; 
				my $lat = $$move[$moveSize]->{"loc"}[1]+0;
				my $address = "";

				my @loc_ave = [$lon, $lat];
				#my $place = LifelogEditor::MainDB::db_search_placeName($self, $user_name, $lon, $lat);
				#if(scalar(@$place) > 0){
				#	if($$place[0]->{'scope'}+0 < 300){
				#		$lon = $$place[0]->{'lon'};
				#		$lat = $$place[0]->{'lat'};
				#		$address = LifelogEditor::GeoCording::latlon2address($lat, $lon);
				#	}
				#	else{
				#		$address = LifelogEditor::GeoCording::latlon2address($lat, $lon);
				#	}
				#}
				#else{
				#	$address = LifelogEditor::GeoCording::latlon2address($lat, $lon);
				#}

				my @loc_detail = ();
				my @locate = [$lon, $lat];
				my $st_time = Time::Piece->strptime($time+1, '%s');
				my %hash = (time_UNIX => $st_time->datetime, time => $time+1,  loc=>@locate);
				push(@loc_detail, \%hash );

				my $ed_time = Time::Piece->strptime($$List[$loop]->{"st_time"} - 1, '%s');
				%hash = (time_UNIX => $ed_time->datetime, time => $$List[$loop]->{"st_time"}-1,  loc=>@locate);
				push(@loc_detail, \%hash );
				my $dwell_time = $ed_time - $st_time; 
				my %stayHash = (st_time => $st_time->epoch,  ed_time=>$ed_time->epoch, dwell_time=>$dwell_time, loc_ave=>@loc_ave,
									st_time_UNIX => $st_time->datetime, ed_time_UNIX => $ed_time->datetime, loc_detail=>\@loc_detail, address=>$address, place=>"", taskType=>"");
				push @retList, \%stayHash;

			}
		}
		push @retList, $$List[$loop];
		$time = $$List[$loop]->{"ed_time"};
	}

	return \@retList;
}


# 多すぎる地点データを表示用に減らす
# 最初と最後は残す
sub cutdown_gpx{
	my $hashList = shift;
	my $cutVal = $gpx_Detail_Cut;	# 何分の１にするか
	my $maxVal = $gpx_Detail_Max;	# 残す最大個数
	
	my $hashVal = scalar(@$hashList);
	
	# 2個以下にはしない
	if($hashVal <= 2){
		return @$hashList;
	}
	
	if($hashVal/$cutVal>$maxVal){
		$cutVal = int ($hashVal/$maxVal);
	}
	
	for(my $i=$hashVal-1;$i>1;$i--){
		if($i % $cutVal != 0){
			splice @$hashList, $i, 1;
		}
	}

	return @$hashList;
}



# 2点間の距離計算(メートル)
sub calc_distance {

	my ( $src_lng, $src_lat, $target_lng, $target_lat ) = @_;

	$src_lng    = deg2rad($src_lng);
	$src_lat    = deg2rad($src_lat);
	$target_lng = deg2rad($target_lng);
	$target_lat = deg2rad($target_lat);

	my $lat = abs($src_lat - $target_lat);
	my $lng = abs($src_lng - $target_lng);

	my $disp_lng = 6378137 * $lng * cos($src_lat);
	my $disp_lat = 6378137 * $lat;

	return sqrt(($disp_lng ** 2) + ($disp_lat ** 2));
}

# メートルをラジアンに
sub meter_to_rad{
	my $meter = shift;
	my $rad = 6378137;
	
	return ($meter / $rad);

}

sub test_filter_gpx{
	my $hashList = shift;

	my @aveList;

	# push @aveList, @$hashList[0];
	# push @aveList, @$hashList[1];

	my $val = scalar(@$hashList);

	#for(my $loop=3; $loop<$val-3; $loop++){
	#	my $lon = ($$hashList[$loop-2]->{'lon'}+$$hashList[$loop-1]->{'lon'}+$$hashList[$loop]->{'lon'}+$$hashList[$loop+1]->{'lon'}+$$hashList[$loop+2]->{'lon'})/5;
	#	my $lat = ($$hashList[$loop-2]->{'lat'}+$$hashList[$loop-1]->{'lat'}+$$hashList[$loop]->{'lat'}+$$hashList[$loop+1]->{'lat'}+$$hashList[$loop+2]->{'lat'})/5;
	#	my %hash = ('lon'=>$lon, 'lat'=>$lat, 'time'=>$$hashList[$loop]->{'time'});
	#	push @aveList, \%hash;
	#}

	# for(my $loop=1; $loop<$val-1; $loop++){
	# 	my $lon = ($$hashList[$loop-1]->{'lon'}+$$hashList[$loop]->{'lon'}+$$hashList[$loop+1]->{'lon'})/3;
	# 	my $lat = ($$hashList[$loop-1]->{'lat'}+$$hashList[$loop]->{'lat'}+$$hashList[$loop+1]->{'lat'})/3;
	# 	my %hash = ('lon'=>$lon, 'lat'=>$lat, 'time'=>$$hashList[$loop]->{'time'});
	# 	push @aveList, \%hash;
	# }

	for(my $loop=0; $loop<$val; $loop++){
		my $lon = $$hashList[$loop]->{'lon'};
		my $lat = $$hashList[$loop]->{'lat'};
		my $time = Time::Piece->strptime($$hashList[$loop]->{'time'}, '%Y-%m-%dT%T');
		my %hash = ('lon'=>$lon, 'lat'=>$lat, 'time'=>$time->epoch);
		push @aveList, \%hash;
	}


	#push @aveList, @$hashList[$val-2];
	# push @aveList, @$hashList[$val-1];

	return (\@aveList, $hashList);
}

sub test_filter2_gpx{
	my $aveList = shift;
	my $oldList = shift;
	
	my $border = 100;
	
	my %delList;

	my $val = scalar(@$aveList);

	for(my $loop=0; $loop<$val; $loop++){
		my $dis = calc_distance($$aveList[$loop]->{'lon'}, $$aveList[$loop]->{'lat'}, $$oldList[$loop]->{'lon'}, $$oldList[$loop]->{'lat'});
		if($dis > $border){
			$delList{"$loop"} = "true";
		}
		else{
			$delList{"$loop"} = "false";
		}
		my $time = Time::Piece->strptime($$aveList[$loop]->{'time'}, '%Y-%m-%dT%T');
		$$aveList[$loop]->{'time'} = $time->epoch;
	}
	
	for(my $loop=$val-1; $loop>=0; $loop--){
		if($delList{"$loop"} eq "true"){
			splice @$aveList, $loop, 1;
		}
	}

	return $aveList;
}


sub test_edit_gpx{
	my $hashList = shift;
	my @retList;
	my @moveHash;
	
	my $border = 100;
	
	my $st_time = $$hashList[0]->{'time'};
	my $ed_time = $st_time;
	
	
	for(my $loop = 0; $loop<scalar(@{$hashList}); $loop++){
	
		# my $time = Time::Piece->strptime(substr($$hashList[$loop]->{"time"},0,19), '%Y-%m-%dT%T');
		my @locate = ["$$hashList[$loop]->{'lon'}","$$hashList[$loop]->{'lat'}"];
		my %hash = ("time" => $$hashList[$loop]->{"time"},  "loc"=>@locate);
		push(@moveHash, \%hash);
		
		if($loop != scalar(@{$hashList})-1){
			my $dis = calc_distance($$hashList[$loop]->{'lon'}, $$hashList[$loop]->{'lat'}, $$hashList[$loop+1]->{'lon'}, $$hashList[$loop+1]->{'lat'});
			if($dis > $border){
				$ed_time = $$hashList[$loop]->{'time'};
				my $st_UNIX = Time::Piece->strptime($st_time, '%s');
				my $ed_UNIX = Time::Piece->strptime($st_time, '%s');
				my @mv = @moveHash;
				my %hash = ('ed_time'=>$ed_time, 'st_time'=>$st_time, 'st_time_UNIX'=>$st_UNIX->datetime, 'ed_time_UNIX'=>$ed_UNIX->datetime, 'loc_detail'=>\@mv);
				push(@retList, \%hash);
				@moveHash = ();
				$st_time = $$hashList[$loop+1]->{'time'};
			}
		
		}
		
	}
	
	if(@moveHash){
		$ed_time = $$hashList[scalar(@{$hashList})-1]->{'time'};
		
		my $st_UNIX = Time::Piece->strptime($st_time, '%s');
		my $ed_UNIX = Time::Piece->strptime($ed_time, '%s');
		
		my %hash = ('ed_time'=>$ed_time, 'st_time'=>$st_time, 'st_time_UNIX'=>$st_UNIX->datetime, 'ed_time_UNIX'=>$ed_UNIX->datetime, 'loc_detail'=>\@moveHash);
		push(@retList, \%hash);
		
	}
	
	return \@retList;
}

sub test_noedit_gpx{
	my $hashList = shift;
	my @retList;
	my @moveHash;
	
	my $ed_time;
	my $st_time;
	
	for(my $loop = 0; $loop<scalar(@{$hashList}); $loop++){
		my $time = Time::Piece->strptime($$hashList[$loop]->{"time"}, '%Y-%m-%dT%T');
		my @locate = ["$$hashList[$loop]->{'lon'}","$$hashList[$loop]->{'lat'}"];
		my %hash = ("time" => $time->epoch,  "loc"=>@locate);
		push(@moveHash, \%hash);
		if($loop == 0){
			$st_time = $time->epoch;
		}
		if($loop == scalar(@{$hashList})-1){
			$ed_time = $time->epoch;
		}
	}
	
	my $st_UNIX = Time::Piece->strptime($st_time, '%s');
	my $ed_UNIX = Time::Piece->strptime($ed_time, '%s');
	
	my %hash = ('ed_time'=>$ed_time, 'st_time'=>$st_time, 'st_time_UNIX'=>$st_UNIX->datetime, 'ed_time_UNIX'=>$ed_UNIX->datetime, 'loc_detail'=>\@moveHash);
	push(@retList, \%hash);
	
	return \@retList;
}

1;