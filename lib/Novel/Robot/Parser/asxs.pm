# ABSTRACT: http://www.23xs.cc
package Novel::Robot::Parser::asxs;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.23xs.cc' }

#sub charset { 'cp936' }

sub scrape_index {
    return {
        book => { path => '//h1', extract => 'TEXT' }, 
        writer=>{ path => '//h3', extract => 'TEXT' }, 
    };
}

sub scrape_chapter_list { 
    {
        path => '//table[@id="at"]//td[@class="L"]//a', 
        #sort => 1, 
    }
}

sub scrape_chapter {
    return {
        title => { path => '//h1', extract => 'TEXT' }, 
        content=>{ path => '//dd[@id="contents"]', extract => 'HTML' }, 
    };
}

1;
