#!/usr/bin/perl
use utf8;
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use Data::Dumper;
use Encode;

my $tz = Novel::Robot::Parser->new( site => 'jjwxc' );
my $url = 'http://www.jjwxc.net/onebook.php?novelid=2456';
my $topic = $tz->get_item_info($url);
print Dumper($topic->{writer}, $topic->{title} || $topic->{book});


done_testing;
