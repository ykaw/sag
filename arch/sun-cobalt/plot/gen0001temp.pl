#!/usr/bin/perl

sub updatesum {
    local($dt, $temp) = @_;
    if ($dt eq $odt) {
        # check up sum
        $count++;
        $sum += $temp;
        if ($max < $temp) {
            $max = $temp;
        } elsif ($temp < $min) {
            $min = $temp;
        }
    } else {
        if ($odt) {
            # output sum
            printf("%s %.2f %.2f %.2f\n", $odt, $min, $sum/$count, $max, "\n");
        }
        # re-initialize
        $count = 1;
        $min = $max = $sum = $temp;
    }
    $odt = $dt;
}

while(<>){
    chop;
    s/#.*//;
    s/^\s*//;
    s/\s*$//;
    next unless $_;
    @F = split;
    if ($F[0] eq '=dt') {
        $dt = sprintf("%04d/%02d/%02d %02d", @F[1.. 4]);
    } elsif ($F[0] eq '=temp'){
        $temp = $F[1];
        &updatesum($dt, $temp);
    }
}
&updatesum("", "");
