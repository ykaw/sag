#!/usr/local/bin/perl

if (scalar(@ARGV) < 2) {
    die "Usage: $0 rot file1 [file2 ...]\n";
}

(($rot = 0 + shift(@ARGV)) < 1) && exit;

while ($f = shift(@ARGV)) {
    for ($i = $rot; 0 <= $i; $i--) {
	$fd = sprintf("%s-%02d", $f, $i);
	if (($j = $i - 1) < 1) {
	    $fs = $f;
	} else {
	    $fs = sprintf("%s-%02d", $f, $j);
	}
	if ( -f $fs ) {
	    rename $fs, $fd;
	}
    }
}
