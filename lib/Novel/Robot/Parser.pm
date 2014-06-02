# ABSTRACT: get novel content from website 小说站点解析引擎
package  Novel::Robot::Parser;
use Novel::Robot::Browser;
use URI;
use Encode;

our $VERSION    = 0.18;
our %NULL_INDEX = (
    url          => '',
    book         => '',
    writer       => '',
    writer_url   => '',
    chapter_list => [],

    intro    => '',
    series   => '',
    progress => '',
    word_num => '',
);

our %NULL_CHAPTER = (
    content    => '',
    id         => 0,
    pid        => 0,
    time       => '',
    title      => '章节为空',
    url        => '',
    writer     => '',
    writer_say => '',
    abstract   => '',
    word_num   => '',
    type       => '',
);

sub site_type { 'novel' }


sub new {
    my ( $self, %opt ) = @_;

    $opt{site} = $self->detect_site( $opt{site} ) || 'jjwxc';
    my $module = "Novel::Robot::Parser::$opt{site}";

    my $browser = Novel::Robot::Browser->new(%opt);

    eval "require $module;";
    bless { browser => $browser, %opt }, $module;

} ## end sub init_parser

sub detect_site {
    my ( $self, $url ) = @_;
    return $url unless ( $url =~ /^http/ );

    my $site =
        ( $url =~ m#^http://www\.jjwxc\.net/# )   ? 'jjwxc'
      : ( $url =~ m#^http://www\.dddbbb\.net/# )  ? 'dddbbb'
      : ( $url =~ m#^http://www\.shunong\.com/# ) ? 'shunong'
      : ( $url =~ m#^http://book\.kanunu\.org/# ) ? 'kanunu'
      : ( $url =~ m#^http://www\.23hh\.com/# )    ? 'asxs'
      : ( $url =~ m#^\Qhttp://www.luoqiu.com/# )  ? 'luoqiu'
      : ( $url =~ m#^\Qhttp://www.23us.com/# )    ? 'dingdian'
      : ( $url =~ m#^\Qhttp://read.qidian.com/# ) ? 'qidian'
      : ( $url =~ m#^\Qhttp://www.snwx.com/# )    ? 'snwx'
      : ( $url =~ m#^http://bbs\.jjwxc\.net/# )   ? 'hjj'
      : ( $url =~ m#^\Qhttp://tieba.baidu.com/# ) ? 'tieba'
      :                                             'unknown';

    return $site;
} ## end sub detect_site

## xs {

sub parse_index   { }
sub parse_chapter { }

sub parse_writer  { }
sub parse_writer_novels  { }
sub parse_writer_urls  { }

sub parse_board  { }
sub parse_board_tiezis  { }
sub parse_board_urls  { }

sub make_query_request { }
sub parse_query  { 'Query' }
sub parse_query_items  { }
sub parse_query_urls  { }

sub parse_tiezi {}
sub parse_tiezi_items  { }
sub parse_tiezi_urls  { }

sub get_chapter_ref {
    my ( $self, $src ) = @_;

    $src = { url => $src || '' } if ( ref($src) ne 'HASH' );
    my %m = ( %NULL_CHAPTER, %$src );
    my $html = $self->{browser}->request_url( $src->{url} );

    my $r = $self->parse_chapter( \$html ) || {};

    $r->{$_} ||= $m{$_} for keys(%m);
    $self->tidy_chapter_content($r);

    return $r;
} ## end sub get_chapter_ref

sub get_index_ref {
    my ( $self, $url, %opt ) = @_;

    my $r;
    if ( $url and $url !~ /^http/ ) {
        $r = $self->parse_index( $url, %opt );
    }
    else {
        my $html = $self->{browser}->request_url($url);
        $r = $self->parse_index( \$html, %opt ) || {};
        $r->{chapter_list} ||= $self->parse_chapter_list( \$html ) || [];
        $r->{url} = $url;
    }

    $r->{$_} ||= $NULL_INDEX{$_} for keys(%NULL_INDEX);
    $self->format_hashref_string( $r, $_ ) for qw/writer book/;
    $self->update_chapter_list($r);

    return $r;
} ## end sub get_index_ref

sub update_chapter_list {
    my ( $self, $r ) = @_;

    my $arr = $r->{chapter_list};
    my $i   = 0;
    for my $chap (@$arr) {
        $chap = { url => $chap || '' } if ( ref($chap) ne 'HASH' );
        $self->format_abs_url( $chap, $r->{url} );

        ++$i;
        $chap->{pid} ||= $i;
        $chap->{id}  ||= $i;
    }
    $r->{chapter_num} = $i;
}

####-------------------------

sub is_list_overflow {
    my ( $self, $r, $max ) = @_;

    return unless ($max);

    my $floor_num = scalar( @{$r} );
    return if ( $floor_num < $max );

    $#{$r} = $max - 1;
    return 1;
}

sub select_list_range {
    my ( $self, $src, $s_min, $s_max ) = @_;

    my $id_sub = sub {
        my ( $id, $default ) = @_;
        return $id // $default if ( exists $src->[0]{id} );
        return ( $id - 1 ) if ( $id and $id =~ /^\d+$/ );
        return $default;
    };

    my $min = $id_sub->( $s_min, $src->[0]{id} // 0 );
    my $max = $id_sub->( $s_max, $src->[-1]{id} // $#$src );

    my @chap_list =
      map { $src->[$_] }
      grep {
        my $j = $src->[$_]{id} // $_;
        $j >= $min and $j <= $max
      } ( 0 .. $#$src );

    return \@chap_list;
}

sub get_novel_ref {
    my ( $self, $index_url, %o ) = @_;

    my $r = $self->get_index_ref( $index_url, %o );
    return unless ($r);

    $r->{floor_list} = $self->{browser}->request_urls(
        $r->{chapter_list},
        %o,
        select_url_sub => sub {
            my ($arr) = @_;
            $self->select_list_range( $arr, 
                $o{min_chapter_num},
                $o{max_chapter_num} );
        },
        data_sub            => sub { $self->get_chapter_ref(@_); },
        no_auto_request_url => 1,
    );

    return $r;
}

#--------------------

sub update_floor_list {
    my ( $self, $r, %o ) = @_;

    my $flist = $r->{floor_list};

    $flist = [ grep { $_->{word_num} >= $o{min_word_num} } @$flist ]
      if ( $o{min_word_num} );

    $flist = [ grep { $_->{writer} eq $r->{writer} } @$flist ]
      if ( $o{only_poster} );

    $r->{floor_list} = $flist;

    return $self;
}

sub is_empty_chapter {
    my ( $self, $chap_r ) = @_;
    return if ( $chap_r and $chap_r->{content} );
    return 1;
}

sub get_nth_chapter_list {
    my ( $self, $index_ref, $n ) = @_;
    my $r = $index_ref->{chapter_list}[ $n - 1 ];
    return $r;
}

sub get_chapter_ids {
    my ( $self, $index_ref, $o ) = @_;

    my $chap_ids = $o->{chapter_ids} || [ 1 .. $index_ref->{chapter_num} ];

    my @sort_chap_ids = sort { $a <=> $b } @$chap_ids;
    return \@sort_chap_ids;
}

sub calc_content_wordnum {
    my ( $self, $f ) = @_;
    return if ( $f->{word_num} );
    my $wd = $f->{content} || '';
    $wd =~ s/<[^>]+>//gs;
    $f->{word_num} = $wd =~ s/\S//gs;
    return $f;
}

sub merge_hashref {
    my ( $self, $h, $model ) = @_;
    return unless ( ref($model) eq 'HASH' and ref($h) eq 'HASH' );
    $h->{$_} ||= $model->{$_} for keys(%$model);
    return $h;
}

sub tidy_chapter_content {
    my ( $self, $r ) = @_;
    for ( $r->{content} ) {
        s/^\s*//s;
        s#\s*([^><]+)(<br\s*/?>\s*){1,}#<p>$1</p>\n#g;
        s#(\S+)$#<p>$1</p>#s;
        s###g;

        #s{<br\s*/?\s*>}{\n}sgi;
        #s{<p\s+[^>]*>}{}sgi;
        #s{<p\s*>}{}sgi;
        #s{</p>}{\n\n}sgi;
        #s{\n\n\n*}{\n\n}sg;
        #s{\S.*?\n}{\n<p>$&</p>}sg;
    }
    return $r;
}

sub get_inner_html {
    my ( $self, $h ) = @_;

    return '' unless ($h);

    my $head_i = index( $h, '>' );
    substr( $h, 0, $head_i + 1 ) = '';

    my $tail_i = rindex( $h, '<' );
    substr( $h, $tail_i ) = '';

    return $h;
} ## end sub get_inner_html

sub format_abs_url {
    my ( $self, $chap, $base_url ) = @_;
    $chap->{url} = URI->new_abs( $chap->{url}, $base_url )->as_string;
    return $chap;
}

sub format_hashref_string {
    my ( $self, $r, $k ) = @_;
    $r->{$k} ||= '';

    for ( $r->{$k} ) {
        s/^\s+|\s+$//gs;
        s/[\*\/\\\[\(\)]+//g;
        s/[\]\s+]/-/g;
    }
    $r;
}

sub get_tiezi_ref {
    my ( $self, $url, %o ) = @_;

    my $items_sub = $self->get_items_sub( 'tiezi', 'floor' );
    my ( $topic, $floor_list ) = $items_sub->( $url, %o );

    unshift @$floor_list, $topic if ( $topic->{content} );
    my %r = (
        %$topic,
        book       => $topic->{title},
        url        => $url,
        floor_list => $floor_list,
    );
    $self->update_floor_list( \%r, %o );

    return \%r;
} ## end sub get_tiezi_ref

sub get_items_sub {
    my ( $self, $class, $item ) = @_;

    my $info_sub_name      = "parse_$class";
    my $data_list_sub_name = "parse_${class}_${item}s";
    my $url_list_sub_name  = "parse_${class}_urls";

    my $items_sub = sub {
        my ( $url, %o ) = @_;

        my ( $title, $item_list ) = $self->{browser}->request_urls_iter(
            $url,
            post_data     => $o{post_data},
            info_sub      => sub { $self->$info_sub_name(@_) },
            data_list_sub => sub { $self->$data_list_sub_name(@_) },
            stop_sub      => sub {
                my ( $info, $data_list ) = @_;
                $self->is_list_overflow( $data_list,
                    $o{"max_${class}_${item}_num"} );
            },
            url_list_sub   => sub { $self->$url_list_sub_name(@_); },
            select_url_sub => sub {
                my ($url_s) = @_;
                $self->select_list_range( $url_s, $o{"min_${class}_page"},
                    $o{"max_${class}_page"} );
            },
        );

        return ( $title, $item_list );
    };

    return $items_sub;
}

sub get_writer_ref {

    my ( $self, $writer_url , %o) = @_;

    my $items_sub = $self->get_items_sub( 'writer', 'novel' );

    my ( $writer_name, $novel_list ) = $items_sub->( $writer_url, %o );

    # novel_list : [ { url, writer, book, series, time },  ]

    return ( $writer_name, $novel_list );
} ## end sub get_writer_ref

sub get_board_ref {
    my ( $self, $url, %o ) = @_;

    my $items_sub = $self->get_items_sub( 'board', 'tiezi' );

    my ( $topic, $tiezi_list ) = $items_sub->( $url, %o );

    return ( $topic, $tiezi_list );
} ## end sub get_tiezi_ref

sub get_query_ref {
    my ( $self, $keyword, %o ) = @_;

    my $items_sub = $self->get_items_sub( 'query', 'item' );

    my ( $url, $post_data ) = $self->make_query_request( $keyword, %o );
    
    my ( $info, $item_list ) =
      $items_sub->( $url, %o, post_data => $post_data, );

    return ( $info, $item_list );
} ## end sub get_tiezi_ref

sub get_book_ref {
    my ( $self, $index_url, %o ) = @_;
    my $bt   = $self->site_type();
    my $name = "get_${bt}_ref";
    $self->$name( $index_url, %o );
}
1;

