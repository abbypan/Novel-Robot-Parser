#ABSTRACT: 小说解析基础模块
=pod

=encoding utf8

=head1 ATTR

=head2 base_url 网站基地址

例如 http://www.jjwxc.net

=head2 site 网站名称

例如 Jjwxc

=head2 charset 网站编码

例如 gb2312

=head1 FUNCTION

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

=head2 calc_index_chapter_num 计算并更新章节数

  $self->calc_index_chapter_num($index_ref);

=cut
package  Novel::Robot::Parser::Base;
use Moo;
use URI;

#网站基地址
has base_url => ( is => 'rw' );

#网站名称
has site => ( is => 'rw' );

#网站编码
has charset => ( is => 'rw' );

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
sub calc_index_chapter_num { 
    my ($self, $r) = @_;
     
    $r->{chapter_info} ||= [];
    $r->{chapter_num} = scalar(@{$r->{chapter_info}}) ;

    my $i = 0;
    for my $c (@{$r->{chapter_info}}){
        $c->{id} ||= ++$i;
    }
	
    return $r->{chapter_num};
}
sub parse_chapter { }
sub parse_writer { }
sub make_query_request { }
sub parse_query { }
sub parse_query_result_urls { }

no Moo;
1;
