[![Build Status](https://travis-ci.org/wang-q/AlignDB-Stopwatch.svg?branch=master)](https://travis-ci.org/wang-q/AlignDB-Stopwatch)
[![codecov](https://codecov.io/gh/wang-q/AlignDB-Stopwatch/branch/master/graph/badge.svg)](https://codecov.io/gh/wang-q/AlignDB-Stopwatch)
[![Cpan version](https://img.shields.io/cpan/v/AlignDB-Stopwatch.svg)](https://metacpan.org/release/AlignDB-Stopwatch)

# NAME

AlignDB::Stopwatch - Record running time and print standard messages

# SYNOPSIS

    use AlignDB::Stopwatch;

    # record command line
    my $stopwatch = AlignDB::Stopwatch->new->record;

    # record config
    $stopwatch->record_conf($opt);

    $stopwatch->start_message("Doing really bad things...");

    $stopwatch->end_message;

# ATTRIBUTES

## program\_name

program name

## program\_argv

program command line options

## program\_conf

program configurations

## start\_time

start time

## divider\_char

Divider char used in output messages

## divider\_length

Length of divider char

## min\_div\_length

minimal single-side divider length

## uuid

Use Data::UUID to generate a UUID that prevent inserting meta info more than
one time on multithreads mode

# METHODS

## block\_message

Print a blocked message

    $self->block_message( $message, $with_duration );

## start\_message

Print a starting message

    $self->start_message( $message, $embed_in_divider );

## end\_message

Print a ending message

    $self->end_message( $message );

# AUTHOR

Qiang Wang &lt;wang-q@outlook.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2008- by Qiang Wang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
