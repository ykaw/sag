#!/usr/bin/perl

package mmavg;

# set start of statistics
#
sub resetcnt {
  $cnt = 0;
}

# add sigle data to the stat
#
sub enter {
  $cnt++;   # number of entered data

  my ($pc, $t) = @_;

  if ($cnt <= 1) {
    # initialization of stat
    $odt = $t;
    $min = 100000000;
    $max = -1;
    $sum = 0;
  } else {
    # update stat
    my $ps = $pc - $opc;
    if (0 <= $ps) {
      $max = $ps if $max < $ps;
      $min = $ps if $ps < $min;
      $sum = $sum + $ps;
    }
  }
  $odt = $t;  # move current values to
  $opc = $pc; # previous ones
}

# Is timestamp changed?
#
sub dtchaned {
  return $odt ne $dt;
}

# output stats
#
sub printout {
  my $t = $_[0];
  $t = $dt unless $t;  # use current dt if arg1 is empty
  if (1<=$cnt) {
    printf("%s %d %1.2f %d\n", $t, $min, $sum/$cnt, $max);
    resetcnt();
  }
}

# put measured data to this package domain
#
sub put {
  my $pc = shift; # numbers of process invocation
                  # from raw log
  $dt = sprintf("%4d/%02d/%02d %02d:00", @_);

  if (dtchaned()) {
    printout($odt);  # output statistics
  }
  enter($pc, $dt);   # send data to stat package
}

resetcnt();

# for debug: dump variables
#
sub dbout {
  printf("%s:%s: =%s procs:%s-%s, max:%s, min:%s, sum:%s\n",
         $odt,$dt,
         $cnt,
         $pc,$opc,
         $max,
         $min,
         $sum);
}

package main;

while (<>) {
  chomp;
  next unless /^=[dpg]/;  # skip irrevant lines

  s/#.*//;                # strip comment
  s/^\s*//;               # and heading
  s/\s*$//;               # and trailing spaces

  if (/^=dt\s+\d\d\d\d\s+\d\d\s+\d\d\s+\d\d\s+\d\d\D*/) {
    # line for timestamp
    @daytime = (split)[1..5];
  } elsif (/^=procs\s+\d+\D*/) {
    # line for process invocation
    $procs=(split)[1];
    mmavg::put($procs, @daytime);
  } elsif (/^=gap$/) {
    mmavg::printout("");  # flush remaining data
    print "\n";
  }
}
mmavg::printout("");  # flush remaining data
