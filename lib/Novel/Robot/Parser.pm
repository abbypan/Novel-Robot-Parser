# ABSTRACT: get novel content from website 小说站点解析引擎
package  Novel::Robot::Parser;
our $VERSION = 0.18;
use Novel::Robot::Browser;
use URI;
use Encode;

sub new {
    my ( $self, %opt ) = @_;

    $opt{site} = $self->detect_site( $opt{site} ) || 'Jjwxc';
    my $module = "Novel::Robot::Parser::$opt{site}";

    my $browser = Novel::Robot::Browser->new(%opt);

    eval "require $module;";
    bless { browser => $browser, %opt }, $module;

} ## end sub init_parser

sub detect_site {
    my ( $self, $url ) = @_;
    return $url unless ( $url =~ /^http/ );

    my $site =
        ( $url =~ m#^http://www\.jjwxc\.net/# )   ? 'Jjwxc'
      : ( $url =~ m#^http://www\.dddbbb\.net/# )  ? 'Dddbbb'
      : ( $url =~ m#^http://www\.shunong\.com/# ) ? 'Shunong'
      : ( $url =~ m#^http://book\.kanunu\.org/# ) ? 'Nunu'
      : ( $url =~ m#^http://www\.23hh\.com/# )    ? 'Asxs'
      : ( $url =~ m#^\Qhttp://www.luoqiu.com/# )  ? 'Luoqiu'
      : ( $url =~ m#^\Qhttp://www.23us.com/# )    ? 'Dingdian'
      :                                             'Base';

    return $site;
} ## end sub detect_site

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
    my ( $self, $info_array_ref, $base_url ) = @_;
    return unless ($info_array_ref);

    for my $r (@$info_array_ref) {
        next unless ($r);

        if ( ref($r) eq 'HASH' ) {
            next unless ( $r->{url} );
            $r->{url} = URI->new_abs( $r->{url}, $base_url )->as_string;
        }
        else {
            $r = URI->new_abs( $r, $base_url )->as_string;
        }
    }
}

sub parse_index { }

sub update_chapter_id {
    my ( $self, $r ) = @_;
    $r->{chapter_info} ||= [];

    my $chap_i = $r->{chapter_info};
    for my $i ( 0 .. $#$chap_i ) {
        $chap_i->[$i]{id} ||= $i + 1;
    }
}

sub update_chapter_num {
    my ( $self, $r ) = @_;
    $r->{chapter_info} ||= [];

    my $chap_i = $r->{chapter_info};
    $r->{chapter_num} = scalar(@$chap_i);
}
sub parse_chapter           { }
sub parse_writer            { }
sub make_query_request      { }
sub parse_query             { }
sub parse_query_result_urls { }

sub get_book_ref {
    my ( $self, $index_url, %opt ) = @_;
    my $res = $self->get_index_ref( $index_url, %opt );

    $opt{min_chapter} = $res->{chapter_info}[0]{id}
      if ( $opt{min_chapter} !~ /\S/ );

    $opt{max_chapter} = $res->{chapter_info}[-1]{id}
      if ( $opt{max_chapter} !~ /\S/ );

    my @infos =
      grep { $_->{id} >= $opt{min_chapter} and $_->{id} <= $opt{max_chapter} }
      @{ $res->{chapter_info} };

    $res->{chapter_info} = $self->{browser}->request_urls(
        \@infos,
        %opt,
        deal_sub => sub {
            my ( $r, $chap ) = @_;
            return { %$chap, %$r };
        },
        request_sub => sub {
            my ($r) = @_;
            return $self->get_chapter_ref( $r->{url} );
        },
    );
    return $res;
}

sub get_index_ref {

    my ( $self, $index_url, %opt ) = @_;

    my $ref;
    unless ( $index_url =~ /^http/ ) {
        $ref = $self->parse_index($index_url);
    }
    else {
        my $html_ref = $self->{browser}->request_url($index_url);

        $ref = $self->parse_index($html_ref);
        return unless ( defined $ref );

        $ref->{index_url} = $index_url;
        $ref->{site}      = $self->{site};

        if ( exists $ref->{more_book_info} ) {
            $self->format_abs_url( $ref->{more_book_info}, $ref->{index_url} );
            for my $r ( @{ $ref->{more_book_info} } ) {
                my $info = $self->{browser}->request_url( $r->{url} );
                next unless ( defined $info );
                $r->{function}->( $ref, $info );
            }
        }
    }

    $opt{index_sub}->($ref) if ( exists $opt{index_sub} );

    for my $k (qw/book writer/) {
        $ref->{$k} = $self->format_string( $ref->{$k} );
    }

    $self->update_chapter_id($ref);
    $self->update_chapter_num($ref);
    $self->format_abs_url( $ref->{chapter_info}, $ref->{index_url} );

    return $ref;
} ## end sub get_index_ref

sub format_string {
    my ( $self, $s ) = @_;
    $s =~ s/[\*\/\\\[\(\)]+//g;
    $s =~ s/[\]\s+]/-/g;
    $s;
}

sub get_chapter_ref {
    my ( $self, $chap_url, %opt ) = @_;

    my $html_ref = $self->{browser}->request_url($chap_url);
    my $ref      = $self->parse_chapter($html_ref);

    my $null_chapter_ref = {
        content => '',
        title   => '章节为空',
        id      => $opt{id} || 1,
    };
    return $null_chapter_ref unless ($ref);

    $ref->{content} =~ s#\s*([^><]+)(<br />\s*){1,}#<p>$1</p>\n#g;
    $ref->{content} =~ s#(\S+)$#<p>$1</p>#s;
    $ref->{content} =~ s###g;

    $ref->{url} = $chap_url;
    $ref->{id} //= $opt{id} unless ( exists $ref->{id} );

    return $ref;
} ## end sub get_chapter_ref

sub get_writer_ref {
    my ( $self, $writer_url ) = @_;

    my $html_ref = $self->{browser}->request_url($writer_url);

    my $writer_books = $self->parse_writer($html_ref);
    $self->format_abs_url( $writer_books->{booklist}, $writer_url );

    return $writer_books;
} ## end sub get_writer_ref

sub get_query_ref {
    my ( $self, $type, $keyword ) = @_;

    my ( $url, $post_vars ) = $self->make_query_request( $type, $keyword );
    $url = encode( $self->charset, $url );
    $post_vars->{$_} = encode( $self->charset, $post_vars->{$_} )
      for keys(%$post_vars);

    my $html_ref = $self->{browser}->request_url( $url, $post_vars );
    return unless $html_ref;

    my $result = $self->parse_query($html_ref);

    my $result_urls_ref = $self->parse_query_result_urls($html_ref);
    for my $url (@$result_urls_ref) {
        my $h = $self->{browser}->request_url($url);
        my $r = $self->parse_query($h);
        push @$result, @$r;
    }

    $self->format_abs_url( $result, $url );

    return $result;
} ## end sub get_query_ref

sub is_empty_chapter {
    my ( $self, $chap_r ) = @_;
    return if ( $chap_r and $chap_r->{content} );
    return 1;
}

sub get_nth_chapter_info {
    my ( $self, $index_ref, $n ) = @_;
    my $r = $index_ref->{chapter_info}[ $n - 1 ];
    return $r;
}

sub get_chapter_ids {
    my ( $self, $index_ref, $o ) = @_;

    my $chap_ids = $o->{chapter_ids} || [ 1 .. $index_ref->{chapter_num} ];

    my @sort_chap_ids = sort { $a <=> $b } @$chap_ids;
    return \@sort_chap_ids;
}

1;

