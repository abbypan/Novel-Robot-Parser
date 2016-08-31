# ABSTRACT: 梦远书城
package Novel::Robot::Parser::my285;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://my285.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//table[@bgcolor="#FFC751"]//td/a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
    };

    my $ref = $parse_index->scrape($html_ref);

    @{$ref}{qw/book writer/} = $$html_ref=~/<title>(.+?)全文\|(.+?)\_/s;

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//td[@height="30"]', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    ($ref->{content}) = $$html_ref=~/<td colspan="2">(.+?)<\/td>/s;
    if(! $ref->{content}){
    ($ref->{content}) = $$html_ref=~/<p style="line-height: 150%">(.+?)<\/td>/s;
    }

    return $ref;
} ## end sub parse_chapter

1;
