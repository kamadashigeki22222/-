use strict;
use warnings;
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);

sub ret_data_hash1{
	my ($file)=@_;
	my %ret_hash;
	while(my $line = <$file>){
		chomp($line);
		$ret_hash{$line} = 1;
		
	}
	return %ret_hash;
}



$_ =<STDIN>;
chomp($_);
my $file1 = IO::File->new();
my $input = './'.$_.'/new_stay_seikai_'.$_.'.txt';
$file1 ->open("<$input") or die("cannot open the file");
my $file2 = IO::File->new();
$input = '../hex_count/spot_times/merge2_result_'.$_.'.txt';
$file2 ->open("<$input") or die("cannot open the file");

my %seikai = ret_data_hash1($file1);
my $seikai_count;
my $all_count;
my $all_seikai = keys %seikai;
while(my $line = <$file2>){
	chomp($line);
	my ($line1,$line2) = split(/,/,$line);
	if(exists($seikai{$line1})){$seikai_count++;}
	$all_count++;
}

my $precision = $seikai_count/$all_count;
my $recall = $seikai_count/$all_seikai;

print "p = $precision, r = $recall\n";