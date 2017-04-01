# ABSTRACT: http://www.lwxs.com
package Novel::Robot::Parser::lwxs;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.lwxs.com' }

sub scrape_index { { 
        book => { path=> '//h1' },
        writer => { regex => '最新章节\((.+?)\)', }, 
    } }

sub scrape_chapter_list { { path => '//div[@id="list"]//dd//a' } }

sub scrape_chapter { {
        title => { path => '//div[@class="con_top"]'}, 
        content=>{ path => '//div[@id="TXT"]', extract => 'HTML' }, 
    } }

sub parse_chapter {
    my ( $self, $html_ref, $ref ) = @_;

    $ref->{title}=~s#^.*>##s;
    $ref->{content}=~s#<div[^>]+>.+?</div>##sg;

    return $ref;
} ## end sub parse_chapter

1;
