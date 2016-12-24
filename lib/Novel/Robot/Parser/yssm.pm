# ABSTRACT: http://www.yssm.org
package Novel::Robot::Parser::yssm;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.yssm.org';

sub charset {
    'utf8';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//d[@class="chapterlist"]//dd//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
    };

    my $ref = $parse_index->scrape($html_ref);
    ($ref->{writer}) = $$html_ref=~m#<meta property="og:novel:author" content="(.+?)"/>#s;
    ($ref->{book}) = $$html_ref=~m#<meta property="og:novel:book_name" content="(.+?)"/>#s;

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="content"]', 'content' => 'HTML';
        process_first '//h1', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return $ref;
} ## end sub parse_chapter

1;
