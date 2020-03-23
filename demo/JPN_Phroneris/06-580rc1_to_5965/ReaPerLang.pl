#!/usr/local/bin/perl
my $ReaPerLang = 'ReaPerLang ver 1.06';

# use strict  ;		# デバッグ用
# use warnings;		# デバッグ用
use autodie    ;	# エラー時に$@を得るため
use Time::HiRes;	# 最後に経過時間を出すため

use utf8;								# このファイル内に直接書いたUTF-8文字列を全て内部文字列にする
use open OUT => ':utf8';				# ファイル出力を全て '>:encoding(UTF-8)' で行う
use Encode qw/encode decode/;

my $enc_os = 'cp932';	# Windows JP
use PerlIO::encoding;	# for building exe
use Encode::JP;			# for building exe
use Encode::CN;			# 念のため
use Encode::KR;			# 念のため
use Encode::TW;			# 念のため
binmode STDIN,  ":encoding(${enc_os})";	# 標準入出力で cp932(見た目)⇔UTF-8(内部) と変換する
binmode STDOUT, ":encoding(${enc_os})";
binmode STDERR, ":encoding(${enc_os})";

sub du($) { decode('UTF-8', shift) };	# 内部文字列にする（文字コードを取り除く）
sub eu($) { encode('UTF-8', shift) };	# UTF-8にする
sub dc($) { decode($enc_os, shift) };
sub ec($) { encode($enc_os, shift) };
sub ed($) { ec(du(shift)) };	# デバッグ時にpで文字列が化けたら"ec $var"または"ed $var"で戻せることが多い
# sub isN($) { Encode::is_utf8(shift) ? 'naibu' : 'hadaka kamo...'; }

my $indent = '';
sub abort
{
	my $err = shift;
	my $noDecode = shift;
	$err = dc($err) unless $noDecode;	# エラー文を自前で直接指定する場合、第2引数をtrueにしてデコードを避ける
	print $indent, '*ERROR*: ', $err, "\n", $indent, 'Press enter to abort.';
	<STDIN>;
	exit 1;
}

