#ABSTRACT: 书农的解析模块
package Novel::Robot::Parser::Shunong;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Parser::Base';

use Web::Scraper;

has '+domain'  => ( default => sub {'http://www.shunong.com'} );
has '+site'    => ( default => sub {'Shunong'} );
has '+charset' => ( default => sub {'cp936'} );

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = scraper {
        process_first '.author', 'writer' => 'TEXT';
        process_first 'h1', 'book' => 'TEXT';
        process_first '.redbutt', 'book_url' => '@href';
        process '//div[@class="booklist clearfix"]//a', 'chapter_info[]' => {
            'title' => 'TEXT', 'url' => '@href'
        };
        };

    my $ref = $parse_index->scrape($html_ref);

    $ref->{writer}=~s/作者：//;
    $ref->{book}=~s/全文阅读//;

    $ref->{chapter_info} = [ grep { exists $_->{url} } @{$ref->{chapter_info}} ];
    $ref->{chapter_num} = scalar(@{ $ref->{chapter_info} });
    unshift @{$ref->{chapter_info}}, undef;

    my ($id) = $ref->{book_url}=~m#/(\d+).html$#;
    for my $i (1 .. $ref->{chapter_num}){
        my $r = $ref->{chapter_info}[$i];
        $r->{url}="$self->{domain}/yuedu/2/$id/$r->{url}";
        $r->{id} = $i;
    }

    return $ref;
} ## end sub parse_index

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    my $parse_chapter = scraper {
        process_first '.author', 'writer' => 'TEXT';
        process_first 'h2', 'book' => 'TEXT';
        process_first '//div[@class="bookcontent clearfix"]', 'content' => sub {
            $self->get_inner_html( $_[0] );
        };
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return unless ( defined $ref->{book} );
    $ref->{writer}=~s/作者：//;
    @{$ref}{'book', 'chapter'} = $ref->{book}=~/(.+?)最新章节：(.+)/;
    $ref->{content}=~s#<div[^>]+></div>##sg;
    $ref->{content}=~s#<script[^>]+></script>##sg;
    return $ref;
} ## end sub parse_chapter


no Moo;
1;
