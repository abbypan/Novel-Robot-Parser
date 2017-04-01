#!/usr/bin/perl
use utf8;
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dumper;
use Encode;

my $tz = Novel::Robot::Parser->new( site => 'dingdian' );
my $url = 'http://www.23us.com/html/0/202/';
my $inf = $tz->get_item_info($url);

is($inf->{writer}, '蝴蝶蓝', 'writer');
is($inf->{book}, '全职高手','book');

done_testing;