my $devmode = 0;
my @rnames = ();
sub readTxt
{
	my ($rname, $f);
	my @default = ('MyLangpack', '00', '01');
	# my @default = ('JPN_Phroneris', '580rc1', '590');
	my $i = $_[0];
	if ($devmode==1)
	{
		$rname = '';
		print "\n";
	}else{
		chomp($rname = <STDIN>);
	}
	$rname = $rname eq '' ? $default[$i] : $rname;
	if ($i == 0)
	{
		$rname = "${rname}.txt";
	}else{
		$rname = "template_reaper${rname}.ReaperLangPack.txt";
	}
	$rnames[$i] = $rname;
	print ' Reading... ', $rname, "\n";
	eval { open $f, '<', ec($rname) };
	&abort($@) if $@;	# エラー時
	my @txt = <$f>;		# 非エラー時
	close $f;
	print ' OK!', "\n\n";
	map { $_=du($_) } @txt;
	map { s/[\x0d\x0a]//g } @txt;	# 改行を削除
	return @txt;
}
sub divDsc
{
	my $flg = shift;	# 0なら文書冒頭の概要部以外を、1なら概要部だけを返す
	return grep { $flg = /^\[common\]/ ? !$flg : $flg } @_;
}

print $ReaPerLang, "\n";
print <<'EOP';

Mode select (0/1)
┃0: First-time mode
┃1: Repeater mode 
┗━━━━━━━━━━
EOP
print ' > ';
my $mode;
chomp($mode = <STDIN>);
if ($mode eq 0)	# 英字などの入力のためにeq
{
	print 'First-time mode. Welcome!';
}
elsif ($mode eq 1)
{
	print 'Repeater mode. Welcome back!';
}
elsif ($mode eq '0d')
{
	print 'Developer mode 0!';
	$devmode = 1;
	$mode = 0;
}
elsif ($mode eq '1d')
{
	print 'Developer mode 1!';
	$devmode = 1;
	$mode = 1;
}else{
	&abort("Invalid value.\n", 1);
}

$indent = ' ';
print "\n\n";
print ' Files in & out (make sure that all are UTF-8 ".txt" files)', "\n";
print ' ┃in : Your old LangPack file', "\n";
print ' ┃in : Old REAPER template file the above LangPack has been adapted to', "\n" if $mode == 1;
print ' ┃in : Current (the newest) REAPER template file', "\n";
print ' ┃out: "_', $mode, '_lng_new.txt" ... Your new LangPack file', "\n";
print ' ┃out: "_', $mode, '_lng_missing.txt" ... List of obsolete translations in your old one', "\n";
print ' ┃out: "_', $mode, '_tmp_crr.txt" ... Current line-to-line template with "scaled" lines', "\n";
print ' ┗━━━━━━━━━━━━━━━━━━━━━━━━', "\n";
print "\n";
print ' Enter your old LangPack name (without ".txt"):', "\n", '  > ';
my @lng_old = &readTxt(0);
my @lng_dsc = &divDsc(1, @lng_old);
@lng_old = &divDsc(0, @lng_old);

print ' Enter the [version] of "template_reaper[version].ReaperLangPack.txt" ';
my @tmpl_old if $mode == 1;
if ($mode == 1)
{
	print '(the older and current)', "\n";
	print '  The older: > ';
	@tmpl_old = &divDsc(0, &readTxt(1));
	print '  Current: > ';
}else{
	print '(current):', "\n";
	print '  > ';
}
my @tmpl_crr;
@tmpl_crr = &readTxt(2);
print ' [Option] Keep empty sections in "_', $mode, '_lng_missing.txt" ?', "\n";
print '  Yes=y/No=n: > ';
my $emp_section;
chomp($emp_section = <STDIN>);
if ($emp_section =~ /^y(?:es)?$/i)	# 大文字/小文字の差は無視
{
	$emp_section = 1;
	print ' All-section mode!';
}
elsif ($emp_section =~ /^(?:no?)?$/i)	# 無記入はNoとする
{
	$emp_section = 0;
	print ' No-empty-section mode!';
}else{
	&abort("Invalid value.\n", 1);
}
print "\n\n";

my @tmpl_dsc;
@tmpl_dsc = &divDsc(1, @tmpl_crr);
@tmpl_crr = &divDsc(0, @tmpl_crr);
if ($#lng_dsc>$#tmpl_dsc)
{
	for (my $i=$#tmpl_dsc; $i<$#lng_dsc; $i++) {
		push @tmpl_dsc, '';
	}
}
elsif ($#lng_dsc<$#tmpl_dsc)
{
	splice @tmpl_dsc, $#lng_dsc-1, $#tmpl_dsc, "; /* ... the rest of this description is cut off by $ReaPerLang */", '';
}

my $start_time = Time::HiRes::time;
my @lng_new = @tmpl_crr;
my @lng_missing = ();
my @section = grep { /^\[/ } @lng_old;
my @endsec = ('[endsec_RPL]');
push @section, @endsec;
map { $_=~/^(\[.+?\])(.*)$/; $_=[$1,$2] } @section;		# $section[セクション名][その後のコメント]
push @lng_new, @endsec;

my $Lol = 0;	# @lng_oldの行数
my $s = -1;		# @sectionの要素数
my $is_s1st = 1;	# 見つからなかった行がそのセクションで初めてのそれかどうか
my $Lns_top = 0;	# @tmpl_crrの現在セクション頭の行数
my $Lns_btm = -1;	# @tmpl_crrの次のセクション頭の行数
sub insertSectionName
{
	my $s = shift;
	push @lng_missing, ('', $section[$s][0].$section[$s][1]);	# "(改行) セクション名+コメント" の形で@lng_missing内に配置
}
my $p_int = 0;
print ' Processing...', "\n";
$| = 1;	# オートフラッシュ（printを即出力する）

foreach my $a (@lng_old)		# @lng_oldを頭から読む
{

	my $p_prev = $p_int;
	my $len = 50;
	my $progress = $Lol*100/$#lng_old;	# 進行度（実数%）
	$p_int = int $progress*$len/100;	# 進行度（切捨てバー長さ）
	printf " %6.2f %% [", $progress;
	if ($progress == 0)
	{
		printf "%s] %5d lines", ' 'x$len, $Lol;
	}
	elsif ($p_int != $p_prev)
	{
		printf "%s%s] %5d lines", '/'x$p_int, ' 'x($len-$p_int), $Lol;
	}
	print "\r";

	my $Lnw = 0;	# @lng_newの行数
	my $hit = 0;	# 一致した奴ありましたよ判定(0/1)
	# $DB::single=1 if $Lol>=11;
	
	if ($a =~ /^\[/)	# セクション名の行ならば
	{
		$s++;
		$is_s1st = 1;
		&insertSectionName($s) if $emp_section==1;
		$Lnw = $Lns_btm + 1;
		while ($hit<1 and $Lnw<=$#lng_new)
		{
			if ($lng_new[$Lnw] =~ /^\Q$section[$s][0]/)
			{
				$lng_new[$Lnw]=$a;		# @lng_new（≒@tmpl_crr）にセクション名を記載（セクションコメント込み）
				$Lns_top = $Lnw;		# @lng_newを読む時の範囲を同名セクション内のみに抑制（上限）
				$hit = -1;
			}
			elsif ($hit == -1 and $lng_new[$Lnw] =~ /^\[/)
			{
				$Lns_btm = $Lnw - 1;	# @lng_newを読む時の範囲を同名セクション内のみに抑制（下限）
				$hit = 1;
			}
			$Lnw++;
		}
	}
	elsif ($a =~ /^5CA1E00000000000=/)	# スケール情報の行ならば
	{
		splice @lng_new, $Lns_btm, 0, $a;	# @lng_newの同一セクションの末尾にスケール情報を追加
		my $scaled = '5CA1E...........=*scaled*';
		splice @tmpl_crr, $Lns_btm, 0, $scaled;				# その分、@tmpl_crrの行数を@lng_newに合わせる
		splice @tmpl_old, $Lol, 0, $scaled if $mode == 1;	# 同様に、@tmpl_oldの行数を@lng_oldに合わせる
		$Lns_btm++;
	}
	elsif ($a =~ /^((?:;\/\^?)?)(\w{16})=(.*)/)	# スケール情報ではない、翻訳済み行または意図的な無効化行ならば
	{
		my $oo_a = $1;	# ;/ または ;/^ の意図的な無効化行（opt-out、「（森）」の独自記法）
		my $code_a = $2;
		my $str_a = $3;
		my $yet_init = ';';	# 未翻訳接頭辞
		if ($mode==1 and $tmpl_old[$Lol]=~/^;\^/)
		{
			$yet_init = ';^';
		}
		
		$Lnw = $Lns_top;
		$hit = 0;
		while ($hit==0 and $Lnw<=$Lns_btm)	# @lng_newを頭から（または属するセクション内のみ）読む
		{
			if ($lng_new[$Lnw] =~ /^\Q${yet_init}\E${code_a}=/)	# 未翻訳接頭辞付きのコード一致行ならば
			{
				$lng_new[$Lnw] = $a;
				$hit = 1;
				# eval { print "${Lol}: ${a}\n"; };
				# if ($@) {
					# print '*ERROR* :', dc($@);
					# $DB::single = 1;
				# }
			}
			$Lnw++;
		}
		if ($hit == 0)		# @lng_oldと@tmpl_crrでコード一致の行が全くないならば
		{
			if ($mode == 1)
			{
				my $str_sub = $tmpl_old[$Lol] =~ s/^;\^?//r;
				$a =~ s/^(?:;\/\^?)?//;
				$yet_init = $oo_a if $oo_a;	# 接頭辞指定。意図的な無効化行ならそれを、そうでないならオプション行区別のために元のを。
				if ($emp_section==0 and $is_s1st==1)
				{
					&insertSectionName($s);
					$is_s1st = 0;
				}
				push @lng_missing, $yet_init.$str_sub, $yet_init.$a;
			}else{
				push @lng_missing, $a;
			}
		}
		$Lol = $Lol + 0;
	}

	$Lol++;

}

$| = 0;
my $time = sprintf("%.3f", Time::HiRes::time - $start_time);
print "\n\n", ' Writing...', "\n\n";

$emp_section = $emp_section==1 ? 'Yes' : 'No';
my $date = localtime;
my @header = (
"Generated by ${ReaPerLang}",
"┃in : ${rnames[0]}",
"┃in : ${rnames[2]}",
"┃out: _${mode}_lng_new.txt",
"┃out: _${mode}_lng_missing.txt",
"┃out: _${mode}_tmp_crr.txt",
"┃Keep empty sections: ${emp_section}",
"┃Date: ${date} (local)",
"┃Time: ${time} sec",
"┗━━━━━━━━━━━━━━━━━━━━━"
);
splice @header, 3, 0, "┃in : ${rnames[1]}" if $mode == 1;
unshift @lng_missing, @header;
map { $_=$_->[0].$_->[1] } @section;
pop @section;
splice @lng_new, -2;
unshift @lng_new, @lng_dsc;
unshift @tmpl_crr, @tmpl_dsc;

sub writeTxt
{
	my $name  = shift;
	my $f;
	my $wname = "_${mode}_${name}.txt";
	my @txt = eval "\@$name";
	map { $_=$_."\n" } @txt;

	eval { open $f, '>', ec($wname) };
	&abort($@) if $@;	# エラー時
	print $f @txt;		# 非エラー時
	close $f;
	print ' Complete writing "', $wname, '": about ', $#txt, " lines.\n";
}

&writeTxt('lng_new');
&writeTxt('lng_missing');
# &writeTxt('section');
&writeTxt('tmpl_crr');

print ' (Time: ', "$time", ' sec)', "\n";
print "\n", ' Press enter to exit.', "\n";
<STDIN>;
