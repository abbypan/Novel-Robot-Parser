#ABSTRACT: 绿晋江的解析模块
=pod

=encoding utf8

=head1 站点

    Jjwxc 

=head1 支持查询类型


    作品

    作者

    主角

    配角

    其他

=cut
package Novel::Robot::Parser::Jjwxc;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Parser::Base';

use HTML::TableExtract qw/tree/;
use Web::Scraper;
use Encode;

has '+base_url'  => ( default => sub {'http://www.jjwxc.net'} );
has '+site'    => ( default => sub {'Jjwxc'} );
has '+charset' => ( default => sub {'cp936'} );

sub make_chapter_url {
    my ( $self, $book_id, $chap_id ) = @_;
    return ( $book_id, $chap_id ) if ( $book_id =~ /^http:/ );

    my $url = "$self->{base_url}/onebook.php?novelid=$book_id&chapterid=$chap_id";

    return ( $url, $chap_id );
} ## end sub make_chapter_url

sub parse_chapter {

    my ( $self, $html_ref ) = @_;

    $self->format_chapter_before_parse($html_ref);

    my $parse_chapter = scraper {
        process_first '.noveltitle', 'book_info[]' => sub {
            return map { $_->as_trimmed_text } ( $_[0]->look_down( '_tag', 'a' ) )[ 0, 1 ];
        };
        process_first '.noveltext>div>h2', 'title' => sub {
            $_[0]->as_trimmed_text;
        };
        process_first '.readsmall', 'writer_say' => sub {
            my $_ = $self->get_inner_html( $_[0] );
            s/.*?<hr size="1" \/>//;
            $_;
        };
        process_first '#content', 'content' => sub {
            $self->get_inner_html( $_[0] );
        };
    };
    my $ref = $parse_chapter->scrape($html_ref);

    return unless ( defined $ref->{title} );
    @{$ref}{ 'book', 'writer' } = @{ $ref->{book_info} };
    return $ref;
} ## end sub parse_chapter

sub format_chapter_before_parse {
    my ( $self, $chapter_content_ref ) = @_;

    for ($$chapter_content_ref) {
        s{<font color='#E[^>]*'>.*?</font>}{}gis;
        s{<font color='#cccccc'>.*?</font>}{}gis;
        s{<script .*?</script>}{}gis;
        s{(</title></p>)}{$1<div id="content">};
        s{(<div style="clear:both;"></div>)}{$1<div id="content">};
        s{(<div id="favoriteshow.?3")}{</div>$1};
        s{(<div align="center" id="favoriteshow_3")}{</div>$1};
        s{<div align="right">\s*<div[^>]+id="report_menu1".+?</div>\s*</div>\s*</div>}{}si;
    } ## end for ($$chapter_content_ref)

} ## end sub format_chapter_before_parse

sub make_index_url {
    my ( $self, $book_id ) = @_;
    return $book_id if ( $book_id =~ /^http:/ );
    my $url = $self->{base_url} . "/onebook.php?novelid=" . $book_id;
    return $url;
} ## end sub make_index_url

sub parse_index {

    my ( $self, $html_ref ) = @_;

    return if ( $$html_ref =~ /自动进入被锁文章的作者专栏/);
    $self->format_index_before_parse($html_ref);

    my $parse_index = scraper {
        process_first '.cytable>tbody>tr>td.sptd>span.bigtext', 'book' => 'TEXT';
        process_first '.cytable>tbody>tr>.sptd>h2>a', 'writer'     => 'TEXT', 'writer_url' => '@href';
        process_first '.readtd>.smallreadbody', 'intro' => sub {
            my $intro =
                   $_[0]->look_down( '_tag', 'div', 'style', 'clear:both' )
                || $_[0]->look_down( '_tag', 'div' )
                || $_[0];

            my $_ = $self->get_inner_html($intro);
            s#</?font[^<]*>\s*##gis;
            return $_;
        };
        process_first '#series', 'series' => 'TEXT';
        process_first '#progress', 'progress' => 'TEXT';
        process_first '#word_num', 'word_num' => 'TEXT';

        process_first '.cytable', 'book_info' => sub {
            my $book_info = $_[0];

            my $red = $book_info->look_down( '_tag', 'span', 'class', 'redtext' );
            $red->delete if($red);

            return $book_info->as_HTML('<>&');
        };
    };

    my $ref = $parse_index->scrape($html_ref);
    return $self->parse_index_with_single_chapter($html_ref) unless ( $ref->{book} ) ;

    $self->parse_chapter_info($ref);

    return $ref;
} ## end sub parse_index

