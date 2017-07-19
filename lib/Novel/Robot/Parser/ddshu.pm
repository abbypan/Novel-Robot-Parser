# ABSTRACT: http://www.ddshu.net
package Novel::Robot::Parser::ddshu;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.ddshu.net' }

sub scrape_novel { { 
        book => { path=> '//div[@class="mytitle"]' },
        writer => { path=> '//div[@class="author"]/a'}, 
    } }

sub scrape_novel_list { { path => '//div[@class="opf"]//td//a' } }

sub scrape_novel_item { {
        title => { path => '//div[@class="mytitle"]' }, 
        content=>{ path => '//div[@id="content"]', extract => 'HTML'}, 
    } }

1;
