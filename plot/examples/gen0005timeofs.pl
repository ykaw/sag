#!/usr/bin/perl

# MAIN FROM HERE
#

# status of parsing
$NOTNTP   = 0;                  # out of ntpctl data
$HDRFOUND = 1;                  # ntpctl's header found
$UNSYNC   = 2;                  # reading data of unsync
$SYNC     = 3;                  # reading data of sync

$stat    = $NOTNTP;             # initial state

# initialize unsynced variables
$dly = 0;
$jit = 0;
$peercnt = 0;

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
    }
    if ($F[0] eq '=gap') {
      print "\n";
    }
    if ($F[0] eq '=ntpctl') {
      $stat = $HDRFOUND;
    }
  } else {
    if ($stat == $HDRFOUND) {
      if ($F[4] eq 'unsynced,') {
        $ofs = 0 + $F[8];
        $stat  = $UNSYNC;
      } elsif ($F[0] eq '*') {
        $ofs = 0 + $F[6];
        $dly = 0 + $F[7];
        $jit = 0 + $F[8];
        $stat = $SYNC;
      }
    } else {                    # Status should be UNSYNC or SYNC.
      if ($stat == $UNSYNC && $F[0] =~ /^\d+$/) {
        $dly += 0 + $F[6];
        $jit += 0 + $F[7];
        $peercnt++;
      }
      if ($F[0] eq '=end') {
        if ($stat == $UNSYNC && 0 < $peercnt) {
          printf("%s %f %f %f\n", $dt, $ofs, $dly/$peercnt, $jit/$peercnt);
          $dly = 0;
          $jit = 0;
          $peercnt = 0;
        } elsif ($stat == $SYNC) {
          printf("%s %f %f %f\n", $dt, $ofs, $dly, $jit);
        }
        $stat = $NOTNTP;
      }
      ;
    }
  }
  # for debug
  # print "$stat: $peercnt: [", join('|', @F), "]\n";
}
