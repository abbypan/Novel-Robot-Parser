# ABSTRACT: http://www.ybdu.com
package Novel::Robot::Parser::ybdu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub scrape_novel_item { {
        title => { path => '//div[@class="h1title"]//h1'}, 
        content=>{ path => '//div[@id="htmlContent"]', extract => 'HTML', sub => sub {
                my ($c) = @_;
                $c=~s#<div class="ad00">.*##s;
                return $c;
            }}, 
} }

1;
