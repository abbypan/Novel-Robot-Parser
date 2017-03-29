# ABSTRACT: http://www.lwxs.com
package Novel::Robot::Parser::lwxs;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

sub base_url { 'http://www.lwxs.com' }

sub scrape_index {
    my ($self) = @_;
    { 
        book => { path=> '//h1' },
        writer => { regex => '最新章节\((.+?)\)', }, 

    }
} ## end sub parse_index

sub scrape_chapter_list { { path => '//div[@id="list"]//dd//a' } }
sub scrape_chapter {
    return {
        title => { path => '//div[@class="con_top"]'}, 
        content=>{ path => '//div[@id="TXT"]', extract => 'HTML' }, 
    };
}

sub parse_chapter {

    my ( $self, $html_ref, $ref ) = @_;

    $ref->{title}=~s#^.*>##s;

    return $ref;
} ## end sub parse_chapter

1;
