# ABSTRACT: http://www.kanshuge.com
package Novel::Robot::Parser::kanshuge;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.kanshuge.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//table[@class="acss"]//td[@class="ccss"]//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h1' , 'book' => 'TEXT';
          process_first '//div[@id="info"]' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作者：//;
    $ref->{book}=~s/\s*最新章节\s*$//;

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="ok"]', 'content' => 'HTML';
        process_first '//h1', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    $ref->{title}=~s/^.*正文 //;
    return $ref;
} ## end sub parse_chapter

1;
