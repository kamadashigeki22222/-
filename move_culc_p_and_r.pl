use strict;
use warnings;
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use Spreadsheet::WriteExcel;
use Excel::Writer::XLSX;       
#my $workbook = Excel::Writer::XLSX->new( 'm_hayashi_t_move_relation.xlsx' ); 
#my $worksheet = $workbook->add_worksheet();
sub ret_data_hash{
	my ($file)=@_;
	my %ret_hash;
	while(my $line = <$file>){
		chomp($line);
		#my ($line,$line2) = split(/,/,$line);  #stayの場合必要
		$ret_hash{$line} = 1;
		
	}
	return %ret_hash;
}
my $i =0;
my $name =<STDIN>;
chomp($name);
my $score =<STDIN>;
my $file = IO::File->new();
my $input = './'.$name.'/'.$name.'_moveline_seikai.txt';
$file ->open("<$input") or die("cannot open the file");
my $file2 = IO::File->new();
$input = './'.$name.'/new_'.$name.'_3_hex.txt';
$file2 ->open("<$input") or die("cannot open the file");
my $file3 = IO::File->new();
$input = './'.$name.'/ap_'.$name.'_3_hex.txt';
$file3 ->open("<$input") or die("cannot open the file");
my $file5 = IO::File->new();
$input = './'.$name.'/new_stay_seikai_'.$name.'.txt';
$file5 ->open("<$input") or die("cannot open the file");
chomp($score);
my %seikai1 = &ret_data_hash($file);
my %seikai2 = &ret_data_hash($file2);
#$_ = keys %seikai2;
my %seikai3 = &ret_data_hash($file3);
my %stay = &ret_data_hash($file5);

my %true_seikai = (%seikai1,%seikai2,%seikai3);
my $seikai_n = keys %true_seikai;
print "$seikai_n\n";
while($i < 15){
my $file4 = IO::File->new();
#$input = '../hex_count/auto_count_result/'.$name.'/new/gn'.$score.'-result_route_'.$name.'.txt';
$input = '../hex_count/auto_count_result/'.$name.'/merge/m_gn'.$score.'-result_route_'.$name.'.txt';
#$input = '../hex_count/move_times/hex_move_times_more_'.$name.'.txt';
print"$input\n";
$file4 ->open("<$input") or die("cannot open the file");
my %all_seikai=();
%all_seikai = %true_seikai;



my $count=0; 
my $count1=0; 
my %check=();
while(my $line = <$file4>){
	chomp($line);
	($_,$line) = split(/,/,$line);
	chomp($_);
	if($stay{$_}){next;}
	chomp($_);
	if(exists($all_seikai{$_})){
		if($all_seikai{$_}){
			$count++;$count1++;
			$all_seikai{$_} = 0;
		}
	}else{
		unless(exists($check{$_})){
		$count++;
		$check{$_} = 0;
		}
	}
}
print "$count,$count1\n";		 

my $precision = $count1/$count;
my $recall = $count1/$seikai_n;
print "p = $precision, r = $recall\n";
#$worksheet->write(1,$score,$precision);
#$worksheet->write(2,$score,$recall);
close($file4);
$i++;
$score++;
print "sc = $score\n";
}
