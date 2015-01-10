# ABSTRACT: 天天小说 http://www.day66.com
package Novel::Robot::Parser::day66;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.day66.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//h1', 'book'   => 'TEXT';
        process_first '//div[@class="directory_title"]//span/a', 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    return $ref;
} ## end sub parse_index

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@class="directory_con"]//li//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
      };
    my $ref = $parse_index->scrape($html_ref);
    return $ref->{chapter_list};
}

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="htmlContent"]',     'content' => 'HTML';
        process_first '//h1',                     'title'   => 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return $ref;
} ## end sub parse_chapter

1;
