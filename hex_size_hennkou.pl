use strict;
use warnings;

use lib qw/lib/;
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
#use Geo::Hex;
use Path::Class;


    print "user_name ";
    my $user_name = <STDIN>;
     chomp($user_name);
     my $size = 10;
     my $user = "$user_name$size";



 print "idoubunkatu ";
    my $idoubunkatu = <STDIN>;
    chomp($idoubunkatu);
    print "input paramater=>";
    my $prm = <STDIN>;
    chomp($prm);
print "hexsize ";
   	my $level = <STDIN>;
    chomp($level);

my @line2;

        if($idoubunkatu == 1 ){
          open(FP,"< auto_count_result/$user_name/merge/gn$prm/gn$prm-result_route_$user.txt") or die("cannot open the file"); #input fiel name
               
    }else{
         if($idoubunkatu == 2){
         open(FP,"< auto_count_result/$user_name/merge/gn$prm/bunkatu_gn$prm-result_route_$user.txt") or die("cannot open the file"); #input fiel name
            }
        }
    
 
    if($idoubunkatu == 1 ){
          open(FH,"> hexsize/$user_name/gn$prm-result_route_$user_name$size.txt") or die("cannot open the file"); #input fiel name
               
    }else{
         if($idoubunkatu == 2){
          open(FH,"> hexsize/$user_name/bunkatu_gn$prm-result_route_$user_name$size.txt") or die("cannot open the file"); #input fiel name
            }
        }







while(my $line = <FP>){     
        chomp($line);  


   my $level2 = $level+2;

 #substr($line, 0, $level2);
 push @line2, substr($line, 0, $level2);
 	#print("$line2\n");
 }

#print("@line2\n");

my %count = ();
#my $i;
@line2 = grep(!$count{$_}++, @line2);
#print @line2 ;
my $kai = @line2;
my $i = 0;

#print $kai;
while ($i < $kai){

	#print $kai;
	print FH $line2[$i], "\n";

	$i ++;
}

