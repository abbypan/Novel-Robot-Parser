#ABSTRACT: 落秋小说 http://www.luoqiu.com
package Novel::Robot::Parser::luoqiu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

sub base_url { 'http://www.luoqiu.com' };

sub charset {
    'cp936';
}

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@class="booklist clearfix"]//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
      };

    my $ref = $parse_index->scrape($html_ref);
    my @res = 
        grep { $_->{url} } @{ $ref->{chapter_list} }
        ;
        return \@res;
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
          process_first '//h1' , 'book' => 'TEXT';
          process_first '//span[@class="author"]' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作者：\s*//;
    $ref->{book}=~s/\s*最新章节\s*$//;

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="content"]', 'content' => 'HTML';
        process_first '//h1[@class="bname_content"]', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    return $ref;
} ## end sub parse_chapter

1;
