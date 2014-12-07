#!/usr/bin/perl
use utf8;
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;

my $xs = Novel::Robot::Parser->new(site => 'kanshu');


my $index_url = 'http://www.1kanshu.com/files/article/html/65/65478/';
my $chapter_url = 'http://www.1kanshu.com/files/article/html/65/65478/10807675.html';

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/^一路荣华/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '看泉听风', 'writer');
is($index_ref->{chapter_list}[3]{url}, $chapter_url, 'chapter_url');

#my $chapter_ref = $xs->get_chapter_ref($chapter_url);
#is($chapter_ref->{title}, '第一章', 'chapter_title');
#is($chapter_ref->{content}=~/加班五天后/s ? 1 : 0, 1, 'chapter_content');

#my $writer_url = 'http://book.kanunu.org/files/writer/183.html';
##$writer_url = 'http://book.kanunu.org/files/writer/6482.html';
#my ($writer, $writer_ref) = $xs->get_board_ref($writer_url);
#is($writer, '古龙', 'writer_name');
#my $cnt = grep { 
#$_->{url} eq 'http://book.kanunu.org/book/4573/index.html' } 
#@$writer_ref;
#is($cnt, 1, 'writer_book');

done_testing;
