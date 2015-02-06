# ABSTRACT: 言情记 http://www.yanqingji.com
package Novel::Robot::Parser::yanqingji;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.yanqingji.net';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@class="book_main"]//td/a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h1' , 'book' => 'TEXT';
          process_first '//h2/a' , 'writer' => 'TEXT';
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
        process_first '//p[@id="zoom"]', 'content' => 'HTML';
        process_first '//div[@class="book_title"]/h1[2]', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return $ref;
} ## end sub parse_chapter

1;
