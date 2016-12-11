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
  } elsif ($F[0] eq '=ntpctl') {
    $indata = 1;
    $found  = 0;
  } elsif ($indata) {
    if ($F[0] eq '*') {
      $found  = 1;
      $ofs = 0 + $F[6];
      $dly = 0 + $F[7];
      $jit = 0 + $F[8];
    } elsif ($F[0] eq '=end') {
      printf("%s %f %f %f\n", $dt, $ofs, $dly, $jit) if $found;
      $indata = 0;
    }
  } elsif ($F[0] eq '=gap') {
    print "\n";
  }
}
