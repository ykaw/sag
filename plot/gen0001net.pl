#!/usr/bin/perl

$TOOMAX = 999999999999;
$TOOMIN = -1;

sub suminit {
    $cnt = $rxsum = $txsum = 0;
    $rxmax = $txmax = $TOOMIN;
    $rxmin = $txmin = $TOOMAX;
}

sub m2s {
    $_[0]*8/60;
}

sub sumprint {
    printf("%s %.2f %.2f %.2f %.2f %.2f %.2f\n",
	   $pdt, &m2s($rxmin/1000), &m2s($rxsum/$cnt/1000), &m2s($rxmax/1000), &m2s($txmin/1000), &m2s($txsum/$cnt/1000), &m2s($txmax/1000));
}

sub update {
    local($dt, $rx, $tx) = @_;
    if ($prx && (0 <= ($rxdif = $rx - $prx)) && (0 <= ($txdif = $tx - $ptx))) {
	if ($pdt ne $dt) {
	    &sumprint;
	    &suminit;
	}
	$cnt++;
	$rxsum += $rxdif;
	$txsum += $txdif;
	if ($rxmax < $rxdif) {
	    $rxmax = $rxdif;
	}
	if ($rxdif < $rxmin) {
	    $rxmin = $rxdif;
	}
	if ($txmax < $txdif) {
	    $txmax = $txdif;
	}
	if ($txdif < $txmin) {
	    $txmin = $txdif;
	}
	# printf("%s %5d>%5d>%-5d %5d/%d\n", $dt, $pmin, $pdif, $pmax, $psum, $pcnt);
    } else {
	# print $dt, '¢¢IGNORED¢¢', $pps, ' - ', $ps, "\n";
    }
    $prx = $rx;
    $ptx = $tx;
    $pdt = $dt;
}

# MAIN FROM HERE
#

&suminit;
while (<>) {
    chop;
    s/#.*//;
    s/^\s*//;
    s/\s*$//;
    next unless $_;
    @F = split;
    if ($F[0] eq '=dt') {
        $dt = sprintf("%04d/%02d/%02d %02d", @F[1.. 4]);
    } elsif ($F[0] eq '=net') {
	$indata = 1;
    } elsif ($F[0] eq '=end') {
	$indata = 0;
    } elsif ($indata) {
	if ($F[0] =~ '^eth0:') {
	    if ($F[0] eq 'eth0:') {
		shift(@F);
	    } else {
		$F[0] =~ s/^eth0://;
	    }
	    &update($dt, $F[0], $F[8]);
        }
    }
}
&sumprint;
