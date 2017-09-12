#!/usr/local/bin/perl
#ReaPerLang ver1.04
my $version = 1.040;

use strict;
use warnings;
use autodie;
use Time::HiRes;

use utf8;								# このファイル内に直接書いたUTF-8文字列を全て内部文字列にする
use open OUT => ':utf8';				# ファイル出力を全て '>:encoding(UTF-8)' で行う
use Encode qw/encode decode/;

my $enc_os = 'cp932';
binmode STDIN,  ":encoding(${enc_os})";		# 標準入出力で cp932(見た目)⇔UTF-8(内部) と変換する
binmode STDOUT, ":encoding(${enc_os})";
binmode STDERR, ":encoding(${enc_os})";

sub du($) { decode('UTF-8', shift) };	# 内部文字列にする
sub eu($) { encode('UTF-8', shift) };	# UTF-8にする
sub dc($) { decode($enc_os, shift) };
sub ec($) { encode($enc_os, shift) };	# ちなみに、デバッグ時に非内部文字列が化けてたら p ec(du($var)) で戻せる
# sub isN($) { Encode::is_utf8(shift) ? 'naibu' : 'hadaka kamo...'; }

my $indent = '';
sub abort
{
	my $err = shift;
	my $nodec = shift;
	$err = dc($err) unless $nodec;	# エラー文を自前で直接指定する場合、第2引数をtrueにしてデコードを避ける
	print $indent, '*ERROR*: ', $err, "\n", $indent, 'Press enter to abort.';
	<STDIN>;
	exit 1;
}

