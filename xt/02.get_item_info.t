#!/usr/bin/perl
use lib '../lib';
use Novel::Robot::Parser;
use Test::More ;
use Data::Dumper;
use utf8;

# { bearead
#my $r = 'xxx';
#print ref($r), "\n";
#exit;
my $xs = Novel::Robot::Parser->new( site=> 'bearead' );
my $index_url = 'https://www.bearead.com/reader.html?bid=b10097021&bookListNum=1';
my $chapter_url = { url => 'https://www.bearead.com/api/book/chapter/content', post_data => 'bid=b10097021&cid=354932' };

my $index_ref = $xs->parse_novel($index_url);
is($index_ref->{book}=~/^苏/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '飘灯', 'writer');
is($index_ref->{chapter_list}[0]{post_data}, $chapter_url->{post_data}, 'chapter_url');

my $html = $xs->{browser}->request_url( $chapter_url->{url}, $chapter_url->{post_data} );
my $chapter_ref = $xs->extract_elements(
    \$html,
    path => $xs->scrape_novel_item(),
    sub  => $xs->can( 'parse_novel_item' ),
);
is($chapter_ref->{title}=~/沽/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/苏/ ? 1 : 0, 1 , 'chapter_content');
# }
exit;

# { tadu
my $xs = Novel::Robot::Parser->new( site=> 'tadu' );
my $index_url = 'http://www.tadu.com/book/catalogue/394959';
my $chapter_url = 'http://www.tadu.com/book/394959/26793462/';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^凰图/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '寐语者', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $html = $xs->{browser}->request_url( $chapter_url );
my $chapter_ref = $xs->extract_elements(
    \$html,
    path => $xs->scrape_novel_item(),
    sub  => $xs->can( 'parse_novel_item' ),
);
is($chapter_ref->{title}=~/章目-楔子/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/华/ ? 1 : 0, 1 , 'chapter_content');
# }

# { tmetb
my $xs = Novel::Robot::Parser->new( site=> 'tmetb' );
my $index_url = 'http://www.tmetb.com/0/271/';
my $chapter_url = 'http://www.tmetb.com/0/271/18340.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^上古/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '星零', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $html = $xs->{browser}->request_url( $chapter_url );
my $chapter_ref = $xs->extract_elements(
    \$html,
    path => $xs->scrape_novel_item(),
    sub  => $xs->can( 'parse_novel_item' ),
);
is($chapter_ref->{title}=~/前奏/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/仙地/ ? 1 : 0, 1 , 'chapter_content');
# }
done_testing;
exit;
# { dingdian
my $xs = Novel::Robot::Parser->new( site=> 'dingdian' );
my $index_url = 'http://www.23us.com/html/27/27686/';
my $chapter_url = 'http://www.23us.com/html/27/27686/17354510.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^奥术/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '爱潜水的乌贼', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $html = $xs->{browser}->request_url( $chapter_url );
my $chapter_ref = $xs->extract_elements(
    \$html,
    path => $xs->scrape_novel_item(),
    sub  => $xs->can( 'parse_novel_item' ),
);
is($chapter_ref->{title}=~/火刑/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/浓烟/ ? 1 : 0, 1 , 'chapter_content');
# }

# { shushu8
my $xs = Novel::Robot::Parser->new( site=> 'shushu8' );
my $index_url = 'http://www.shushu8.com/tianxiananxuijieluding/';
my $chapter_url = 'http://www.shushu8.com/tianxiananxuijieluding/1';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^天下男修皆炉鼎/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '青衫烟雨', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $html = $xs->{browser}->request_url( $chapter_url );
my $chapter_ref = $xs->extract_elements(
    \$html,
    path => $xs->scrape_novel_item(),
    sub  => $xs->can( 'parse_novel_item' ),
);
is($chapter_ref->{title}=~/穿越/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/苏/ ? 1 : 0, 1 , 'chapter_content');
# }
# { lwxs520
my $xs = Novel::Robot::Parser->new( site=> 'lwxs520' );
my $index_url = 'http://www.lwxs520.com/books/21/21457/index.html';
my $chapter_url = 'http://www.lwxs520.com/books/21/21457/5018894.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^天醒/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '蝴蝶蓝', 'writer');
is($index_ref->{chapter_list}[33]{url}, $chapter_url, 'chapter_url');

my $html = $xs->{browser}->request_url( $chapter_url );
my $chapter_ref = $xs->extract_elements(
    \$html,
    path => $xs->scrape_novel_item(),
    sub  => $xs->can( 'parse_novel_item' ),
);
is($chapter_ref->{title}=~/无比强烈的好奇心/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/世界到底有多大/ ? 1 : 0, 1 , 'chapter_content');
# }



# { kanunu
my $xs = Novel::Robot::Parser->new( site=> 'kanunu' );
#my $index_url = 'http://www.kanunu8.com/book/4559/';
#my $chapter_url = 'http://www.kanunu8.com/book/4559/62299.html';
my $index_url = 'http://www.kanunu8.com/wuxia/201103/2337.html';
my $chapter_url = 'http://www.kanunu8.com/wuxia/201103/2337/68465.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^武林/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '古龙', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');
print Dumper($index_ref);

my $html = $xs->{browser}->request_url( $chapter_url );
my $chapter_ref = $xs->extract_elements(
    \$html,
    path => $xs->scrape_novel_item(),
    sub  => $xs->can( 'parse_novel_item' ),
);
is($chapter_ref->{title}=~/风雪/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/怒雪威寒/ ? 1 : 0, 1 , 'chapter_content');
# }
 exit;

