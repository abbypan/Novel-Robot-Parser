# ABSTRACT: 小说站点解析引擎
=pod

=encoding utf8

=head1 ATTR

=head2 site 网站名称

例如 Jjwxc

=head2 charset 网站编码

例如 gb2312

=head1 FUNCTION

=head2 get_index_ref 获取目录页信息

    my $index_ref = $xs->get_index_ref($index_url);

=head2 get_chapter_ref 获取章节页信息

    my $chapter_url = 'http://www.jjwxc.net/onebook.php?novelid=2456&chapterid=2';

    my $chapter_ref = $xs->get_chapter_ref($chapter_url, 2);

=head2 get_writer_ref 获取作者页信息

    my $writer_url = 'http://www.jjwxc.net/oneauthor.php?authorid=3243';

    my $writer_ref = $xs->get_writer_ref($writer_url);

=head2 get_query_ref 获取查询结果

    my $query_type = '作者';

    my $query_value = '顾漫';

    my $query_ref = $xs->get_query_ref($query_type, $query_value);

=head2 parse_index 解析目录页

   my $index_ref = $self->parse_index($index_html_ref);

=head2 parse_chapter 解析章节页
  
   my $chapter_ref = $self->parse_chapter($chapter_html_ref);

=head2 parse_writer 解析作者页

   my $writer_ref = $self->parse_writer($writer_html_ref);

=head2 make_query_request 指定类型及关键字生成查询请求

  查询类型：  $type
	
  查询关键字：$keyword

  my ($query_url, $post_data) = $self->make_query_request( $type, $keyword );

=head2 parse_query 解析查询结果

  my $query_ref = $self->parse_query($query_html_ref); 

=head2 parse_query_result_urls 查询结果为分页url

  my $query_urls_ref = $self->parse_query_result_urls($query_html_ref);

=head2 get_inner_html 获取html元素的innerHTML

  my $inner_html = $self->get_inner_html($element);

=head2 format_abs_url 批量将url转换成绝对路径

  $self->format_abs_url($index_ref->{chapter_info}, $index_ref->{index_url});

  $self->format_abs_url($index_ref->{more_book_info}, $index_ref->{index_url});

  $self->format_abs_url($query_urls_ref, $query_url);

=head2 update_chapter_id 更新章节id

  $self->update_chapter_id($index_ref);

=head2 update_chapter_num 更新章节数

  $self->update_chapter_num($index_ref);

=cut
package  Novel::Robot::Parser;
our $VERSION = 0.14;
use Novel::Robot::Browser;
use URI;
use Encode;

sub new {
    my ( $self, %opt) = @_;

    $opt{site}      = $self->detect_site($opt{site}) || 'Jjwxc';
    my $module = "Novel::Robot::Parser::$opt{site}";

    my $browser = Novel::Robot::Browser->new(%opt);

    eval "require $module;";
    bless { browser => $browser, %opt }, $module;

} ## end sub init_parser

sub detect_site {
    my ( $self, $url ) = @_;
    return $url unless ( $url =~ /^http/ );

    my $site =
          ( $url =~ m#^http://www\.jjwxc\.net/# )  ? 'Jjwxc'
        : ( $url =~ m#^http://www\.dddbbb\.net/# ) ? 'Dddbbb'
        : ( $url =~ m#^http://www\.shunong\.com/# ) ? 'Shunong'
        : ( $url =~ m#^http://book\.kanunu\.org/# ) ? 'Nunu'
        : ( $url =~ m#^http://www\.23hh\.com/# ) ? 'Asxs'
        :                                            'Base';

    return $site;
} ## end sub detect_site

sub get_inner_html {
    my ( $self, $h ) = @_;

    return '' unless($h);

    my $head_i = index( $h, '>' );
    substr( $h, 0, $head_i + 1 ) = '';

    my $tail_i = rindex( $h, '<' );
    substr( $h, $tail_i ) = '';

    return $h;
} ## end sub get_inner_html

sub format_abs_url {
	my ($self, $info_array_ref, $base_url) = @_;
	return unless($info_array_ref);

	for my $r (@$info_array_ref){
		next unless($r);

		if(ref($r) eq 'HASH'){
			$r->{url} = URI->new_abs($r->{url}, $base_url)->as_string;
		}else{
			$r = URI->new_abs($r, $base_url)->as_string;
		}

	}
}

sub parse_index { }

sub update_chapter_id {
    my ($self, $r) = @_;
    $r->{chapter_info} ||= [];

    my $chap_i = $r->{chapter_info};
    for my $i ( 0 .. $#$chap_i){
        $chap_i->[$i]{id} ||= $i+1;
    }
}

sub update_chapter_num {
    my ($self, $r) = @_;
    $r->{chapter_info} ||= [];

    my $chap_i = $r->{chapter_info};
    $r->{chapter_num} = scalar(@$chap_i);
}
sub parse_chapter { }
sub parse_writer { }
sub make_query_request { }
sub parse_query { }
sub parse_query_result_urls { }

sub get_book_ref {
    my ($self, $index_url, %opt) = @_;
    my $res =  $self->get_index_ref($index_url, %opt);

    my @infos = grep {
    not (
    ( $opt{min_chapter} and $_->{id}<$opt{min_chapter} )
        or
    ( $opt{max_chapter} and $_->{id}>$opt{max_chapter} )
    )
    } @{$res->{chapter_info}};

    $res->{chapter_info} = $self->{browser}->request_urls(
         \@infos, 
        %opt, 
        deal_sub => sub {
            my ( $r, $chap ) = @_;
            return { %$chap , %$r };
        },
        request_sub => sub {
            my ($r) = @_;
            return $self->get_chapter_ref( $r->{url} );
        },
    );
    return $res;
}

sub get_index_ref {

    my ( $self, $index_url ) = @_;

    return $self->parse_index($index_url)
      unless ( $index_url =~ /^http/ );

    my $html_ref = $self->{browser}->request_url($index_url);

    my $ref = $self->parse_index($html_ref);
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

    $self->update_chapter_id($ref);
    $self->update_chapter_num($ref);
    $self->format_abs_url( $ref->{chapter_info}, $ref->{index_url} );

    return $ref;
} ## end sub get_index_ref

sub get_chapter_ref {
    my ( $self, $chap_url, %opt ) = @_;

    my $html_ref = $self->{browser}->request_url($chap_url);
    my $ref      = $self->parse_chapter($html_ref);

    my $null_chapter_ref = {
        content => '',
        title   => '[空]',
        id      => $opt{id} || 1,
    };
    return $null_chapter_ref unless ($ref);

    $ref->{content} =~ s#\s*([^><]+)(<br />\s*){1,}#<p>$1</p>\n#g;
    $ref->{content} =~ s#(\S+)$#<p>$1</p>#s;
    $ref->{content} =~ s###g;

    $ref->{url} = $chap_url;
    $ref->{id}  //= $opt{id} unless(exists $ref->{id});

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

    my ( $url, $post_vars ) =
    $self->make_query_request( $type, $keyword );
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
    my ($self, $chap_r) = @_;
    return if($chap_r and $chap_r->{content});
    return 1;
}

sub get_nth_chapter_info {
    my ($self, $index_ref, $n) = @_;
    my $r = $index_ref->{chapter_info}[ $n - 1 ];
    return $r;
}

sub get_chapter_ids {
    my ($self, $index_ref, $o) = @_;

    my $chap_ids = $o->{chapter_ids} || [ 1 .. $index_ref->{chapter_num} ];

    my @sort_chap_ids = sort { $a <=> $b } @$chap_ids;
    return \@sort_chap_ids;
}

1;
