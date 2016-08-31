#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(
    site=> 'my285',
);

my $index_url = 'http://my285.com/cx/bblc/index.htm';
my $chapter_url = 'http://my285.com/cx/bblc/01.htm';

my $index_ref = $xs->get_index_ref($index_url);
dump($index_ref);
is($index_ref->{book}=~/^杉杉/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '顾漫', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/一/ ? 1 : 0, 1 , 'chapter_title');

done_testing;
