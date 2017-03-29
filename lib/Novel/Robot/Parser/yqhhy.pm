# ABSTRACT: 言情后花园 http://www.yqhhy.cc
package Novel::Robot::Parser::yqhhy;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

sub base_url {  'http://www.yqhhy.cc' }

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//div[@id="readtext"]//td/a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h1' , 'book' => 'TEXT';
          process_first '//div[@id="info"]' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);
    $ref->{writer}=~s/作者：//;

    $ref->{chapter_list} = [
        grep { $_->{url} } @{ $ref->{chapter_list} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//div[@id="content"]', 'content' => 'HTML';
        process_first '//h1', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    $ref->{content}=~s#<span style="display:none">[^<]+</span>##sgi;
    $ref->{content}=~s#<script [^>]+>[^<]*</script>##sgi;

    return $ref;
} ## end sub parse_chapter

1;
