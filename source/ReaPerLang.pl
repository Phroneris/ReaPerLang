#!perl

my $ReaPerLang = 'ReaPerLang v1.12-dev';



##### 初期設定

### 基本

use v5.36.1;
# no strict;    # リリース用
# no warnings;  # リリース用

use autodie;      # エラー時に$@を得る
use Time::HiRes;  # 最後に出す経過時間のため



### 文字エンコーディング関連

use utf8;  # このファイル内に直接書いたUTF-8文字列を全て内部文字列にする
use open OUT => ':utf8';  # ファイル出力を全て '>:encoding(UTF-8)' で行う
use Encode qw/encode decode/;

my $enc_os = 'cp932';  # Windows JP
use PerlIO::encoding;  # for building exe
use Encode::JP;        # for building exe
use Encode::CN;        # 念のため
use Encode::KR;        # 念のため
use Encode::TW;        # 念のため

## 標準入出力で cp932(見た目)⇔UTF-8(内部) と変換する
binmode STDIN,  ":encoding(${enc_os})";
binmode STDOUT, ":encoding(${enc_os})";
binmode STDERR, ":encoding(${enc_os})";

sub du ($s) { decode('UTF-8', $s); }  # 内部文字列にする（文字コードを取り除く）
sub eu ($s) { encode('UTF-8', $s); }  # UTF-8にする
sub dc ($s) { decode($enc_os, $s); }
sub ec ($s) { encode($enc_os, $s); }

## デバッグ時にpで文字列が化けたら ec $var または ed $var で戻せることが多い
sub ed ($s) { ec(du($s)); }
# sub isN ($s) { Encode::is_utf8($s) ? 'naibu' : 'hadaka kamo...'; }



##### 汎用的なサブルーチンと変数

my ($indent, $indentUnit) = ('', 1);

sub indentMore ()
{
  #### インデントを増やす
  # :return (string) : 利用は想定していないが、増えた後の$indentが返る
  $indent .= ' ' x $indentUnit;
}

sub indentLess ()
{
  #### インデントを減らす
  # :return (string) : 利用は想定していないが、増えた後の$indentが返る
  $indent = substr $indent, 0, -$indentUnit;
}

sub getIndentedTxt (@lines)
{
  #### 複数の文字列を結合してインデントする
  # :param  array  @lines: 複数の文字列（空も可）
  # :return string       : インデント済み文字列
  my $txt = join '', @lines;
  return $txt =~ s/^/$indent/gmr =~ s/^ +$//gmr;
}

sub prindent (@lines)
{
  #### インデント込みでprintする
  # :param  array     @lines: printする複数の文字列（空も可）
  # :return (boolean)       : 利用は想定していないが、printの成否に応じた真偽値が返る
  print &getIndentedTxt(@lines);  # 出力先を変更したい場合はselectに頼ることになる
}

sub sayndent (@lines)
{
  #### インデント込みでsayする
  # :param  array     @lines: sayする複数の文字列（空も可）
  # :return (boolean)       : 利用は想定していないが、sayの成否に応じた真偽値が返る
  say &getIndentedTxt(@lines);  # &prindent() ではなく一応本物のsayを使っておく
}


my $finalMessage;  # ENDブロックで使用

sub abort ($err, $noDecode = 0)  # オプション引数にはデフォルト値を指定
{
  #### 任意のエラー文を出力して異常終了する
  # :param  string/$@ $err     : エラー文
  # :param? boolean   $noDecode: エラー文を文字列で指定する場合、真にしてデコードを避ける
  # :return void               : 異常終了（die）してENDブロックに飛ぶ

  $err = dc($err) unless $noDecode;
  $finalMessage = &getIndentedTxt("Press enter to abort.\n");

  ## $errの終端改行と最後の\nのどちらも無ければエラー発生箇所が表示されるが、
  ## どうせこのdieの書かれた行番号になるだけなのであまり意味は無い
  die $indent, '*ERROR*: ', $err, "\n";
}


