# ABSTRACT: 解析raw
=pod

=encoding utf8

=head1 FUNCTION

=head2 parse_index

解析raw 文件
  
  my $raw_content_ref = $self->parse_index( '/someotherdir/somefile.raw' );

=cut
package Novel::Robot::Parser::raw;
use strict;
use warnings;
use base 'Novel::Robot::Parser';

use File::Slurp;
use Data::MessagePack;
use utf8;

sub parse_index {
    my ($self, $raw_file) = @_;
    my $s = read_file( $raw_file, binmode => ':raw' ) ;
    my $mp = Data::MessagePack->new();
    $mp->utf8(1);
    my $up = $mp->unpack($s);
    return $up;
}

1;
