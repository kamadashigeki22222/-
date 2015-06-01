use Geo::Hex v => 3, qw(latlng2geohex geohex2latlng latlng2zone geohex2zone);


sub up_right_zone{
   my ($element,$level,$n,$geohex_code,@nextzone_element) = @_;
   my $c = 0;
   if($element eq '8'){
      unshift(@nextzone_element,'2');   
      $c = 1;
   }
   elsif($element eq '7'){
       unshift(@nextzone_element,'1');
      $c = 1;
   }
   elsif($element eq '6'){
       unshift(@nextzone_element,'0');
      $c = 1;
   }else{
      unshift(@nextzone_element,$element+3+'');
      my $num = @nextzone_element;
      my $new_code = substr($geohex_code,0,-$num);

   while(@nextzone_element != ()){
      $new_code = $new_code . shift(@nextzone_element);
   } 
    return $new_code; 
   }
   if($c == 1){
    $level --;
    my $tmp = substr($geohex_code,$level,1);
    &up_right_zone($tmp,$level,$n,$geohex_code,@nextzone_element);
 }
}

sub down_right_zone{
   my ($element,$level,$n,$geohex_code,@nextzone_element) = @_;

   my $c = 0;
   if($element eq '6'){
      unshift(@nextzone_element,'8');   
      $c = 1;
   }
   elsif($element eq '3'){
       unshift(@nextzone_element,'5');
      $c = 1;
   }
   elsif($element eq '0'){
       unshift(@nextzone_element,'2');
      $c = 1;
   }else{
      unshift(@nextzone_element,$element-1+'');
      my $num = @nextzone_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@nextzone_element != ()){
      $new_code = $new_code . shift(@nextzone_element);
   } 
      return $new_code; 
   }
   if($c == 1){
    $level --;
    my $tmp = substr($geohex_code,$level,1);
    &down_right_zone($tmp,$level,$n,$geohex_code,@nextzone_element);
 }
}

sub down_left_zone{
   my ($element,$level,$n,$geohex_code,@nextzone_element) = @_;

   my $c = 0;
   if($element eq '2'){
      unshift(@nextzone_element,'8');   
      $c = 1;
   }
   elsif($element eq '1'){
       unshift(@nextzone_element,'7');
      $c = 1;
   }
   elsif($element eq '0'){
       unshift(@nextzone_element,'6');
      $c = 1;
   }else{
      unshift(@nextzone_element,$element-3+'');
      my $num = @nextzone_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@nextzone_element != ()){
        $new_code = $new_code . shift(@nextzone_element);
      } 
      return $new_code; 
   }
   if($c == 1){
    $level --;
    my $tmp = substr($geohex_code,$level,1);
    &down_left_zone($tmp,$level,$n,$geohex_code,@nextzone_element);
 }
}

sub up_left_zone{
   my ($element,$level,$n,$geohex_code,@nextzone_element) = @_;
   my $c = 0;
   if($element eq '8'){
      unshift(@nextzone_element,'6');   
      $c = 1;
   }
   elsif($element eq '5'){
       unshift(@nextzone_element,'3');
      $c = 1;
   }
   elsif($element eq '2'){
       unshift(@nextzone_element,'0');
      $c = 1;
   }else{
      unshift(@nextzone_element,$element+1+'');
      my $num = @nextzone_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@nextzone_element != ()){
        $new_code = $new_code . shift(@nextzone_element);
      }  
      return $new_code; 
   }
   if($c == 1){
    $level --;
    my $tmp = substr($geohex_code,$level,1);
    &up_left_zone($tmp,$level,$n,$geohex_code,@nextzone_element);
 }
}


