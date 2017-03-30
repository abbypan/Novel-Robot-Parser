# ABSTRACT: 书农 http://www.shunong.com
package Novel::Robot::Parser::shunong;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

sub base_url { 'http://www.shunong.com' }

sub scrape_chapter_list { { path => '//div[@class="booklist clearfix"]//a' } }

sub scrape_index {
    return {
        book => { path => '//h1'}, 
        writer=>{ path => '.author'}, 
    };
}

sub scrape_chapter {
    return {
        title => { path => '//h2'}, 
        content=>{ path => '//div[@class="bookcontent clearfix"]', extract => 'HTML' }, 
    };
}

sub parse_chapter {
    my ( $self, $html_ref, $ref ) = @_;
    return unless ( defined $ref->{book} );
    @{$ref}{'book', 'title'} = $ref->{book}=~/(.+?)最新章节：(.+)/;
    $ref->{content}=~s#<a href="http://www.jidubook.com/".+?</a>##sg;
    $ref->{content}=~s#<a href="http://www.shunong.com/".+?</a>##sg;
    return $ref;
} ## end sub parse_chapter


1;
