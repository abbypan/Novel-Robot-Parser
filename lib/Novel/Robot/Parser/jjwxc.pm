#ABSTRACT: 绿晋江 http://www.jjwxc.net
=pod

=encoding utf8

=head1 FUNCTION

=head2 make_query_request

  #$type：作品，作者，主角，配角，其他
  
  $parser->make_query_request( $type, $keyword );

=cut

package Novel::Robot::Parser::jjwxc;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

use Web::Scraper;
use Encode;

our $BASE_URL = 'http://www.jjwxc.net';

sub charset {
    'cp936';
}

sub parse_chapter {
    my ( $self, $html_ref ) = @_;

    $$html_ref =~ s{<font color='#E[^>]*'>.*?</font>}{}gis;

    my %chap;

    @chap{qw/title content/} =
      $$html_ref =~ m#<h2>(.+?)</h2>(.+?)<div id="favoriteshow.?3"#s;
    return unless ( $chap{content} );
    for($chap{content}){
        s{</?div[^>]*>}{}sgi;
        s/^\s*//s;
        #s{<br\s*/?\s*>}{\n}sgi;
        #s{<p\s+[^>]*>}{}sgi;
        #s{<p\s*>}{}sgi;
        #s{</p>}{\n\n}sgi;
        #s{\n\n\n*}{\n\n}sg;
        #s{\S.*?\n}{\n<p>$&</p>}sg;
    }

    @chap{qw/book writer/} = $$html_ref =~ m#<title>《(.+?)》(.+?)　ˇ#s;

    ( $chap{writer_say} ) =
      $$html_ref =~
m#<div class=readsmall[^>]+><hr[^>]+>作者有话要说：</br>(.+?)</div>#s;
    return \%chap;
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    return if ( $$html_ref =~ /自动进入被锁文章的作者专栏/ );

    my $parse_index = scraper {
        process_first '//h1[@itemprop="name"]',
          'book' => 'TEXT';
        process_first '//h2/a',
          'writer_url' => '@href';
        process_first '//span[@itemprop="author"]',
          'writer'     => 'TEXT';
        process_first '.readtd>.smallreadbody',
          'intro' => sub { $self->get_book_intro(@_); };
    };

    my $ref = $parse_index->scrape($html_ref);

    ( $ref->{series} ) =
      $$html_ref =~ m{<span>所属系列：</span>(.*?)</li>}s;
    ( $ref->{progress} ) =
      $$html_ref =~ m{<span>文章进度：</span>(.*?)</li>}s;
    ( $ref->{word_num} ) =
      $$html_ref =~ m{<span>全文字数：</span>(\d+)字</li>}s;
    for my $key (qw/series progress/){
        $ref->{$key}=~s/<[^>]+>|^\s+|\s+$//gs;
    }

    return $self->parse_index_just_one_chapter($html_ref)
      unless ( $ref->{book} );

    $self->parse_book_chapter_info( $ref, $html_ref );

    return $ref;
} ## end sub parse_index

sub get_book_intro {
    my ( $self, $e ) = @_;
    my $intro =
         $e->look_down( '_tag', 'div', 'style', 'clear:both' )
      || $e->look_down( '_tag', 'div' )
      || $e;

    my $intro_html = $intro->as_HTML('<>&');
    my $h          = $self->get_inner_html($intro_html);
    $h =~ s#</?font[^<]*>\s*##gis;

    return $h;
}

sub get_book_chapter_info_html {
    my ( $self, $book_info ) = @_;

    my $red = $book_info->look_down( '_tag', 'span', 'class', 'redtext' );
    $red->delete if ($red);

    return $book_info->as_HTML('<>&');
}

sub parse_index_just_one_chapter {
    my ( $self, $html_ref ) = @_;

    my $refine_one_chap = scraper {
        process_first '.bigtext',                       'book'      => 'TEXT';
        process_first '//td[@class="noveltitle"]/h1/a', 'index_url' => '@href';
        process_first '//td[@class="noveltitle"]/a',
          'writer'     => 'TEXT',
          'writer_url' => '@href';
        process_first '//h2', 'chap_title' => 'TEXT';
    };
    my $ref = $refine_one_chap->scrape($html_ref);

    my %chap = (
        id       => 1,
        title    => $ref->{chap_title},
        abstract => $ref->{chap_title},
        num      => $ref->{word_num},
        url      => $ref->{index_url} . '&chapterid=1',
    );
    push @{ $ref->{chapter_info} }, \%chap;
    delete( $ref->{chap_title} );

    return $ref;

} ## end unless ( $ref->{book} )

