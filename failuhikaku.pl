#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;  # Data構造表示用モジュールの読み込み
use File::Path;
use Math::Trig;
use Path::Class;
use Term::ReadLine;
my @hexr;
my @hexB;
#my $time;

open(FP1, "FileA.txt") or die("cannot open the file");

while(my $line = readline(FP1)){
	(my $hex,my $time) = split(/,/,$line);

	push @hexr, $hex;

	#print "$hex \n"

}

print "@hexr \n";
close(Fp1);

open(FP2, "FileB.txt") or die("cannot open the file");

while(my $line = readline(FP2)){
	(my $hex,my $time) = split(/,/,$line);

	push @hexB, $hex;

	#print "$hex \n"

}

print "@hexB \n";
close(FP2);

my @correct;
my @wrong;
my $flag = 0;
foreach my $hex (@hexr){

	# 探索
	foreach my $hex_B (@hexB){
		if ($hex eq $hex_B){
			push @correct, $hex;
			$flag = 1; # 見つかった
			last; # ループを抜ける処理

		}
	}

	if ($flag == 0){
		push @wrong, $hex;
	}
	$flag = 0;
}

my $c_num = $#correct + 1;
my $w_num = $#wrong + 1;

print "correct: num:$c_num\n";
print "wrong: num:$w_num\n";






