#!/usr/bin/perl

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
    } elsif ($F[0] eq '=end') {
	printf("%s %.2f %.2f %.2f %.2f\n",
	       $dt, $mem_use, $mem_buf, $mem_txt, $swp_use);
	$indata = 0;
    } elsif ($indata) {
	if ($F[0] eq 'Mem:') {
	    $mem_use = 100*($F[1]-$F[3])/$F[1];
	    $mem_buf = 100*($F[1]-$F[3]-$F[6])/$F[1];
	    $mem_txt = 100*($F[1]-$F[3]-$F[6]-$F[5])/$F[1];
	} elsif ($F[0] eq 'Swap:') {
	    $swp_use = 100*$F[2]/$F[1];
	}
    }
}
