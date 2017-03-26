# ABSTRACT:  http://m.xiaoxiaoshuwu.com
package Novel::Robot::Parser::xiaoxiaoshuwu;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://m.xiaoxiaoshuwu.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//h3', 'book'   => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    ($ref->{writer})= $$html_ref=~m#是由作家(.+?)所作#s;

    return $ref;
} ## end sub parse_index

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//ul[@class="chapter"]//a',
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
        process_first '//div[@id="chapterContent"]',     'content' => 'HTML';
        process_first '//div[@id="nr_title"]',                     'title'   => 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    $ref->{content}=~s/<[^>]+?>/<br \/>/sg;

    return $ref;
} ## end sub parse_chapter

1;
