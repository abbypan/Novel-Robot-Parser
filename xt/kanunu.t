#!/usr/bin/perl
use utf8;
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;

my $xs = Novel::Robot::Parser->new(site => 'kanunu');


my $index_url = 'http://www.kanunu8.com/book3/6141/index.html';
my $chapter_url = 'http://www.kanunu8.com/book3/6141/108261.html';

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/风尘叹/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '飘灯', 'writer');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/冥/ ? 1 : 0, 1, 'chapter_title');

##my $writer_url = 'http://book.kanunu.org/files/writer/6482.html';
#my ($writer, $writer_ref) = $xs->get_board_ref($writer_url);
#is($writer, '古龙', 'writer_name');

done_testing;
