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
    } elsif ($F[0] eq '=time') {
	print "$dt ", $F[1], "\n";
    } elsif ($F[0] eq '=gap') {
	print "\n";
    }
}
