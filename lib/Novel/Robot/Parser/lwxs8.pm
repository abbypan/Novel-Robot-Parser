# ABSTRACT: http://www.lwxs8.com
package Novel::Robot::Parser::lwxs8;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.lwxs8.com' }

sub scrape_novel { { 
        book => { path=> '//h1' },
        writer => { path => '//h3//a', }, 
    } }

sub scrape_novel_list { { path => '//ul[@class="list-group list-charts"]//li//a' } }

sub scrape_novel_item { {
        title => { path => '//div[@class="panel-heading"]', }, 
        content=>{ path => '//div[@class="panel-body content-body content-ext"]', extract => 'HTML' }, 
    } }

1;
