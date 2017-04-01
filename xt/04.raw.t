#!/usr/bin/perl
use lib '../lib';
use utf8;
use Novel::Robot::Parser;
use Test::More ;
use Encode::Locale;
use Encode;
use Data::MessagePack;

my $xs = Novel::Robot::Parser->new( site=> 'zhonghuawuxia' );

my $index_url = 'http://www.zhonghuawuxia.com/book/1757';
my $index_ref = $xs->get_novel_ref($index_url, min_chapter_num=>0, max_chapter_num=>1);
my $mp = Data::MessagePack->pack($index_ref);
print $mp;

done_testing;
