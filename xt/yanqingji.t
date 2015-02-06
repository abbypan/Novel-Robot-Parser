#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'yanqingji',
);

my $index_url = 'http://www.yanqingji.com/xiaoshuo/9232/index.html';
my $chapter_url = "http://www.yanqingji.com/xiaoshuo/9232/194070.html";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/我意逍遥/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '少紫', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/第一章/?1:0, 1 , 'chapter_title');

done_testing;
