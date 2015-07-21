package AlignDB::Stopwatch;

# ABSTRACT: Record running time and print standard messages

use Moose;

use Time::Duration;
use Data::UUID;
use File::Spec;
use YAML qw(Dump Load DumpFile LoadFile);

=attr program_name

program name

=cut

has program_name => ( is => 'ro', isa => 'Str' );

=attr program_argv

program command line options

=cut

has program_argv => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

=attr program_conf

program configurations

=cut

has program_conf => ( is => 'ro', isa => 'Object' );

=attr start_time

start time

=cut

has 'start_time' => ( is => 'rw', isa => 'Value' );

=attr divider_char

Divider char used in output messages

=cut

has 'divider_char' => ( is => 'rw', isa => 'Str', default => sub {"="}, );

=attr divider_length

Length of divider char

=cut

has 'divider_length' => ( is => 'rw', isa => 'Int', default => sub {30}, );

=attr min_div_length

minimal single-side divider length

=cut

has 'min_div_length' => ( is => 'rw', isa => 'Int', default => sub {5} );

=attr uuid

Use Data::UUID to generate a UUID that prevent inserting meta info more than
one time on multithreads mode

=cut

has uuid => ( is => 'ro', isa => 'Str' );

sub BUILD {
    my $self = shift;

    $self->{start_time} = time;
    $self->{uuid}       = Data::UUID->new->create_str;

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

=method block_message

Print a blocked message

    $self->block_message( $message, $with_duration );

=cut

sub block_message {
    my $self          = shift;
    my $message       = shift;
    my $with_duration = shift;

    my $text;
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

=method start_message

Print a starting message

    $self->start_message( $message, $embed_in_divider );

=cut

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

=method end_message

Print a ending message

    $self->end_message( $message );

=cut

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
    my ( undef, undef, $filename )
        = File::Spec->splitpath( $self->program_name );
    return $filename;
}

1;

__END__

=head1 SYNOPSIS

    use AlignDB::Stopwatch;

    # record ARGV and Config
    my $stopwatch = AlignDB::Stopwatch->new(
        program_name => $0,
        program_argv => [@ARGV],
        program_conf => $Config,
    );

    $stopwatch->start_message("Doing really bad things...");
    
    $stopwatch->end_message;

=cut
