#!/usr/bin/perl
use lib '../lib';
use utf8;
use Novel::Robot::Parser;
use Test::More ;
use Encode::Locale;
use Encode;
use Data::MessagePack;
use Data::Dumper;

my $xs = Novel::Robot::Parser->new( site=> 'raw' );
my $r = $xs->parse_novel('/tmp/a-b.raw');
#use File::Slurp qw/read_file/;
#my $mp = read_file('/tmp/a-b.raw', binmode => ':raw');
#my $r =  Data::MessagePack->unpack($mp);
print Dumper($r);
exit;

my $xs = Novel::Robot::Parser->new( site=> 'jjwxc' );
my $index_url = 'http://www.jjwxc.net/onebook.php?novelid=22742';
my $index_ref = $xs->get_novel_ref($index_url, min_chapter_num=>0, max_chapter_num=>1);
my $mp = Data::MessagePack->pack($index_ref);
#print $mp;
my $r =  Data::MessagePack->unpack($mp);
#print Dumper($r);

done_testing;
