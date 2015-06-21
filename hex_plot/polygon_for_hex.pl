#GeoHex by @sa2da (http://geogames.net) is licensed under Creative Commons BY-SA 2.1 Japan License.

use strict;
use warnings;

use lib qw/lib/;
use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);
#use Geo::Hex;
use Path::Class;
#use XML::LibXML;


#idoubunkatu 1 移動状態を分割せずにおこない，最後に滞在地を除去，2　移動状態に分割してからおこなう
#prm　1~15までのコストパラメータ
#jyoutai　1　滞在地　2　移動経路　3　生活圏の移動経路


    print "user_name ";
    my $user_name = <STDIN>;
     chomp($user_name);
    #print $username ." test\n";
    # $_ = <STDIN>;
    print "jyoutai 1 taizai 2 idou 3 seikatuido";
    my $jyoutai = <STDIN>;
     chomp($jyoutai);
    print "idoubunkatu ";
    my $idoubunkatu = <STDIN>;
    chomp($idoubunkatu);
    print "input paramater=>";
    my $prm = <STDIN>;
    chomp($prm);

    #Hexのサイズを変更
    print "input size=>";
    my $size = <STDIN>;
    chomp($size);



    #入力ファイル
    if ($jyoutai == 1) {
         open(FP,"< ../spot_times/merge/$user_name/merge2_hex_spot_times_$user_name$size.txt") or die("cannot open the file"); #input fiel name
         #open(FP,"< ../spot_times/code/new_hex_spot_times_kamada.txt") or die("cannot open the file"); #input fiel name
         #open(FP,"< ../spot_times/merge/merge2_hex_spot_times_filter_kamada.txt") or die("cannot open the file"); #input fiel name
        
    }elsif($jyoutai == 2){

        if($idoubunkatu == 1 ){
            open(FP,"< ../move_times/idou/$user_name/idou_$user_name$size.txt") or die("cannot open the file"); #input fiel name
            #open(FP,"< ../move_times/idou/test2.txt") or die("cannot open the file"); #input fiel name
        
        }else{
        
        if($idoubunkatu == 2){
         open(FP,"< ../move_times/idou/$user_name/bunkatu_idou_$user_name$size.txt") or die("cannot open the file"); #input fiel name
             }
        
            }
        
        

    }elsif($jyoutai == 3){
         if($idoubunkatu == 1 ){
          open(FP,"< ../auto_count_result/$user_name/merge/gn$prm/gn$prm-result_route_$user_name$size.txt") or die("cannot open the file"); #input fiel name
               
    }else{
         if($idoubunkatu == 2){
         open(FP,"< ../auto_count_result/$user_name/merge/gn$prm/bunkatu_gn$prm-result_route_$user_name$size.txt") or die("cannot open the file"); #input fiel name
            }
        }
   
}

    #my $input = '../hex_count/auto_count_result/'.$_.'/new/gn3-result_route_'.$_.'.txt';
    #my $input = '"../spot_times/merge2_hex_spot_times_filter_$_.txt"';
    #my $input = '../hex_count/move_times/hex_move_times_more3_'.$_.'.txt';
    #my $input = '../spot_label/'.$_.'/new_kasai_3_hex.txt';
    
    #open(FP,"< ../spot_times/merge/merge6_hex_spot_times_filter_$username.txt") or die("cannot open the file"); #input fiel name
    #open(FP,"< ../move_times/idou/idou333_$username.txt") or die("cannot open the file"); #input fiel name
    #open(FP,"< ../move_times/linear/li2000_kamada.txt") or die("cannot open the file"); #input fiel name
    #open(FP,"< ../auto_count_result/kamada/merge/test_gn15-result_route_$username.txt") or die("cannot open the file"); #input fiel name
    

    #my $input = '../hex_count/auto_count_result/s_t_m_t_hayashi_merge.csv';
    #open(FP,"<../hex_count/spot_times/merge2_result_saito.txt") or die("cannot open the file"); #input fiel name
    print "running\n";
    my $geohex = Geo::Hex->new( version => 3 );

    #open(FH,"> kml/m_gn1-result_route_$username.kml") or die("cannot open the file"); #input fiel name
    #open(FH,"> kml/m_gn9-result_$username.kml") or die("cannot open the file"); #input fiel name
    #open(FH,"> kml/m_gn15-result_$username.kml") or die("cannot open the file"); #input fiel name
    #open(FH,"> kml/seikatuidou2_$username.kml") or die("cannot open the file"); #input fiel name

 #出力ファイル

