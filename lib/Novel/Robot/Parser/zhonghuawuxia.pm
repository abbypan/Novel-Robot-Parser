# ABSTRACT: zhonghuawuxia.pm http://www.zhonghuawuxia.com
package Novel::Robot::Parser::zhonghuawuxia;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.zhonghuawuxia.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@class="index_area"]//ul//li//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//div[@class="title"]//b' , 'book' => 'TEXT';
          process_first '//div[@class="title"]' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    ($ref->{writer})= $ref->{writer}=~m#.*作者(.+)$#;

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    my ($book_id) = $$html_ref=~m#/bookinfo/(\d+)#s;
    $_->{url}=~s#/chapter/(\d+)$#/Public/js/$book_id/$1.js# for @{ $ref->{chapter_list} };

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    $$html_ref=~s#^.*?"##s;
    $$html_ref=~s#"\)$##s;
    return { content => $$html_ref };

    #my $parse_chapter = scraper {
        #process_first '//div[@id="content"]', 'content' => 'HTML';
        #process_first '//h1[@class="story_title"]', 'title'=> 'TEXT';
    #};
    #my $ref = $parse_chapter->scrape($html_ref);
    #$ref->{content}=~s#<div[^>]*?>.+?</div>##sg;
    #return $ref;
} ## end sub parse_chapter

1;
