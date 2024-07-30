# Kompira Enterprise: シンプルで軽量な次世代運用自動化プラットフォーム

このディレクトリには Azure Container Instances (ACI) にデプロイするための ARM template ファイルが含まれています。

## 事前準備

デプロイ作業を行うために、以下の準備をしてください。

1. Azure CLI のインストール
  以下のリンクを参考に、お使いの OS に Azure CLI をインストールします。

  [Azure CLI インストールガイド](https://learn.microsoft.com/ja-jp/cli/azure/install-azure-cli)

2. ke2-docker リポジトリのファイル一式を取得
   https://github.com/fixpoint/ke2-docker から、Code -> Download ZIP を選択し、
   ke-docker リポジトリのファイル一式を取得して、作業用 PC の適当なディレクトリに
   展開します。

## デプロイ手順

### Azure上に各種リソース作成

Azure 上に以下に示すの各種リソースを作成していきます。
(作成するリソースの名前は適宜変更してください)

- リソースグループ: KE20RG
- ストレージアカウント: ke20storage
- PostgreSQLサーバ: postgresql-for-ke

#### Azure へのログインとサブスクリプションの切り替え

以降の作業のために、Azure に CLI からログインして、サブスクリプションを必要に応じて切り替えます。
(Azure CLI は PowerShell 上から実行することを想定しています)

以下のコマンドで Azure にログインします。

```
az login
```
ブラウザが起動するので、画面上からログインしてください。

複数のサブスクリプションが存在する場合、必要に応じて、使用するサブスクリプションを切り替えます。

そのために、アカウントのサブスクリプションの一覧を確認します。
```
az account list --output table
```
以下のコマンドで、必要に応じてサブスクリプションを切り替えることができます。
```
az account set --subscription "<サブスクリプション名>"
```

#### リソースグループとストレージアカウントの作成

リソースグループ作成します。
```
az group create --name KE20RG --location japaneast
```

ストレージアカウントを作成します。
```
az storage account create --name ke20storage --resource-group KE20RG
```

#### Azure Database for PostgreSQL (フレキシブルサーバ) の作成

Azure ポータルにログインして、Azure Database for PostgreSQL (フレキシブルサーバ)リソースを
以下のパラメータで作成します。

- リソースグループ: KE20RG
- サーバ名: postgresql-for-ke
- リージョン: Japan East
- PostgreSQLバージョン: 15
- ワークロードの種類: 必要に応じて適切なプランを選択してください
- 管理ユーザ: kompira
- パスワード: 適切なパスワードを指定してください

作成時に、「Azure 内の任意の Azure サービスにこのサーバーへのパブリック アクセスを許可する」を
チェックしておきます。
他のパラメータはデフォルトでかまいません。

■ PGCRYPTO の有効化
作成した Azure Database for PostgreSQL (フレキシブルサーバ) リソースのサーバパラメタの設定で、
azure.extensions からPGCRYPTO の拡張を有効にしておきます。

■ kompira データベースの作成
PostgreSQL サーバ上に kompira という名称でデータベースを作成しておきます。

#### Key Vault の作成と設定

デプロイ時に必要となるため、Azure 上に以下のリソースを作成します。リソースの名前は適宜変更してください。

- vault名: ke2vault

```
# Vault の作成
az keyvault create --name ke2vault --resource-group KE20RG

# デプロイ時に使用する database-url シークレットを作成します。
az keyvault secret set --vault-name ke2vault --name "database-url" --value "pgsql://<PostgreSQLユーザ名>:<PostgreSQLユーザのパスワード>@postgresql-for-ke.postgres.database.azure.com:5432/kompira"
```

注意: <PostgreSQLユーザ名> および <PostgreSQLユーザのパスワード> は、実際のユーザー名とパスワードに置き換えてください。

シークレットの値を再度更新する場合、同じコマンドを再度実行できます。
```
az keyvault secret set --vault-name ke2vault --name "database-url" --value <change-value>
```

#### 共有ファイルボリュームの作成する

Azure Container Instances で必要となる共有ファイルボリュームを以下の名称で作成しておきます。

- kompira-var: /var/opt/kompira のマウント用
- kompira-nginx-conf: nginx の conf ファイル用
- rabbitmq-conf: RabbitMQ 設定ファイル用
- ssl-cert: SSL・CA 証明書用

※ ファイル共有名に使用できるのは、小文字、数字、ハイフンのみです。
   ファイル共有名の先頭と末尾にはアルファベットまたは数字を使用する必要があります。
   2 つの連続するハイフンを含めることはできません。  

以下のコマンドを実行します。

```
az storage share-rm create \
  --resource-group KE20RG \
  --storage-account ke20storage \
  --name kompira-var

az storage share-rm create \
  --resource-group KE20RG \
  --storage-account ke20storage \
  --name kompira-nginx-conf

az storage share-rm create \
  --resource-group KE20RG \
  --storage-account ke20storage \
  --name rabbitmq-conf

az storage share-rm create \
  --resource-group KE20RG \
  --storage-account ke20storage \
  --name ssl-cert
```

#### 証明書ファイルのアップロード手順

作成した ssl-cert 共有ボリュームに以下のコマンドを使用して証明書ファイルをアップロードします。

```
az storage file upload --account-name ke20storage -s ssl-cert --source <サーバー証明書のローカルパス> -p server.crt

az storage file upload --account-name ke20storage -s ssl-cert --source <サーバーキーのローカルパス> -p server.key

az storage file upload --account-name ke20storage -s ssl-cert --source <CA 証明書のローカルパス> -p local-ca.crt
```

注意: `<サーバー証明書のローカルパス>`, `<サーバーキーのローカルパス>`, および `<CA 証明書のローカルパス>` は、それぞれの証明書ファイルが保存されているローカルパスに置き換えてください。

Azure ポータルにログインして、ke20storage ストレージアカウントのファイル共有 kompira-nginx-conf に移動し、
画面上からアップロードすることも可能です。


#### Nginx の conf ファイルのアップロード

Nginx の conf ファイルを kompira-nginx-conf ボリュームに default.conf という名称でアップロードします。

Azure CLI の以下のコマンドで ke-docker に含まれる Nginx の conf ファイルをアップロードします。

```
cd .\ke2-docker
az storage file upload --account-name ke20storage -s kompira-nginx-conf --source ./configs/nginx-azure.conf -p default.conf
```

Azure ポータルにログインして、ke20storage ストレージアカウントのファイル共有 kompira-nginx-conf に移動し、
画面上からアップロードすることも可能です。


#### RabbitMQ の conf ファイルのアップロード

以下のコマンドを使用して、RabbitMQ の conf ファイルを rabbitmq-conf ボリュームにアップロードします。

```
cd .\ke2-docker

az storage file upload --account-name ke20storage -s rabbitmq-conf --source ./configs/rabbitmq-auth.conf -p 20-auth.conf

az storage file upload --account-name ke20storage -s rabbitmq-conf --source ./configs/rabbitmq-ssl.conf -p 30-ssl.conf
```

Azure ポータルにログインして、ke20storage ストレージアカウントのファイル共有 kompira-nginx-conf に移動し、
画面上からアップロードすることも可能です。


### アプリケーションを ACI にデプロイ

ke2-docker/ke2/cloud/azureci ディレクトリ上で Azure CLI を使用して ARM テンプレート aci-deployment.json をデプロイします。

aci-parameters.json ファイルを使用して必要な値を設定します。以下のフィールドを更新します。

- `<subscription-id>`: サブスクリプション ID
- `<resource-group-name>`: `KE20RG` (作成するリソースの名前は適宜変更してください)
- `<vault-name>`: `ke2vault` (作成するリソースの名前は適宜変更してください)
- `<storage-account-name>`: `ke20storage` (作成するリソースの名前は適宜変更してください)
- `<storage-account-key>`: 取得したストレージアカウントキー

ストレージアカウントキーは以下のコマンドを使用して取得できます。

```
az storage account keys list --resource-group KE20RG --account-name ke20storage --output table
```

#### システムの起動

ke2-docker/ke2/cloud/azureci ディレクトリ上で Azure CLI を使用して ARM テンプレートのデプロイ。
```
> cd ./ke2-docker/ke2/cloud/azureci
> az deployment group create \
  --resource-group hasan-ke2-azure \
  --template-file aci-deployment.json \
  --parameters @aci-parameters.json
```

Azure ポータルの KE20RG リソースグループの配下に、azureci コンテナインスタンスが作成されるので、
そこから、各コンテナの状態を確認することができます。
azureci コンテナインスタンスの Public IP アドレスにブラウザから HTTP・HTTPS アクセスすると、Kompira Enterprise のログイン画面が表示されるので、ログインすることができます。

デプロイ時にパラメータをオーバーライドすることも可能です。
```
az deployment group create \
  --resource-group KE20RG \
  --template-file aci-deployment.json \
  --parameters @aci-parameters.json \
  --parameters databaseUrl=<database-url> \
  --parameters storageAccountName=<storage-account-name> \
  --parameters storageAccountKey=<storage-account-key>
  ```

オーバーライドできるパラメータは以下のとおりです。

- imageTag: イメージのタグ（デフォルト: "latest"）
- timezone: タイムゾーン（デフォルト: "Asia/Tokyo"）
- dnsNameLabel: DNS 名ラベル（デフォルト: 空）。
  DNS 名ラベルを追加する場合、`<dnsNameLabel>`.japaneast.azurecontainer.io にブラウザからアクセスできます。
- databaseUrl: データベースの接続 URL（デフォルト: Key Vault を使用して参照）
  Key Vault を使用しない場合、直接渡すこともできます。
- storageAccountName: ストレージアカウント名
- storageAccountKey: ストレージアカウントキー

#### コンテナログの確認

特定のコンテナのログを確認するには、以下のコマンドを実行します。

■ コンテナ名
- kompira
- kengine
- jobmngrd
- redis
- rabbitmq
- nginx


```
az container logs --resource-group KE20RG --name azureci --container-name <コンテナ名>
```

#### コンテナへのシェルアクセス

特定のコンテナにシェルアクセスするには、以下のコマンドを実行します。

```
az container exec --resource-group KE20RG --name azureci --container-name <コンテナ名> --exec-command /bin/sh
```

#### システムの削除・停止

以下でコンテナを削除します。
```
az deployment group delete --resource-group KE20RG --name azureci
```

コンテナを削除ではなく停止・起動・再起動したい場合は、以下のコマンドも利用できます。

停止:
```
az container stop --resource-group KE20RG --name azureci
```

起動:
```
az container start --resource-group KE20RG --name azureci
```

再起動:
```
az container restart --resource-group KE20RG --name azureci
```
