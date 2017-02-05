# ABSTRACT: 乐文小说 http://www.xs82.com
package Novel::Robot::Parser::lewen;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.xs82.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//h1', 'book'   => 'TEXT';
        process_first '//div[@class="infot"]/span', 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    $ref->{writer}=~s/作者//;

    return $ref;
} ## end sub parse_index

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//ul[@class="chapterlist"]//a',
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
        process_first '//div[@id="content"]',     'content' => 'HTML';
        process_first '//h1',                     'title'   => 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    $ref->{content}=~s/<[^>]+?>/<br \/>/sg;

    return $ref;
} ## end sub parse_chapter

1;
