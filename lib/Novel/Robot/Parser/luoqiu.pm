# ABSTRACT: http://www.luoqiu.com
package Novel::Robot::Parser::luoqiu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.luoqiu.com' };

sub scrape_chapter_list { { path => '//div[@id="container_bookinfo"]//a' } }

sub scrape_index { { 
        book => { path=> '//h1//a' },
        writer => { regex => '<meta name="author" content="(.+?)" />', }, 
} }

sub scrape_chapter { {
        title => { path => '//h1[@class="bname_content"]'}, 
        content=>{ path => '//div[@id="content"]', extract => 'HTML' }, 
    } }

1;
