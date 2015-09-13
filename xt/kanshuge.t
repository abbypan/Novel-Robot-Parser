#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'kanshuge',
);

my $index_url = 'http://www.kanshuge.com/files/article/html/29/29662/index.html';
my $chapter_url = "http://www.kanshuge.com/files/article/html/29/29662/5077231.html";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/将军在上/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '橘花散里', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/凯旋归来/?1:0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/大秦国最近有喜事/s ?1:0, 1 , 'chapter_content');


done_testing;
