# ABSTRACT: http://www.bookben.com
package Novel::Robot::Parser::bookben;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.bookben.com' }

sub charset { 'cp936' }

sub scrape_novel_list { { path=>'//div[@class="info_views"]//ul//a' } }

sub scrape_novel {
    return {
        book => { path => '//dt[@class="ct"]/a', extract => '@title' }, 
        writer=>{ path => '//dl[@class="yxjj"]//dd[2]'}, 
    };
}

sub scrape_novel_item { {
        title => { path => '//div[@clas="view_t"]' }, 
        content => { path => '//div[@id="view_content_txt"]', extract=>'HTML' }, 
    } }

1;
