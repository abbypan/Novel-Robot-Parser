#!/usr/bin/perl
use utf8;
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dump qw/dump/;
use Data::Dumper;
use Encode;


my $tz = Novel::Robot::Parser->new( site => 'hjj' );
my $url = 'http://bbs.jjwxc.net/showmsg.php?board=153&id=57';
my $r = $tz->get_tiezi_ref($url);
is($r->{writer},  '施定柔', 'writer_name');
is($r->{title}=~/迷侠/ ? 1 : 0, 1, 'title');

#my ($u, $post_data) = $tz->make_query_request('迷侠', 
    #board => 153, 
    #query_type=> '贴子主题',
#);
#my $c = $tz->{browser}->request_url($u, $post_data);
#print $c;
#exit;


done_testing;
