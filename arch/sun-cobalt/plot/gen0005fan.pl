#!/usr/bin/perl

# MAIN FROM HERE
#
while (<>) {
    # strip extra stuff
    chop;
    s/#.*//;
    s/^\s*//;
    s/\s*$//;
    next unless $_;

    # process valid data
    @F = split;
    if ($F[0] eq '=dt') {
        $dt = sprintf("%04d/%02d/%02d %02d:%02d", @F[1.. 5]);
    } elsif ($F[0] eq '=fan') {
	$indata = 1;
        $fan_rots = '';
    } elsif ($F[0] eq '=end') {
	printf("%s%s\n", $dt, $fan_rots);
	$indata = 0;
    } elsif ($indata) {
	if ($F[0] eq 'fan') {
	    $fan_rots .= " $F[3]";
	}
    }
}