sub down_zone{
   my ($element,$level,$n,$geohex_code,@nextzone_element) = @_;

   if($element eq '6'){
      unshift(@nextzone_element,'5');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_right_zone($tmp,$level,$n,$geohex_code,@nextzone_element);  
   }
   elsif($element eq '3'){
      unshift(@nextzone_element,'2');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_right_zone($tmp,$level,$n,$geohex_code,@nextzone_element);  
   }
   elsif($element eq '2'){
      unshift(@nextzone_element,'7');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_left_zone($tmp,$level,$n,$geohex_code,@nextzone_element);  

   }   
   elsif($element eq '1'){
      unshift(@nextzone_element,'6');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_left_zone($tmp,$level,$n,$geohex_code,@nextzone_element);        

   }
   elsif($element eq '0'){
      unshift(@nextzone_element,'8');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_zone($tmp,$level,$n,$geohex_code,@nextzone_element);
   }else{
      unshift(@nextzone_element,$element-4+'');
      my $num = @nextzone_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@nextzone_element != ()){
        $new_code = $new_code . shift(@nextzone_element);
      } 
      return $new_code; 
   }
}

sub up_zone{
   my ($element,$level,$n,$geohex_code,@nextzone_element) = @_;

   if($element eq '2'){
      unshift(@nextzone_element,'3');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_left_zone($tmp,$level,$n,$geohex_code,@nextzone_element);  
   }
   elsif($element eq '5'){
      unshift(@nextzone_element,'6');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_left_zone($tmp,$level,$n,$geohex_code,@nextzone_element);  
   }
   elsif($element eq '7'){
      unshift(@nextzone_element,'2');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_right_zone($tmp,$level,$n,$geohex_code,@nextzone_element);  
   }   
   elsif($element eq '6'){
      unshift(@nextzone_element,'1');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_right_zone($tmp,$level,$n,$geohex_code,@nextzone_element);        

   }
   elsif($element eq '8'){
      unshift(@nextzone_element,'0');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_zone($tmp,$level,$n,$geohex_code,@nextzone_element);
   }else{
      unshift(@nextzone_element,$element+4+'');
      my $num = @nextzone_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@nextzone_element != ()){
          $new_code = $new_code . shift(@nextzone_element);
      } 
      return $new_code; 
   }
}




    open(FP,"20121019.txt") or die("cannot open the file");
    
    #open(FP2,">delete_noise_result.txt") or die("cannot open the file");
    my @logdata;
    my @geohex_code;
    my $logdata_num = 0;
    while(my $line = <FP>){     
          chomp($line);     
          my @time_lat_lon = split(/,/,$line);
             $logdata[$logdata_num][0] = $time_lat_lon[0];
             $logdata[$logdata_num][1] = $time_lat_lon[1];
             $logdata[$logdata_num][2] = $time_lat_lon[2];
             $logdata_num++;
      }
    my $lat;
    my $lng; 
    my $level = 7       ;
  
    for($i = 0; $i < $logdata_num; $i++){
       $lat = $logdata[$i][1];
       $lng = $logdata[$i][2];
       $geohex_code[$i] = latlng2geohex($lat,$lng,$level);       
    }
    my $n = 10;
   print "geo = $geohex_code[$n]\n";
   $level= $level +1;
   my $tail_element = substr($geohex_code[$n],$level,1);
   my @tmp;
   

   my $new_code = &up_right_zone($tail_element,$level,,$n,$geohex_code[$n],@tmp);   \
   print "up_right = $new_code\n";
 
   
   $new_code = &down_right_zone($tail_element,$level,,$n,$geohex_code[$n],@tmp);
   print "down_right = $new_code\n";
  

   $new_code = &down_left_zone($tail_element,$level,,$n,$geohex_code[$n],@tmp);
   print "down_left = $new_code\n";
   

   $new_code = &up_left_zone($tail_element,$level,,$n,$geohex_code[$n],@tmp);
   print "up_left = $new_code\n";


   $new_code = &down_zone($tail_element,$level,,$n,$geohex_code[$n],@tmp);
   print "down = $new_code\n";
   
   
   $new_code = &up_zone($tail_element,$level,,$n,$geohex_code[$n],@tmp);
   print "up = $new_code\n";