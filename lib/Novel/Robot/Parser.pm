# ABSTRACT: get novel / bbs content from website
package  Novel::Robot::Parser;

use strict;
use warnings;
use utf8;

use Novel::Robot::Browser;
use URI;
use Encode;
use Web::Scraper;

our $VERSION    = 0.27;

our %NULL_INDEX = (
    url          => '',
    book         => '',
    writer       => '',
    writer_url   => '',
    chapter_list => [],

    intro    => '',
    series   => '',
    progress => '',
    word_num => '',
);

our %NULL_CHAPTER = (
    content    => '',
    id         => 0,
    pid        => 0,
    time       => '',
    title      => '章节为空',
    url        => '',
    writer     => '',
    writer_say => '',
    abstract   => '',
    word_num   => '',
    type       => '',
);


sub new {
    my ( $self, %opt ) = @_;

    $opt{site} = $self->detect_site( $opt{site} ) || 'jjwxc';
    my $module = "Novel::Robot::Parser::$opt{site}";

    my $browser = Novel::Robot::Browser->new(%opt);

    eval "require $module;";
    bless { browser => $browser, %opt }, $module;

} ## end sub init_parser

our %SITE_DOM_NAME = (
    'bbs.jjwxc.net'=>'hjj',
    'www.kanunu8.com'=>'kanunu',
    'm.xiaoxiaoshuwu.com' => 'xiaoxiaoshuwu', 
    'read.qidian.com'=>'qidian',
    'tieba.baidu.com'=>'tieba',
    'www.123yq.com'=>'yesyq',
    'www.23us.com'=>'dingdian',
    'www.23xs.cc'=>'asxs',
    'www.biquge.tw'=> 'biquge',
    'www.71wx.net'=>'qywx',
    'www.ddshu.net'=>'ddshu',
    'www.hkslg520.com'=>'hkslg',
    'www.jjwxc.net'=>'jjwxc',
    'www.kanshuge.la'=>'kanshuge',
    'www.kanunu8.com'=>'kanunu',
    'www.luoqiu.com'=>'luoqiu',
    'www.qqxs.cc'=>'qqxs',
    'www.shunong.com'=>'shunong',
    'www.snwx.com'=>'snwx',
    'www.tadu.com'=>'tadu',
    'www.ttzw.com'=>'ttzw',
    'www.lwxs.com'=>'lwxs',
    'www.yanqingji.com'=>'yanqingji',
    'www.ybdu.com'=>'ybdu',
    'www.yqhhy.cc'=>'yqhhy',
    'www.yssm.org' => 'yssm', 
    'www.zhonghuawuxia.com'=>'zhonghuawuxia',
    'www.zilang.net'=>'zilang',
);

sub detect_site {
    my ( $self, $url ) = @_;
    return $url unless ( $url =~ /^http/ );

    my ($dom) = $url=~m#^.*?\/\/(.+?)/#;
    my $site = exists $SITE_DOM_NAME{$dom} ? $SITE_DOM_NAME{$dom} : 'unknown';

    return $site;
} ## end sub detect_site


sub get_item_info {
    my ( $self, $index_url ) = @_;
    my $bt   = $self->site_type();
    return $self->get_index_ref($index_url) if($bt eq 'novel');

    my $items_sub = $self->get_items_sub('tiezi', 'floor');
    my ($topic, $floor_list) = $items_sub->($index_url);
    return $topic;
}

sub get_item_ref {
    my ( $self, $index_url, %o ) = @_;
    my $bt   = $self->site_type();
    my $name = "get_${bt}_ref";
    $self->$name( $index_url, %o );
}

sub get_novel_ref {
    my ( $self, $index_url, %o ) = @_;

    my $r = $self->get_index_ref( $index_url, %o );
    return unless ($r);
    return $r if($r->{floor_list} and scalar(@{$r->{floor_list}})>0);

    $r->{floor_list} = $self->{browser}->request_urls(
        $r->{chapter_list},
        %o,
        select_url_sub => sub {
            my ($arr) = @_;
            $self->select_list_range( $arr, 
                $o{min_chapter_num},
                $o{max_chapter_num} );
        },
        data_sub            => sub { $self->get_chapter_ref(@_); },
        no_auto_request_url => 1,
    );

    $self->update_floor_list( $r, %o );

    return $r;
}

