#!/usr/bin/perl
use utf8;
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use Data::Dumper;
use Encode;

my $tz = Novel::Robot::Parser->new( site => 'dingdian' );

my $url = 'http://www.23wx.com/html/0/202/';

my $topic = $tz->get_item_info($url);
print $topic->{writer}, "\n";
print $topic->{title} || $topic->{book},"\n";

done_testing;
