#ABSTRACT: 努努书坊的解析模块 http://book.kanunu.org
=pod

=encoding utf8

=head1 FUNCTION

=head2 parse_index

=head2 parse_chapter

=cut
package Novel::Robot::Parser::Nunu;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Parser::Base';

use Web::Scraper;

has '+base_url' => ( default => sub { 'http://book.kanunu.org' } );
has '+site'     => ( default => sub { 'Nunu' } );
has '+charset'  => ( default => sub { 'cp936' } );

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process '//tr[@bgcolor="#ffffff"]//td//a',
          'chapter_info[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
          };
          process_first '//h2//b' , 'book' => 'TEXT';
          process_first '//font//strong' , 'writer' => 'TEXT';
    };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作品集.*//s;
    $ref->{writer}=~s/^→//;

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

no Moo;
1;
