#ABSTRACT: 豆豆小说阅读网
=pod

=encoding utf8

=head1 站点

    Dddbbb

=head1 支持查询类型

    作品

    作者

    主角

=cut
package Novel::Robot::Parser::Dddbbb;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Parser::Base';

use Web::Scraper;
use Encode;

has '+base_url'  => ( default => sub {'http://www.dddbbb.net'} );
has '+site'    => ( default => sub {'Dddbbb'} );
has '+charset' => ( default => sub {'cp936'} );

sub make_index_url {
    my ( $self, $id_1, $id_2 ) = @_;
    return $id_1 if ( $id_1 =~ /^http/ );
    return "$self->{base_url}/$id_1/$id_2/index.html";
} ## end sub make_index_url

sub parse_index {

    my ( $self, $html_ref ) = @_;

    my $parse_index = 
    
          $$html_ref =~ /<h2 id="lc">/  ? 
    scraper {
        process_first '#lc', 'book_info' => sub {
            my ( $writer, $book ) = ( $_[0]->look_down( '_tag', 'a' ) )[ 2, 3 ];
            return [
                $writer->as_trimmed_text, $self->{base_url} . $writer->attr('href'),
                $book->as_trimmed_text,   $self->{base_url} . $book->attr('href')
            ];
        };
        process_first '//table[@width="95%"]//td[2]', 'intro' => sub {
            $_[0]->look_down( '_tag', 'script' )->delete;
            $self->get_inner_html( $_[0] );
        };
    }
    :
    scraper {
        process_first '.cntPath', 'book_info' => sub {
            my ( $writer, $book ) = ( $_[0]->look_down( '_tag', 'a' ) )[ 3, 4 ];
            return [
                $writer->as_trimmed_text, $writer->attr('href'),
                $book->as_trimmed_text,   $book->attr('href')
            ];
        };
        process_first '.bookintro', 'intro' => sub { $self->get_inner_html( $_[0] ) };
    };


    my $ref = $parse_index->scrape($html_ref);

    @{$ref}{ 'writer', 'writer_url', 'book', 'index_url' } = @{ $ref->{book_info} };

    ( my $book_info_url = $ref->{index_url} ) =~ s#index.html$#opf.html#;
    $ref->{book_info_urls}{$book_info_url} = sub { $self->parse_chapter_info(@_) };

    return $ref;
} ## end sub parse_index

sub parse_chapter_info {

    #章节信息
    my ( $self, $ref, $html_ref ) = @_;

    my $refine_engine = scraper {
        process '//div[@class="opf"]//a', 'chapter_info[]' => {
            title => 'TEXT', 
            url => '@href',
        }; 
    };
    
    my $r = $refine_engine->scrape($html_ref);
    $ref->{chapter_info} = $r->{chapter_info};

    $ref->{chapter_num} = scalar(@{ $ref->{chapter_info} });
    unshift @{ $ref->{chapter_info} }, undef;

    for my $i ( 1 .. $ref->{chapter_num}){
        my $r = $ref->{chapter_info}[$i];
        $r->{url}="$self->{base_url}$r->{url}";
        $r->{id} = $i;
    }

    return $ref;
} ## end sub parse_chapter_info

sub make_chapter_url {
    my ( $self, $book_id, $chapter_id, $id ) = @_;
    return ( $book_id, $chapter_id ) if ( $book_id =~ /^http/ );
    my $url = "$self->{base_url}/${book_id}_$chapter_id.html";
    return ( $url, $id );
} ## end sub make_chapter_url

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    $$html_ref=~s#\<img[^>]+dou\.gif[^>]+\>#，#g;

    my $parse_chapter = scraper {
        process_first '#toplink', 'book_info' => sub {
            my ( $writer, $book ) =
                map { $_->as_trimmed_text } ( $_[0]->look_down( '_tag', 'a' ) )[ 3, 4 ];
            return [ $book, $writer ];
        };
        process_first '.mytitle', 'title' => sub { $_[0]->as_trimmed_text };
        process_first '#content', 'content' => sub { $self->get_inner_html( $_[0] ) };
    };
    my $ref = $parse_chapter->scrape($html_ref);

    @{$ref}{ 'book', 'writer' } = @{ $ref->{book_info} };

    $ref->{content}=~s#<script[^>]+></script>##sg;
    $ref->{content}=~s#<div[^>]+></div>##sg;

    return $ref;
} ## end sub parse_chapter


sub make_writer_url {

    my ( $self, $writer_id ) = @_;
    return $writer_id if ( $writer_id =~ /^http/ );
    return "$self->{base_url}/html/author/$writer_id.html";
} ## end sub make_writer_url

sub parse_writer {

    my ( $self, $html_ref ) = @_;

    my $parse_writer = scraper {
        process_first '#list',
            writer => sub { ( $_[0]->look_down( '_tag', 'font' ) )[0]->as_trimmed_text };
        process_first '#border_1', series => sub {
            my @books = $_[0]->look_down( '_tag', 'ul' );
            shift(@books);
            my @urls;
            for my $book (@books) {
                my $url = $book->look_down( 'id', 'idname' )->look_down( '_tag', 'a' );
                next unless ( defined $url );

                my $series = $book->look_down( 'id', 'idzj' )->as_text;
                $series =~ s/\s*(\S*)\s*.*$/$1/;

                my $bookname = $url->as_trimmed_text;
                push @urls, [ $series, $bookname, $self->{base_url} . $url->attr('href') ];
            } ## end for my $book (@books)
            return \@urls;
        };
    };

    my $ref = $parse_writer->scrape($html_ref);

    return $ref;
} ## end sub parse_writer

sub make_query_url {

    my ( $self, $type, $keyword ) = @_;

    my $url = $self->{base_url} . '/search.php';

    my %Query_Type = ( '作品' => 'name', '作者' => 'author', '主角' => 'main', );

    return (
        $url,
        {   'keyword' => $keyword,
            'select'  => $Query_Type{$type},
            'Submit'  => encode( $self->{charset}, '搜索' ),
        },
    );

} ## end sub make_query_url

sub parse_query {

    my ( $self, $html_ref ) = @_;
    my $parse_query = scraper {
        process '//h3', 'books[]' => sub {
            my $bookname = $_[0]->look_down( '_tag', 'a' );
            return unless ( defined $bookname );
            my ($bname) = $bookname->as_trimmed_text;
            my $writer = $_[0]->right->look_down( '_tag', 'a' )->as_trimmed_text;
            return [ $writer, $bname, $self->{base_url} . $bookname->attr('href') ];
        };
    };
    my $ref = $parse_query->scrape($html_ref);

    return $ref;
} ## end sub parse_query

1;
