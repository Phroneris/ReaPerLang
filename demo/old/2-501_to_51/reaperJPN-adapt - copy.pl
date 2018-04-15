#!/usr/local/bin/perl

$name1="";
$name2="";

print "旧日本語txtファイル名（.txt抜き）を入力:\n> ";
chomp($name1=<STDIN>);
if(!open(jpn_old,"<$name1.txt")){
	print "開けなかった。キレそう\n\n";
	print "エンターキーで終了";
	<STDIN>;
	exit(0);
}else{
	@jpn_old=<jpn_old>;
	close(jpn_old);
	print "OK!\n\n";
}
print "最新のREAPER翻訳テンプレートtxtファイル名（.txt抜き）を入力:\n> ";
chomp($name2=<STDIN>);
if(!open(reaper_orig,"<$name2.txt")){
	print "開けなかった。キレそう\n\n";
	print "エンターキーで終了";
	<STDIN>;
	exit(0);
}else{
	@reaper_orig=<reaper_orig>;
	close(reaper_orig);
	print "OK!\n\n";
}

@reaper_new=@reaper_orig;
@jpn_missing=();
@dialog=grep{/^\[/&&($_=~s/^(.+\]).*\n/$1/)}@jpn_old;
map{s/([\Q\\*+.?{}()[]^$\-|\/\E])/\\$1/g;$_;}@dialog;	# 正規表現に影響する文字を全てエスケープ

$jo=0;		# @jpn_oldの行数
$jm=0;		# @jpn_missingの行数
$ro=0;		# @reaper_origの行数
$rn=0;		# @reaper_newの行数
$thereis=0;	# 一致した奴ありましたよ判定(0/1)
$d=-1;		# @dialogの要素数

$|=1;		# オートフラッシュ（printを即出力する）
$p_int=0;
print "処理中...\n";

foreach $a(@jpn_old){		# @jpn_oldを頭から読む

	$progress=$jo*100/$#jpn_old;	# 進行度（実数%）
	$len=50;
	$p_prev=$p_int;
	$p_int=int($progress*$len/100);	# 進行度（切捨てバー長さ）
	printf(" %6.2f % [",$progress);
	if($progress==0){
		print " "x$len,"]";
	}elsif($p_int!=$p_prev){
		print "/"x($p_int)," "x($len-$p_int),"]";
	}
	print "\r";
	
	if($a=~/^\[/){				# カギカッコ始まりならば
		$d++;
		$jpn_missing[$jm]="\n";
		$jpn_missing[$jm+1]="$dialog[$d]\n";		# \n[dialog名]～の形で@jpn_missing内に配置
		$jm=$jm+2;
		
	}elsif($a=~/^5CA1E00000000000=/){		# ダイアログのスケール情報ならば

		$rn=0;
		while($rn<$#reaper_new){
			if($reaper_new[$rn]=~/^$dialog[$d+1]/){		# いま読んでいる@jpn_oldの要素が属するダイアログと
				splice @reaper_new,$rn-1,0,$a;			# 同じ@reaper_newのダイアログの末尾にスケール情報を追加
				$rn=$rn+2;
			}else{
				$rn++;
			}
		}
		$ro=0;
		while($ro<$#reaper_orig){
			if($reaper_orig[$ro]=~/^$dialog[$d+1]/){	# 上記処理の分、@reaper_origの行数を@reaper_newに合わせる
				splice @reaper_orig,$ro-1,0,"\n";
				$ro=$ro+2;
			}else{
				$ro++;
			}
		}
		
	}elsif($a=~/^\w/){			# スケール情報以外の単語構成文字始まりならば
		$a=~/(\w+)=(.*)\n/;
		$code_a=$1; $str_a=$2;
		$rn=0;
		foreach $b(@reaper_orig){				# @reaper_origを頭から読む
			if($reaper_new[$rn]=~/^;\w+=/){		# その行の@reaper_newが ;コード=文言\n という形の行（日本語化前の文言行）ならば
				$b=~/^;(\w+)=(.*)\n/;
				$code_b=$1; $str_b=$2;
				if($code_a eq $code_b){					# @jpn_oldと@reaper_origがコード一致ならば
					$reaper_new[$rn]="$code_a=$str_a\n";
					$thereis=1;
				}
			}
			$rn++;
		}
		if($thereis==0){				# @jpn_oldと@reaper_origでコード一致の行が全くないならば
			$jpn_missing[$jm]="$code_a=$str_a\n";
			$jm++;
		}
	}
	
	$thereis=0;
	$jo++;
}

$|=0;
print "\n";

splice @jpn_missing,0,1;
map{s/\\([\[\]])/$1/g;$_;}@jpn_missing;
open(jpn_missing,">jpn_missing.txt") or print "jpn_missing.txt へ書き出せなかった。キレそう\n";
print jpn_missing @jpn_missing;
close(jpn_missing);
print "jpn_missing.txt へ約 ",$jm-1," 行書き出しました。\n";

open(reaper_new,">reaper_new.txt") or print "reaper_new.txt へ書き出せなかった。キレそう\n";
print reaper_new @reaper_new;
close(reaper_new);
print "reaper_new.txt へ約 $rn 行書き出しました。\n";

=pod
print "jpn_old.txt は $jo 行でした。\n";
open(reaper_orig,">reaper_orig.txt") or print "reaper_orig.txt へ書き出せなかった。キレそう\n";
print reaper_orig @reaper_orig;
close(reaper_orig);
print "reaper_orig.txt へ約 $ro 行書き出しました。\n";
map{s/\\(\\*)/$1/g;$_;}@dialog;
map{s/^(.*)$/$1\n/;$_;}@dialog;
open(dialog,">dialog.txt");
print dialog @dialog;
close(dialog);
print "dialog.txt へ約 $d 行書き出しました。\n";
=cut

print "\nエンターキーで終了";
$end=<STDIN>;


# copyっていうファイル名になってるけど、何の目的でそうしたんだっけ？
# 半年前の作業だから覚えてない。
