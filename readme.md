
ReaPerLang v1.040
====

![Demo](https://github.com/Phroneris/ReaperJPN-Phroneris/blob/master/tool/demo.gif)


### 概要

+ 度重なる翻訳作業や公式 merge tool の適用などにより中身がゴチャついた哀れな LangPack を、  
  最新 template ファイルに適応したほぼ行対行（※）の一致状態へ「編集用最適化」するツール。  
  （※例外: `5CA1E00000000000=` によるサイズ調整行）  
  行対行の状態になることで、訳すべき行の選択や template との比較が簡単になる。
+ 最適化の際、template 側で既に失われている翻訳行は "missing" ファイルへと隔離される。


### 必要なもの

+ Perl v5.20.2 ぐらい
+ ReaPerLang (ReaPerLang.pl)

以下は `*.txt` ファイル、UTF-8 形式とし、RPL と同じフォルダに置く。
+ LangPack ファイル
+ 最新の template ファイル
+ 古い template ファイル (「お帰りなさいモード」のみ)


### 得られるもの (`*.txt`、UTF-8 )

+ 最適化された LangPack ファイル
+ "missing" ファイル


### モード

+ 「初めましてモード（First-time mode）」と「お帰りなさいモード（Repeater mode）」がある。
+ 「初めましてモード」は、このツールを初めて使う人用。単純に上記のような最適化を行う。  
  ただし、元々 `;^` で始まっていたオプション翻訳行は全て失われる。  
  必要なのは LangPack ファイルと、それの適応先にしたい最新の template ファイル。
+ 「お帰りなさいモード」は、過去にこのツールで適応させた LangPack について、  
  更に最新の状態へのアップデートを行いたい人用。  
  適応後もオプション翻訳行が保持される。  
  使用に際して、LangPack ファイルと最新の template ファイルだけでなく、  
  かつてこのツールの使用時に最新版として利用した古い template ファイル  
  （LangPack ファイルと行対行（サイズ調整行以外）のもの）も必要になる。


### 諸注意

+ ファイルは上書きされる。
+ Windows 以外での利用については知らない。  
  多分文字化けが起こるので、`my $enc_os = 'cp932';` を utf8 とかにすれば良いかも。
+ edit-me エリアは一切移植しないので、後から手修正よろしく。
+ template 側のファイル命名則が微妙に一致しない場合（v501 以前がそう）、事前に手修正よろしく。
+ LangPack 側の翻訳済み行以外は全て template 側のものに置き換えられるため、  
  未翻訳行をコメントアウトに使っている人は注意。
+ この RPL は翻訳作業をやりやすくするためのものであって、  
  公式 merge tool みたいに LangPack へ要素を追加するようなものではない。むしろ削る。  
  REAPER へ最終的に適用するための LangPack を作成して公開する場合、  
  ReaPerLang で最適化 → 翻訳作業 → 公式 merge tool で統合 → 公開  
  みたいな流れが良いんじゃないかと思う。


----

(English version of the above)  


### Overview

+ LangPacks tend to be a mess by repeated translation work and the official merge tool.  
  This tool adapts such a LangPack file to the newest REAPER template smartly.  
  You will get a new "work-optimized" Langpack which is almost line-to-line(※)  
  to compare with the template and select lines to translate easily.  
  (※ except `5CA1E00000000000=` lines)
+ In optimization, lost translations in the template will move to a "missing" file.


### Requirement

+ Perl v5.20.2 or something
+ ReaPerLang (ReaPerLang.pl)

The following must be `*.txt`, UTF-8 and placed in the same path as RPL.
+ LangPack file
+ The newest template file
+ Older template file ("repeater mode" only)


### Outputs (`*.txt`、UTF-8 )

+ Optimized LangPack file
+ A "missing" file


### Modes

+ "First-time mode" and "repeater mode" are available.
+ "First-time mode" is for those who use this tool for the first time.  
  In this mode, this tool simply executes the conversion as above.  
  Note that all optional translations which originally begins with `;^` will be discarded.  
  You need a LangPack file and the newest template file to adapt to.
+ "Repeater mode" is for those who want to update a LangPack file  
  which had been adapted by this tool ever and have been translated further.  
  Optional translations are preserved even after processing.  
  To use this mode, you need not only an old LangPack and the newest template,  
  but also an old line-to-line(※) template file used in previous conversion.  
  (※ except `5CA1E00000000000=` lines)


### Tips

+ Output Files will be overwritten.
+ I don't know what will happen if RPL is used on non-Windows OS...  
  You may get some garbling. Editing `my $enc_os = 'cp932';` to utf8 could make you happy.
+ The edit-me area will not be transferred at all. Please edit manually.
+ If template naming differs a bit from `template_reaper[version].ReaperLangPack.txt`  
  (like v501 or before), fix manually in advance.
+ In LangPack, all lines except translated are replaced by ones in template,  
  so take care if you use untranslated lines as comment-outs.
+ This tool is to make translation work easier,  
  not to add something to a LangPack like the official merge tool (RPL trims rather).  
  To release a LangPack file to apply to REAPER finally, the following flow seems nice:  
  Optimize (RPL) -> translate -> merge (official tool) -> release


----


### ライセンス (License)

+ [MIT](http://b4b4r07.mit-license.org)


### 作者 (Author)

+ [森の子リスのミーコの大冒険 (Phroneris)](https://twitter.com/Phroneris)