sub parse_book_volume {
    my ( $self, $ref, $cell ) = @_;

    my $volume = $cell->look_down( 'class', 'volumnfont' );
    return unless ($volume);

    my $id = $ref->{main_chapter_id} + 1;
    $ref->{volume}{$id} = $volume->as_trimmed_text;
    return $id;
}

sub parse_book_chapter_info {
    my ( $self, $ref, $html_ref ) = @_;

    my $s = scraper {
        process '//tr[@itemtype="http://schema.org/Chapter"]', 'chap[]' => scraper {
            process '//td',      'info[]' => 'TEXT';
            process_first '//a', 'url'    => '@href';
        };
    };
    my $r      = $s->scrape($html_ref);
    my $chaps  = $r->{chap};
    my @fields = qw/id title abstract word_num time/;
    for my $c (@$chaps) {
        my $info = $c->{info};
        $c->{ $fields[$_] } = $info->[$_] for ( 0 .. 4 );
        $c->{type} = $self->format_chapter_type( $c->{title} );
        $c->{id} =~ s/\s+//g;
        delete( $c->{info} );
    }

    $ref->{main_chapter_id} = scalar(@$chaps);

    $ref->{chapter_info} = $chaps;
    return $ref;
}

sub format_chapter_type {
    my ( $self, $title ) = @_;
    my $type =
        $title =~ /\[VIP\]$/ ? 'vip'
      : $title =~ /\[锁\]$/ ? 'lock'
      :                        'normal';
    return $type;
}

sub parse_writer {
    my ( $self, $html_ref ) = @_;
    my @series_book;
    my $series = '未分类';

    my $parse_writer = scraper {
        process_first '//tr[@valign="bottom"]//b', writer => 'TEXT';

        process '//tr[@bgcolor="#eefaee"]', 'booklist[]' => sub {
            my $tr = $_[0];
            $series = $self->parse_writer_series( $tr, $series );

            my $book = $self->parse_writer_book( $tr, $series );
            push @series_book, $book if ($book);
        };
    };

    my $ref = $parse_writer->scrape($html_ref);
    $ref->{booklist} = \@series_book;
    $ref->{writer} =~ s/^\s*//;

    return $ref;
} ## end sub parse_writer

sub parse_writer_series {
    my ( $self, $tr, $series ) = @_;

    return $series unless ( $tr->look_down( 'colspan', '7' ) );

    if ( $tr->as_trimmed_text =~ /【(.*)】/ ) {
        $series = $1;
    }

    return $series;
}

sub parse_writer_book {
    my ( $self, $tr, $series ) = @_;

    my $book = $tr->look_down( '_tag', 'a' );
    return unless ($book);

    my $book_url = $book->attr('href');

    my $bookname = $book->as_trimmed_text;
    substr( $bookname, 0, 1 ) = '';
    $bookname .= '[锁]' if ( $tr->look_down( 'color', 'gray' ) );

    my $progress = ( $tr->look_down( '_tag', 'td' ) )[4]->as_trimmed_text;
    return {
        series => $series,
        book   => "$bookname($progress)",
        url    => "$BASE_URL/$book_url",
    };

}

sub make_query_request {

    my ( $self, $type, $keyword ) = @_;

    my %qt = (
        '作品' => '1',
        '作者' => '2',
        '主角' => '4',
        '配角' => '5',
        '其他' => '6',
    );

    my $url = qq[$BASE_URL/search.php?kw=$keyword&t=$qt{$type}];

    return $url;
} ## end sub make_query_request

sub parse_query_result_urls {
    my ( $self, $html_ref ) = @_;

    my $parse_query = scraper {
        process '//div[@class="page"]/a', 'urls[]' => sub {
            return unless ( $_[0]->as_text =~ /^\[\d*\]$/ );
            my $url = $BASE_URL . ( $_[0]->attr('href') );
            $url = encode( $self->{charset}, $url );
            return $url;
        };
    };
    my $r = $parse_query->scrape($html_ref);
    return $r->{urls} || [];
} ## end sub parse_query_result_urls

sub parse_query {
    my ( $self, $html_ref ) = @_;

    my $parse_query = scraper {
        process '//h3[@class="title"]/a',
          'books[]' => {
            'book' => 'TEXT',
            'url'  => '@href',
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
        my $r = $ref->{books}[$i];
        my ( $writer, $progress ) = @{ $ref->{writers}[$i] };
        push @result,
          {
            writer => $writer,
            book   => "$r->{book}($progress)",
            url    => $r->{url}
          };
    }

    return \@result;
} ## end sub parse_query

1;
