#ABSTRACT: 努努书坊的解析模块 http://book.kanunu.org
package Novel::Robot::Parser::Nunu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

use Web::Scraper;

our $BASE_URL = 'http://book.kanunu.org';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//tr[@bgcolor="#ffffff"]//td//a',
          'chapter_info[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h2//b' , 'book_h2' => 'TEXT';
          process_first '//h1//b' , 'book_h1' => 'TEXT';
          process_first '//font//strong' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作品集.*//s;
    $ref->{writer}=~s/^→//;
    $ref->{book} = $ref->{book_h2} || $ref->{book_h1};

    $ref->{chapter_info} = [ grep { exists $_->{url} } @{ $ref->{chapter_info} } ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//td[@width="820"]', 'content' => 'HTML';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    @{$ref}{qw/title book writer/} =
      $$html_ref =~ m#<title>\s*(.+?)_(.+?)_\s*(.+?) 小说在线阅读#s;

    return unless ( defined $ref->{book} );
    return $ref;
} ## end sub parse_chapter

sub parse_writer {

    my ( $self, $html_ref ) = @_;

    my $parse_writer = scraper {
        process_first '//h2/b', writer => 'TEXT';
        process '//tr//td//a', 'booklist[]' => {
            url => '@href', book => 'TEXT'
        };
    };

    my $ref = $parse_writer->scrape($html_ref);

    $ref->{writer}=~s/作品集//;
    $ref->{booklist} = [ grep { $_->{url} and 
        ( $_->{url}=~/index.html$/ or $_->{url}=~m#/\d+/$#) } 
        @{$ref->{booklist}} ]; 
    return $ref;
} ## end sub parse_writer

1;