if ($jyoutai == 1) {
    #print "a";
         #print "$user_name ";
         open(FH,"> kml/$user_name/taizai/spot_$user_name$size.kml") or die("cannot open the file"); #input fiel name
         
    }elsif($jyoutai == 2){

        if($idoubunkatu == 1 ){
            open(FH,"> kml/$user_name/idou/idou_$user_name$size.kml") or die("cannot open the file"); #input fiel name
             #open(FH,"> kml/test2.kml") or die("cannot open the file"); #input fiel name
        
        
        }else{
        
        if($idoubunkatu == 2){
         open(FH,"> kml/$user_name/idou/bunkatu_idou_$user_name$size.kml") or die("cannot open the file"); #input fiel name
             }
        
            }      
    }elsif($jyoutai == 3){
         if($idoubunkatu == 1 ){
          open(FH,"> kml/$user_name/seikatu/gn$prm/gn$prm-result_route_$user_name$size.kml") or die("cannot open the file"); #input fiel name
               
    }else{
         if($idoubunkatu == 2){
          open(FH,"> kml/$user_name/seikatu/gn$prm/bunkatu_gn$prm-result_route_$user_name$size.kml") or die("cannot open the file"); #input fiel name
            }
        }
}

    print FH '<?xml version="1.0" encoding="UTF-8"?>
    <kml xmlns="http://www.opengis.net/kml/2.2">
      <Document>
        <name>kamada</name>
        <description>kamada</description>';


    #my $dom = XML::LibXML::Document->new('1.0', 'utf-8');
    #my $kml = $dom->createElement('kml');
    #$kml->setAttribute('xmlns' => 'http://earth.google.com/kml/2.0');
    #$dom->setDocumentElement( $kml );

    #my $document = $dom->createElement('Document');
    #$kml->appendChild( $document );

    #my $folder = $dom->createElement('Folder');
    #$document->appendChild( $folder );

    my $map = create_map();
    print $map ." map\n";

    for my $code (keys(%{ $map })) {   
        # my $placemark = create_placemark_node( dom => $dom, name => $code, description => $code, %{$map->{$code}} );
        my $placemark = create_placemark_node( name => $code, description => $code, %{$map->{$code}} );
        # $folder->appendChild($placemark) if $placemark;
        print "name $code , desc $code, " . %{$map->{$code}} . "\n";
    }
    # #出力ファイル
    # my $file = file('kml', 'm_gn4-result_route_'.$_.'.kml');

    print FH ' </Document>
    </kml>
    ';

    # my $fh = $file->openw or die $!;
    # $fh->print($dom->toString( 1 ));
    # $fh->close;


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


sub create_placemark_node {
    my %attr = @_;

   # print "<flag>" . $attr{flag} ."\n";

    print FH "\n<Placemark>\n";

#      my $dom = $attr{dom};
#      my $placemark = $dom->createElement('Placemark');

#     my $name = $dom->createElement('name');
#     $name->appendText($attr{name});
#     $placemark->appendChild( $name );

    print FH "<name>" . $attr{name} . "</name>\n";
#     my $desc = $dom->createElement('description');
#     $desc->appendText($attr{description});
#     $placemark->appendChild( $desc );

#     my $polygon = $dom->createElement('Polygon');
#     $placemark->appendChild( $polygon );
    print FH "<Style> \n   <LineStyle> \n       <linecolor>ff000000</linecolor> \n       <width>3</width> \n   </LineStyle> \n";
    
#     my $style = $dom->createElement('Style');
#     $placemark->appendChild( $style );
#     my $linestyle = $dom->createElement('LineStyle');
#     my $linecolor = $dom->createElement('color');
#      my $colorcode = "ff000000";
#     $linecolor -> appendText($colorcode);
#     $linestyle->appendChild( $linecolor );
#      my $linewidth = $dom->createElement('width');
#      my $w = "3";
#      $linewidth -> appendText($w);
#      $linestyle->appendChild( $linewidth );
      
#     $style->appendChild( $linestyle );
#     my $polystyle = $dom->createElement('PolyStyle');
#     $style->appendChild( $polystyle );

    print FH "   <PolyStyle> \n     <color>";

#     #print "count = $attr{count}\n";
     my $red = getR($attr{count});
     my $green = getG($attr{count});
     my $blue = getB($attr{count});
# #ヒートマップ
     my $colorcode =$blue.$green.$red."FF";

     #$colorcode = "ff000000";

     print FH "$colorcode";

     print FH "</color> \n   </PolyStyle> \n</Style>\n";

#     my $polycolor = $dom->createElement('color');
#     $polycolor -> appendText($colorcode);
#     $polystyle->appendChild( $polycolor );

#     my $polyoutline = $dom->createElement('outline');
#     $polyoutline -> appendText("0");
#     $style->appendChild( $polyoutline );

#     my $extrude = $dom->createElement('extrude');
#     $extrude->appendText(1);
#     $polygon->appendChild($extrude);

#     my $altitudeMode = $dom->createElement('altitudeMode');
#     $altitudeMode->appendText('relativeToGround');
#     $polygon->appendChild($altitudeMode);

#     my $outerBoundaryIs = $dom->createElement('outerBoundaryIs');
#     $polygon->appendChild( $outerBoundaryIs );

#     my $linearRing = $dom->createElement('LinearRing');
#     $outerBoundaryIs->appendChild( $linearRing );

print FH "<Polygon>
   <extrude>1</extrude>
   <altitudeMode>relativeToGround</altitudeMode>
   <outerBoundaryIs><LinearRing><coordinates>
                ";

#     my $coordinates = $dom->createElement('coordinates');
    my $str;
    my $coords = $attr{hex}->hex_coords();
    return if ( ( $coords->[4]->[0] > 85.051128514 ) or ( $coords->[1]->[0] < -85.051128514 ) );

    for my $coord (@{ $coords }) {
        #if($attr{flag} == 1){
           #$str .= sprintf "%f,%f,%d\n", $coord->[1], $coord->[0], 30;
        #}else{
        	#高さ
           $str .= sprintf "%f,%f,%d\n", $coord->[1], $coord->[0], $attr{count}*10;
        #}
        print FH $coord->[1].",".  $coord->[0].",". ($attr{count}*10)."\n";
    }
    print FH @{$coords}[0]->[1].",".  @{$coords}[0]->[0].",". ($attr{count}*10)."\n";

    print FH "   </coordinates></LinearRing></outerBoundaryIs>
</Polygon>
</Placemark>";

    # $coordinates->appendText($str);
    # $linearRing->appendChild( $coordinates );

    # $placemark;
}


sub create_map {
    my $map = {};
    while(my $line = <FP>){     
        chomp($line);  

        my($code,$flag) = split(/,/,$line);

        my ($lat,$lng)= geohex2latlng($code);
        #hex size
        #my $zone = $geohex->to_zone($lat,$lng,10); 
         my $zone = $geohex->to_zone($lat,$lng,$size); 


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