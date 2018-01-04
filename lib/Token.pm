package Token;
use strict;

sub hexCharAsNumber {
    my ($xd) = @_;
    return (ord($xd) >= ord('a')) ? ord($xd) - 87 : 0+$xd;
}

sub apply_op {
    my ($num, $op) = @_;
    my $op1 = $op->[1];  #  '+' | '-' ~ SUM | XOR
    my $op2 = $op->[0];  #  '+' | '^' ~ SLL | SRL
    my $shiftAmount = hexCharAsNumber($op->[2]);   #  [0-9a-f]

    my $mask = ($op1 eq '+') ? $num >> $shiftAmount : $num << $shiftAmount;
    return ($op2 eq '+') ? ($num + $mask & 0xffffffff) : ($num ^ $mask);
}

sub shiftLeftOrRightThenSumOrXor {
    my ($num, $ops) = @_;
    my $acc = $num;
    foreach my $op (@$ops) {
        $acc = apply_op($acc, [split //, $op]);
    }
    return $acc;
}

sub transformQuery {
    my ($query) = @_;
    my $e = [];
    foreach my $char (split //, $query) {
      my $code = ord($char);
      if ($code < 128) {
        push @$e, $code;                 #  0{l[6-0]}
      } elsif ($code < 2048) {
        push @$e, $code >> 6 | 0xC0;     #  110{l[10-6]}
        push @$e, $code & 0x3F | 0x80;   #  10{l[5-0]}
      } else {
        push @$e, $code >> 12 | 0xE0;    #  1110{l[15-12]}
        push @$e, $code >> 6 & 0x3F | 0x80;   #  10{l[11-6]}
        push @$e, $code & 0x3F | 0x80;        #  10{l[5-0]}
      }
    }
    return $e;
}

sub normalizeHash {
    my ($num) = @_;
    if ($num < 0) {
        $num = ($num & 0x7fffffff) + 0x80000000;
    }
    return $num % 1E6;
}

sub calcHash {
    my ($query, $windowTkk) = @_;

    #  STEP 1: spread the the query char codes on a byte-array, 1-3 bytes per char
    my $bytesArray = transformQuery($query);

    #  STEP 2: starting with TKK index, add the array from last step one-by-one, and do 2 rounds of shift+add/xor
    my ($tkkIndex, $tkkKey) = split /\./, $windowTkk;

    my $round1 = $tkkIndex;
    foreach my $byte (@$bytesArray) {
        $round1 = shiftLeftOrRightThenSumOrXor($round1+$byte, ['+-a', '^+6']);
    }

    #  STEP 3: apply 3 rounds of shift+add/xor and XOR with they TKK key
    my $round2 = shiftLeftOrRightThenSumOrXor($round1, ['+-3', '^+b', '+-f']) ^ $tkkKey;

    #  STEP 4: Normalize to 2s complement & format
    my $norm = normalizeHash($round2);

    return sprintf("%d.%d", $norm, $norm ^ $tkkIndex);
}

1;