# ABSTRACT: http://www.shushu8.com
package Novel::Robot::Parser::shushu8;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';


sub scrape_novel_list { { path=>'//ul/li/a'} }


1;
