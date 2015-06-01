sub next_zone{
	my $code = shift;
	my @up = &upzone($code);
	my @down = &downzone($code);
	my @all= (@up,@down);
	return @all;
}

sub upzone{
	my @ret_array;
	$geohex = shift;
	#my $geohex= "XM5321370";
	my @geo = split(//,$geohex);
	#print "$geohex\n";
	my $count = -1; 
	my $c=1;
	my $n;
	while($c){
		$n =$geo[$count];
		$n=$n+3;
		if($n < 9&& $n >=0){$c=0}
		$geo[$count] = ($n%9);
		$count--;
	}

	$geohex = join("",@geo);
	#print "$geohex\n";
	push(@ret_array,$geohex);
	@geo = split(//,$geohex);
	#print "$geohex\n";
	$count = -1; 
	$c=1;
	while($c){
		$n =$geo[$count];
		$n=$n+1;
		unless(($n%3)==0){$geo[$count] = $n;$c=0}
		else{
			$geo[$count] = ($n%3)+($geo[$count]-2);
			$count--;
		}
	}

	$geohex = join("",@geo);
	push(@ret_array,$geohex);
	#print "$geohex\n";
	$c =1;
	@geo = split(//,$geohex);

	$count=-1;
	while($c){
		$n =$geo[$count];
		$n=$n-3;
		if($n < 9&& $n >=0){$c=0;}
		$geo[$count] = ($n%9);
		$count--;
	}
	$geohex = join("",@geo);
	#print "$geohex\n";
	push(@ret_array,$geohex);
	return @ret_array;
}

sub downzone{
	my @ret_array;
	$geohex = shift;	
	@geo = split(//,$geohex);
	#print "$geohex\n";
	$count = -1; 
	$c=1;
	while($c){
		$n =$geo[$count];
		if(($n%3)==0){$geo[$count] = ($geo[$count]+2); $count--;}
		else{
			$n--;
			$geo[$count] = $n;
			$c=0;
		}
	}

	$geohex = join("",@geo);
	#print "$geohex\n";
	push(@ret_array,$geohex);
	$c =1;
	@geo = split(//,$geohex);
	#print "$geohex\n";
	$count=-1;
	while($c){
		$n =$geo[$count];
		$n=$n-3;
	if($n < 9&& $n >=0){$c=0;}
		$geo[$count] = ($n%9);
		$count--;
	}
	
	$geohex = join("",@geo);
	#print "$geohex\n";
	push(@ret_array,$geohex);
	@geo = split(//,$geohex);
	#print "$geohex\n";
	$count = -1; 
	$c=1;
	while($c){
		$n =$geo[$count];
		$n=$n+1;
		unless(($n%3)==0){$geo[$count] = $n;$c=0}
		else{
			$geo[$count] = ($n%3)+($geo[$count]-2);
			$count--;
		}
	}

	$geohex = join("",@geo);
	#print "$geohex\n";
	push(@ret_array,$geohex);
	return @ret_array;
}
1;