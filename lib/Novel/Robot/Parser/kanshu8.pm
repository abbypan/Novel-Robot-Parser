# ABSTRACT: 看书吧 http://www.kanshu8.net
package Novel::Robot::Parser::kanshu8;
use strict;
use warnings;
use utf8;
use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.kanshu8.net';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '//h1', 'book'   => 'HTML';
        process_first '//title', 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    $ref->{writer}=~s/^.+\((.+?)\)\,.+$/$1/;
    
    return $ref;
} ## end sub parse_index

sub parse_chapter_list {
    my ( $self, $r, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//td//div[@class="dccss"]//a',
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
        process_first '//div[@id="content"]',     'content' => 'HTML';
        process_first '//h2', 'title'   => 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    $ref->{content}=~s#<[^>]+>#\n#sg;

    return $ref;
} ## end sub parse_chapter

1;
