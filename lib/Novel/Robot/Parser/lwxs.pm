# ABSTRACT: 乐文小说 http://www.lwxs.com
package Novel::Robot::Parser::lwxs;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.lwxs.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//h1', 'book'   => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    ($ref->{writer})=$$html_ref=~m#最新章节\((.+?)\)#s;

    return $ref;
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
        process_first '//div[@id="TXT"]',     'content' => 'HTML';
        process_first '//div[@class="con_top"]', 'title'   => 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    $ref->{content}=~s/<[^>]+?>/<br \/>/sg;

    ($ref->{title})=~s#^.*</a>(.+?)</div>#s;

    return $ref;
} ## end sub parse_chapter

1;
