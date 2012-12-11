#!perl -w
#
# Spottee Analysis for Specific Contest Dates
# - for post-contest use
# - Analyzing spots and making a list of most spotted stations
#   and its band breakdowns
# - using DXSpider outputs
#
# rin fukuda, jg1vgx@jarl.com, Nov 2004
# ver 0.02

use strict;

# setting bands
my @bands = qw/ "160" " 80" " 40" " 20" " 15" " 10" /;
my @map0 = qw/ 1800 3500 7000 14000 21000 28000 /;
my @map1 = qw/ 2000 4000 7300 14350 21450 29700 /;
my @map_cw0 = qw/ 1800 3500 7000 14000 21000 28000 /;
my @map_cw1 = qw/ 2000 3600 7060 14100 21100 28200 /;
my @map_rtty0 = qw/ 0 3520 7025 14070 21070 28070 /;
my @map_rtty1 = qw/ 0 3525 7045 14112 21125 28150 /;
my @map_ssb0 = qw/ 1800 3600 7030 14100 21150 28200 /;
my @map_ssb1 = qw/ 2000 4000 7300 14350 21450 28800 /;

# start of the program
print "\n*** SPOTS ANALYSIS ***\n\n";

# get input files
print "Enter input log file name: ";
chomp(my $infile = <STDIN>);
open F, $infile or die "Can't open $infile!\n";

# open output files
open FO, ">toplist.txt" or die "Can't make output file!\n";
open FA, ">analyzed.txt" or die "Can't make output file!\n";
open FU, ">unanalyzed.txt" or die "Can't make output file!\n";

# set contest mode types
print "Choose contest type (0:cw, 1:ssb, 2:cw+ssb, 3:rtty, 4:10m, 5:160m) :";
chomp(my $mode = <STDIN>);
die "Wrong type!\n" unless(0<=$mode && $mode<=5);

# band count data hash
# key is the callsign
# each field is ' 'x4 length
# has 7 fields, total + 6 bands in all band contests
# has 3 fields, total + 2 modes in single band contests, eg. 10m
# has 1 field, in single band contests where modes can't be analyzed, eg. 160m

my %calls;

while(<F>) {
	# reading DXSpider log line by line

	# splitting fields in line
	my @fields = split;

	# removing no spot lines

	# some empty lines
	# line should have at least two fields
	next unless(defined($fields[0]));
	next unless(defined($fields[1]));

	# DXSpider prompts
	# second field is 'de'
	if($fields[1] eq 'de') {
		next;
	}
	# other garbage?
	# first field should only comprise with numeric or dot
	if(!($fields[0] =~ /^[\d.]+$/)) {
		print FU;	# write out other garbages as unanalyzed
		next;
	}

	# check mode and band count
	#         param = mode, freq, call
	if(&band_count($mode, $fields[0], $fields[1])) {
		# $flag = 1, good spot
		print FA;
		next;
	} else {
		# $flag = 0, not useful spot or line
		print FU;
		next;
	}
}

close F;

# count totals unless 160m
# and print output header
if(0<=$mode && $mode<=3) {
	# 6 band contests
	foreach(keys %calls) {
		my($new, $total);
		for(my $i=0; $i<6; ++$i) {
			$new = substr($calls{$_}, ($i+1)*4, 4);
			$total += $new unless $new eq '    ';
		}
		substr($calls{$_}, 0, 4) = sprintf "%4d", $total;
	}
	# print output header
	print FO "callsign   total 160  80  40  20  15  10\n";
	print FO "----------------------------------------\n";
} elsif($mode==4) {
	# 10m contests
	foreach(keys %calls) {
		my($new, $total);
		for(my $i=0; $i<2; ++$i) {
			$new = substr($calls{$_}, ($i+1)*4, 4);
			$total += $new unless $new eq '    ';
		}
		substr($calls{$_}, 0, 4) = sprintf "%4d", $total;
	}
	# print output header
	print FO "callsign   total  cw ssb\n";
	print FO "------------------------\n";
} elsif($mode==5) {
	# print output header
	print FO "callsign   spots\n";
	print FO "----------------\n";
}

# print output
my $out;
foreach(sort by_score keys %calls) {
	$out = sprintf "%-12s%s\n", $_, $calls{$_};
	print FO $out;
}

close FO;
close FA;
close FU;

sub by_score { $calls{$b} cmp $calls{$a} }

# define a callsign element in the hash unless defined, 6 bands
sub def_call {
	# pad with space for a new callsign
	unless(defined($calls{$_[0]})) {
		$calls{$_[0]} = ' 'x4x7;
		# 6 bands + total = 7
	}
}

# define a callsign element in the hash unless defined, single band, dual mode
sub def_call_s {
	# pad with space for a new callsign
	unless(defined($calls{$_[0]})) {
		$calls{$_[0]} = ' 'x4x3;
		# 2 modes + total = 3
	}
}

# define a callsign element in the hash unless defined, single band, single mode
sub def_call_ss {
	# pad with space for a new callsign
	unless(defined($calls{$_[0]})) {
		$calls{$_[0]} = ' 'x4;
		# only total field
	}
}

# analyze a line if it is within appropriate band and set band counts
# $flag is 1 when meaningful line was analyzed, 0 if unrelated/useless/out-of-band lines
sub band_count {
	my $new;

	# case CW
	if($_[0] == 0) {
		my $flag = 0;
		for(my $i=0; $i<6; ++$i) {
			if($map_cw0[$i] <= $_[1] && $_[1] <= $map_cw1[$i]) {
				&def_call($_[2]);
				$new = substr($calls{$_[2]}, ($i+1)*4, 4);
				substr($calls{$_[2]}, ($i+1)*4, 4) = sprintf "%4d", ++$new;
				$flag = 1;
			}
		}
		return $flag;
	}

	# case SSB
	if($_[0] == 1) {
		my $flag = 0;
		for(my $i=0; $i<6; ++$i) {
			if($map_ssb0[$i] <= $_[1] && $_[1] <= $map_ssb1[$i]) {
				&def_call($_[2]);
				$new = substr($calls{$_[2]}, ($i+1)*4, 4);
				substr($calls{$_[2]}, ($i+1)*4, 4) = sprintf "%4d", ++$new;
				$flag = 1;
			}
		}
		return $flag;
	}

	# case CW+SSB
	if($_[0] == 2) {
		my $flag = 0;
		for(my $i=0; $i<6; ++$i) {
			if($map_cw0[$i] <= $_[1] && $_[1] <= $map_cw1[$i]) {
				&def_call($_[2]);
				$new = substr($calls{$_[2]}, ($i+1)*4, 4);
				substr($calls{$_[2]}, ($i+1)*4, 4) = sprintf "%4d", ++$new;
				$flag = 1;
			}
		}
		for(my $i=0; $i<6; ++$i) {
			if($map_ssb0[$i] <= $_[1] && $_[1] <= $map_ssb1[$i]) {
				&def_call($_[2]);
				$new = substr($calls{$_[2]}, ($i+1)*4, 4);
				substr($calls{$_[2]}, ($i+1)*4, 4) = sprintf "%4d", ++$new;
				$flag = 1;
			}
		}
		return $flag;
	}

	# case RTTY
	if($_[0] == 3) {
		my $flag = 0;
		for(my $i=0; $i<6; ++$i) {
			if($map_rtty0[$i] <= $_[1] && $_[1] <= $map_rtty1[$i]) {
				&def_call($_[2]);
				$new = substr($calls{$_[2]}, ($i+1)*4, 4);
				substr($calls{$_[2]}, ($i+1)*4, 4) = sprintf "%4d", ++$new;
				$flag = 1;
			}
		}
		return $flag;
	}

	# case 10m
	if($_[0] == 4) {
		my $flag = 0;
		# CW spot?
		if($map_cw0[5] <= $_[1] && $_[1] <= $map_cw1[5]) {
			&def_call_s($_[2]);
			$new = substr($calls{$_[2]}, 1*4, 4);
			substr($calls{$_[2]}, 1*4, 4) = sprintf "%4d", ++$new;
			$flag = 1;
		}
		# SSB spot?
		if($map_ssb0[5] <= $_[1] && $_[1] <= $map_ssb1[5]) {
			&def_call_s($_[2]);
			$new = substr($calls{$_[2]}, 2*4, 4);
			substr($calls{$_[2]}, 2*4, 4) = sprintf "%4d", ++$new;
			$flag = 1;
		}
		return $flag;
	}

	# case 160m
	if($_[0] == 5) {
		my $flag = 0;
		if($map0[0] <= $_[1] && $_[1] <= $map1[0]) {
			&def_call_ss($_[2]);
			$new = substr($calls{$_[2]}, 0, 4);
			substr($calls{$_[2]}, 0, 4) = sprintf "%4d", ++$new;
			$flag = 1;
		}
		return $flag;
	}
}
