#GeoHex by @sa2da (http://geogames.net) is licensed under Creative Commons BY-SA 2.1 Japan License.

use strict;
use warnings;

use lib qw/lib/;

use Geo::Hex;
use Path::Class;
use XML::LibXML;

open(FP,"hayashi_all.txt") or die("cannot open the file"); #input fiel name
print "running\n";
my $geohex = Geo::Hex->new( version => 3 );

my $dom = XML::LibXML::Document->new('1.0', 'utf-8');
my $kml = $dom->createElement('kml');
$kml->setAttribute('xmlns' => 'http://earth.google.com/kml/2.0');
$dom->setDocumentElement( $kml );

my $document = $dom->createElement('Document');
$kml->appendChild( $document );

my $folder = $dom->createElement('Folder');
$document->appendChild( $folder );

my $map = create_map();

for my $code (keys(%{ $map })) {
    my $placemark = create_placemark_node( dom => $dom, name => $code, description => $code, %{$map->{$code}} );
    $folder->appendChild($placemark) if $placemark;
}

my $file = file('kml', 'hayashi_all-height_red.kml');
my $fh = $file->openw or die $!;
$fh->print($dom->toString( 1 ));
$fh->close;
print "success!!\n";
=put
sub getR{
        my ($i) = @_;
        $i = $i*10;    
        if($i> 255){
         $i = 255;
        }
        my $ret;
	if($i < 128){
		$ret = 0;
	}elsif($i > 127 && $i < 191){
		$ret = ($i-127)*4;
	}elsif($i > 190){
		$ret = 255;
	}
	
        $ret = sprintf "%02x", $ret;
        #print "R = $ret\n";
	return $ret;
}

sub getG{
    
        my ($i) = @_;
        $i = $i*10;     
        if($i> 255){
         $i = 255;
        }
        my $ret;
	if($i >= 64 && $i <= 191){
		$ret = 255;
	}elsif($i < 64){
		$ret =  $i * 4;
	}else{
		$ret = 256-($i-191)*4;
	}
        $ret = sprintf "%02x", $ret;
        #print "R = $ret\n";
	return $ret;
}

sub getB{
    
        my ($i) = @_;
        $i = $i*10;
        if($i> 255){
         $i = 255;
        }
        
        my $ret;
	if($i <= 64){
		$ret = 255;
	}elsif($i > 64 && $i < 127){
		$ret = 255-($i-64)*4;
	}elsif($i >= 127){
		$ret = 0;
	}
        $ret = sprintf "%02x", $ret;
        #print "R = $ret\n";	
	return $ret;

}
=cut



sub create_placemark_node {
    my %attr = @_;
    my $dom = $attr{dom};

    my $placemark = $dom->createElement('Placemark');

    my $name = $dom->createElement('name');
    $name->appendText($attr{name});
    $placemark->appendChild( $name );

    my $desc = $dom->createElement('description');
    $desc->appendText($attr{description});
    $placemark->appendChild( $desc );

    my $polygon = $dom->createElement('Polygon');
    $placemark->appendChild( $polygon );
    
    my $style = $dom->createElement('Style');
    $placemark->appendChild( $style );

    my $polystyle = $dom->createElement('PolyStyle');
    $style->appendChild( $polystyle );



    #print "count = $attr{count}\n";
    #my $red = getR($attr{count});
    #my $green = getG($attr{count});
    #my $blue = getB($attr{count});
    #print "R = $red\n";
     #   print "B = $blue\n";
      #      print "G = $green\n";
    #my $colorcode = "ff".$blue.$green.$red;
    #my $colorcode = "ff0000FF";
   
    my $colorcode;
    if($attr{count} == 1){
        $attr{count} = 20;
        $colorcode = "ff00FFFF";
    }elsif($attr{count} == 2){
        $attr{count} = 30;
        $colorcode = "ff00EEFF";
    }elsif($attr{count }==3){
         $attr{count} = 50;
        $colorcode = "ff00AAFF";
    }elsif($attr{count} < 5){
        $colorcode = "ff0099FF";
        $attr{count} = 70;
    }elsif($attr{count} < 10){
        $colorcode = "ff0088FF";
        $attr{count}=100;
    }elsif($attr{count} < 20){
        $colorcode = "ff0066FF";
        $attr{count} = 140;
    }elsif($attr{count} < 30){
        $colorcode = "ff0044FF";
        $attr{count} = 180;
    }elsif($attr{count} < 40){
        $colorcode = "ff0022FF";
        $attr{count} = 200;
    }else{
        $colorcode = "ff0000FF";
        $attr{count} = 250;
    }
    $colorcode = "ff0000FF";
    my $polycolor = $dom->createElement('color');
    $polycolor -> appendText($colorcode);
    $polystyle->appendChild( $polycolor );

    my $polyoutline = $dom->createElement('outline');
    $polyoutline -> appendText(0);
    $style->appendChild( $polyoutline );

    my $extrude = $dom->createElement('extrude');
    $extrude->appendText(1);
    $polygon->appendChild($extrude);

    my $altitudeMode = $dom->createElement('altitudeMode');
    $altitudeMode->appendText('relativeToGround');
    $polygon->appendChild($altitudeMode);

    my $outerBoundaryIs = $dom->createElement('outerBoundaryIs');
    $polygon->appendChild( $outerBoundaryIs );

    my $linearRing = $dom->createElement('LinearRing');
    $outerBoundaryIs->appendChild( $linearRing );

    my $coordinates = $dom->createElement('coordinates');
    my $str;
    my $coords = $attr{hex}->hex_coords();
    return if ( ( $coords->[4]->[0] > 85.051128514 ) or ( $coords->[1]->[0] < -85.051128514 ) );

    for my $coord (@{ $coords }) {
    
        $str .= sprintf "%f,%f,%d\n", $coord->[1], $coord->[0], ($attr{count});
    }

    $coordinates->appendText($str);
    $linearRing->appendChild( $coordinates );

    $placemark;
}

sub create_map {
    my @logdata;
    my $logdata_num = 0;
    my $map = {};
    while(my $line = <FP>){     
          chomp($line);     
          my @time_lat_lon = split(/,/,$line);
             $logdata[$logdata_num][0] = $time_lat_lon[0];
             $logdata[$logdata_num][1] = $time_lat_lon[1];
             $logdata[$logdata_num][2] = $time_lat_lon[2];
             $logdata_num++;
      }
      
    #my $teng = HexTweetMap::Models->get('teng');
    #my @tweets = $teng->search_by_sql(q{select * from tweet});

    #for my $tweet (@tweets) {
    for(my $i = 0; $i < $logdata_num; $i++){
       my $lat = $logdata[$i][1];
       my $lng = $logdata[$i][2];
        my $zone = $geohex->to_zone($lat,$lng,10); 

        unless ( $map->{$zone->code} ) {
            $map->{$zone->code} = {
                hex => $zone,
                count => 1,
            };
        }
        else {
            $map->{$zone->code}->{count}++;
        }
    #}
}
    $map;

}