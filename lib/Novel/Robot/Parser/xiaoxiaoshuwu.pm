# ABSTRACT:  http://m.xiaoxiaoshuwu.com
package Novel::Robot::Parser::xiaoxiaoshuwu;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

sub base_url {  'http://m.xiaoxiaoshuwu.com' }

sub scrape_index {
    my ($self) = @_;
    { 
        book => { path=> '//h3' },
        writer => { sub => $self->extract_element_sub('是由作家(.+?)所作'), }, 

    }
} ## end sub parse_index

sub scrape_chapter_list { { path => '//ul[@class="chapter"]//a' } }

sub scrape_chapter {
    return {
        title => { path => '//div[@id="nr_title"]'}, 
        content=>{ path => '//div[@id="chapterContent"]', extract => 'HTML' }, 
    };
}

1;
