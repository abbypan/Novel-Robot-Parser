# ABSTRACT: http://www.shunong.com
package Novel::Robot::Parser::shunong;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub scrape_novel_list { { 
        #path => '//div[@class="book_list"]//a' 
        path => '//div[@class="booklist clearfix"]//a' 
    } }


1;
