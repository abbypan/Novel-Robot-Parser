#ABSTRACT: 小说解析基础模块
package  Novel::Robot::Parser::Base;
use Moo;

#网站基地址
has base_url => ( is => 'rw' );

#网站名称
has site => ( is => 'rw' );

#网站编码
has charset => ( is => 'rw' );

sub get_inner_html {
#元素内置HTML
    my ( $self, $elem ) = @_;

    my $_ = $elem->as_HTML('<>&');

    my $head_i = index( $_, '>' );
    substr( $_, 0, $head_i + 1 ) = '';

    my $tail_i = rindex( $_, '<' );
    substr( $_, $tail_i ) = '';

    return $_;
} ## end sub get_inner_html

sub make_index_url { my ($self, $url) = @_; return $url; }
sub parse_index { }

sub make_chapter_url { my ($self, $url) = @_; return $url; }
sub parse_chapter { }

sub make_writer_url { my ($self, $url) = @_; return $url; }
sub parse_writer { }

sub make_query_url { my ($self, $url) = @_; return $url; }
sub parse_query { }

sub get_query_result_urls {
#查询结果为多页时，取得除第1页之外的其他结果页面的url
}

no Moo;
1;
