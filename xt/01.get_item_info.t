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

my $tz = Novel::Robot::Parser->new( site => 'hjj' );
my $url = 'http://bbs.jjwxc.net/showmsg.php?board=153&id=57';
my $r = $tz->get_item_info($url);
is($r->{writer},  '施定柔', 'writer_name');
is($r->{title}=~/迷侠/ ? 1 : 0, 1, 'title');

done_testing;
