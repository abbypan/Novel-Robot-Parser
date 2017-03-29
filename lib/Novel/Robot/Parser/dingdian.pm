# ABSTRACT: http://www.23us.com
package Novel::Robot::Parser::dingdian;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

sub base_url { 'http://www.23us.com' }

sub scrape_index {
    my ($self) = @_;
    return {
        writer => { regex => '<meta name="og:novel:author" content="(.+?)"/>', }, 
        book=>{ regex => '<meta name="og:novel:book_name" content="(.+?)"/>', }, 
    };
}

sub scrape_chapter_list {
    { path => '//table[@id="at"]//a'}
}

sub scrape_chapter {
    return {
        title => { path => '//h1' }, 
        content=>{ path => '//dd[@id="contents"]', extract => 'HTML' }, 
    };
}

1;
