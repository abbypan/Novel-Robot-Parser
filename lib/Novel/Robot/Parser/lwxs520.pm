# ABSTRACT: http://www.lwxs520.com
package Novel::Robot::Parser::lwxs520;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.lwxs520.com' }

sub scrape_novel { { 
        book => { path=> '//h1' },
        writer => { path => '//div[@class="infot"]//span', }, 
    } }

sub parse_novel {
    my ( $self, $h, $r ) = @_;
    $r->{writer}=~s#\/.*$##;
    return $r;
}


sub scrape_novel_list { { path => '//td[@class="bookinfo_td"]//td//a' } }

sub scrape_novel_item { {
        title => { path => '//h1', }, 
        content=>{ path => '//div[@id="content"]', extract => 'HTML' }, 
    } }

1;
