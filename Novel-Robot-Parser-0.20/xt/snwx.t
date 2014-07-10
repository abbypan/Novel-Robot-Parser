#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(site => 'snwx');

my $index_url = 'http://www.snwx.com/book/6/6966/';
my $chapter_url = 'http://www.snwx.com/book/6/6966/2102693.html';

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book},'断情逐妖记','book');
is($index_ref->{writer}, '牵机', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/风雨如晦/?1:0, 1 , 'chapter_title');



done_testing;
