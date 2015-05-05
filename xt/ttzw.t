#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'ttzw',
);

my $index_url = 'http://www.ttzw.com/book/62432/';
my $chapter_url = "http://www.ttzw.com/book/62432/5059447.html";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book} eq '棣萼交辉' ? 1 : 0, 1,'book');
is($index_ref->{writer}, '富察悠悠toutou', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/分卷说明/?1:0, 1 , 'chapter_title');

done_testing;
