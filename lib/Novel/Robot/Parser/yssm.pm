# ABSTRACT: http://www.yssm.org
package Novel::Robot::Parser::yssm;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url {  'http://www.yssm.org' }

sub charset { 'utf8' }

sub scrape_index { {
        writer => { regex => '<meta property="og:novel:author" content="(.+?)"/>', }, 
        book=>{ regex => '<meta property="og:novel:book_name" content="(.+?)"/>', }, 
    } }

sub scrape_chapter_list {
    { path => '//dl[@class="chapterlist"]//dd//a'}
}

sub scrape_chapter { {
        title => { path => '//h1' }, 
        content=>{ path => '//div[@id="content"]', extract => 'HTML' }, 
    } }

1;
