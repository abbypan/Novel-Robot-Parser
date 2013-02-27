#ABSTRACT: 小说解析基础模块
package  Novel::Robot::Parser::Base;
use Moo;

#网站基地址
has domain => ( is => 'rw' );

#网站名称
has site => ( is => 'rw' );

#网站编码
has charset => ( is => 'rw' );

#元素内置HTML
sub get_inner_html {
    my ( $self, $elem ) = @_;

    my $_ = $elem->as_HTML('<>&');

    my $head_i = index( $_, '>' );
    substr( $_, 0, $head_i + 1 ) = '';

    my $tail_i = rindex( $_, '<' );
    substr( $_, $tail_i ) = '';

    return $_;
} ## end sub get_inner_html

#解析index内容之前，先做一些简单文本处理
sub alter_index_before_parse { }

#解析chapter内容之前，先做一些简单文本处理
sub alter_chapter_before_parse { }

#查询结果为多页时，取得除第1页之外的其他结果页面的url
sub get_query_result_urls { }

no Moo;
1;
