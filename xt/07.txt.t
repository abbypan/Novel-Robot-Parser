#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dumper;
use utf8;

my $xs = Novel::Robot::Parser->new(site => 'txt');

my $r = $xs->get_item_ref('txt.txt', 
    writer => 'xxx', 
    book => 'yyy',
);

print Dumper($r);

done_testing;