# { asxs
my $xs = Novel::Robot::Parser->new( site=> 'asxs' );
my $index_url = 'http://www.23xs.cc/book/169/index.html';
my $chapter_url = 'http://www.23xs.cc/book/169/85538.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^死人经/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '冰临神下', 'writer');
is($chapter_url,$index_ref->{chapter_list}[0]{url} , 'chapter_url');
#print $index_ref->{chapter_list}[0]{url},"\n";

my $html = $xs->{browser}->request_url( $chapter_url );
my $chapter_ref = $xs->extract_elements(
    \$html,
    path => $xs->scrape_novel_item(),
    sub  => $xs->can( 'parse_novel_item' ),
);
is($chapter_ref->{title}=~/杀手/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/顶尖/ ? 1 : 0, 1 , 'chapter_content');
# }


# { lwxs 
my $xs = Novel::Robot::Parser->new( site=> 'lwxs' );
my $index_url = 'http://www.lwxs.com/shu/5/5242/';
my $chapter_url = 'http://www.lwxs.com/shu/5/5242/2023834.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^慢慢/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '绝世小白', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/引仙台/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/甲/ ? 1 : 0, 1 , 'chapter_content');
# }
#
# { lwxs 
my $xs = Novel::Robot::Parser->new( site=> 'lwxs' );
my $index_url = 'http://www.lwxs.com/shu/5/5242/';
my $chapter_url = 'http://www.lwxs.com/shu/5/5242/2023834.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^慢慢/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '绝世小白', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/引仙台/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/甲/ ? 1 : 0, 1 , 'chapter_content');
# }

# { shunong 
my $xs = Novel::Robot::Parser->new( site=> 'shunong' );
my $index_url = 'http://www.shunong.com/wx/8558/';
my $chapter_url = 'http://www.shunong.com/wx/8558/267184.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^青崖白鹿记$/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '沈璎璎', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/^第1章$/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/树入天台石路新/ ? 1 : 0, 1 , 'chapter_content');
# }

# { luoqiu 
my $xs = Novel::Robot::Parser->new( site=> 'luoqiu' );
my $index_url = 'http://www.luoqiu.com/read/3111/';
my $chapter_url = 'http://www.luoqiu.com/read/3111/555962.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^死人经/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '冰临神下', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/杀手/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/顶尖/ ? 1 : 0, 1 , 'chapter_content');
# }


# { kanshuge 
my $xs = Novel::Robot::Parser->new( site=> 'kanshuge' );
my $index_url = 'http://www.kanshuge.la/files/article/html/48/48682/index.html';
my $chapter_url = 'http://www.kanshuge.la/files/article/html/48/48682/8438614.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^死人经/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '冰临神下', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/杀手/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/顶尖/ ? 1 : 0, 1 , 'chapter_content');
# }

# { jjwxc
my $xs = Novel::Robot::Parser->new( site=> 'jjwxc' );
my $index_url = 'http://www.jjwxc.net/onebook.php?novelid=14838';
my $chapter_url = 'http://m.jjwxc.net/book2/14838/1';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^断情/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '牵机', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/序章/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/大江之东/ ? 1 : 0, 1 , 'chapter_content');
# }

# { hkslg 
my $xs = Novel::Robot::Parser->new( site=> 'hkslg' );
my $index_url = 'http://www.hkslg520.com/4/4205/index.html';
my $chapter_url = 'http://www.hkslg520.com/4/4205/1074131.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^死人经/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '冰临神下', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/杀手/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/顶尖/ ? 1 : 0, 1 , 'chapter_content');
# }

# { ddshu
my $xs = Novel::Robot::Parser->new( site=> 'ddshu' );
my $index_url = 'http://www.ddshu.net/html/1920/index.html';
my $chapter_url = 'http://www.ddshu.net/1920_1050551.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^武林/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '古龙', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/风雪/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/怒雪威寒/ ? 1 : 0, 1 , 'chapter_content');
# }

# { qywx
my $xs = Novel::Robot::Parser->new( site=> 'qywx' );
my $index_url = 'http://www.71wx.net/xiaoshuo/36/36452/';
my $chapter_url = 'http://www.71wx.net/xiaoshuo/36/36452/5297096.shtml';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^死人经/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '冰临神下', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/杀手/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/顶尖/ ? 1 : 0, 1 , 'chapter_content');
# }

# { biquge
my $xs = Novel::Robot::Parser->new( site=> 'biquge' );
my $index_url = 'http://www.biquge.tw/74_74259/';
my $chapter_url = 'http://www.biquge.tw/74_74259/3817727.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^月西女传/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '水草二十三', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/楔子/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/为妖者/ ? 1 : 0, 1 , 'chapter_content');
# }


# { asxs
my $xs = Novel::Robot::Parser->new( site=> 'asxs' );
my $index_url = 'http://www.23xs.cc/book/169/index.html';
my $chapter_url = 'http://www.23xs.cc/book/169/85538.html';

my $index_ref = $xs->get_item_info($index_url);
is($index_ref->{book}=~/^死人经/ ? 1 : 0, 1,'book');
is($index_ref->{writer}, '冰临神下', 'writer');
is($index_ref->{chapter_list}[0]{url}, $chapter_url, 'chapter_url');

my $chapter_ref = $xs->get_chapter_ref($chapter_url);
is($chapter_ref->{title}=~/杀手/ ? 1 : 0, 1 , 'chapter_title');
is($chapter_ref->{content}=~/顶尖/ ? 1 : 0, 1 , 'chapter_content');
# }


done_testing;