######## {{{

sub get_index_ref {

    my ( $self, $url, %opt ) = @_;

    my $r={};
    if ( $url and $url !~ /^http/ ) { 
       $r = $self->parse_index( $url, %opt ); 
   }
   else {
        my $html = $self->{browser}->request_url($url);
        my $index_xpath = $self->scrape_index();
        while(my ($xk, $xr) = each %$index_xpath){
            $r->{$xk} = $self->scrape_element(\$html, $xr);
        }
        $r = $self->parse_index( \$html, $r );
        $r->{chapter_list} ||= $self->parse_chapter_list( \$html, $r ) || [];
        $r->{url} = $url;
    }

    $r->{$_} ||= $NULL_INDEX{$_} for keys(%NULL_INDEX);
    $self->tidy_string( $r, $_ ) for qw/writer book/;

    $r->{chapter_num}  = $self->update_url_list($r->{chapter_list}, $r->{url});
    $r->{writer_url} = $self->format_abs_url( $r->{writer_url}, $self->base_url );

    return $r;
} ## end sub get_index_ref

sub parse_index { 
    my ($self, $h, $r) = @_;
    $r->{writer}=~s/作\s*者：//;
    $r->{book}=~s/\s*最新章节\s*$//;
    return $r;
}

sub scrape_index { {} }

sub scrape_chapter_list { }

sub parse_chapter_list {
    my ( $self, $html_ref, $r ) = @_;

    my $path_r = $self->scrape_chapter_list();
    return [] unless($path_r);

    my $parse_index = scraper {
        process $path_r->{path},
        'chapter_list[]' => {
            'title' => 'TEXT',
            'url'   => '@href'
        };
    };
    my $ref = $parse_index->scrape($html_ref);

    my @chap = grep { exists $_->{url}  and $_->{url} } @{ $ref->{chapter_list} };
    return \@chap unless($path_r->{sort});

    my @sort_chap = sort { $a->{url} cmp $b->{url} } @chap;
    return \@sort_chap;
}

sub tidy_string {
    my ( $self, $r, $k ) = @_;
    $r->{$k} ||= '';

    for ( $r->{$k} ) {
        s/^\s+|\s+$//gs;
        s/[\*\/\\\[\(\)]+//g;
        s/[[:punct:]]//sg;
        s/[\]\s+]/-/g;
    }

    $r;
}

sub update_url_list {
    my ( $self, $arr , $base_url) = @_;

    my $i   = 0;
    for my $chap (@$arr) {
        $chap = { url => $chap || '' } if ( ref($chap) ne 'HASH' );
        $self->format_abs_url( $chap, $base_url );

        ++$i;
        $chap->{pid} ||= $i;
        $chap->{id}  ||= $i;
    }
    return $i;
}

sub format_abs_url {
    my ( $self, $chap, $base_url ) = @_;
    $base_url ||= $self->base_url();
    return $chap if( ! $chap or ! $base_url or $base_url!~/^http/ );

    if(ref($chap) eq 'HASH'){
        $chap->{url} = URI->new_abs( $chap->{url}, $base_url )->as_string;
    }else{
        $chap =  URI->new_abs( $chap, $base_url )->as_string;
    }

    return $chap;
}

########## }}}

sub site_type { 'novel' }
sub charset { 'cp936' }
sub base_url { }

############

sub get_chapter_ref {
    my ( $self, $src ) = @_;

    $src = { url => $src || '' } if ( ref($src) ne 'HASH' );
    my $html = $self->{browser}->request_url( $src->{url} );

    my $r = {};
    my $chapter_xpath = $self->scrape_chapter();
    while(my ($xk, $xr) = each %$chapter_xpath){
       $r->{$xk} = $self->scrape_element(\$html, $xr);
    }
    $r = $self->parse_chapter( \$html, $r );

    $r->{$_} ||= $src->{$_} for keys(%$src);
    $r->{$_} ||= $NULL_CHAPTER{$_} for keys(%NULL_CHAPTER);
    $self->tidy_chapter_content($r);

    return $r;
} ## end sub get_chapter_ref

sub scrape_chapter { {} }

