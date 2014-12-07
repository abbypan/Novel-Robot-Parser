#!/usr/bin/perl
use utf8;
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use Data::Dumper;

my $pr = Novel::Robot::Parser->new(site=>'jjwxc');

my $index_url = 'http://www.jjwxc.net/onebook.php?novelid=2456';
my $chapter_url = "http://m.jjwxc.net/book2/2456/1";

my $index_ref = $pr->get_index_ref($index_url);
is($index_ref->{book}=~/^何以笙箫默/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '顾漫', 'writer');
is($index_ref->{chapter_num}, 16, 'chapter_num');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chap_r = $pr->get_chapter_ref($chapter_url);
is($chap_r->{title}, '第一章', 'chapter_title');
is($chap_r->{content}=~/默笙/s ? 1 : 0, 1, 'chapter_content');

my $writer_url = "http://www.jjwxc.net/oneauthor.php?authorid=3243";
my ($writer_name, $writer_ref) = $pr->get_board_ref($writer_url);
is($writer_name eq '顾漫' ? 1 : 0, 1, 'writer_name');
my $cnt = grep { $_->{url} eq $index_url } @$writer_ref;
is($cnt, 1, 'writer_book');

my $query_ref = $pr->get_query_ref('顾漫', query_type=> '作者');
my $cnt = grep { $_->{url} eq $index_url } @$query_ref;
is($cnt, 1, 'query_writer');

done_testing;
