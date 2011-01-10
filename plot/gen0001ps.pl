#!/usr/bin/perl

$TOOMAXPID = 9999999;
$TOOMINPID = -1;

sub suminit {
    $pcnt = $psum = 0;
    $pmax = $TOOMINPID;
    $pmin = $TOOMAXPID;
}

sub sumprint {
    printf("%s %d %.2f %d\n",
	   $pdt, $pmin, $psum/$pcnt, $pmax);
}

sub update {
    local($dt, $ps) = @_;
    if ($pps && (0 < ($pdif = $ps - $pps))) {
	if ($pdt ne $dt) {
	    &sumprint;
	    &suminit;
	}
	$pcnt++;
	$psum += $pdif;
	if ($pmax < $pdif) {
	    $pmax = $pdif;
	}
	if ($pdif < $pmin) {
	    $pmin = $pdif;
	}
	# printf("%s %5d>%5d>%-5d %5d/%d\n", $dt, $pmin, $pdif, $pmax, $psum, $pcnt);
    } else {
	# print $dt, '¢¢IGNORED¢¢', $pps, ' - ', $ps, "\n";
    }
    $pps = $ps;
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
    } elsif ($F[0] eq '=la') {
        $ps = $F[5];
	&update($dt, $ps) if $dt;
	$dt = "";
    } elsif ($F[0] eq '=gap') {
        &sumprint;
        print "\n";
    }
}
&sumprint;
