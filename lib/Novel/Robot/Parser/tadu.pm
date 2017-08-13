# ABSTRACT: http://www.tadu.com
package Novel::Robot::Parser::tadu;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.tadu.com' }

sub charset { 'utf8' }

sub scrape_novel_list { { path=>'//div[@class="detail-chapters"]//a' } }

sub scrape_novel {
    return {
        book => { path => '//h3'}, 
        writer=>{ path => '//div[@class="book-infor"]//a'}, 
    };
}

sub scrape_novel_item { {
        title => { path => '//h2' }, 
        content => { path => '//div[@id="partContent"]', extract=>'HTML' }, 
    } }

#sub parse_novel_item {
    #my ($self, $h, $r) = @_;
    #($r->{content}) = $$h=~/\$\("#partContent"\)\.html\(unescape\("(.+?)"\)\)/s;
    #return $self->unescape_js($r->{content});
#}

1;
