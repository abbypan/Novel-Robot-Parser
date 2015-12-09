# ABSTRACT: 少年文学网 www.snwx.com
package Novel::Robot::Parser::snwx;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';

use Web::Scraper;

sub base_url { 'http://www.snwx.com'}

sub charset {
    'cp936';
}

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@id="list"]//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
      };
    my $ref = $parse_index->scrape($html_ref);
    my @ch = sort { $a->{url} cmp $b->{url} } @{$ref->{chapter_list}};
    return \@ch;

}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
          process_first '//div[@class="infotitle"]//h1' , 'book' => 'TEXT';
          process_first '//div[@class="infotitle"]//i' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    $ref->{writer}=~s/作者.*?\*//;
    $ref->{writer}=~s/作者：//;
    $ref->{writer}=~s/\*//g;

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="BookText"]', 'content' => 'HTML';
        process_first '//div[@class="bookname"]//h1', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return $ref;
} ## end sub parse_chapter

1;
