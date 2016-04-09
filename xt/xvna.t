#!/usr/bin/perl
use utf8;
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use Data::Dumper;
use Encode;


my $tz = Novel::Robot::Parser->new( site => 'xvna' );
my $url = 'http://ncs.xvna.com/yd969205-1/';
my $r = $tz->get_tiezi_ref($url);
print "$r->{writer}, $r->{title}\n";
is($r->{writer}=~/匪我/ ? 1 : 0 ,  1 , 'writer_name');
is($r->{title}=~/寻找/ ? 1 : 0, 1, 'title');



done_testing;
