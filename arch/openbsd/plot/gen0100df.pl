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
        $dt = sprintf("%04d/%02d/%02d %02d", @F[1.. 4]);
    } elsif ($F[0] eq '=df') {
	$indata = 1;
        $disk_use = '';
    } elsif ($F[0] eq '=end') {
	printf("%s%s\n", $dt, $disk_use);
	$indata = 0;
    } elsif ($indata) {
	if ($F[0] =~ m|^/dev/|) {
	    $disk_use .= sprintf(" %.2f", 100*$F[2]/$F[1]);
	}
    }
}