sub scrape_element {
    my ($self, $h, $o) = @_;
    return $self->extract_regex_element($h, $o->{regex}) if($o->{regex});
    return $o->{sub}->($h) unless($o->{path});

    $o->{extract} ||='TEXT';

    my   $parse = $o->{is_list} ? 
    scraper { process $o->{path}, 'data[]' => $o->{extract}; } :
    scraper { process_first $o->{path}, 'data' => $o->{extract}; };
    my $r = $parse->scrape($h);
    return unless(defined $r->{data});

    return $r->{data} unless($o->{sub});
    return $o->{sub}->($r->{data});
}

sub extract_regex_element {
    my ($self, $h, $reg) = @_;
    my ($d) = $$h=~m#$reg#s;
    return $d;
}

sub parse_chapter {
    my ($self, $h, $r) = @_;
    return $r;
}

############

sub get_tiezi_ref {
    my ( $self, $url, %o ) = @_;

    my $items_sub = $self->get_items_sub( 'tiezi', 'floor', %o );
    my ( $topic, $floor_list ) = $items_sub->( $url, %o );

    $floor_list = [ reverse @$floor_list ] if($o{reverse_content_list});
    $self->update_url_list( $floor_list, $self->base_url || $url );
    $floor_list =  $self->select_list_range( $floor_list, $o{min_chapter_num}, $o{max_chapter_num} );

    if(! $floor_list->[0]{content} and $o{deal_content_url}){
        for my $x (@$floor_list) {
            my $u = $x->{url};
            my $h = $self->{browser}->request_url($u);
            $x->{content} = $o{deal_content_url}->($h);
        }
    }

    unshift @$floor_list, $topic if ( $topic->{content} );
    my %r = (
        %$topic,
        book       => $topic->{title},
        title      => $topic->{title},
        url        => $url,
        floor_list => $floor_list,
    );
    $self->update_floor_list( \%r, %o );

    return \%r;
} ## end sub get_tiezi_ref

sub parse_tiezi {}
sub parse_tiezi_items  { }
sub parse_tiezi_urls  { }

sub get_board_ref {
    my ( $self, $url, %o ) = @_;

    my $items_sub = $self->get_items_sub( 'board', 'item' );

    my ( $topic, $item_list ) = $items_sub->( $url, %o );

    $self->update_url_list($item_list, $url);

    return ( $topic, $item_list );
} ## end sub get_tiezi_ref

sub parse_board  { }
sub parse_board_items  { }
sub parse_board_urls  { }

sub get_items_sub {
    my ( $self, $class, $item , %opt) = @_;

    my $info_sub_name      = "parse_$class";
    my $data_list_sub_name = "parse_${class}_${item}s";
    my $url_list_sub_name  = "parse_${class}_urls";

    my $items_sub = sub {
        my ( $url, %o ) = @_;

        my ( $title, $item_list ) = $self->{browser}->request_urls_iter(
            $url,
            post_data     => $o{post_data},
            parse_info    => sub { $self->$info_sub_name(@_) },
            parse_content => sub { $self->$data_list_sub_name(@_) },
            get_url_list  => sub { $self->$url_list_sub_name(@_) },
            min_page_num  => $o{"min_${class}_page"},
            max_page_num  => $o{"max_${class}_page"},
            stop_iter     => sub {
                my ( $info, $data_list, $i) = @_;
                $self->is_list_overflow( $data_list, $o{"max_${class}_${item}_num"} );
            },
            %opt, 
        );

        return ( $title, $item_list );
    };

    return $items_sub;
}

sub get_query_ref {
    my ( $self, $keyword, %o ) = @_;

    my $items_sub = $self->get_items_sub( 'query', 'item' );

    my ( $url, $post_data ) = $self->make_query_request( $keyword, %o );
    
    my ( $info, $item_list ) =
      $items_sub->( $url, %o, post_data => $post_data, );
    
    $self->update_url_list($item_list, $url);

    return ( $info, $item_list );
} ## end sub get_tiezi_ref

sub make_query_request { }
sub parse_query  { 'Query' }
sub parse_query_items  { }
sub parse_query_urls  { }

####-------------------------


sub is_list_overflow {
    my ( $self, $r, $max ) = @_;

    return unless ($max);

    my $floor_num = scalar( @{$r} );
    return if ( $floor_num < $max );

    $#{$r} = $max - 1;
    return 1;
}

