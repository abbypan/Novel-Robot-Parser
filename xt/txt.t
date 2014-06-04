#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(site => 'txt');

my $r = $xs->get_item_ref('txt.txt', 
    writer => 'xxx', 
    book => 'yyy',
);

dump($r);

done_testing;
