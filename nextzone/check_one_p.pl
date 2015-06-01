sub check_one_point{
	my ($code,@all_code) = @_;
	my  $tail_element = substr($code,-1,1);
	my $return_code;
	my $next_zone_n=0;
	my @next_element=();
	$return_code =  &up_zone($tail_element,-1,$code,@next_element);
	if(grep {$_ eq $return_code} @all_code) {$next_zone_n++;}
	$return_code =  &up_right_zone($tail_element,-1,$code,@next_element);
	if(grep {$_ eq $return_code} @all_code){ $next_zone_n++;}
	$return_code =  &down_right_zone($tail_element,-1,$code,@next_element);
	if(grep {$_ eq $return_code} @all_code) {$next_zone_n++;}
	$return_code =  &down_zone($tail_element,-1,$code,@next_element);
	if(grep {$_ eq $return_code} @all_code) {$next_zone_n++;}
	$return_code =  &down_left_zone($tail_element,-1,$code,@next_element);
	if(grep {$_ eq $return_code} @all_code) {$next_zone_n++;}	
	$return_code =  &up_left_zone($tail_element,-1,$code,@next_element);
	if(grep {$_ eq $return_code} @all_code) {$next_zone_n++;}		
	
	return $next_zone_n;
}
1;