package Protocol::HTTP2::Frame::Goaway;
use strict;
use warnings;
use Protocol::HTTP2::Constants qw(:flags :errors);
use Protocol::HTTP2::Trace qw(tracer bin2hex);

sub decode {
    my ( $context, $buf_ref, $buf_offset, $length ) = @_;
    my $frame_ref = $context->frame;

    if ( $frame_ref->{stream} != 0 ) {
        $context->error(PROTOCOL_ERROR);
        return undef;
    }

    my ( $last_stream_id, $error_code ) =
      unpack( 'N2', substr( $$buf_ref, $buf_offset, 8 ) );

    $last_stream_id &= 0x7FFF_FFFF;

    tracer->debug( "GOAWAY with error code $error_code, "
          . "last stream is $last_stream_id\n" );

    tracer->debug( "additional debug data: "
          . bin2hex( substr( $$buf_ref, $buf_offset + 8 ) )
          . "\n" )
      if $length - 8 > 0;

    return $length;
}

1;
