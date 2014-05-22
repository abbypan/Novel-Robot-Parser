#ABSTRACT: 爱尚小说 http://www.23hh.com
package Novel::Robot::Parser::asxs;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';
use Web::Scraper;

our $BASE_URL = 'http://www.23hh.com';

sub charset {
    'cp936';
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//table[@id="at"]//td[@class="L"]//a',
          'chapter_info[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h1' , 'book' => 'TEXT';
          process_first '//h3' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作者：//;
    $ref->{book}=~s/\s*最新章节\s*$//;

    $ref->{chapter_info} = [
        grep { $_->{url} } @{ $ref->{chapter_info} }
    ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '//dd[@id="contents"]', 'content' => 'HTML';
        process_first '//h1', 'title'=> 'TEXT';
        process_first '//dl', 'book' => 'HTML';
    };
    my $ref = $parse_chapter->scrape($html_ref);
    $ref->{book} ||='';
    $ref->{book}=~s#.*<a href="[^>]+">([^<]+)</a>.*#$1#s;
    $ref->{writer}='';

    return unless ( defined $ref->{book} );
    return $ref;
} ## end sub parse_chapter

1;
