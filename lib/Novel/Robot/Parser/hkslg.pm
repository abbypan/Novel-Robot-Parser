#ABSTRACT: 顺隆书院 http://www.hkslg.com/
package Novel::Robot::Parser::hkslg;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.hkslg.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//td[@class="bookinfo_td"]//div[@class="dccss"]//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h1' , 'book' => 'TEXT';
          process_first '//div[@class="infot"]//span' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作者：//;

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="content"]/p', 'content' => 'HTML';
        process_first '//h2', 'title'=> 'TEXT';
        process_first '//h1', 'book' => 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    return $ref;
} ## end sub parse_chapter

1;
