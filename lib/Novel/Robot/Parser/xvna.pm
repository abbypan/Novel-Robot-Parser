# ABSTRACT:  http://ncs.xvna.com
package Novel::Robot::Parser::xvna;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

use HTML::Entities;
use Web::Scraper;

sub base_url { 'http://ncs.xvna.com'; }

sub charset   { 'utf8' }
sub site_type { 'tiezi' }

sub parse_tiezi {
    my ( $self, $h ) = @_;

    my $parse_query = scraper {
        process_first '//title',                        'title'  => 'TEXT';
    };
    my $ref = $parse_query->scrape($h);
    ($ref->{title}) = $ref->{title}=~/《(.*?)》/;
    $ref->{writer} = 'unknown';
    
    return $ref;
} ## end sub parse_Novel_topic

sub parse_tiezi_floors {
    my ( $self, $h ) = @_;

    my $parse_query = scraper {
        process '//div[@class="Contents"]', content => 'HTML';
    };
    my $ref    = $parse_query->scrape($h);
    return unless($ref->{content});
    $ref->{content}=~s#<div [^>]+>.+?</div>##sg;
    $ref->{content}=~s#<script [^>]+>.+?</script>##sg;
    $ref->{content}=~s#>\n*#>\n#sg;
    $ref->{writer} ||= 'unknown';
    return [ $ref ];
} ## end sub parse_Novel_floors

sub parse_tiezi_urls {
    my ( $self, $h ) = @_;
    my $parse_query = scraper {
        process_first '//a[@class="ep"]',   'end' => '@href';
    };
    my $ref    = $parse_query->scrape($h);
    my ($base, $page) = $ref->{end} =~ /^(.+?-)(\d+)\/$/;
    my @urls   = map { $self->base_url()."$base$_" } ( 2 .. $page );
    return \@urls;
} ## end sub parse_Novel_urls

1;
