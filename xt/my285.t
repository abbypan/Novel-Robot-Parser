#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use Encode::Locale;
use Encode;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'my285',
);

my $index_url = 'http://www.my285.com/gdwx/qt/zsy/index.htm';
my $chapter_url = "http://www.my285.com/gdwx/qt/zsy/000.htm";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/再生缘/ ? 1 : 0, 1,'book');
is($index_ref->{writer}=~/陈端生/? 1 : 0, 1, 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');
dump($index_ref->{chapter_list});

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/序言/?1:0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/钱塘/?1:0, 1 , 'chapter_content');

done_testing;
