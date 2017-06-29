# ABSTRACT: 言情记 http://www.shushu8.com
package Novel::Robot::Parser::shushu8;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.shushu8.com' }

sub charset { 'cp936' }

sub scrape_novel_list { { path=>'//ul/li/a'} }

sub scrape_novel {
    return {
        book => { path => '//h1'}, 
        writer=>{ path => '//h6/a'}, 
    };
}

sub scrape_novel_item {
    return {
        title => { path => '//h1'}, 
        content=>{ path => '//pre[@id="content"]', extract => 'HTML' }, 
    };
}

1;
