# Kompira Enterprise: シンプルで軽量な次世代運用自動化プラットフォーム

このディレクトリにはオンプレシングル(DB 外部接続)構成用の Docker Compose ファイルが含まれています。

オンプレシングル(DB 外部接続)構成は、PostgreSQL データベースをユーザー側で用意し、
それ以外の Kompira Enterprise を動作させるために必要なミドルウェアを
Docker コンテナで動作させます。

## PostgreSQL サーバの要件

- バージョン: 12 以上
- その他: 拡張モジュール pgcrypto がインストールされていること (RHEL/CentOS の場合、postgresql-contrib パッケージをインストールしておく)

## 事前準備

以下では、Docker が動作しているホストサーバ上に PostgreSQL を動作している想定で、データベースの設定手順について記述します。

(1) kompira ユーザーとデータベースの作成

kompira ユーザを作成します。kompira ユーザはスーパーユーザー権限が必要です。kompira ユーザのパスワードを入力してください。
（附属の docker-compose.yml では、パスワードは kompira としていますので、必要に応じて docker-compose.yml の DATABASE_URL 環境変数のパスワードを変更してください)

    $ sudo -i -u postgres createuser -d -s -P kompira

kompira データベースを作成します。
    
    $ sudo -i -u postgres createdb --encoding=utf8 kompira

(2) PostgreSQL サーバの接続設定

ローカルホスト以外からも PostgreSQL サーバに接続できるように必要に応じて、
postgresql.conf (RHEL/CentOS で標準パッケージをインストールした場合 /var/lib/pgsql/data/postgresql.conf) の
listen_address を以下のように設定します。

    listen_address = '*'

kompira ユーザからパスワード接続できるように、pg_hba.conf (RHEL/CentOS で標準パッケージをインストールした場合 /var/lib/pgsql/data/pg_hba.conf) に
以下のエントリを追加します。
(ここでは docker compose によって作成される docker network のアドレスが 172.0.0.0/8 に含まれることを想定しています。お使いの環境によって適切なアドレスに置き換えてください)

    host    kompira         kompira         172.0.0.0/8             scram-sha-256

上記の設定後、 postgresql サービスを再起動する必要があります。

## システムの開始

以下のコマンドを実行して Kompira Enterprise 開始します。

```
$ export LOCAL_UID=$UID LOCAL_GID=$(id -g)
$ docker compose pull
$ docker compose up -d
```

### システムの停止

Kompira Enterprise を停止するには以下のコマンドを実行します。

```
$ docker compose stop
```

### システムの再開

停止した Kompira Enterprise を再開するには以下のコマンドを実行します。
(代わりに docker compose up -d を使うことも可能です)

```
$ docker compose start
```

### システムの削除

以下のコマンドを実行すると、システムが停止し、すべてのコンテナとデータボリュームが削除されます。
(PostgreSQL データベースのデータは削除されません)

```
$ docker compose down -v
```

-v オプションを指定しない場合、コンテナのみ削除され、データボリュームは残されます。
