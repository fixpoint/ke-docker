#! /bin/sh
set -e

# SSL 証明書を /etc/rabbitmq/ssl にコピーしてパーミッション変更
/bin/cp -f -a -r -T /run/.kompira_ssl /etc/rabbitmq/ssl
chown -R rabbitmq:rabbitmq /etc/rabbitmq/ssl 

# SSL 認証プラグインを有効化
rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl

# クラスタ構成時は、再参加できるようにメンバーをクリアしておく
for cluster_node in $(grep '^cluster_formation.classic_config.nodes' /etc/rabbitmq/conf.d/*.conf | cut -d'=' -f2); do
    if [[ rabbit@$(hostname) != ${cluster_node} ]]; then
        if rabbitmqctl -n ${cluster_node} forget_cluster_node rabbit@$(hostname) 2> /dev/null; then
            break
        fi
    fi
done

# rabbitmq-server を起動
exec rabbitmq-server "$*"
