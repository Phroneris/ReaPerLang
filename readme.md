
ReaPerLang v1.05
====

![Demo](https://github.com/Phroneris/ReaperJPN-Phroneris/blob/master/tool/demo.gif)


### 概要

+ 度重なる翻訳作業や公式 merge tool の適用などにより中身がゴチャついた哀れな LangPack を、  
  最新 template ファイルに適応した**完全な**行対行の一致状態へ「編集用最適化」するツール。
+ 最適化の際、template 側で既に失われている翻訳行は `missing` ファイルへと隔離される。
+ `5CA1E00000000000=` のサイズ調整行を template 側に追加した、  
  **完全な**行対行の `tmpl_crr` ファイルも出力される。比較翻訳作業に活用しよう。


### 使う理由

+ 行対行の状態になることで、訳すべき行の選択や template との比較が簡単になる。  
  例: [Notepad++](https://notepad-plus-plus.org/) の分割表示機能で 2 つのファイルを同時に開いて `縦スクロールを同期` する。


### 必要なもの

+ Perl v5.20.2 ぐらい
+ ReaPerLang (`ReaPerLang.pl`)

以下は `*.txt` ファイル、UTF-8 形式とし、ReaPerLang と同じフォルダに置く。
+ LangPack ファイル
+ 最新の template ファイル
+ 古い template ファイル (「お帰りなさいモード」のみ)


### 得られるもの (`*.txt`、UTF-8 )

+ `lng_new` ファイル (最適化された LangPack ファイル)
+ `missing` ファイル
+ `tmpl_crr` ファイル


### モード

+ 「初めましてモード（First-time mode）」と「お帰りなさいモード（Repeater mode）」がある。

#### 「初めましてモード」
+ このツールを初めて使う人用。単純に上記のような最適化を行う。
+ ただし、元々 `;^` で始まっていたオプション翻訳行は全て失われる。
+ 必要なのは LangPack ファイルと、それの適応先にしたい最新の template ファイル。

#### 「お帰りなさいモード」
+ 過去にこのツールで適応させた LangPack を、更に最新の状態へアップデートしたい人用。
+ 適応後もオプション翻訳行が保持される。  
+ 使用に際して、LangPack ファイルと最新の template ファイルだけでなく、  
  かつてこのツールの使用時に最新版として利用した古い template ファイル  
  （https://landoleet.org/i8n/ からダウンロードしたままのもの）も必要になる。


### 諸注意

+ ファイルは上書きされる。
+ Windows 以外での利用については知らない。  
  多分文字化けが起こるので、`my $enc_os = 'cp932';` を utf8 とかにすれば良いかも。
+ 文書冒頭の概要部も移植され、その際 `tmpl_crr` の概要部は行数を揃えられる。
+ template 側のファイル命名則が微妙に一致しない場合（v501 以前がそう）、事前に手修正よろしく。
+ `;/` で始まる LangPack 側の行は翻訳済み行と同様に移植されるので、コメントアウトに利用可能。
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
+ In optimization, lost translations in the template will move to a `missing` file.
+ A `tmpl_crr` file will be also output as a **completely** line-to-line one  
  with `5CA1E00000000000=` scaling lines. Make use of it for your comparative translation.


### Why ReaPerLang?

+ You will get a new "work-optimized" Langpack which is **completely** line-to-line  
  to compare easily with the template and select lines to translate.  
  (i.e. Open files in [Notepad++](https://notepad-plus-plus.org/) by multiple view and enable `Synchronise Vertical Scrolling`)


### Requirement

+ Perl v5.20.2 or something
+ ReaPerLang (`ReaPerLang.pl`)

The following must be `*.txt`, UTF-8 and placed in the same path as ReaPerLang.
+ LangPack file
+ The newest template file
+ Older template file ("repeater mode" only)


### Outputs (`*.txt`、UTF-8 )

+ A `lng_new` file (Optimized LangPack file)
+ A `missing` file
+ A `tmpl_crr` file


### Modes

+ "First-time mode" and "repeater mode" are available.

#### "First-time mode"
+ For those who use this tool for the first time.  
  This tool simply executes the conversion as above.
+ Note that all optional translations which originally begins with `;^` will be discarded.
+ You need a LangPack file and the newest template file to adapt to.

#### "Repeater mode"
+ For those who want to update a LangPack file  
  which had been adapted by this tool ever and have been translated manually further.
+ Optional translations will be preserved even after processing.
+ To use this mode, you need not only an old LangPack and the newest template,  
  but also an old template file(※) used on previous conversion.  
  (※ as downloaded in https://landoleet.org/i8n/)


### Tips

+ Output Files will be overwritten.
+ I don't know what will happen if RPL is used on non-Windows OS...  
  You may get some garbling. Editing `my $enc_os = 'cp932';` to utf8 could make you happy.
+ The description area on the top of your file will also be transferred  
  and one in the `tmpl_crr` will be forced to have as many lines as it.
+ If template naming differs a bit from `template_reaper[version].ReaperLangPack.txt`  
  (like v501 or before), fix manually in advance.
+ Lines beggining with `;/` in LangPack will also be transferred just like translated ones  
  so you can use them as some commentouts.
+ This tool is to make translation work easier,  
  not to add something to a LangPack like the official merge tool (RPL trims rather).  
  To release a LangPack file to apply to REAPER finally, the following flow seems nice:  
  Optimize (RPL) -> translate -> merge (official tool) -> release


----


### ライセンス (License)

+ [MIT](http://b4b4r07.mit-license.org)


### 作者 (Author)

+ [森の子リスのミーコの大冒険 (Phroneris)](https://twitter.com/Phroneris)



