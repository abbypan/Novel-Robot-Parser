#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dumper;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'lwxs',
);

my $index_url = 'http://www.lwxs.com/shu/5/5239/';
my $chapter_url = 'http://www.lwxs.com/shu/5/5239/2023067.html';

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/^慢慢/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '绝世小白', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
#dump($chapter_ref);
is($chapter_ref->{title}=~/引仙台/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/门甲/ ? 1 : 0, 1 , 'chapter_content');

done_testing;
