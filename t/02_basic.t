use strict;
use Test::More (tests => 17);

BEGIN
{
    use_ok("Event::Notify");
}

my $notify = Event::Notify->new;
ok( $notify );
isa_ok( $notify, "Event::Notify");

{
    package Event::Notify::Test::Observer;
    sub new { bless {}, shift }
    sub register
    {
        my ($self, $notify) = @_;
        $notify->register_event( 'foo', $self );
        $notify->register_event( 'bar', $self );
        $notify->register_event( 'baz', $self );
    }

    sub notify
    {
        my ($self, $event, @args) = @_;
        Test::More::ok(1);
        Test::More::like($event, qr/^foo|bar|baz$/);
    }
}

{
    package Event::Notify::Test::BadObserver;
    sub new { bless {}, shift }
}

{
    my $observer = Event::Notify::Test::Observer->new;
    eval {
        $notify->register( $observer );
    };
    ok( !$@, "register() seems to work" );
    
    $notify->notify('foo');
    $notify->notify('bar');
    $notify->notify('baz');
    $notify->notify('quux'); # should not cause ok()
}

{
    my $observer = Event::Notify::Test::BadObserver->new;
    eval {
        $notify->register_event('foo', $observer);
    };
    like( $@, qr/does not implement a notify\(\) method/ );
}

{
    my $observer = sub { 
        my($event) = @_;
        Test::More::ok(1);
        Test::More::like($event, qr/^foo|bar|baz$/);
    };

    $notify->notify('foo');
    $notify->notify('bar');
    $notify->notify('baz');
    $notify->notify('quux'); # should not cause ok()
}