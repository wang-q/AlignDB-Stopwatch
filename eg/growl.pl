#!/usr/bin/perl
use strict;
use warnings;

use AlignDB::Stopwatch;

print "Testing AlignDB::Stopwatch $AlignDB::Stopwatch::VERSION\n";

$ENV{growl_send}     = 1;
$ENV{growl_appname}  = "AlignDB Stopwatch";
$ENV{growl_host}     = "localhost";
$ENV{growl_password} = "alignDB";
$ENV{growl_starting} = 1;
$ENV{growl_ending}   = 1;
$ENV{growl_other}    = 1;

my $stopwatch = AlignDB::Stopwatch->new( program_name => $0, );

$stopwatch->start_message;
$stopwatch->block_message("A block text");
$stopwatch->end_message;
