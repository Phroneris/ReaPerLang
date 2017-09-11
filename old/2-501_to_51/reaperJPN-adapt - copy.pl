#!/usr/local/bin/perl

$name1="";
$name2="";

print "�����{��txt�t�@�C�����i.txt�����j�����:\n> ";
chomp($name1=<STDIN>);
if(!open(jpn_old,"<$name1.txt")){
	print "�J���Ȃ������B�L������\n\n";
	print "�G���^�[�L�[�ŏI��";
	<STDIN>;
	exit(0);
}else{
	@jpn_old=<jpn_old>;
	close(jpn_old);
	print "OK!\n\n";
}
print "�ŐV��REAPER�|��e���v���[�gtxt�t�@�C�����i.txt�����j�����:\n> ";
chomp($name2=<STDIN>);
if(!open(reaper_orig,"<$name2.txt")){
	print "�J���Ȃ������B�L������\n\n";
	print "�G���^�[�L�[�ŏI��";
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
map{s/([\Q\\*+.?{}()[]^$\-|\/\E])/\\$1/g;$_;}@dialog;	# ���K�\���ɉe�����镶����S�ăG�X�P�[�v

$jo=0;		# @jpn_old�̍s��
$jm=0;		# @jpn_missing�̍s��
$ro=0;		# @reaper_orig�̍s��
$rn=0;		# @reaper_new�̍s��
$thereis=0;	# ��v�����z����܂����攻��(0/1)
$d=-1;		# @dialog�̗v�f��

$|=1;		# �I�[�g�t���b�V���iprint�𑦏o�͂���j
$p_int=0;
print "������...\n";

foreach $a(@jpn_old){		# @jpn_old�𓪂���ǂ�

	$progress=$jo*100/$#jpn_old;	# �i�s�x�i����%�j
	$len=50;
	$p_prev=$p_int;
	$p_int=int($progress*$len/100);	# �i�s�x�i�؎̂ăo�[�����j
	printf(" %6.2f % [",$progress);
	if($progress==0){
		print " "x$len,"]";
	}elsif($p_int!=$p_prev){
		print "/"x($p_int)," "x($len-$p_int),"]";
	}
	print "\r";
	
	if($a=~/^\[/){				# �J�M�J�b�R�n�܂�Ȃ��
		$d++;
		$jpn_missing[$jm]="\n";
		$jpn_missing[$jm+1]="$dialog[$d]\n";		# \n[dialog��]�`�̌`��@jpn_missing���ɔz�u
		$jm=$jm+2;
		
	}elsif($a=~/^5CA1E00000000000=/){		# �_�C�A���O�̃X�P�[�����Ȃ��

		$rn=0;
		while($rn<$#reaper_new){
			if($reaper_new[$rn]=~/^$dialog[$d+1]/){		# ���ܓǂ�ł���@jpn_old�̗v�f��������_�C�A���O��
				splice @reaper_new,$rn-1,0,$a;			# ����@reaper_new�̃_�C�A���O�̖����ɃX�P�[������ǉ�
				$rn=$rn+2;
			}else{
				$rn++;
			}
		}
		$ro=0;
		while($ro<$#reaper_orig){
			if($reaper_orig[$ro]=~/^$dialog[$d+1]/){	# ��L�����̕��A@reaper_orig�̍s����@reaper_new�ɍ��킹��
				splice @reaper_orig,$ro-1,0,"\n";
				$ro=$ro+2;
			}else{
				$ro++;
			}
		}
		
	}elsif($a=~/^\w/){			# �X�P�[�����ȊO�̒P��\�������n�܂�Ȃ��
		$a=~/(\w+)=(.*)\n/;
		$code_a=$1; $str_a=$2;
		$rn=0;
		foreach $b(@reaper_orig){				# @reaper_orig�𓪂���ǂ�
			if($reaper_new[$rn]=~/^;\w+=/){		# ���̍s��@reaper_new�� ;�R�[�h=����\n �Ƃ����`�̍s�i���{�ꉻ�O�̕����s�j�Ȃ��
				$b=~/^;(\w+)=(.*)\n/;
				$code_b=$1; $str_b=$2;
				if($code_a eq $code_b){					# @jpn_old��@reaper_orig���R�[�h��v�Ȃ��
					$reaper_new[$rn]="$code_a=$str_a\n";
					$thereis=1;
				}
			}
			$rn++;
		}
		if($thereis==0){				# @jpn_old��@reaper_orig�ŃR�[�h��v�̍s���S���Ȃ��Ȃ��
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
open(jpn_missing,">jpn_missing.txt") or print "jpn_missing.txt �֏����o���Ȃ������B�L������\n";
print jpn_missing @jpn_missing;
close(jpn_missing);
print "jpn_missing.txt �֖� ",$jm-1," �s�����o���܂����B\n";

open(reaper_new,">reaper_new.txt") or print "reaper_new.txt �֏����o���Ȃ������B�L������\n";
print reaper_new @reaper_new;
close(reaper_new);
print "reaper_new.txt �֖� $rn �s�����o���܂����B\n";

=pod
print "jpn_old.txt �� $jo �s�ł����B\n";
open(reaper_orig,">reaper_orig.txt") or print "reaper_orig.txt �֏����o���Ȃ������B�L������\n";
print reaper_orig @reaper_orig;
close(reaper_orig);
print "reaper_orig.txt �֖� $ro �s�����o���܂����B\n";
map{s/\\(\\*)/$1/g;$_;}@dialog;
map{s/^(.*)$/$1\n/;$_;}@dialog;
open(dialog,">dialog.txt");
print dialog @dialog;
close(dialog);
print "dialog.txt �֖� $d �s�����o���܂����B\n";
=cut

print "\n�G���^�[�L�[�ŏI��";
$end=<STDIN>;


# copy���Ă����t�@�C�����ɂȂ��Ă邯�ǁA���̖ړI�ł��������񂾂����H
# ���N�O�̍�Ƃ�����o���ĂȂ��B
