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
	$indata = 0;

	$mem_use = 100*($mem_total-$mem_free)/$mem_total;
	$mem_buf = 100*($mem_total-$mem_free-$mem_cach)/$mem_total;
	$mem_txt = 100*($mem_total-$mem_free-$mem_cach-$mem_buff)/$mem_total;
	$swp_use = 100*($swp_total-$swp_free)/$swp_total;

	printf("%s %.2f %.2f %.2f %.2f\n",
	       $dt, $mem_use, $mem_buf, $mem_txt, $swp_use);
    } elsif ($indata) {
	if ($F[0] eq 'MemTotal:') {
	    $mem_total = $F[1];
	} elsif ($F[0] eq 'MemFree:') {
	    $mem_free = $F[1];
	} elsif ($F[0] eq 'Buffers:') {
	    $mem_buff = $F[1];
	} elsif ($F[0] eq 'Cached:') {
	    $mem_cach = $F[1];
	} elsif ($F[0] eq 'SwapTotal:') {
	    $swp_total = $F[1];
	} elsif ($F[0] eq 'SwapFree:') {
	    $swp_free = $F[1];
	}
    }
}
