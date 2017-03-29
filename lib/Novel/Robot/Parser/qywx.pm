# ABSTRACT: http://www.71wx.net
package Novel::Robot::Parser::qywx;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.71wx.net' }

sub scrape_index {
    return {
        book => { path => '//h1' }, 
        writer=>{ path => '//div[@class="ml_title"]//span' }, 
    };
}

sub scrape_chapter_list {
    { path => '//div[@class="ml_main"]//dd//a' }
}

sub scrape_chapter {
    return {
        title => { path => '//h2' }, 
        content=>{ path => '//div[@class="yd_text2"]', extract => 'HTML' }, 
    };
}

1;
