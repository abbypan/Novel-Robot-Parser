#!/usr/bin/perl
use utf8;
use lib '../lib';
use lib '../../Novel-Robot-Browser/lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use Data::Dumper;

my $xs = Novel::Robot::Parser->new(site=> 'dddbbb');

my $index_url = 'http://www.dddbbb.net/html/10678/index.html';
my $chapter_url = "http://www.dddbbb.net/10678_569905.html";
my $writer_url = "http://www.dddbbb.net/html/author/2373.html";

my $index_ref = $xs->get_index_ref($index_url);
is($index_ref->{book}=~/^拼图/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '凌淑芬', 'writer');
is($index_ref->{chapter_num}, 14, 'chapter_num');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}, '序', 'chapter_title');
is($chapter_ref->{content}=~/几许/s ? 1 : 0, 1, 'chapter_content');

my ($writer_name, $books_ref) = $xs->get_board_ref($writer_url);
is($writer_name,  '凌淑芬', 'writer_name');
my $cnt = grep { $_->{book} eq '拼图' } @$books_ref;
is($cnt, 1, 'writer_book');

my ($info, $query_ref) = $xs->get_query_ref('拼图', query_type=>'作品');
my $cnt = grep { $_->{url} eq $index_url } @$query_ref;

is($cnt, 1, 'query_book');

done_testing;
