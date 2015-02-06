# ABSTRACT: 紫琅文学 http://www.zilang.net
package Novel::Robot::Parser::zilang;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.zilang.net';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@class="list"]//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h1' , 'book' => 'TEXT';
          process_first '//div[@class="book"]//span' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    $ref->{book}=~s/《(.*)》/$1/;

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="text_area"]', 'content' => 'HTML';
        process_first '//h1', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return $ref;
} ## end sub parse_chapter

1;