sub parse_chapter_info {
    my ($self, $ref) = @_;

    #是否锁文
    unless ( $ref->{book_info} ) {
        $ref->{chapter_num} = 0;
        return $ref;
    }

    my $te = HTML::TableExtract->new();
    $te->parse( $ref->{book_info} );
    my $table = $te->first_table_found;
    my $row   = $#{ $table->rows } - 1;

    my $table_tree = $table->tree;
    my $volume_name;
    for my $i ( 3 .. $row ) {
        my $first = $table_tree->cell( $i, 0 );
        if ( my $volume = $first->look_down( 'class', 'volumnfont' ) ) {

            #分卷了
            $volume_name = $volume->as_trimmed_text;
        }
        else {
            my %chap;

            $chap{id} = $first->as_trimmed_text;
            $chap{title} = $table_tree->cell( $i, 1 )->as_trimmed_text;
            $chap{type} = $self->format_chapter_type($chap{title});
            $chap{url} = $table_tree->cell( $i, 1 )->extract_links()->[0]->[0];
            $chap{abstract} = $table_tree->cell( $i, 2 )->as_trimmed_text;
            $chap{num}      = $table_tree->cell( $i, 3 )->as_trimmed_text;
            $chap{time}     = $table_tree->cell( $i, 5 )->as_trimmed_text;

            if ( defined $volume_name ) {
                $chap{volume} = $volume_name;
                $volume_name = undef;
            }

            push @{ $ref->{chapter_info} }, \%chap;
        } ## end else [ if ( my $volume = $first...)]
    } ## end for my $i ( 3 .. $row )

    $ref->{chapter_num} = scalar(@{ $ref->{chapter_info} } ) unless ( exists $ref->{chapter_num} );
    unshift @{$ref->{chapter_info}}, undef;

    return $ref;
}

sub format_chapter_type {
    my ($self, $title) = @_;
            my $type =
                  $title =~ /\[VIP\]$/ ? 'vip'
                : $title =~ /\[锁\]$/ ? 'lock'
                :                                   'normal';
                return $type;
}

sub parse_index_with_single_chapter {
    my ($self, $html_ref) = @_;

    my $ref = {};

    #只有一个章节
    $ref->{chapter_num} = 1;

    my $refine_one_chap = scraper {
        process_first '.bigtext', 'book' => sub { $_[0]->as_trimmed_text };
        process_first '//td[@class="noveltitle"]/h1/a', 'index_url' => '@href';
        process_first '//td[@class="noveltitle"]/a',
        'writer'     => 'TEXT',
        'writer_url' => '@href';
        process_first '//h2', 'chap_title' => 'TEXT';
    };
    my $temp_ref = $refine_one_chap->scrape($html_ref);
    my @temp_fields = ( 'book', 'writer', 'writer_url', 'index_url' );
    @{$ref}{@temp_fields} = @{$temp_ref}{@temp_fields};

    my %chap;
    $chap{id}                           = 1;
    $chap{title}                        = $temp_ref->{chap_title};
    $chap{abstract}                     = $chap{title};
    $chap{num}                          = $ref->{word_num};
    $ref->{chapter_info}[ $chap{id} ]{url} = $ref->{index_url} . '&chapterid=1';
    push @{ $ref->{chapter_info} }, \%chap;
    return $ref;

    } ## end unless ( $ref->{book} )

