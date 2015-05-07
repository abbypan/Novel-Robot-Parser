# ABSTRACT: 千千小说
package Novel::Robot::Parser::qqxs;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.qqxs.cc';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@id="list"]//dd/a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//div[@id="intro"]/h3', book => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{book}=~s/^.*?《//s;
    $ref->{book}=~s/》.*$//s;
    @{$ref}{qw/writer/} = $$html_ref=~/作者([^\n]+?)所写的/s;

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@class="bookname"]/h1', 'title'=> 'TEXT';
        process_first '//div[@id="booktext"]', content=> 'HTML';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    $ref->{title}=~s/^.*?\s+//s;
    $ref->{content}=~s/<[^>]+>/<br>/sg;
    return $ref;
} ## end sub parse_chapter

1;
