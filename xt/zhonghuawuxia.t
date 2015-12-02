#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use Encode::Locale;
use Encode;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'zhonghuawuxia',
);

my $index_url = 'http://www.zhonghuawuxia.com/book/1945';
my $chapter_url = "http://www.zhonghuawuxia.com/chapter/69550";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/浩然剑/ ? 1 : 0, 1,'book');
is($index_ref->{writer}=~/赵晨光/? 1 : 0, 1, 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');
dump($index_ref->{chapter_list});

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/序/?1:0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/刺客/?1:0, 1 , 'chapter_content');

done_testing;
