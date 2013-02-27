# ABSTRACT: 小说站点解析引擎
package  Novel::Robot::Parser;
use Moo;
use Novel::Robot::Parser::Jjwxc;
use Novel::Robot::Parser::Dddbbb;

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
        :                                            'Base';

    return $site;
} ## end sub detect_site

1;
