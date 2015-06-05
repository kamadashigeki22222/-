 #!/usr/bin/perl
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
use strict;
use warnings;
use File::Path;


sub count_hex{
	my ($file)=@_;
	my %count;
	my $level = 10;
	while(my $line = <$file>){
		chomp($line);
		my ($id,$st_time,$end_time,$lat,$lng,$time)=split(/,/,$line);
		my $code = latlng2geohex($lat,$lng,$level);
		if (exists($count{$code})){
				$count{$code} = $count{$code} + 1;
		} else{
				$count{$code}=1;
		}
	}
	return %count;
}


print "user_name ";
   	my $user_name = <STDIN>;
    chomp($user_name);



my $file = IO::File->new();
$file ->open("../kasai_program/result/stay_$user_name.csv") or die("cannot open the file");


open(FP1, "> code/new_hex_spot_times_$user_name.txt") or die("cannot open the file");

my %spot_hex = &count_hex($file);
foreach my $key (sort{$spot_hex{$b} <=> $spot_hex{$a}}keys %spot_hex){
    print FP1 "$key,$spot_hex{$key} \n";
}