sub format_index_before_parse {
    my ( $self, $html_ref ) = @_;
    for ($$html_ref) {
        s{<span>所属系列：</span>(.*?)</li>}{<span id='series'>$1</span></li>}s;
        s{<span>文章进度：</span>(.*?)</li>}{<span id='progress'>$1</span></li>}s;
        s{<span>全文字数：</span>(\d+)字</li>}{<span id='word_num'>$1</span></li>}s;
    }
} ## end sub format_index_before_parse

sub make_writer_url {

    my ( $self, $writer_id ) = @_;
    return $writer_id if ( $writer_id =~ /^http:/ );
    return qq[$self->{base_url}/oneauthor.php?authorid=$writer_id];
} ## end sub make_writer_url

sub parse_writer {
    my ( $self, $html_ref ) = @_;
    my @series_book;
    my $series;
    my $parse_writer = scraper {
        process_first '//tr[@valign="bottom"]//b', writer => sub { $_[0]->as_trimmed_text };
        process '//tr[@bgcolor="#eefaee"]', 'series[]' => sub {
            my $tr = $_[0];
            if ( my $se = $tr->look_down( 'colspan', '7' ) ) {

                ($series) = $tr->as_trimmed_text =~ /【(.*)】/;
            }
            else {

                my $book = $tr->look_down( '_tag', 'a' );
                return unless ($book);
                my $bookname = $book->as_trimmed_text;
                substr( $bookname, 0, 1 ) = '';

                $bookname .= '[锁]'
                    if ( $tr->look_down( 'color', 'gray' ) );
                my $progress = ( $tr->look_down( '_tag', 'td' ) )[4]->as_trimmed_text;

                $series ||= '未分类';
                push @series_book,
                    [ $series, "$bookname($progress)",
                    $self->{base_url} . '/' . $book->attr('href') ];

            } ## end else [ if ( my $se = $tr->look_down...)]
            return;

        };
    };

    my $ref = $parse_writer->scrape($html_ref);
    $ref->{series} = \@series_book;

    return $ref;
} ## end sub parse_writer

sub make_query_url {

    my ( $self, $type, $keyword ) = @_;
    my %Query_Type = (
        '作品' => '1',
        '作者' => '2',
        '主角' => '4',
        '配角' => '5',
        '其他' => '6',
    );

    my $url = qq[$self->{base_url}/search.php?kw=$keyword&t=$Query_Type{$type}];

    return $url;
} ## end sub make_query_url

sub get_query_result_urls {

    ###查询结果为多页
    my ( $self, $html_ref ) = @_;

    my $parse_query = scraper {
        process '//div[@class="page"]/a', 'urls[]' => sub {
            return unless ( $_[0]->as_text =~ /^\[\d*\]$/ );
            my $url = $self->{base_url} . ( $_[0]->attr('href') );
            $url = encode( $self->{charset}, $url );
            return $url;
        };
    };
    my $ref = $parse_query->scrape($html_ref);

    return $ref;
} ## end sub get_query_result_urls

sub parse_query {
    my ( $self, $html_ref ) = @_;

    my $parse_query = scraper {
        process '//h3[@class="title"]', 'books[]' => sub {
            my $book = $_[0]->look_down( '_tag', 'a' );
            my ($novelid) = $book->attr('href') =~ /novelid=(\d*)/;
            $book = $book->as_trimmed_text;
            return [ $book, $novelid ];
        };
        process '//div[@class="info"]', 'writers[]' => sub {
            my $writer = $_[0]->look_down( '_tag', 'a' )->as_trimmed_text;
            my ($progress) = $_[0]->as_text =~ /进度：(\S+)\s*┃/s;
            return [ $writer, $progress ];

        };
    };
    my $ref = $parse_query->scrape($html_ref);

    my @result;
    foreach my $i ( 0 .. $#{ $ref->{books} } ) {
        my ( $bookname,   $novelid )  = @{ $ref->{books}[$i] };
        my ( $writername, $progress ) = @{ $ref->{writers}[$i] };
        push @result, [ $writername, "$bookname($progress)", $self->make_index_url($novelid) ];
    }
    return \@result;
} ## end sub parse_query

no Moo;
1;
