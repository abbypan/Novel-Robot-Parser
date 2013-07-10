#ABSTRACT: 绿晋江的解析模块 http://www.jjwxc.net
=pod

=encoding utf8

=head1 FUNCTION

=head2 parse_chapter

=head2 parse_index

=head2 parse_writer

=head2 parse_query

=head1  支持查询类型 query type

  作品，作者，主角，配角，其他

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


sub parse_chapter {
    my ($self, $html_ref) = @_;
    $$html_ref=~s{<font color='#E[^>]*'>.*?</font>}{}gis;
    
    my %chap;

    @chap{qw/title content/} = $$html_ref=~m#<h2>(.+?)</h2>(.+?)<div id="favoriteshow.?3"#s;
    return unless($chap{content});
    $chap{content}=~s{</?div[^>]+>}{}sg;

    @chap{qw/book writer/} = $$html_ref=~m#<title>《(.+?)》(.+?)　ˇ#s;

    ($chap{writer_say}) = 
    $$html_ref=~m#<div class=readsmall[^>]+><hr[^>]+>作者有话要说：</br>(.+?)</div>#s;      
    return \%chap;
}

sub parse_index {

    my ( $self, $html_ref ) = @_;

    return if ( $$html_ref =~ /自动进入被锁文章的作者专栏/);

    my $parse_index = scraper {
        process_first '.cytable>tbody>tr>td.sptd>span.bigtext', 'book' => 'TEXT';
        process_first '.cytable>tbody>tr>.sptd>h2>a', 
		      'writer'     => 'TEXT', 'writer_url' => '@href';
        process_first '.readtd>.smallreadbody', 'intro' => sub { $self->get_book_intro(@_); };
        process_first '.cytable', 'book_chapter_info' => sub {
            $self->get_book_chapter_info_html(@_);
        };
    };



    my $ref = $parse_index->scrape($html_ref);
    ($ref->{series}) = $$html_ref=~m{<span>所属系列：</span>(.*?)</li>}s;
    ($ref->{progress}) = $$html_ref=~m{<span>文章进度：</span>(.*?)</li>}s;
    ($ref->{word_num}) = $$html_ref=~m{<span>全文字数：</span>(\d+)字</li>}s;

    return $self->parse_index_just_one_chapter($html_ref) unless ( $ref->{book} ) ;


    $self->parse_book_chapter_info($ref) if($ref->{book_chapter_info});

    return $ref;
} ## end sub parse_index


sub get_book_intro {
   my ($self, $e) = @_;
   my $intro =
	   $e->look_down( '_tag', 'div', 'style', 'clear:both' )
	   || $e->look_down( '_tag', 'div' )
	   || $e;

   my $intro_html = $intro->as_HTML('<>&');
   my $h = $self->get_inner_html($intro_html);
   $h=~s#</?font[^<]*>\s*##gis;

   return $h;
}

sub get_book_chapter_info_html {
    my ($self, $book_info) = @_;

    my $red = $book_info->look_down( '_tag', 'span', 'class', 'redtext' );
    $red->delete if($red);

    return $book_info->as_HTML('<>&');
}

sub parse_index_just_one_chapter {
    my ($self, $html_ref) = @_;

    my $refine_one_chap = scraper {
        process_first '.bigtext', 'book' => 'TEXT';
        process_first '//td[@class="noveltitle"]/h1/a', 'index_url' => '@href';
        process_first '//td[@class="noveltitle"]/a',
        'writer'     => 'TEXT',
        'writer_url' => '@href';
        process_first '//h2', 'chap_title' => 'TEXT';
    };
    my $ref = $refine_one_chap->scrape($html_ref);

    my %chap = (
		    id => 1, 
		    title => $ref->{chap_title}, 
		    abstract => $ref->{chap_title}, 
		    num => $ref->{word_num}, 
		    url => $ref->{index_url} . '&chapterid=1',
	       );
    push @{ $ref->{chapter_info} }, \%chap;
    delete($ref->{chap_title});

    return $ref;

    } ## end unless ( $ref->{book} )

