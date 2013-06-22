#ABSTRACT: 书农的解析模块 http://www.shunong.com
=pod

=encoding utf8

=head1 FUNCTION

=head2 parse_index

=head2 parse_chapter

=cut
package Novel::Robot::Parser::Shunong;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Parser::Base';

use Web::Scraper;

has '+base_url'  => ( default => sub {'http://www.shunong.com'} );
has '+site'    => ( default => sub {'Shunong'} );
has '+charset' => ( default => sub {'cp936'} );

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '.author', 'writer' => 'TEXT';
        process_first 'h1', 'book' => 'TEXT';
        process_first '.redbutt', 'index_url' => '@href';
        process '//div[@class="booklist clearfix"]//a', 'chapter_info[]' => {
            'title' => 'TEXT', 'url' => '@href'
        };
        };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作者：//;
    $ref->{book}=~s/全文阅读//;

    $ref->{chapter_info} = [ grep { exists $_->{url} } @{$ref->{chapter_info}} ];

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '.author', 'writer' => 'TEXT';
        process_first 'h2', 'book' => 'TEXT';
        process_first '//div[@class="bookcontent clearfix"]', 'content' => 'HTML';
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return unless ( defined $ref->{book} );
    $ref->{writer}=~s/作者：//;
    @{$ref}{'book', 'title'} = $ref->{book}=~/(.+?)最新章节：(.+)/;
    $ref->{content}=~s#<div[^>]+></div>##sg;
    $ref->{content}=~s#<script[^>]+></script>##sg;
    $ref->{content}=~s#<a href="http://www.jidubook.com/".+?</a>##sg;
    $ref->{content}=~s#<a href="http://www.shunong.com/".+?</a>##sg;
    return $ref;
} ## end sub parse_chapter


no Moo;
1;
