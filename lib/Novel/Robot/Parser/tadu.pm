# ABSTRACT: 塔读文学 http://www.tadu.com
package Novel::Robot::Parser::tadu;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.tadu.com';

sub charset {
    'utf8';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;
    #http://www.tadu.com/book/356496/toc/

    my $parse_index = scraper {
        process '//div[@class="catalogList"]//a',
          'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//div[@class="c_title"]//h3' , 'book' => 'TEXT';
          process_first '//div[@class="catalog_top"]//a' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $h ) = @_;

    my $parse_chapter = scraper {
        #process_first '//div[@id="partContent"]', 'content' => 'HTML';
        process_first '//div[@class="title"]//h2', 'title'=> 'TEXT';
    };
    my $ref = $parse_chapter->scrape($h);
    my ($c) = $$h=~/\$\("#partContent"\)\.html\(unescape\("(.+?)"\)\)/s;
    $ref->{content} = $self->unescape_js($c);
    return $ref;
} ## end sub parse_chapter

1;
