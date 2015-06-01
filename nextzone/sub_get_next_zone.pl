
sub up_right_zone{
   my ($element,$level,$geohex_code,@nextzone_element) = @_;
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
    &up_right_zone($tmp,$level,$geohex_code,@nextzone_element);
 }
}

sub down_right_zone{
   my ($element,$level,$geohex_code,@nextzone_element) = @_;

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
    &down_right_zone($tmp,$level,$geohex_code,@nextzone_element);
 }
}

sub down_left_zone{
   my ($element,$level,$geohex_code,@nextzone_element) = @_;

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
    &down_left_zone($tmp,$level,$geohex_code,@nextzone_element);
 }
}

sub up_left_zone{
   my ($element,$level,$geohex_code,@nextzone_element) = @_;
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
    &up_left_zone($tmp,$level,$geohex_code,@nextzone_element);
 }
}


sub down_zone{
   my ($element,$level,$geohex_code,@nextzone_element) = @_;

   if($element eq '6'){
      unshift(@nextzone_element,'5');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_right_zone($tmp,$level,$geohex_code,@nextzone_element);  
   }
   elsif($element eq '3'){
      unshift(@nextzone_element,'2');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_right_zone($tmp,$level,$geohex_code,@nextzone_element);  
   }
   elsif($element eq '2'){
      unshift(@nextzone_element,'7');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_left_zone($tmp,$level,$geohex_code,@nextzone_element);  
   }   
   elsif($element eq '1'){
      unshift(@nextzone_element,'6');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_left_zone($tmp,$level,$geohex_code,@nextzone_element);        

   }
   elsif($element eq '0'){
      unshift(@nextzone_element,'8');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &down_zone($tmp,$level,$geohex_code,@nextzone_element);
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
   my ($element,$level,$geohex_code,@nextzone_element) = @_;

   if($element eq '2'){
      unshift(@nextzone_element,'3');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_left_zone($tmp,$level,$geohex_code,@nextzone_element);  
   }
   elsif($element eq '5'){
      unshift(@nextzone_element,'6');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_left_zone($tmp,$level,$geohex_code,@nextzone_element);  
   }
   elsif($element eq '7'){
      unshift(@nextzone_element,'2');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_right_zone($tmp,$level,$geohex_code,@nextzone_element);  
   }   
   elsif($element eq '6'){
      unshift(@nextzone_element,'1');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_right_zone($tmp,$level,$geohex_code,@nextzone_element);        

   }
   elsif($element eq '8'){
      unshift(@nextzone_element,'0');
      $level --;
      my $tmp = substr($geohex_code,$level,1);
      &up_zone($tmp,$level,$geohex_code,@nextzone_element);
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
1;
