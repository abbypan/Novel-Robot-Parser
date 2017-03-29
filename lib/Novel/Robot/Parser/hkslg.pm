# ABSTRACT: http://www.hkslg520.com/
package Novel::Robot::Parser::hkslg;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

sub base_url { 'http://www.hkslg520.com' }

sub scrape_chapter_list {
    { path => '//td[@class="bookinfo_td"]//div[@class="dccss"]//a' }
}

sub scrape_index {
    return {
        book => { path => '//h1'}, 
        writer=>{ path => '//div[@class="infot"]//span' }, 
    };
}
#$ref->{writer}=~s/作者：//s;

sub scrape_chapter {
    return {
        title => { path => '//h2' }, 
        content=>{ path => '//div[@id="content"]/p', extract => 'HTML' }, 
    };
}

sub parse_chapter {
    my ( $self, $html_ref, $ref ) = @_;

    $ref->{content}=~s/^.*?正文，敬请欣赏！//s;
    $ref->{content}=~s/\(tXT下载WWW.XsHUOTxT.Com\)//sg;
    return $ref;
} ## end sub parse_chapter

1;
