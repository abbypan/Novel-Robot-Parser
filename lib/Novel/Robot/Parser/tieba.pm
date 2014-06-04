#ABSTRACT:  百度贴吧 http:://tieba.baidu.com
package Novel::Robot::Parser::tieba;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Parser';

use HTML::Entities;
use JSON;
use Web::Scraper;

sub base_url { 'http://tieba.baidu.com'; }

sub charset   { 'utf8' }
sub site_type { 'tiezi' }

sub parse_tiezi {
    my ( $self, $h ) = @_;

    my $parse_query = scraper {
        process_first '//h1',                        'title'  => 'TEXT';
        process_first '//li[@class="d_name"]',       'writer' => 'TEXT';
        #process_first '//div[contains(@class,"l_post ")]' , 'info' => '@data-field';
    };
    my $ref = $parse_query->scrape($h);
    
    return $ref;
} ## end sub parse_Novel_topic

sub parse_tiezi_floors {
    my ( $self, $h ) = @_;

    my $parse_query = scraper {
        #process '//div[@id="j_p_postlist"]//div[contains(@class,"l_post ")]', 
        process '//div[contains(@class,"l_post ")]', 
        'floors[]' => scraper {
            process '.' , 'info' => '@data-field';
            process_first '//h1[@class="core_title_txt"]', 'title'  => 'TEXT';
            process_first '//li[@class="d_name"]',         'writer' => 'TEXT';
            process_first '//div[contains(@class,"d_post_content ")]', content => 'HTML';
        };
    };
    my $ref    = $parse_query->scrape($h);

    my @floors ;
my        $json = JSON->new->allow_nonref;

    for my $f (@{ $ref->{floors} }){
        next unless($f->{content});
        $self->parse_floor_info($f);
        push @floors, $f;
    }
    return \@floors;
} ## end sub parse_Novel_floors

sub parse_floor_info {
    my ($self, $f) = @_;
    $f->{writer} ||= 'unknown';
    #$f->{content} =~ s/<img[^>]*>//sgi;

    return unless($f->{info});
    my $x = decode_entities($f->{info});
    ($f->{id}) = $x=~/"post_no":(\d+),/s;
    ($f->{time}) = $x=~/"date":"(.+?)",/s;
    delete($f->{info});
    return $self;
}

sub parse_tiezi_urls {
    my ( $self, $h ) = @_;
    my $parse_query = scraper {
        process_first '//link[@rel="canonical"]',   'base' => '@href';
        process_first '//li[@class="l_reply_num"]', 'page' => 'TEXT';
    };
    my $ref    = $parse_query->scrape($h);
    my ($page) = $ref->{page} =~ /共(\d+)页/s;
    my @urls   = map { "$ref->{base}?pn=$_" } ( 2 .. $page );
    return \@urls;
} ## end sub parse_Novel_urls

1;
