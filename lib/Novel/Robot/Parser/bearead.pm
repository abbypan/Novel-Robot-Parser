# ABSTRACT: http://www.bearead.org
package Novel::Robot::Parser::bearead;
use strict;
use warnings;
use utf8;
use JSON;

use base 'Novel::Robot::Parser';

sub base_url { 'https://www.bearead.com' }

sub parse_novel {
  my ( $self, $bid, $rr ) = @_;
  my $c = $self->{browser}->request_url( 'https://www.bearead.com/api/book/detail', "bid=$bid" );
  my $r = decode_json( $c );
  $r = $r->{data};
  my %res;
  $res{book}         = $r->{name};
  $res{writer}       = $r->{author}{nickname};
  $res{floor_list} = [
    map {
    my $c = $self->{browser}->request_url('https://www.bearead.com/api/book/chapter/content', "bid=$_->{bid}&cid=$_->{cid}");
    my $cr = $self->parse_novel_item(\$c);
    $cr->{title} = $_->{name};
    $cr;
    } @{ $r->{chapter} } ];
  return \%res;
}

sub parse_novel_item {
  my ( $self, $h ) = @_;
  my $r = decode_json( $$h );
  return { content => $r->{data}{content} };
}

1;
