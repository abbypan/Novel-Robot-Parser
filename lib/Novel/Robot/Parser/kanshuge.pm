# ABSTRACT: http://www.kanshuge.la
package Novel::Robot::Parser::kanshuge;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.kanshuge.la' }

sub scrape_chapter_list {
    { path=> '//dl[@class="chapterlist"]//dd//a'}
}

sub scrape_index {
    return {
        book => { path => '//h1' }, 
        writer=>{ path => '//div[@class="btitle"]//em' }, 
    };
}

sub scrape_chapter {
    return {
        title => { path => '//h1' }, 
        content=>{ path => '//div[@id="BookText"]', extract => 'HTML' }, 
    };
}


1;
