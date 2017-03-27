# ABSTRACT: http://www.biquge.tw
package Novel::Robot::Parser::biquge;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.biquge.tw';

sub charset {
    'utf8';
}

sub parse_index {

    my ( $self, $hr ) = @_;

    my ($wn) = $$hr=~m#<meta property="og:novel:author" content="(.+?)"/>#s;
    my ($bn) = $$hr=~m#<meta property="og:title" content="(.+?)"/>#s; 
    
    return {
        writer => $wn, 
        book => $bn, 
    };
} ## end sub parse_index

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@id="list"]//dd//a',
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

    return $ref;
} ## end sub parse_chapter

1;
