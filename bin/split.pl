#!/usr/bin/perl

#
#  split.pl  -  Split a file in two by time-change-border
#
#  $Id: split.pl,v 1.2 2004/05/17 01:21:52 cvs Exp $

if (@ARGV != 2) {
    die "Usage: $0 Old_FileName New_FileName\n";
}
$old_fname = shift @ARGV;
$new_fname = shift @ARGV;
open(OFILE,">$old_fname") || die "Can\'t Open:$old_fname\n";
open(NFILE,">$new_fname") || die "Can\'t Open:$new_fname\n";

while (<>) {
    chop;
    s/#.*//;
    s/^\s*//;
    s/\s*$//;
    next unless $_;

    @F = split;

    if ($F[0] eq '=dt') {
	$the_dayhour = join(' ', @F[1..3]);
	if (! $prev_dayhour) {
	    $prev_dayhour = $the_dayhour;
	}
	if ($the_dayhour eq $prev_dayhour) {
	    $pr_start = 0;
	} else {
	    $pr_start = 1;
	}
    }
    if ($pr_start eq 0) {
	print OFILE $_,"\n";
    } else {
	print NFILE $_,"\n";
    }
}

close(OFILE);
close(NFILE);
