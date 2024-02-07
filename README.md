# Kompira Enterprise: シンプルで軽量な次世代運用自動化プラットフォーム

## 1. Kompira Enterprise とは

Kompira Enterprise は IT 運用管理業務の自動化を支援するための基盤システムです。
ジョブフローを記述することで、様々な運用業務、管理業務、さらには障害の復旧処理まで自動化することができます。

## 2. Kompira Enteprise Docker Compose ファイル

このリポジトリには、以下の各種デプロイの構成に対応した Kompira Enterprise の **Docker Compose ファイル** が含まれています。

* [オンプレシングル (all in one)][allinone]
* [オンプレシングル (DB外部接続)][withoutdb]
* [Azure Container Instances デプロイ][azureci]

[allinone]: https://github.com/fixpoint/ke-docker/allinone
[withoutdb]: https://github.com/fixpoint/ke-docker/withoutdb
[azureci]: https://github.com/fixpoint/ke-docker/azureci

## 3. クイックスタート

Docker エンジンと git コマンドがインストールされているサーバであれば、以下のコマンドを実行することですぐに使い始めることができます。

```
$ git clone https://github.com/fixpoint/ke-docker.git
$ cd ke-docker/allinone
$ export LOCAL_UID=$UID LOCAL_GID=$(id -g)
$ docker compose pull
$ docker compose up -d
```

ブラウザから Docker エンジンが動作しているサーバにアクセス (https://<サーバのアドレス>/.login) するとログイン画面が表示されます。
以下のアカウントでログインして Kompira をはじめることができます。

* ユーザ名: `root`
* パスワード: `root`

ログイン後の画面の右上にある「ヘルプ」をクリックすると、オンラインマニュアルが表示されますので使い方の参考にしてください。

## 4. 準備と設定
### 4.1. Docker エンジンの準備

Docker エンジンのインストール手順と起動方法については以下を参考にしてください。

https://docs.docker.com/engine/install/

### 4.2. 環境変数の設定

デプロイ時に環境変数を設定しておくことで、Kompira の動作環境を指定することが出来ます。
以下では各構成で共通的な環境変数について示します。
各構成で独自の環境変数が定義されている場合もありますのでそれぞれの README.md を参照してください。


| 環境変数        | 意味                        | デフォルト値                            | 備考                                                   |
| --------------- | --------------------------- | --------------------------------------- | ------------------------------------------------------ |
| `TZ`            | タイムゾーン                | "Asia/Tokyo"                            | 画面やログで表示される時刻のタイムゾーンを指定します   |
| `LANGUAGE_CODE` | 言語コード ("ja" or "en")   | "ja"                                    | 初回起動時にインポートする初期データの言語を指定します |
| `IMAGE_NAME`    | Kompira イメージ            | "kompira.azurecr.io/kompira-enterprise" | デプロイする Kompira コンテナのイメージを指定します    |
| `IMAGE_TAG`     | Kompira タグ                | "latest"                                | デプロイする Kompira コンテナのタグを指定します        |
| `LOCAL_UID`     | ローカル実行ユーザID        | (無し)                                  | fluentd コンテナを実行するユーザIDを指定します         |
| `LOCAL_GID`     | ローカル実行グループID      | (無し)                                  | fluentd コンテナを実行するグループIDを指定します       |

## 5. Kompira ライセンス

[Kompira Enterprise ライセンス利用規約](https://www.kompira.jp/Kompira_terms.pdf)に同意の上、ダウンロードページからダウンロードして下さい。

Kompira の使用には、ライセンス登録が必要です。詳しくは [license@kompira.jp](mailto:license@kompira.jp) までご連絡ください。

※ ご利用の Kompira のバージョンに依らず、最新のライセンス利用規約が適用されます。

## 6. Kompira 関連の情報

### 6.1. Kompira 運用自動化コラム

Kompira の実践的な使い方やジョブフローの書き方については [運用自動化コラム](https://www.kompira.jp/column/) を参考にしてみてください。

### 6.2. Kompira コミュニティサイト

Kompira の使い方が分からない場合などは、 [コミュニティ> KompiraEnterprise関連](https://kompira.zendesk.com/hc/ja/community/topics/360000014321-KompiraEnterprise%E9%96%A2%E9%80%A3) を参考にしてみてください。同じような質問や回答が見つからない場合は、新たに投稿してみてください。