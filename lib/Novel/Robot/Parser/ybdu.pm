# ABSTRACT: 一本读 http://www.ybdu.com
package Novel::Robot::Parser::ybdu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.ybdu.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//ul[@class="mulu_list"]//a', 'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          #process_first '//h1' , 'book' => 'TEXT';
          #process_first '//div[@class="book"]//span' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    ($ref->{book}) = $$html_ref=~/var articlename='(.+?)';/s;
    #var url_articleinfo='http://www.ybdu.com/xiazai/4/4996/';
    $ref->{writer}= '未名';

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="htmlContent"]', 'content' => 'HTML';
        process_first '//div[@class="h1title"]//h1', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    $ref->{content}=~s#<div class="ad00">.*##s;

    return $ref;
} ## end sub parse_chapter

1;
