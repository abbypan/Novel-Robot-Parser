# ABSTRACT: 塔读文学 http://www.tadu.com
package Novel::Robot::Parser::tadu;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.tadu.com' }

sub charset { 'utf8' }

sub scrape_chapter_list { { path=>'//div[@class="catalogList"]//a' } }

sub scrape_index {
    return {
        book => { path => '//div[@class="c_title"]//h3'}, 
        writer=>{ path => '//div[@class="catalog_top"]//a'}, 
    };
}

sub scrape_chapter { {
        title => { path => '//div[@class="title"]//h2' }, 
    } }

sub parse_chapter {
    my ($self, $h, $r) = @_;
    ($r->{content}) = $$h=~/\$\("#partContent"\)\.html\(unescape\("(.+?)"\)\)/s;
    return $self->unescape_js($r->{content});
}

1;
