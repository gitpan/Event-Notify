# $Id: /mirror/perl/Event-Notify/trunk/lib/Event/Notify.pm 9011 2007-11-13T06:20:52.950316Z daisuke  $
#
# Copyright (c) 2007 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Event::Notify;
use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.00001';

sub new
{
    my $class = shift;
    return bless { observers => {} }, $class;
}

sub register
{
    my ($self, $observer) = @_;
    $observer->register($self) if $observer->can('register');
}

sub register_event
{
    my($self, $event, $observer) = @_;

    if (! $observer->can('notify')) {
        Carp::croak("$observer does not implement a notify() method");
    }

    $self->{observers}{$event} ||= [];
    push @{ $self->{observers}{$event} }, $observer;
}

sub unregister_event
{
    my($self, $event, $observer) = @_;

    my $observers = $self->{observers}{$event};
    return () unless $observers;

    for my $i (0 .. $#{$observers}) {
        next unless $observers->[$i] == $observer;
        return splice(@$observers, $i, 1);
    }
    return ();
}

sub notify
{
    my ($self, $event, @args) = @_;

    my $observers = $self->{observers}{$event} || [];
    $_->notify($event, @args) for @$observers;
}

1;

__END__

=head1 NAME

Event::Notify - Simple Observer/Notifier

=head1 SYNOPSIS

  use Event::Notify;

  my $notify = Event::Notify->new;
  $notify->register( $observer );
  $notify->register_event( $event, $observer );
  $notify->notify( $event, @args );

=head1 DESCRIPTION

Event::Notify implements a simple Observer pattern. It's not really intended
to be subclassed, or a fancy system. It just registers observers, and
broadcasts events, that's it. The simplicity is that it can be embedded
in a class that doesn't necessarily want to be a subclass of a notifier.

Simply create a slot for it, and delegate methods to it:

  package MyClass;
  use Event::Notify;

  sub new {
    my $class = shift;
    my $self = shift;
    $self->{notify} = Event::Notify->new;
  }

  # This interface doesn't have to be this way. Here, we're just making
  # a simple delegation mechanism 
  sub register_event { shift->{notify}->register_event(@_) }
  sub unregister_event { shift->{notify}->unregister_event(@_) }
  sub notify { shift->{notify}->notify(@_) }

Voila, you got yourself a observable module without inheritance!

=head1 METHODS

=head2 new

Creates a new instance

=head2 register($observer)

Registers a new observer. The observer must implement a notify() method.

When called, the observer's register() method is invoked, so each observer
can register itself to whatever event the observer wants to subscribe to.

So your observer's register() method could do something like this:

  package MyObserver;
  sub register {
    my ($observer, $notify) = @_;
    $notify->register_event( 'event_name1', $observer );
    $notify->register_event( 'event_name2', $observer );
    $notify->register_event( 'event_name3', $observer );
    $notify->register_event( 'event_name4', $observer );
  }

Think of it as sort of an automatic initializer.

=head2 register_event($event,$observer)

Registers an observer $observer as observing a particular event $event

=head2 unregister_event($event,$obserer)

Unregisters an observer.

=head2 notify($event,@args)

Notifies all of the observers about a particular event. @args is passed
directly to the observers' notify() event

=head1 AUTHOR

Copyright (c) 2007 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut