#ABSTRACT: 要看书 http://www.1kanshu.com
package Novel::Robot::Parser::kanshu;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.1kanshu.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//h1', 'book'   => 'HTML';
    };

    my $ref = $parse_index->scrape($html_ref);

    @{$ref}{qw/book writer/} = $ref->{book}=~m#《(.+?)》<span>作者:(.+?)</span>#s;
    
    return $ref;
} ## end sub parse_index

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@id="chapter"]//dd//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
      };
    my $ref = $parse_index->scrape($html_ref);
    my @list = sort { $a->{url} cmp $b->{url} } @{$ref->{chapter_list}};
    return \@list;
}

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="text_area"]',     'content' => 'HTML';
        process_first '//div[@id="chapter_title"]//h1', 'title'   => 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return $ref;
} ## end sub parse_chapter

1;
