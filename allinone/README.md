# Kompira Enterprise: シンプルで軽量な次世代運用自動化プラットフォーム

このディレクトリにはオンプレシングル(オールインワン)構成用の Docker Compose ファイルが含まれています。

## クイックスタート

オンプレシングル(オールインワン)構成は、Kompira Enterprise を動作させるために必要なすべてのミドルウェアを
Docker コンテナで動作させるため、簡単に始めることができます。

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

以下のコマンドを実行すると、システムが停止し、すべてのコンテナとデータが削除されます。

```
$ docker compose down -v
```

-v オプションを指定しない場合、コンテナのみ削除され、データは残されます。
したがって、再び docker compose up -d 開始すると、以前のデータにアクセスすることができます。


## SSLの設定

Nginx と RabbitMQ で SSL を利用するには、ホスト側の ke-docker/ssl ディレクトリに以下の証明書を用意します。

- server.crt	  # サーバ証明書
- server.key	  # 秘密鍵
- ca.crt	  # 中間CA証明書

docker-compose.override.yml.sample を docker-compose.override.yml にコピーしてから、以下のコマンドを実行します。

```
$ docker compose up -d
```
