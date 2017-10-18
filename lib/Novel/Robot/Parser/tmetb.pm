# ABSTRACT: http://www.tmetb.net
package Novel::Robot::Parser::tmetb;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.tmetb.net' }

sub charset { 'cp936' }

sub scrape_novel_list { { path=>'//div[@class="box-item"]//li/a'} }

sub scrape_novel {
    return {
        book => { path => '//h4'}, 
        writer=>{ regex => '<title>[^<]+_(.+?)</title>'}, 
    };
}

sub scrape_novel_item {
    return {
        title => { path => '//h1' }, 
        content=>{ path => '//div[@id="text_area"]', extract => 'HTML' }, 
    };
}

1;
