#!/usr/local/bin/perl
#reaperJPN-adapt ver1.01

sub readtxt {
	my $tname = "";
	chomp($tname = <STDIN>);
	if($_[0] == 1){
		$tname = "JPN_Phroneris" if($tname eq "");
	}else{
		$tname = "template_reaper${tname}.ReaperLangPack";
	}
	print " 読み込み中... $tname.txt\n";
	if(!open(file,"<$tname.txt")){
		print "開けなかった。キレそう\n\n";
		print "エンターキーで終了";
		<STDIN>;
		exit(0);
	}else{
		my @txt = <file>;
		close(file);
		print " OK!\n\n";
		return @txt;
	}
}

print "旧日本語txtファイル名が \"JPN_Phroneris.txt\" で良ければEnterを、\nそうでなければファイル名（.txt抜き）を入力:\n> ";
@jpn_old = &readtxt(1);

print "REAPER翻訳テンプレートtxtファイル名\n\"template_reaper***.ReaperLangPack.txt\" の、***にあたる数字を入力\n（最新版とその1つ前版）\n";
print "最新版: > ";
@reaper_curr = &readtxt(2);
print "1つ前版: > ";
@reaper_prev = &readtxt(3);


@jpn_new = @reaper_curr;
@jpn_missing = ();
@dialog = grep{/^\[/&&($_=~s/^(.+\]).*\n/$1/)}@jpn_old;
map{s/([\[\]])/\\$1/g;$_;}@dialog;	# []をエスケープ

$Jol = 0;		# @jpn_oldの行数
$Jms = 0;		# @jpn_missingの行数
$Jnw = 0;		# @jpn_newの行数
$Rcr = 0;		# @reaper_currの行数
$thereis = 0;	# 一致した奴ありましたよ判定(0/1)
$d = -1;		# @dialogの要素数

$| = 1;			# オートフラッシュ（printを即出力する）
$p_int = 0;
print "処理中...\n";

foreach $a(@jpn_old){		# @jpn_oldを頭から読む

	$progress = 100* $Jol/$#jpn_old;	# 進行度（実数%）
	$len = 50;
	$p_prev = $p_int;
	$p_int = int($progress*$len/100);	# 進行度（切捨てバー長さ）
	printf(" %6.2f % [",$progress);
	if($progress==0){
		print " "x$len,"]";
	}elsif($p_int!=$p_prev){
		print "/"x($p_int)," "x($len-$p_int),"]";
	}
	print "\r";

	if($a=~/^\[/){				# カギカッコ始まりならば
		$d++;
		$jpn_missing[$Jms] = "\n";
		$jpn_missing[$Jms+1] = "$dialog[$d]\n";		# \n[dialog名]～の形で@jpn_missing内に配置
		$Jms = $Jms+2;
		
	}elsif($a=~/^5CA1E00000000000=/){		# ダイアログのスケール情報ならば

		$Jnw = 0;
		while($Jnw>=0 and $Jnw<$#jpn_new){
			if($jpn_new[$Jnw]=~/^$dialog[$d+1]/){		# いま読んでいる@jpn_oldの要素が属するダイアログと
				splice @jpn_new,$Jnw-1,0,$a;			# 同じ@jpn_newのダイアログの末尾にスケール情報を追加
				$Jnw = -999;
			}
			$Jnw++;
		}
		$Rcr = 0;
		while($Rcr>=0 and $Rcr<$#reaper_curr){
			if($reaper_curr[$Rcr]=~/^$dialog[$d+1]/){	# 上記処理の分、@reaper_currの行数を@jpn_newに合わせる
				splice @reaper_curr,$Rcr-1,0,"\n";
				$Rcr = -999;
			}
			$Rcr++;
		}
		
	}elsif($a=~/^\w/){			# スケール情報以外の単語構成文字始まり（＝翻訳されている文言行）ならば
	
		$Jnw = 0;
		$thereis = 0;
		if($reaper_prev[$Jol]=~/^;\^/){			# @reaper_prevの同じ行が;^始まり（＝オプション行）ならば
			while($thereis==0 and $Jnw<$#jpn_new){		# 下記で@reaper_currを読むときの範囲を
				if($jpn_new[$Jnw]=~/^$dialog[$d]/){		# いま読んでいる@jpn_oldの要素が属するダイアログ内のみに調整
					$startJnw = $Jnw;
				}elsif($jpn_new[$Jnw]=~/^$dialog[$d+1]/){
					$thereis = 1;
					$endJnw = $Jnw + 1;
				}
				$Jnw++;
			}
			$yet_init = "^;\\\^";	# 未翻訳頭
		}else{
			$startJnw = 0;
			$endJnw = $#reaper_curr;
			$yet_init = "^;";
		}

		$Jnw = $startJnw;
		$thereis = 0;
		$a =~ /(\w+)=(.*)\n/;
		$code_a = $1; $str_a = $2;
		while($thereis==0 and $Jnw<$endJnw){		# @reaper_currを頭から（または属するダイアログ内のみ）読む
			if($jpn_new[$Jnw]=~/${yet_init}\w+=/){			# @jpn_newの同じ行が {未翻訳頭}単語構成文字=文言\n という形の行（＝翻訳されていない文言行）ならば
				$reaper_curr[$Jnw] =~ /${yet_init}(\w+?)=(.*)\n/;
				$code_b = $1; $str_b = $2;
				if($code_a eq $code_b){							# @jpn_oldと@reaper_currがコード一致ならば
					$jpn_new[$Jnw] = "$code_a=$str_a\n";
					$thereis = 1;
				}
			}
			$Jnw++;
		}
		if($thereis==0){		# @jpn_oldと@reaper_currでコード一致の行が全くないならば
			$jpn_missing[$Jms] = substr($reaper_prev[$Jol],1);
			$jpn_missing[$Jms+1] = "$code_a=$str_a\n";
			$Jms = $Jms+2;
		}
	}
	
	$thereis = 0;
	$Jol++;
}

$| = 0;
print "\n";

splice @jpn_missing,0,1;
map{s/\\([\[\]])/$1/g;$_;}@jpn_missing;
open(jpn_missing,">_jpn_missing.txt") or print "_jpn_missing.txt へ書き出せなかった。キレそう\n";
print jpn_missing @jpn_missing;
close(jpn_missing);
print "_jpn_missing.txt へ約 ",$Jms-1," 行書き出しました。\n";

open(jpn_new,">_jpn_new.txt") or print "_jpn_new.txt へ書き出せなかった。キレそう\n";
print jpn_new @jpn_new;
close(jpn_new);
print "_jpn_new.txt へ約 $Jnw 行書き出しました。\n";

print "\nエンターキーで終了";
$end = <STDIN>;
