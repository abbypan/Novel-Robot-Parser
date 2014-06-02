#ABSTRACT: 落秋小说 http://www.luoqiu.com
package Novel::Robot::Parser::luoqiu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.luoqiu.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@class="booklist clearfix"]//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h1' , 'book' => 'TEXT';
          process_first '//span[@class="author"]' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作者：//;
    $ref->{book}=~s/最新章节$//;

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="content"]', 'content' => 'HTML';
        process_first '//h1[@class="bname_content"]', 'title'=> 'TEXT';
        process_first '//div[@class="border_b"]//a', 'book' => 'TEXT';
        process_first '//div[@class="border_b"]', 'writer' => 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    $ref->{book} ||='';
    $ref->{writer} ||='';
    $ref->{writer}=~s/^.*作者：(.+)?\s*书名.*/$1/s;

    return $ref;
} ## end sub parse_chapter

1;
