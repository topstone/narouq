この「narouq」は、元の [narou.rb](https://github.com/whiteleaf7/narou) を元に以下の点のみ改変しています。

* 実行 file の名称を「narou」から「narouq」へ変更 (元の narou.rb と共存可能)
* Gemfile.lock 削除 ([関連記事](https://sanemat.github.io/archives/langturn.com-translations-33/))
* [AozoraEpub3](https://github.com/kyukyunyorituryo/AozoraEpub3) が必要な directory を持っていない場合に作成 ([元の narou.rb へ pull request を送った](https://github.com/whiteleaf7/narou/pull/371)が reject されたためこちらで実装)
* Java 18 以降に対応 ([関連記事](https://github.com/whiteleaf7/narou/issues/399))
* Ruby 2.6 以上が必要 ([関連記事](https://github.com/whiteleaf7/narou/issues/390))
