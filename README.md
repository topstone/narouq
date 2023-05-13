Narou.rb - 小説家になろうのダウンローダ＆縦書き整形＆管理アプリ。Kindle（などの電子書籍端末）でなろうを読む場合に超便利です！
===================================================================================

[![Gem Version](https://badge.fury.io/rb/narou.svg)](https://badge.fury.io/rb/narou)
[![Join the chat at https://gitter.im/whiteleaf7/narou](https://badges.gitter.im/whiteleaf7/narou.svg)](https://gitter.im/whiteleaf7/narou?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

概要 - Summary
--------------
このアプリは[小説家になろう](https://syosetu.com/)などで公開されている小説の管理、
及び電子書籍データへの変換を支援します。縦書き用に特化されており、
横書きに最適化されたWEB小説を違和感なく縦書きで読むことが出来るようになります。
また、校正機能もありますので、小説としての一般的な整形ルールに矯正します。（例：感嘆符のあとにはスペースが必ずくる）

小説家になろうを含めて、下記のサイトに対応しています。
+ 小説家になろう https://syosetu.com/
+ ノクターンノベルズ https://noc.syosetu.com/
+ ムーンライトノベルズ https://mnlt.syosetu.com/
+ ミッドナイトノベルズ https://mid.syosetu.com/
+ ハーメルン https://syosetu.org
+ Arcadia http://www.mai-net.net/
+ 暁 https://www.akatsuki-novels.com/ （※300話以上ある作品は未対応）
+ カクヨム https://kakuyomu.jp/

コンソールで操作するアプリケーションですが、ブラウザを使って直感的に操作することができる WEB UI も搭載！（[デモページ](https://whiteleaf7.github.io/narou/demo/)）

主な機能は小説家になろうの小説のダウンロード、更新管理、テキスト整形、AozoraEpub3・kindlegen連携によるEPUB/MOBI出力です。  
その他にも変換したデータを直接電子書籍端末へ送信する機能は、メールで送信する機能などもあります。

詳細な説明やインストール方法は **[Narou.rb 説明書](https://github.com/whiteleaf7/narou/wiki)** に書いてあるのですが、Narou.rb 説明書 の内容は大変古くなっています。Narou.rb 説明書 を読む際には下記の点に留意して下さい。

* [本家 AozoraEpub3](https://w.atwiki.jp/hmdev/) は2015年を最後に更新されていないため、利用は大変危険です。代わりに改造版 AozoraEpub 3 の最新版をご利用下さい。
* Java 20 が公開されている今の時代では Java 8 は大変古いです。本家 AozoraEpub 3 が Java 8 を要求しているだけですので、今の時代に Java 8 を使い続けることは有益ではないと考えます。また、[改造版 AozoraEpub 3 は 1.1.1b15Q から Java 8 非対応となっています](https://github.com/kyukyunyorituryo/AozoraEpub3/releases/tag/v1.1.1b15Q)。みんなでどんどん新しい Java 環境を試し、bug が見つかったらどんどん報告する、という方針が効率的な開発に繋がると考えます。

![WEB UI ScreenCapture](https://raw.github.com/wiki/whiteleaf7/narou/images/webui_cap.png)
![Console ScreenCapture](https://raw.github.com/wiki/whiteleaf7/narou/images/narou_cap.gif)

本家との差分 - Difference between "narouq" and original "narou"
--------------------

* 本家 "narou" とは別の "narouq" という名称にしたので、併存が可能です。同時に、help 出力も narouq に変更しました。
* Gemfile.lock を除去してあります (.git_ignore にも追記しています)。これは、Git repository に Gemfile.lock を残しておくと fork する開発者の迷惑になる、という考えに基づきます。
* Ruby 2.6.0 以上を必要とします。
* last_commit_year を 2023 にしました。これで一部の CI が正常化すると思われます。
* Java 18 以降に対応させたつもりです。
* [DMincho.ttf を自動で複製](https://jbbs.shitaraba.net/bbs/read.cgi/computer/44668/1511245701/558)するようにしたつもりです。
* [Ruby 3.2 の仕様変更に対応](https://jbbs.shitaraba.net/bbs/read.cgi/computer/44668/1511245701/544)させたつもりです。
* 要求する sinatra の版を 2.0.8.1 以上 4 未満に変更しました。

更新履歴 - ChangeLog
--------------------

3.8.2: 2022/09/10
-----------------
#### 修正内容
- フォルダが存在しない場合に自動で作成する様に修正

----

「小説家になろう」は株式会社ヒナプロジェクトの登録商標です
