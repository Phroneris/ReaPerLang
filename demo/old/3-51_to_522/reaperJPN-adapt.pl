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
	print " �ǂݍ��ݒ�... $tname.txt\n";
	if(!open(file,"<$tname.txt")){
		print "�J���Ȃ������B�L������\n\n";
		print "�G���^�[�L�[�ŏI��";
		<STDIN>;
		exit(0);
	}else{
		my @txt = <file>;
		close(file);
		print " OK!\n\n";
		return @txt;
	}
}

print "�����{��txt�t�@�C������ \"JPN_Phroneris.txt\" �ŗǂ����Enter���A\n�����łȂ���΃t�@�C�����i.txt�����j�����:\n> ";
@jpn_old = &readtxt(1);

print "REAPER�|��e���v���[�gtxt�t�@�C����\n\"template_reaper***.ReaperLangPack.txt\" �́A***�ɂ����鐔�������\n�i�ŐV�łƂ���1�O�Łj\n";
print "�ŐV��: > ";
@reaper_curr = &readtxt(2);
print "1�O��: > ";
@reaper_prev = &readtxt(3);


@jpn_new = @reaper_curr;
@jpn_missing = ();
@dialog = grep{/^\[/&&($_=~s/^(.+\]).*\n/$1/)}@jpn_old;
map{s/([\[\]])/\\$1/g;$_;}@dialog;	# []���G�X�P�[�v

$Jol = 0;		# @jpn_old�̍s��
$Jms = 0;		# @jpn_missing�̍s��
$Jnw = 0;		# @jpn_new�̍s��
$Rcr = 0;		# @reaper_curr�̍s��
$thereis = 0;	# ��v�����z����܂����攻��(0/1)
$d = -1;		# @dialog�̗v�f��

$| = 1;			# �I�[�g�t���b�V���iprint�𑦏o�͂���j
$p_int = 0;
print "������...\n";

foreach $a(@jpn_old){		# @jpn_old�𓪂���ǂ�

	$progress = 100* $Jol/$#jpn_old;	# �i�s�x�i����%�j
	$len = 50;
	$p_prev = $p_int;
	$p_int = int($progress*$len/100);	# �i�s�x�i�؎̂ăo�[�����j
	printf(" %6.2f % [",$progress);
	if($progress==0){
		print " "x$len,"]";
	}elsif($p_int!=$p_prev){
		print "/"x($p_int)," "x($len-$p_int),"]";
	}
	print "\r";

	if($a=~/^\[/){				# �J�M�J�b�R�n�܂�Ȃ��
		$d++;
		$jpn_missing[$Jms] = "\n";
		$jpn_missing[$Jms+1] = "$dialog[$d]\n";		# \n[dialog��]�`�̌`��@jpn_missing���ɔz�u
		$Jms = $Jms+2;
		
	}elsif($a=~/^5CA1E00000000000=/){		# �_�C�A���O�̃X�P�[�����Ȃ��

		$Jnw = 0;
		while($Jnw>=0 and $Jnw<$#jpn_new){
			if($jpn_new[$Jnw]=~/^$dialog[$d+1]/){		# ���ܓǂ�ł���@jpn_old�̗v�f��������_�C�A���O��
				splice @jpn_new,$Jnw-1,0,$a;			# ����@jpn_new�̃_�C�A���O�̖����ɃX�P�[������ǉ�
				$Jnw = -999;
			}
			$Jnw++;
		}
		$Rcr = 0;
		while($Rcr>=0 and $Rcr<$#reaper_curr){
			if($reaper_curr[$Rcr]=~/^$dialog[$d+1]/){	# ��L�����̕��A@reaper_curr�̍s����@jpn_new�ɍ��킹��
				splice @reaper_curr,$Rcr-1,0,"\n";
				$Rcr = -999;
			}
			$Rcr++;
		}
		
	}elsif($a=~/^\w/){			# �X�P�[�����ȊO�̒P��\�������n�܂�i���|�󂳂�Ă��镶���s�j�Ȃ��
	
		$Jnw = 0;
		$thereis = 0;
		if($reaper_prev[$Jol]=~/^;\^/){			# @reaper_prev�̓����s��;^�n�܂�i���I�v�V�����s�j�Ȃ��
			while($thereis==0 and $Jnw<$#jpn_new){		# ���L��@reaper_curr��ǂނƂ��͈̔͂�
				if($jpn_new[$Jnw]=~/^$dialog[$d]/){		# ���ܓǂ�ł���@jpn_old�̗v�f��������_�C�A���O���݂̂ɒ���
					$startJnw = $Jnw;
				}elsif($jpn_new[$Jnw]=~/^$dialog[$d+1]/){
					$thereis = 1;
					$endJnw = $Jnw + 1;
				}
				$Jnw++;
			}
			$yet_init = "^;\\\^";	# ���|��
		}else{
			$startJnw = 0;
			$endJnw = $#reaper_curr;
			$yet_init = "^;";
		}

		$Jnw = $startJnw;
		$thereis = 0;
		$a =~ /(\w+)=(.*)\n/;
		$code_a = $1; $str_a = $2;
		while($thereis==0 and $Jnw<$endJnw){		# @reaper_curr�𓪂���i�܂��͑�����_�C�A���O���̂݁j�ǂ�
			if($jpn_new[$Jnw]=~/${yet_init}\w+=/){			# @jpn_new�̓����s�� {���|��}�P��\������=����\n �Ƃ����`�̍s�i���|�󂳂�Ă��Ȃ������s�j�Ȃ��
				$reaper_curr[$Jnw] =~ /${yet_init}(\w+?)=(.*)\n/;
				$code_b = $1; $str_b = $2;
				if($code_a eq $code_b){							# @jpn_old��@reaper_curr���R�[�h��v�Ȃ��
					$jpn_new[$Jnw] = "$code_a=$str_a\n";
					$thereis = 1;
				}
			}
			$Jnw++;
		}
		if($thereis==0){		# @jpn_old��@reaper_curr�ŃR�[�h��v�̍s���S���Ȃ��Ȃ��
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
open(jpn_missing,">_jpn_missing.txt") or print "_jpn_missing.txt �֏����o���Ȃ������B�L������\n";
print jpn_missing @jpn_missing;
close(jpn_missing);
print "_jpn_missing.txt �֖� ",$Jms-1," �s�����o���܂����B\n";

open(jpn_new,">_jpn_new.txt") or print "_jpn_new.txt �֏����o���Ȃ������B�L������\n";
print jpn_new @jpn_new;
close(jpn_new);
print "_jpn_new.txt �֖� $Jnw �s�����o���܂����B\n";

print "\n�G���^�[�L�[�ŏI��";
$end = <STDIN>;
