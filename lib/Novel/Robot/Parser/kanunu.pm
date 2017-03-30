# ABSTRACT: http://www.kanunu8.com
package Novel::Robot::Parser::kanunu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

sub base_url { 'http://www.kanunu8.com' }


sub scrape_chapter_list { { path => '//tr[@bgcolor="#ffffff"]//td//a',  } }

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//h2',        'book_h2' => 'TEXT';
        process_first '//h1',        'book_h1' => 'TEXT';
        #process_first '//font//strong', 'writer'  => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    $ref->{book} = $ref->{book_h2} || $ref->{book_h1};

    ($ref->{writer})= $$html_ref=~/作者：(\S+) 发布时间：/s;

    return $ref;
} ## end sub parse_index

sub scrape_chapter { {
        title => { regex => '<title>\s*(.+?)_.+?_\s*.+? 小说在线阅读' }, 
        content=>{ path => '//td[@width="820"]', extract => 'HTML' }, 
    } }

#sub parse_chapter {
#
#    my ( $self, $h ) = @_;
#
#    my $parse_chapter = scraper {
#        process_first '//td[@width="820"]', 'content' => 'HTML';
#    };
#    my $ref = $parse_chapter->scrape($h);
#
#    ( $ref->{title} ) =
#      $$h =~ m#<title>\s*(.+?)_.+?_\s*.+? 小说在线阅读#s;
#
#    return $ref;
#} ## end sub parse_chapter

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
