#!/usr/bin/perl

sub normscale {
    my $val  = $_[0];
    my $fact = 1;

    $fact = 1024           if $val =~ /\d+k$/i;
    $fact = 1024*1024      if $val =~ /\d+m$/i;
    $fact = 1024*1024*1024 if $val =~ /\d+g$/i;

   return($fact*$val);
}

# MAIN FROM HERE
#
while (<>) {
    chop;
    s/#.*//;
    s/^\s*//;
    s/\s*$//;
    next unless $_;
    @F = split;
    if ($F[0] eq '=dt') {
        $dt = sprintf("%04d/%02d/%02d %02d:%02d", @F[1.. 5]);
    } elsif ($F[0] eq '=mem') {
	$indata = 1;
    } elsif ($indata) {
        if ($F[0] eq '=end') {
            print "$dt $act $tot $free $cache $swpu $swpt\n";
            $indata = 0;
	} elsif ($F[0] eq 'Memory:') {
	    ($act, $tot) = ($F[2] =~ /(\d+[KMG]?)\/(\d+[KMG]?)/i);
	    $act = &normscale($act);
            $tot = &normscale($tot);
	    $free = &normscale($F[5]);
	    $cache = &normscale($F[7]);
	    ($swpu, $swpt) = ($F[9] =~ /(\d+[KMG]?)\/(\d+[KMG]?)/i);
	    $swpu = &normscale($swpu);
	    $swpt = &normscale($swpt);
	}
    } elsif ($F[0] eq '=gap') {
	print "\n";
    }
}