sub select_list_range {
    my ( $self, $src, $s_min, $s_max ) = @_;

    my $have_id;
    {
        my $ref  = ref($src->[0]);
        $have_id = ($ref and $ref eq 'HASH' and exists $src->[0]{id});
    }

    my $default_sub = sub {
        my ($hashref, $fallback) = @_;
        return $fallback unless $have_id;
        return $hashref->{id} // $fallback;
    };

    my $id_sub = sub {
        my ( $id, $default ) = @_;
        return ($id and $id=~/\S/) ? $id : $default if $have_id;
        return ( $id - 1 ) if ( $id and $id =~ /^\d+$/ );
        return $default;
    };

    my $min = $id_sub->( $s_min, $default_sub->($src->[0], 0) );
    my $max = $id_sub->( $s_max, $default_sub->($src->[-1], $#$src) );

    my @chap_list =
      map { $src->[$_] }
      grep {
        my $j = $have_id ? ($src->[$_]{id} // $_) : $_;
        $j >= $min and $j <= $max
      } ( 0 .. $#$src );

    return \@chap_list;
}

sub update_floor_list {
    my ( $self, $r, %o ) = @_;

    my $flist = $r->{floor_list};
    $r->{raw_floor_num} = scalar(@$flist);

    $self->calc_content_word_num($_) for @$flist;

    $flist = [ grep { $_->{word_num} >= $o{min_floor_word_num} } @$flist ]
      if ( $o{min_floor_word_num} );

    $flist = [ grep { $_->{writer} eq $r->{writer} } @$flist ]
      if ( $o{only_poster} );

    $flist = [ grep { $_->{content}=~/$o{grep_content}/s } @$flist ]
      if ( $o{grep_content} );

    $flist = [ grep { $_->{content}!~/$o{filter_content}/s } @$flist ]
      if ( $o{filter_content} );

    $flist->[$_]{id} ||= $_+1 for (0 .. $#$flist);

    $flist->[$_]{title} ||= $r->{chapter_list}[$_]{title} || 'unknown' for (0 .. $#$flist);

    $r->{floor_list} = $flist;

    return $self;
}

sub is_empty_chapter {
    my ( $self, $chap_r ) = @_;
    return if ( $chap_r and $chap_r->{content} );
    return 1;
}

sub get_nth_chapter_list {
    my ( $self, $index_ref, $n ) = @_;
    my $r = $index_ref->{chapter_list}[ $n - 1 ];
    return $r;
}

sub get_chapter_ids {
    my ( $self, $index_ref, $o ) = @_;

    my $chap_ids = $o->{chapter_ids} || [ 1 .. $index_ref->{chapter_num} ];

    my @sort_chap_ids = sort { $a <=> $b } @$chap_ids;
    return \@sort_chap_ids;
}

sub calc_content_word_num {
    my ( $self, $f ) = @_;
    return if ( $f->{word_num} );
    my $wd = $f->{content} || '';
    $wd =~ s/<[^>]+>//gs;
    $f->{word_num} = $wd =~ s/\S//gs;
    return $f;
}

sub merge_hashref {
    my ( $self, $h, $model ) = @_;
    return unless ( ref($model) eq 'HASH' and ref($h) eq 'HASH' );
    $h->{$_} ||= $model->{$_} for keys(%$model);
    return $h;
}

sub tidy_chapter_content {
    my ( $self, $r ) = @_;
    for ( $r->{content} ) {
         s###sg;
         s#<script(\s+[^>]+\>|\>)[^<]*</script>##sg;
         s#\s*\<[^>]+?\>#\n#sg;
         s{\n\n\n*}{\n}sg;
         s{\s*(\S.*?)\s*\n}{\n<p>$1</p>}sg;
    }
    return $r;
}

sub get_inner_html {
    my ( $self, $h ) = @_;

    return '' unless ($h);

    my $head_i = index( $h, '>' );
    substr( $h, 0, $head_i + 1 ) = '';

    my $tail_i = rindex( $h, '<' );
    substr( $h, $tail_i ) = '';

    return $h;
} ## end sub get_inner_html



sub unescape_js {
    my ($self, $s) = @_;
    $s =~ s/%u([0-9a-f]{4})/chr(hex($1))/eigs;
    $s =~ s/%([0-9a-f]{2})/chr(hex($1))/eigs;
    return $s;
}

1;

