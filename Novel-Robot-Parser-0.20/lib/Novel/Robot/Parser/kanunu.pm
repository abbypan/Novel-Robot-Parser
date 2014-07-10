#ABSTRACT: 努努书坊 http://book.kanunu.org
package Novel::Robot::Parser::kanunu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

sub base_url {
    'http://book.kanunu.org';
}

sub charset {
    'cp936';
}

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;
    my $parse_index = scraper {
        process '//tr[@bgcolor="#ffffff"]//td//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
    };
    my $ref = $parse_index->scrape($html_ref);
    my @res = grep { exists $_->{url} } @{ $ref->{chapter_list} };
    return \@res;
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//h2//b',        'book_h2' => 'TEXT';
        process_first '//h1//b',        'book_h1' => 'TEXT';
        process_first '//font//strong', 'writer'  => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer} =~ s/作品集.*//s;
    $ref->{writer} =~ s/^→//;
    $ref->{book} = $ref->{book_h2} || $ref->{book_h1};

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $h ) = @_;

    my $parse_chapter = scraper {
        process_first '//td[@width="820"]', 'content' => 'HTML';
    };
    my $ref = $parse_chapter->scrape($h);

    ( $ref->{title} ) =
      $$h =~ m#<title>\s*(.+?)_.+?_\s*.+? 小说在线阅读#s;

    return $ref;
} ## end sub parse_chapter

sub parse_board {

    my ( $self, $html_ref ) = @_;

    my $parse_writer = scraper {
        process_first '//h2/b', writer => 'TEXT';
    };

    my $ref = $parse_writer->scrape($html_ref);

    $ref->{writer} =~ s/作品集//;
    return $ref->{writer};
} ## end sub parse_writer

sub parse_board_items {
    my ( $self, $html_ref ) = @_;

    my $parse_writer = scraper {
        process '//tr//td//a',
          'booklist[]' => {
            url  => '@href',
            book => 'TEXT'
          };
    };

    my $ref = $parse_writer->scrape($html_ref);

    my @books = grep {
        $_->{url}
          and
          ( $_->{url} =~ /index.html$/ or $_->{url} =~ m#/\d+/$# )
    } @{ $ref->{booklist} };
    return \@books;

}

1;
