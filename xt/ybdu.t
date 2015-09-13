#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'ybdu',
);

my $index_url = 'http://www.ybdu.com/xiaoshuo/4/4996/';
my $chapter_url = "http://www.ybdu.com/xiaoshuo/4/4996/715401.html";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/琉璃美人/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '未名', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/第一章/?1:0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/遥远/?1:0, 1 , 'chapter_content');

done_testing;
