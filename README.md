# Kompira Enterprise: シンプルで軽量な次世代運用自動化プラットフォーム

## 1. Kompira Enterprise とは

Kompira Enterprise は IT 運用管理業務の自動化を支援するための基盤システムです。
ジョブフローを記述することで、様々な運用業務、管理業務、さらには障害の復旧処理まで自動化することができます。

## 2. Kompira Enteprise Docker Compose ファイル

このリポジトリには、以下の各種デプロイの構成に対応した Kompira Enterprise の **Docker Compose ファイル** が含まれています。

* オンプレシングル
    * [標準シングル構成](ke2/single/basic)
    * [外部DBシングル構成](ke2/single/extdb)
* オンプレクラスタ
    * [Swarmクラスタ構成](ke2/cluster/swarm)
* クラウド
    * [AzureCI構成](ke2/cloud/azureci)


## 3. クイックスタート

Docker エンジンと git コマンドがインストールされているサーバであれば、以下のコマンドを実行することですぐに使い始めることができます。

```
$ git clone https://github.com/fixpoint/ke2-docker.git
$ cd ke2-docker/ke2/single/basic
$ docker compose pull
$ ../../../scripts/create-cert.sh
$ docker compose up -d
```

ブラウザから Docker エンジンが動作しているサーバにアクセス (https://<サーバのアドレス>/.login) するとログイン画面が表示されます。
以下のアカウントでログインして Kompira をはじめることができます。

* ユーザ名: `root`
* パスワード: `root`

ログイン後の画面の右上にある「ヘルプ」をクリックすると、オンラインマニュアルが表示されますので使い方の参考にしてください。

※ なお、上記手順の create-cert.sh では自己署名 SSL 証明書を生成しています。その SSL 証明書をコンテナ起動時に HTTPS および AMQPS に適用していますので、ブラウザでアクセスする際にセキュリティの警告が表示されます。

## 4. 準備と設定
### 4.1. Docker の準備

Docker engine および docker compose plugin については以下のバージョン要件があります。

- Docker engine: version 24.0 以上
- Docker compose plugin: version 2.24.6 以上

Docker のインストール手順と起動方法については以下を参考にしてください。

https://docs.docker.com/engine/install/

たとえば RHEL 環境では以下のような手順になります。

```
$ sudo yum install -y yum-utils
$ sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
$ sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
$ sudo systemctl enable --now docker
```

### 4.2. 環境変数の設定

デプロイ時に環境変数を設定しておくことで、Kompira の動作環境を指定することが出来ます。
以下では各構成で共通的な環境変数について示します。
各構成で独自の環境変数が定義されている場合もありますのでそれぞれの README.md を参照してください。


| 環境変数                | 意味                        | デフォルト値                            | 備考                                                   |
| ----------------------- | --------------------------- | --------------------------------------- | ------------------------------------------------------ |
| `TZ`                    | タイムゾーン                | "Asia/Tokyo"                            | 画面やログで表示される時刻のタイムゾーンを指定します   |
| `LANGUAGE_CODE`         | 言語コード ("ja" or "en")   | "ja"                                    | 初回起動時にインポートする初期データの言語を指定します |
| `KOMPIRA_IMAGE_NAME`    | Kompira イメージ            | "kompira.azurecr.io/kompira-enterprise" | デプロイする Kompira コンテナのイメージを指定します    |
| `KOMPIRA_IMAGE_TAG`     | Kompira タグ                | "latest"                                | デプロイする Kompira コンテナのタグを指定します        |

## 5. Kompira ライセンス

[Kompira Enterprise ライセンス利用規約](https://www.kompira.jp/Kompira_terms.pdf)に同意の上、ダウンロードページからダウンロードして下さい。

Kompira の使用には、ライセンス登録が必要です。詳しくは [license@kompira.jp](mailto:license@kompira.jp) までご連絡ください。

※ ご利用の Kompira のバージョンに依らず、最新のライセンス利用規約が適用されます。

## 6. Kompira 関連の情報

### 6.1. Kompira 運用自動化コラム

Kompira の実践的な使い方やジョブフローの書き方については [運用自動化コラム](https://www.kompira.jp/column/) を参考にしてみてください。

### 6.2. Kompira コミュニティサイト

Kompira の使い方が分からない場合などは、 [コミュニティ> KompiraEnterprise関連](https://kompira.zendesk.com/hc/ja/community/topics/360000014321-KompiraEnterprise%E9%96%A2%E9%80%A3) を参考にしてみてください。同じような質問や回答が見つからない場合は、新たに投稿してみてください。