# ABSTRACT: 言情记 http://www.yanqingji.com
package Novel::Robot::Parser::yanqingji;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.yanqingji.net' }

sub scrape_chapter_list { { path=>'//div[@class="book_main"]//td/a'} }

sub scrape_index {
    return {
        book => { path => '//h1'}, 
        writer=>{ path => '//h2/a'}, 
    };
}

sub scrape_chapter {
    return {
        title => { path => '//div[@class="book_title"]/h1[2]'}, 
        content=>{ path => '//p[@id="zoom"]', extract => 'HTML' }, 
    };
}

1;
