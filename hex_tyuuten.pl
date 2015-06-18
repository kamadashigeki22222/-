 use strict;
use warnings;

use lib qw/lib/;
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
#use Geo::Hex;
use Path::Class;


 open(FP,"< result.txt") or die("cannot open the file"); #input fiel name

open(FH,"> test.txt") or die("cannot open the file"); #input fiel name

my $geohex = Geo::Hex->new( version => 3 );

my $map = create_map();
 for my $code (keys(%{ $map })) {   
        # my $placemark = create_placemark_node( dom => $dom, name => $code, description => $code, %{$map->{$code}} );
        my $placemark = create_placemark_node( name => $code, description => $code, %{$map->{$code}} );
        # $folder->appendChild($placemark) if $placemark;
        #print "name $code , desc $code, " . %{$map->{$code}} . "\n"

}


sub create_placemark_node {
    my %attr = @_;

 	my $str;
    my $coords = $attr{hex}->hex_coords();

    # $coords->[ヘックスの番号]->[0=緯度，1=経度]

    return if ( ( $coords->[4]->[0] > 85.051128514 ) or ( $coords->[1]->[0] < -85.051128514 ) );

    for my $coord (@{ $coords }) {
        #if($attr{flag} == 1){
           #$str .= sprintf "%f,%f,%d\n", $coord->[1], $coord->[0], 30;
        #}else{
        	#高さ
           $str .= sprintf "%f,%f,%d\n", $coord->[1], $coord->[0], $attr{count}*10;
        #}
        #print FH $coord->[1].",".  $coord->[0]."\n";

    }
    #print FH @{$coords}[0]->[1].",".  @{$coords}[0]->[0]."\n";

    my $lat0 = @{$coords}[1]->[0]+0;
    my $lon0 = @{$coords}[1]->[1]+0;

    my $lat3 = @{$coords}[4]->[0]+0;
    my $lon3 = @{$coords}[4]->[1]+0;

    print FH "-------\n";
    print FH $lat0. "," . $lon0 . "\n";
    print FH $lat3. "," . $lon3 . "\n";
    print FH (($lat0 + $lat3)/2) . "," . (($lon0 + $lon3) /2) . "\n";

    }


    sub create_map {
    my $map = {};
    while(my $line = <FP>){     
        chomp($line);  

        my($code,$flag) = split(/,/,$line);

        my ($lat,$lng)= geohex2latlng($code);
        #hex size
        my $zone = $geohex->to_zone($lat,$lng,10); 
        # my $zone = $geohex->to_zone($lat,$lng,$size); 


        unless ( $map->{$zone->code} ) {
            $map->{$zone->code} = {
                hex => $zone,
                count => 1,
                flag => $flag
            };
            # print "$map->{$zone->code}->{count}";
        }
        else {
            $map->{$zone->code}->{count}++;
            # print "$map->{$zone->code}->{count}";
        }
    #}
   }
    $map;

}