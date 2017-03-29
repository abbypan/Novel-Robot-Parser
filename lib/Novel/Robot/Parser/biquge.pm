# ABSTRACT: http://www.biquge.tw
package Novel::Robot::Parser::biquge;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.biquge.tw' }

sub charset { 'utf8' }

sub scrape_index {
    my ($self) = @_;
    return {
        writer => { sub => $self->extract_element_sub('<meta property="og:novel:author" content="(.+?)"/>'), }, 
        book=>{ sub => $self->extract_element_sub('<meta property="og:title" content="(.+?)"/>'), }, 
    };
}

sub scrape_chapter_list { { path => '//div[@id="list"]//dd//a' } }

sub scrape_chapter {
    return {
        title => { path => '//h1' }, 
        content=>{ path => '//div[@id="content"]', extract => 'HTML' }, 
    };
}

1;
