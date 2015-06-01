
sub up_right_zone{
   my ($element,$e_num,$geohex_code) = @_;
   my $c = 0;
   my @next_element=();
   if($element eq '8'){
      unshift(@next_element,'2');   
      $c = 1;
   }
   elsif($element eq '7'){
       unshift(@next_element,'1');
      $c = 1;
   }
   elsif($element eq '6'){
       unshift(@next_element,'0');
      $c = 1;
   }else{
      unshift(@next_element,$element+3+'');
      my $num = @next_element;
      my $new_code = substr($geohex_code,0,-$num);

   while(@next_element != ()){
      $new_code = $new_code . shift(@next_element);
   } 
    return $new_code; 
   }
   if($c == 1){
    $e_num --;
    my $tmp = substr($geohex_code,$e_num,1);
    &up_right_zone($tmp,$e_num,$geohex_code);
 }
}

sub down_right_zone{
   my ($element,$e_num,$geohex_code) = @_;
   my @next_element=();
   my $c = 0;
   if($element eq '6'){
      unshift(@next_element,'8');   
      $c = 1;
   }
   elsif($element eq '3'){
       unshift(@next_element,'5');
      $c = 1;
   }
   elsif($element eq '0'){
       unshift(@next_element,'2');
      $c = 1;
   }else{
      unshift(@next_element,$element-1+'');
      my $num = @next_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@next_element != ()){
      $new_code = $new_code . shift(@next_element);
   } 
      return $new_code; 
   }
   if($c == 1){
    $e_num --;
    my $tmp = substr($geohex_code,$e_num,1);
    &down_right_zone($tmp,$e_num,$geohex_code);
 }
}

sub down_left_zone{
   my ($element,$e_num,$geohex_code) = @_;
   my @next_element=();
   my $c = 0;
   if($element eq '2'){
      unshift(@next_element,'8');   
      $c = 1;
   }
   elsif($element eq '1'){
       unshift(@next_element,'7');
      $c = 1;
   }
   elsif($element eq '0'){
       unshift(@next_element,'6');
      $c = 1;
   }else{
      unshift(@next_element,$element-3+'');
      my $num = @next_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@next_element != ()){
        $new_code = $new_code . shift(@next_element);
      } 
      return $new_code; 
   }
   if($c == 1){
    $e_num --;
    my $tmp = substr($geohex_code,$e_num,1);
    &down_left_zone($tmp,$e_num,$geohex_code);
 }
}

sub up_left_zone{
   my ($element,$e_num,$geohex_code) = @_;
   my @next_element=();
   my $c = 0;
   if($element eq '8'){
      unshift(@next_element,'6');   
      $c = 1;
   }
   elsif($element eq '5'){
       unshift(@next_element,'3');
      $c = 1;
   }
   elsif($element eq '2'){
       unshift(@next_element,'0');
      $c = 1;
   }else{
      unshift(@next_element,$element+1+'');
      my $num = @next_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@next_element != ()){
        $new_code = $new_code . shift(@next_element);
      }  
      return $new_code; 
   }
   if($c == 1){
    $e_num --;
    my $tmp = substr($geohex_code,$e_num,1);
    &up_left_zone($tmp,$e_num,$geohex_code);
 }
}


sub down_zone{
   my ($element,$e_num,$geohex_code) = @_;
   my @next_element=();
   if($element eq '6'){
      unshift(@next_element,'5');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &down_right_zone($tmp,$e_num,$geohex_code);  
   }
   elsif($element eq '3'){
      unshift(@next_element,'2');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &down_right_zone($tmp,$e_num,$geohex_code);  
   }
   elsif($element eq '2'){
      unshift(@next_element,'7');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &down_left_zone($tmp,$e_num,$geohex_code);  
   }   
   elsif($element eq '1'){
      unshift(@next_element,'6');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &down_left_zone($tmp,$e_num,$geohex_code);        

   }
   elsif($element eq '0'){
      unshift(@next_element,'8');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &down_zone($tmp,$e_num,$geohex_code);
   }else{
      unshift(@next_element,$element-4+'');
      my $num = @next_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@next_element != ()){
        $new_code = $new_code . shift(@next_element);
      } 
      return $new_code; 
   }
}

sub up_zone{
   my ($element,$e_num,$geohex_code) = @_;
   my @next_element=();
   if($element eq '2'){
      unshift(@next_element,'3');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &up_left_zone($tmp,$e_num,$geohex_code);  
   }
   elsif($element eq '5'){
      unshift(@next_element,'6');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &up_left_zone($tmp,$e_num,$geohex_code);  
   }
   elsif($element eq '7'){
      unshift(@next_element,'2');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &up_right_zone($tmp,$e_num,$geohex_code);  
   }   
   elsif($element eq '6'){
      unshift(@next_element,'1');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &up_right_zone($tmp,$e_num,$geohex_code);        

   }
   elsif($element eq '8'){
      unshift(@next_element,'0');
      $e_num --;
      my $tmp = substr($geohex_code,$e_num,1);
      &up_zone($tmp,$e_num,$geohex_code);
   }else{
      unshift(@next_element,$element+4+'');
      my $num = @next_element;
      my $new_code = substr($geohex_code,0,-$num);
      while(@next_element != ()){
          $new_code = $new_code . shift(@next_element);
      } 
      return $new_code; 
   }
}
1;
