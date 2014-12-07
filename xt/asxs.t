#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'asxs',
);

my $index_url = 'http://www.23hh.com/book/2/2786/';
my $chapter_url = "http://www.23hh.com/book/2/2786/8314173.html";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/^全职高手/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '蝴蝶蓝', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/被驱逐的高手/?1:0, 1 , 'chapter_title');

done_testing;
