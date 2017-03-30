# ABSTRACT: 123yq http://www.123yq.com
package Novel::Robot::Parser::yesyq;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.123yq.com' }

sub scrape_chapter_list { { path=>'//div[@id="list"]//dd//a', sort=>1 } }

sub scrape_index { {
        writer => { path => '//div[@id="info"]//p[1]', }, 
        book=>{ path => '//h1', }, 
    } }

sub parse_index {
    my ($self, $h, $ref) = @_;

    $ref->{writer}=~s/.*?者：//;

    return $ref;
} ## end sub parse_index

sub scrape_chapter { {
        title => { path => '//h1'}, 
        content=>{ path => '//div[@id="TXT"]', extract => 'HTML', sub => sub {
                my ($c) = @_;
                $c=~s#<div[^>]*?>.+?</div>##sg;
                return $c;
            }}, 
    } }
1;
