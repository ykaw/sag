#!/usr/bin/perl

# MAIN FROM HERE
#

# status of parsing
$NOTNTP   = 0;                  # out of ntpctl data
$HDRFOUND = 1;                  # ntpctl's header found
$UNSYNC   = 2;                  # reading data of unsync
$SYNC     = 3;                  # reading data of sync

$stat    = $NOTNTP;             # initial state

while (<>) {
  chop;
  s/#.*//;
  s/^\s*//;
  s/\s*$//;
  next unless $_;

  @F = split;

  if ($stat == $NOTNTP) {
    if ($F[0] eq '=dt') {
      $dt = sprintf("%04d/%02d/%02d %02d:%02d", @F[1.. 5]);
    } elsif ($F[0] eq '=gap') {
      print "\n";
    } elsif ($F[0] eq '=ntpctl') {
      $stat = $HDRFOUND;
    }
  } elsif ($stat == $HDRFOUND) {
    if ($F[4] eq 'unsynced,' ||
        $F[7] eq 'unsynced,' ) {
      $ofs = 0 + $F[8];
      $dly = 0;
      $jit = 0;
      $peercnt = 0;
      $stat  = $UNSYNC;
    } elsif ($F[0] eq '*') {
      $ofs = 0 + $F[6];
      $dly = 0 + $F[7];
      $jit = 0 + $F[8];
      $stat = $SYNC;
    }
  } elsif ($stat == $UNSYNC ) {
    if ($F[0] =~ /^\d+$/) {
      $dly += 0 + $F[6];
      $jit += 0 + $F[7];
      $peercnt++;
    } elsif ($F[0] eq '=end') {
      if (1 <= $peercnt) {
        printf("%s %f %f %f\n", $dt, $ofs, $dly/$peercnt, $jit/$peercnt);
      }
      $dly = 0;
      $jit = 0;
      $peercnt = 0;
      $stat = $NOTNTP;
    }
  } elsif ($stat == $SYNC ) {
    if ($F[0] eq '=end') {
      printf("%s %f %f %f\n", $dt, $ofs, $dly, $jit);
      $stat = $NOTNTP;
    }
  }
  # for debug
  # print "$stat: $peercnt: [", join('|', @F), "]\n";
}