sub parse_book_volume {
	my ($self, $ref, $cell) = @_;

	my $volume = $cell->look_down( 'class', 'volumnfont' );
	return unless($volume);

	my $id = $ref->{main_chapter_id} +1;
	$ref->{volume}{$id} = $volume->as_trimmed_text;
	return $id;
}

sub parse_book_chapter_info {
    my ($self, $ref) = @_;
	
    my $te = HTML::TableExtract->new();
    $te->parse( $ref->{book_chapter_info} );
    my $table = $te->first_table_found;

    my $row   = $#{ $table->rows } - 1;
    my $table_tree = $table->tree;
    
    $ref->{main_chapter_id} = 0;

    for my $i ( 3 .. $row ) {
	my $first_cell = $table_tree->cell( $i, 0 );
	next if($self->parse_book_volume($ref, $first_cell));

	my %chap;
	$chap{url} = $table_tree->cell( $i, 1 )->extract_links()->[0]->[0];
	@chap{qw/id title abstract num time/} = map {
		$table_tree->cell($i, $_)->as_trimmed_text
	} (0, 1, 2, 3, 5);
	$chap{type} = $self->format_chapter_type($chap{title});
	push @{ $ref->{chapter_info} }, \%chap;

	$ref->{main_chapter_id} = $chap{id};
    } ## end for my $i ( 3 .. $row )

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


sub parse_writer {
	my ( $self, $html_ref ) = @_;
	my @series_book;
	my $series ='未分类';

	my $parse_writer = scraper {
		process_first '//tr[@valign="bottom"]//b', writer => 'TEXT';

		process '//tr[@bgcolor="#eefaee"]', 'booklist[]' => sub {
			my $tr = $_[0];
		$series = $self->parse_writer_series($tr, $series);

		my $book = $self->parse_writer_book($tr, $series);
		push @series_book, $book if($book);
		};
	};

	my $ref = $parse_writer->scrape($html_ref);
	$ref->{booklist} = \@series_book;
    $ref->{writer}=~s/^\s*//;

	return $ref;
} ## end sub parse_writer

sub parse_writer_series {
	my ($self, $tr, $series) =@_;

	return $series unless($tr->look_down( 'colspan', '7' ));

	if($tr->as_trimmed_text =~ /【(.*)】/) {
		$series = $1;
	}

	return $series;
}

sub parse_writer_book {
	my ($self, $tr, $series) =@_;

	    my $book = $tr->look_down( '_tag', 'a' );
	    return unless ($book);

	    my $book_url = $book->attr('href');

	    my $bookname = $book->as_trimmed_text;
	    substr( $bookname, 0, 1 ) = '';
	    $bookname .= '[锁]' if ( $tr->look_down( 'color', 'gray' ) );

	    my $progress = ( $tr->look_down( '_tag', 'td' ) )[4]->as_trimmed_text;
	    return {
		    series => $series, 
		    book => "$bookname($progress)",
		    url =>  "$self->{base_url}/$book_url", 	
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

	my $url = qq[$self->{base_url}/search.php?kw=$keyword&t=$qt{$type}];

	return $url;
} ## end sub make_query_request

sub parse_query_result_urls {
	my ( $self, $html_ref ) = @_;

	my $parse_query = scraper {
		process '//div[@class="page"]/a', 'urls[]' => sub {
			return unless ( $_[0]->as_text =~ /^\[\d*\]$/ );
		my $url = $self->{base_url} . ( $_[0]->attr('href') );
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
		process '//h3[@class="title"]/a', 'books[]' => {
			'book' => 'TEXT', 
			'url' => '@href', 
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
		push @result, { 
			writer => $writer, 
			book => "$r->{book}($progress)", 
			url => $r->{url} };
	}

	return \@result;
} ## end sub parse_query

no Moo;
1;
