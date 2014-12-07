#!/usr/bin/perl
use utf8;
use Test::More ;
use Data::Dumper;
use Encode;
use lib '../lib';
use Novel::Robot::Parser;

my $url = 'http://tieba.baidu.com/p/673372712';
my $parser = Novel::Robot::Parser->new( site => 'tieba' );

my $r = $parser->get_tiezi_ref($url, 
    #min_word_num => 100, 
    #only_poster => 1, 
    #max_floor_num => 3, 
    #max_page_num => 2, 
);

print Dumper($r);

done_testing;
