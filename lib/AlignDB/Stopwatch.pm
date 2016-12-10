package AlignDB::Stopwatch;
use Moose;
use Time::Duration;
use Data::UUID;
use File::Spec;
use YAML qw(Dump Load DumpFile LoadFile);

our $VERSION = '1.0.2';

has program_name     => ( is => 'ro', isa => 'Str' );
has program_argv     => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has program_conf     => ( is => 'ro', isa => 'Object' );
has 'start_time'     => ( is => 'rw', isa => 'Value' );
has 'divider_char'   => ( is => 'rw', isa => 'Str', default => sub {"="}, );
has 'divider_length' => ( is => 'rw', isa => 'Int', default => sub {30}, );
has 'min_div_length' => ( is => 'rw', isa => 'Int', default => sub {5} );
has uuid             => ( is => 'ro', isa => 'Str' );

sub BUILD {
    my $self = shift;

    $self->{start_time} = time;
    $self->{uuid}       = Data::UUID->new->create_str;

    return;
}

#@returns AlignDB::Stopwatch
sub record {
    my $self = shift;

    $self->{program_name} = $main::0;

    $self->{program_argv} = [@main::ARGV];

    return $self;
}

sub record_conf {
    my $self = shift;
    my $conf = shift;

    $self->{program_conf} = $conf;

    return;
}

sub print_divider {
    my $self  = shift;
    my $title = shift;

    my $title_length = $title ? length $title : 0;

    my $divider_char   = $self->divider_char;
    my $divider_length = $self->divider_length;
    my $min_div_length = $self->min_div_length;

    my $divider_str;

    if ( !$title_length ) {
        $divider_str .= $divider_char x $divider_length;
        $divider_str .= "\n";
    }
    elsif ( $title_length > $divider_length - 2 * $min_div_length ) {
        $divider_str .= $divider_char x $min_div_length;
        $divider_str .= $title;
        $divider_str .= $divider_char x $min_div_length;
        $divider_str .= "\n";
    }
    else {
        my $left_length = int( ( $divider_length - $title_length ) / 2 );
        my $right_length = $divider_length - $title_length - $left_length;
        $divider_str .= $divider_char x $left_length;
        $divider_str .= $title;
        $divider_str .= $divider_char x $right_length;
        $divider_str .= "\n";
    }

    return $divider_str;
}

sub print_prompt {
    my $self = shift;
    return "==> ";
}

sub duration_now {
    my $self = shift;
    return duration( time - $self->start_time );
}

sub print_duration {
    my $self = shift;
    return "Runtime " . $self->duration_now . ".\n";
}

sub print_empty_line {
    my $self = shift;
    my $number = shift || 1;

    return "\n" x $number;
}

sub print_message {
    my $self    = shift;
    my $message = shift;

    return $message . "\n";
}

sub block_message {
    my $self          = shift;
    my $message       = shift;
    my $with_duration = shift;

    my $text;
    $text .= $self->print_empty_line;
    $text .= $self->print_prompt;
    $text .= $self->print_message($message);
    if ($with_duration) {
        $text .= $self->print_prompt;
        $text .= $self->print_duration;
    }
    $text .= $self->print_empty_line;

    print $text;

    return;
}

sub start_time2 {
    my $self = shift;
    return scalar localtime $self->start_time;
}

sub time_now {
    my $self = shift;
    return scalar localtime;
}

sub print_time {
    my $self  = shift;
    my $title = shift;

    my $time_str;

    if ( !defined $title ) {
        $time_str .= "Current time: ";
    }
    elsif ( $title =~ /start/i ) {
        $time_str .= "Start at: ";
    }
    elsif ( $title =~ /end/i ) {
        $time_str .= "End at: ";
    }
    else {
        $time_str .= "$title: ";
    }
    $time_str .= $self->time_now;
    $time_str .= "\n";

    return $time_str;
}

sub start_message {
    my $self             = shift;
    my $message          = shift;
    my $embed_in_divider = shift;

    my $text;
    if ( defined $message ) {
        if ( defined $embed_in_divider ) {
            $text .= $self->print_divider($message);
        }
        else {
            $text .= $self->print_divider;
            $text .= $self->print_message($message);
        }
    }
    else {
        $text .= $self->print_divider;
    }
    $text .= $self->print_time("start");
    $text .= $self->print_empty_line;

    print $text;

    return;
}

sub end_message {
    my $self    = shift;
    my $message = shift;

    my $text;
    $text .= $self->print_empty_line;
    if ( defined $message ) {
        $text .= $self->print_message($message);

    }
    $text .= $self->print_time("end");
    $text .= $self->print_duration;
    $text .= $self->print_divider;

    print $text;

    return;
}

sub cmd_line {
    my $self = shift;
    return join( ' ', $self->program_name, @{ $self->program_argv } );
}

sub init_config {
    my $self = shift;
    return Dump $self->program_conf;
}

sub operation {
    my $self = shift;
    my ( undef, undef, $filename ) = File::Spec->splitpath( $self->program_name );
    return $filename;
}

1;

__END__

=head1 NAME

AlignDB::Stopwatch - Record running time and print standard messages

=head1 SYNOPSIS

    use AlignDB::Stopwatch;

    # record command line
    my $stopwatch = AlignDB::Stopwatch->new->record;

    # record config
    $stopwatch->record_conf($opt);

    $stopwatch->start_message("Doing really bad things...");

    $stopwatch->end_message;

=head1 ATTRIBUTES

=head2 program_name

program name

=head2 program_argv

program command line options

=head2 program_conf

program configurations

=head2 start_time

start time

=head2 divider_char

Divider char used in output messages

=head2 divider_length

Length of divider char

=head2 min_div_length

minimal single-side divider length

=head2 uuid

Use Data::UUID to generate a UUID that prevent inserting meta info more than
one time on multithreads mode

=head1 METHODS

=head2 block_message

Print a blocked message

    $self->block_message( $message, $with_duration );

=head2 start_message

Print a starting message

    $self->start_message( $message, $embed_in_divider );

=head2 end_message

Print a ending message

    $self->end_message( $message );

=head1 AUTHOR

Qiang Wang <wang-q@outlook.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2008- by Qiang Wang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
