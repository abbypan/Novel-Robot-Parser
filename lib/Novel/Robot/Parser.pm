# ABSTRACT: 小说站点解析引擎

=pod

=encoding utf8

=head1 DESCRIPTION 

小说解析模块

=head2 支持小说来源

- Jjwxc :  http://www.jjwxc.net

    - 查询：作者，作品

- Dddbbb : http://www.dddbbb.net

    - 查询：作者，作品

- Shunong : http://www.shunong.com

- Nunu :  http://book.kanunu.org

- TXT : txt文件

=cut
package  Novel::Robot::Parser;
use Moo;
use Novel::Robot::Parser::Dddbbb;
use Novel::Robot::Parser::Jjwxc;
use Novel::Robot::Parser::Shunong;
use Novel::Robot::Parser::Nunu;
use Novel::Robot::Parser::TXT;

our $VERSION = 0.09;

sub init_parser {
    my ( $self, $site ) = @_;
    my $s      = $self->detect_site($site);
    my $parser = eval qq[new Novel::Robot::Parser::$s()];
    return $parser;
} ## end sub init_parser

sub detect_site {
    my ( $self, $url ) = @_;
    return $url unless ( $url =~ /^http/ );

    my $site =
          ( $url =~ m#^http://www\.jjwxc\.net/# )  ? 'Jjwxc'
        : ( $url =~ m#^http://www\.dddbbb\.net/# ) ? 'Dddbbb'
        : ( $url =~ m#^http://www\.shunong\.com/# ) ? 'Shunong'
        : ( $url =~ m#^http://book\.kanunu\.org/# ) ? 'Nunu'
        :                                            'Base';

    return $site;
} ## end sub detect_site

1;