my @rnames = ();
sub readtxt
{
	my ($rname, $f);
	my @default = ('JPN_Phroneris', 522, '550rc21');
	my $i = $_[0];
	chomp($rname = <STDIN>);
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
	map { s/[\r\n]//g } @txt;	# 改行を削除
	return @txt;
}

printf "ReaPerLang ver %.2f\n", $version;
print <<'EOP';

Mode select (0/1)
┃0: First-time mode
┃1: Repeater mode 
┗━━━━━━━━━━
EOP
print ' > ';
my $mode;
chomp($mode = <STDIN>);
if ($mode eq 0)	# 英字などを入力された場合のためにここの分岐だけeq
{
	print 'First-time mode. Welcome!';
}
elsif ($mode eq 1)
{
	print 'Repeater mode. Welcome back!';
}else{
	&abort("Invalid value.\n",1);
}

$indent = ' ';
print "\n\n";
print ' Files in & out (make sure that all are UTF-8 ".txt" files)', "\n";
print ' ┃in : Your old LangPack file', "\n";
print ' ┃in : Old REAPER template file the above LangPack has been adapted to', "\n" if $mode == 1;
print ' ┃in : Current (the newest) REAPER template file', "\n";
print ' ┃out: "_lng', $mode, '_new.txt" ... Your new LangPack file', "\n";
print ' ┃out: "_lng', $mode, '_missing.txt" ... List of obsolete translations in your old one', "\n";
print ' ┗━━━━━━━━━━━━━━━━━━━━━━━━', "\n";
print "\n";
print ' Enter your old LangPack name (without ".txt"):', "\n", '  > ';
my @lng_old = &readtxt(0);

print ' Enter the [version] of "template_reaper[version].ReaperLangPack.txt" ';
my @tmpl_old if $mode == 1;
my @tmpl_crr;
if ($mode == 1)
{
	print '(the older and current)', "\n";
	print '  The older: > ';
	@tmpl_old = &readtxt(1);
	print '  Current: > ';
	@tmpl_crr = &readtxt(2);
}else{
	print '(current)', "\n";
	print '  > ';
	@tmpl_crr = &readtxt(2);
}

my $start_time = Time::HiRes::time;
my @lng_new = @tmpl_crr;
my @lng_missing = ();
my @section = grep { /^\[/ } @lng_old;	# []以後の文言を消すなら grep { $_=~s/^(\[.+?\]).*$/$1/ } @lng_old;
push @section, '[owari]';
map { s/(\[|\])/\\$1/g } @section;		# []をエスケープ

my $Lol = 0;	# @lng_oldの行数
my $s = -1;		# @sectionの要素数

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
	if ($a =~ /^\[/)					# セクション名の行ならば
	{
		push @lng_missing, ('', $section[++$s]);		# \n[section名]～の形で@lng_missing内に配置
	}
	elsif ($a =~ /^5CA1E00000000000=/)	# スケール情報の行ならば
	{
		while ($hit==0 and $Lnw<=$#lng_new)
		{
			if ($lng_new[$Lnw] =~ /^$section[$s+1]/)	# いま読んでいる@lng_oldの要素が属するセクションと
			{											# 同じ@lng_new(≒@tmpl_crr)のセクションの末尾にスケール情報を追加
				splice @lng_new, $Lnw-1, 0, $a;
				splice @tmpl_crr, $Lnw-1, 0, ';5CA1E ; sized!';	# その分、@tmpl_crrの行数を@lng_newに合わせる
				splice @tmpl_old, $Lol-1, 0, ';5CA1E ; sized!' if $mode == 1;	# 同様に、@tmpl_oldの行数を@lng_oldに合わせる
				$hit = 1;
			}
			$Lnw++;
		}
	}
	elsif ($a =~ /^\w+?=/)				# スケール情報ではない翻訳済みの行ならば
	{
		my $startLnw = 0;
		my $endLnw = $#tmpl_crr;
		my $yet_init = ';';
		if ($mode==1 and $tmpl_old[$Lol]=~/^;\^/)			# @tmpl_oldの同じ行が;^始まりのオプション行ならば
		{
			$yet_init = ';\^';	# 未翻訳接頭辞
			while ($hit==0 and $Lnw<=$#lng_new)		# 下記で@lng_newを読むときの範囲を
			{										# いま読んでいる@lng_oldの要素が属するセクション内のみに調整
				if ($lng_new[$Lnw] =~ /^$section[$s]/)
				{
					$startLnw = $Lnw;
				}
				elsif ($lng_new[$Lnw] =~ /^$section[$s+1]/)
				{
					$hit = 1;
					$endLnw = $Lnw+1;
				}
				$Lnw++;
			}
		}

		$a =~ /^(\w+?)=(.*)/;
		my $code_a = $1; my $str_a = $2;
		$Lnw = $startLnw;
		while ($hit==0 and $Lnw<=$endLnw)	# @lng_newを頭から（または属するセクション内のみ）読む
		{
			if ($lng_new[$Lnw] =~ /^${yet_init}${code_a}=/)	# 未翻訳接頭辞付きのコード一致行ならば
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
				push @lng_missing, ($str_sub, $a);
			}else{
				push @lng_missing, $a;
			}
		}
	}

	$Lol++;

}

$| = 0;
print "\n\n", ' Writing...', "\n\n";

unshift @lng_missing, "; List of translations no longer used in \"${rnames[2]}\"\n\n";
pop @section;
map { s/\\(\[|\])/$1/g } @lng_missing;
map { s/\\(\[|\])/$1/g } @section;

sub writetxt
{
	my $name  = shift;
	my $f;
	my $wname = "_${mode}_${name}.txt";
	my @txt = eval "\@$name";
	map { s/^(.*)$/$1\n/ } @txt;

	eval { open $f, '>', ec($wname) };
	&abort($@) if $@;	# エラー時
	print $f @txt;		# 非エラー時
	close $f;
	print ' Complete writing "', $wname, '": about ', $#txt, " lines.\n";
}

&writetxt('lng_new');
&writetxt('lng_missing');
# &writetxt('section');
# &writetxt('tmpl_crr');

printf " (Time: %.3f sec)\n", Time::HiRes::time - $start_time;
print "\n", ' Press enter to exit.', "\n";
<STDIN>;
