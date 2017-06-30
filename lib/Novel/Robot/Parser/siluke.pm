# ABSTRACT: http://www.siluke.tw
package Novel::Robot::Parser::siluke;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.siluke.tw' }

sub scrape_novel_list { { path=>'//div[@id="list"]//dd/a'} }

sub scrape_novel {
    return {
        book => { path => '//h1'}, 
        writer=>{ path => '//meta[@property="og:novel:author"]', extract=>'@content' }, 
    };
}

sub scrape_novel_item {
    return {
        title => { path => '//h1'}, 
        content=>{ path => '//div[@id="content"]', extract => 'HTML' }, 
    };
}

1;
