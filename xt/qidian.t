#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use utf8;

my $xs = Novel::Robot::Parser->new(site => 'qidian');

my $index_url = 'http://read.qidian.com/BookReader/46130.aspx';
my $chapter_url = "http://read.qidian.com/BookReader/46130,1216673.aspx";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book},'亚马逊女王','book');
is($index_ref->{writer}, '飘灯', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/缪斯的清晨/?1:0, 1 , 'chapter_title');



done_testing;
