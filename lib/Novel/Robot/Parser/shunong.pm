# ABSTRACT: 书农 http://www.shunong.com
package Novel::Robot::Parser::shunong;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

use Web::Scraper;

sub base_url { 'http://www.shunong.com'; }

sub charset {
    'cp936';
}

sub parse_chapter_list {
    my ( $self, $r , $html_ref ) = @_;
    my $parse_index = scraper {
        process '//div[@class="booklist clearfix"]//a', 'chapter_list[]' => {
            'title' => 'TEXT', 'url' => '@href'
        };
        };
    my $ref = $parse_index->scrape($html_ref);

    my @res =grep { exists $_->{url} } @{$ref->{chapter_list}} ;
    return \@res;
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '.author', 'writer' => 'TEXT';
        process_first 'h1', 'book' => 'TEXT';
    };
    my $ref = $parse_index->scrape($html_ref);
    $ref->{writer}=~s/作者：//;
    $ref->{book}=~s/全文阅读//;


    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '.author', 'writer' => 'TEXT';
        process_first 'h2', 'book' => 'TEXT';
        process_first '//div[@class="bookcontent clearfix"]', 'content' => 'HTML';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return unless ( defined $ref->{book} );
    $ref->{writer}=~s/作者：//;
    @{$ref}{'book', 'title'} = $ref->{book}=~/(.+?)最新章节：(.+)/;
    $ref->{content}=~s#<div[^>]+></div>##sg;
    $ref->{content}=~s#<script[^>]+></script>##sg;
    $ref->{content}=~s#<a href="http://www.jidubook.com/".+?</a>##sg;
    $ref->{content}=~s#<a href="http://www.shunong.com/".+?</a>##sg;
    return $ref;
} ## end sub parse_chapter


1;