my $devmode = 0;
my $pname;
my @rfiles = ();

sub readTxt ($i_rfile)
{
  #### 所定のファイルを探し、ファイル名を@rfilesに保持し、中身のテキストを読み込む
  # :param  integer $i_rfile: 0: 自分の旧言語パック
  #                           1: 旧テンプレート
  #                           2: 最新テンプレート
  # :return array           : ファイルの各行の文字列リスト

  my ($rname, $rfile, $f);
  my @default = ('MyLangpack', '00', '01');
  # @default = ('JPN_Phroneris', '619', '683');

  if ($devmode == 1)
  {
    $rname = '';
    &sayndent();
  }
  else {
    chomp($rname = <STDIN>);
  }

  $rname = $rname eq '' ? $default[$i_rfile] : $rname;

  my @heads;

  if ($i_rfile == 0)  # 自分の旧LangPackを読む場合
  {
    $pname = $rname =~ s/(\.ReaperLangPack)?(\.txt)?$//inr;
    @heads = ('');
  }
  else {              # テンプレートを読み込む場合
    $rname = "reaper${rname}";
    @heads = ('', 'template_');
  }

  &indentMore();

  foreach my $head (@heads)
  {
    my $found = 0;

    foreach my $ext ('.ReaperLangPack', '.txt', '.ReaperLangPack.txt', '')
    {
      $rfile = "${head}${rname}${ext}";
      $rfiles[$i_rfile] = $rfile;
      &prindent('Searching... ', $rfile);
      if (-f $rfile)
      {
        $found = 1;
        print '  <- Found!', "\n\n";
        last;
      }
      else {
        print "\n";
      }
    }

    if ($found)
    {
      last;
    }
    else {
      &abort("Can't find a \"${rname}\"-like file for reading.\n", 1);
    }
  }

  &indentLess();

  eval { open $f, '<', ec($rfile); };
  &abort($@) if $@;  # エラー時
  my @txt = <$f>;    # 非エラー時
  close $f;

  map { $_ = du($_); } @txt;
  map { s/[\x0d\x0a]//g; } @txt;  # 改行を削除

  return @txt;

}


sub divDsc ($flg, @txt)
{
  #### 言語パック冒頭の概要部とそれ以外とを切り離す
  # :param  boolean $flg: true : 概要部以外を返す
  #                       false: 概要部だけを返す
  # :param  array   @txt: 概要部を含む言語パック文書の文字列配列
  # :return array       : $flgの指定に応じて切り離された方の文字列配列
  return grep { $flg = /^\[common\]/ ? !$flg : $flg; } @txt;
}



##### 標準入出力で対話


### モード選択

&sayndent($ReaPerLang);
&prindent(<<~ 'EOP');

Mode select (0/1)
|| 0: First-time mode
|| 1: Repeater mode
=======================
EOP
&indentMore();
&prindent('> ');

my $mode;
chomp($mode = <STDIN>);
&indentMore();

if ($mode eq 0)  # 英字などの入力のためにeq
{
  &sayndent('First-time mode. Welcome!');
}
elsif ($mode eq 1)
{
  &sayndent('Repeater mode. Welcome back!');
}
elsif ($mode eq '0d')
{
  &sayndent('Developer mode 0!');
  $devmode = 1;
  $mode = 0;
}
elsif ($mode eq '1d')
{
  &sayndent('Developer mode 1!');
  $devmode = 1;
  $mode = 1;
}
else {
  &abort("Invalid value.\n", 1);
}

&indentLess();
&indentLess();


### ファイル指定

&indentMore();

&sayndent();
&sayndent();
&sayndent('Files in & out (All are UTF-8 text)');
&sayndent('|| in : Your old LangPack file');
&sayndent('|| in : Old REAPER template file the above LangPack has been adapted to') if $mode == 1;
&sayndent('|| in : Current (the newest) REAPER template file');
&sayndent('|| out: Your new LangPack file');
&sayndent('|| out: List of "missing" (currently obsolete) translations');
&sayndent('|| out: Current line-to-line REAPER template file');
&sayndent('===================================================');
&sayndent();
&sayndent('Enter your old LangPack name (extension can be omitted):');
&indentMore();
&prindent('> ');

my @lng_old = &readTxt(0);
&indentLess();
my @lng_dsc = &divDsc(1, @lng_old);
@lng_old = &divDsc(0, @lng_old);


&prindent('Enter the version in ');
my @tmpl_old if $mode == 1;

if ($mode == 1)
{
  print 'each template name (the older and current)', "\n";
  &indentMore();
  &prindent('The older: > ');
  @tmpl_old = &divDsc(0, &readTxt(1));
  &prindent('Current: > ');
}
else {
  print 'the current template name:', "\n";
  &indentMore();
  &prindent('> ');
}

my @tmpl_crr;
@tmpl_crr = &readTxt(2);
&indentLess();


### missingファイルのセクション残留オプション

&sayndent('[Option] Leave empty sections in the "missing" list?');
&indentMore();
&prindent('Yes=y, No=n/(blank): > ');
my $emp_section;

if ($devmode == 1)
{
  $emp_section = '';
  print "\n";
}
else {
  chomp($emp_section = <STDIN>);
}

&indentMore();

if ($emp_section =~ /^y(?:es)?$/i)     # 大文字/小文字の差は無視
{
  $emp_section = 1;
  # &sayndent('All-section mode!');
}
elsif ($emp_section =~ /^(?:no?)?$/i)  # 無記入はNoとする
{
  $emp_section = 0;
  # &sayndent('No-empty-section mode!');
}
else {
  &abort("Invalid value.\n", 1);
}

&indentLess();
&indentLess();

&sayndent();
&sayndent();


### 確認

my @modes = ('First-time', 'Repeater');
my @yesNo = ('No', 'Yes');
my @wfiles = (
  "_${mode}_${rfiles[0]}",
  "_${mode}_${pname}_missing.txt",
  "_${mode}_${rfiles[2]}",
  "_${mode}_${pname}_section.txt"
);
my @outInfo = (
  "|| ${modes[$mode]} Mode",
  "|| in : ${rfiles[0]}",  # 旧言語パック
  "|| in : ${rfiles[2]}",  # 旧テンプレート
  "|| out: ${wfiles[0]}",  # 新言語パック
  "|| out: ${wfiles[1]}",  # missing
  "|| out: ${wfiles[2]}",  # 行対行化した新テンプレート
  "|| Leave empty sections: ${yesNo[$emp_section]}",
  "============================================="
);

splice @outInfo, 2, 0, "|| in : ${rfiles[1]}" if $mode == 1;  # 新テンプレート

&sayndent('* Process Confirmation *');
&sayndent($_) foreach @outInfo;
&sayndent();
&sayndent('Press enter to continue.');
<STDIN>;
&sayndent();



##### メイン処理

&indentMore();


### 概要部の分離処理

my @tmpl_dsc;
@tmpl_dsc = &divDsc(1, @tmpl_crr);
@tmpl_crr = &divDsc(0, @tmpl_crr);

if ($#lng_dsc > $#tmpl_dsc)
{
  for (my $i = $#tmpl_dsc; $i < $#lng_dsc; $i++)
  {
    push @tmpl_dsc, '';
  }
}
elsif ($#lng_dsc < $#tmpl_dsc)
{
  splice
    @tmpl_dsc, $#lng_dsc - 1, $#tmpl_dsc,
    ";/ ... the rest of this description is cut off by $ReaPerLang",
    ''
  ;
}


### 前処理と宣言

my $start_time = Time::HiRes::time;

my @lng_new = @tmpl_crr;
my @lng_missing = ();
my @section = grep { /^\[/; } @lng_old;
my $endsec = '[endsec_RPL]';
push @lng_new, ('', $endsec);
push @section, $endsec;

## $section[インデックス] = [セクション名, その後のコメント]
map { $_ =~ /^(\[.+?\])(.*)$/; $_ = [$1, $2]; } @section;


my $Lol = 0;       # @lng_oldの行数
my $s = -1;        # @sectionのインデックス
my $is_s1st = 1;   # 見つからなかった行がそのセクションで初めてのそれかどうか
my $Lns_top = 0;   # @tmpl_crrの現在セクション頭の行数
my $Lns_btm = -1;  # @tmpl_crrの次のセクション頭の行数

sub insertSectionName ($s)
{
  #### セクション名を@lng_missingに "(改行) セクション名+コメント" の形で配置
  # :param  integer   $s: @sectionのインデックス
  # :return (integer)   : 利用は想定していないが、push後の配列の要素数が返る
  push @lng_missing, ('', $section[$s][0] . $section[$s][1]);
}


### @lng_oldを頭から読んで各行処理

my $p_int = 0;

&sayndent('Processing...');
$| = 1;  # オートフラッシュ（printを即出力する）

foreach my $a (@lng_old)
{


  my $p_prev = $p_int;
  my $len = 50;
  my $progress = $Lol * 100 / $#lng_old;  # 進行度（実数%）
  $p_int = int $progress * $len / 100;    # 進行度（切捨てバー長さ）

  ## ループの中なので一応速度を気にして、サブルーチンを使わずインデント
  printf $indent . '%6.2f %% [', $progress;

  if ($progress == 0)
  {
    printf '%s] %5d lines', ' ' x $len, $Lol;
  }
  elsif ($p_int != $p_prev)
  {
    printf '%s%s] %5d lines', '/' x $p_int, ' ' x ($len - $p_int), $Lol;
  }
  print "\r";  # 行頭へ戻る


  my $Lnw = 0;  # @lng_newの行数
  my $hit = 0;  # 一致した奴ありましたよ判定(0/1)
  # $DB::single = 1 if $Lol >= 11;

  if ($a =~ /^\[/)  # セクション名の行ならば
  {

    $s++;
    $is_s1st = 1;
    &insertSectionName($s) if $emp_section == 1;
    $Lnw = $Lns_btm + 1;

    while ($hit < 1 and $Lnw <= $#lng_new)
    {
      if ($lng_new[$Lnw] =~ /^\Q$section[$s][0]/)
      {
        $lng_new[$Lnw] = $a;  # @lng_new（≒@tmpl_crr）にセクション名を記載（セクションコメント込み）
        $Lns_top = $Lnw;      # @lng_newを読む時の範囲を同名セクション内のみに抑制（上限）
        $hit = -1;
      }
      elsif ($hit == -1 and $lng_new[$Lnw] =~ /^\[/)
      {
        $Lns_btm = $Lnw - 1;  # @lng_newを読む時の範囲を同名セクション内のみに抑制（下限）
        $hit = 1;
      }

      $Lnw++;
    }

  }
  elsif ($a =~ /^5CA1E00000000000=/)  # スケール情報の行ならば
  {

    splice @lng_new, $Lns_btm, 0, $a;  # @lng_newの同一セクションの末尾にスケール情報を追加
    my $scaled = '5CA1E...........=*scaled*';
    splice @tmpl_crr, $Lns_btm, 0, $scaled;            # その分、@tmpl_crrの行数を@lng_newに合わせる
    splice @tmpl_old, $Lol, 0, $scaled if $mode == 1;  # 同様に、@tmpl_oldの行数を@lng_oldに合わせる

    $Lns_btm++;

  }
  elsif ($a =~ /^((?:;\/\^?)?)(\w{16})=(.*)/)  # スケール情報ではない、翻訳済み行または意図的な無効化行ならば
  {

    my $oo_a = $1;  # ;/ または ;/^ の意図的な無効化行（opt-out、「（森）」の独自記法）
    my $code_a = $2;
    my $str_a = $3;
    my $yet_init = ';';  # 未翻訳接頭辞

    if (($mode == 0 and $oo_a =~ /;\/\^/) or ($mode == 1 and $tmpl_old[$Lol] =~ /^;\^/))
    {
      $yet_init = ';^';
    }

    $Lnw = $Lns_top;
    $hit = 0;

    while ($hit == 0 and $Lnw <= $Lns_btm)  # @lng_newを頭から（または属するセクション内のみ）読む
    {
      if ($lng_new[$Lnw] =~ /^\Q${yet_init}\E${code_a}=/)  # 未翻訳接頭辞付きのコード一致行ならば
      {
        $lng_new[$Lnw] = $a;
        $hit = 1;
      }
      $Lnw++;
    }

    if ($hit == 0)  # @lng_oldと@tmpl_crrでコード一致の行が全くないならば
    {
      if ($emp_section == 0 and $is_s1st == 1)
      {
        &insertSectionName($s);
        $is_s1st = 0;
      }

      if ($mode == 1)
      {
        my $str_sub = $tmpl_old[$Lol] =~ s/^;\^?//r;
        $a =~ s/^(?:;\/\^?)?//;

        ## 接頭辞指定。意図的な無効化行ならそれを、そうでないならオプション行区別のために元のを。
        $yet_init = $oo_a if $oo_a;

        push @lng_missing, $yet_init . $str_sub, $yet_init . $a;
      }
      else {
        push @lng_missing, $a;
      }
    }

    $Lol = $Lol + 0;
  }

  $Lol++;


}

$| = 0;

print "\n";  # 進捗バーの行末

my $time = sprintf('%.3f', Time::HiRes::time - $start_time);

&sayndent();
&sayndent('Process done!');
&sayndent('(Time: ', $time, ' sec)');
&sayndent();
&sayndent();



##### 後処理とファイル出力

&indentMore();

my $date = localtime;
my @additionalInfo = (
  "|| Date: ${date} (local)",
  "|| Time: ${time} sec"
);

splice @outInfo, -1, 0, @additionalInfo;
unshift @lng_missing, "Generated by ${ReaPerLang}", @outInfo;
map { $_ = $_->[0] . $_->[1]; } @section;
splice @section, -1;
splice @lng_new, -2;
unshift @lng_new, @lng_dsc;
unshift @tmpl_crr, @tmpl_dsc;


&sayndent('Writing...');
&sayndent();

sub writeTxt ($i_wfile, @txt)
{
  #### @wfilesのファイル名でテキストファイルを書き出す
  # :param  integer   $i_wfile: 0: 新言語パック
  #                             1: missing
  #                             2: 新テンプレート（行対行化したもの）
  #                             3: 旧言語パックからセクション名の行だけ抽出したもの
  # :param  array     @txt    : ファイルの各行の文字列リスト
  # :return (boolean)         : 利用は想定していないが、printの成否に応じた真偽値が返る

  my $wfile = $wfiles[$i_wfile];
  my $f;

  map { $_ = $_ . "\n"; } @txt;

  eval { open $f, '>', ec($wfile); };
  &abort($@) if $@;  # エラー時
  print $f @txt;     # 非エラー時
  close $f;

  &sayndent('Completed writing "', $wfile, '": about ', $#txt, ' lines.');
}

&writeTxt(0, @lng_new);
&writeTxt(1, @lng_missing);
&writeTxt(2, @tmpl_crr);
# &writeTxt(3, @section);

&sayndent();
&sayndent();

$indent = '';
$finalMessage = &getIndentedTxt("All done!\nPress enter to exit.\n");


## 異常終了でも正常終了でも必ずここに飛ぶ。ただし正常なら $? == 0
END {
  print { $? > 0 ? *STDERR : *STDOUT; } $finalMessage;
  <STDIN>;
}
