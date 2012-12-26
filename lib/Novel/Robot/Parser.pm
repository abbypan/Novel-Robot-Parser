# ABSTRACT: 小说站点解析引擎
use strict;
use warnings;
package  Novel::Robot::Parser;
use Moo;
use Novel::Robot::Parser::Jjwxc;
use Novel::Robot::Parser::Dddbbb;

sub init_parser {
      my ( $self, $site ) = @_;
      my $parser = eval qq[new Novel::Robot::Parser::$site()];
      return $parser;
}

no Moo;
1;
