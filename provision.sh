#! /bin/bash

apt-get update
apt-get install -y bsdtar vim jq tree

adduser --home /home/emq --shell /bin/bash -gecos '' --disabled-password emq

wget -qO- "http://emqtt.com/downloads/3009/ubuntu16_04" | bsdtar -xvf- -C /home/emq

find /home/emq/emqx -type d -name bin -print | xargs chmod -R +x
ln -s /home/emq/emqx/bin/* /usr/local/bin/

ulimit -n 1048576
sysctl -w fs.file-max=2097152
sysctl -w fs.nr_open=2097152
sysctl -w net.core.somaxconn=65536

cp /vagrant/emqx.conf /home/emq/emqx/etc/emqx.conf
sed -i "s/node.name.*/node.name = $EMQX_NODE_NAME/" /home/emq/emqx/etc/emqx.conf
sed -i "s/cluster.static.seeds.*/cluster.static.seeds = $EMQX_CLUSTER_NODES/" /home/emq/emqx/etc/emqx.conf

sudo -H -u emq bash -c 'emqx start'
sleep 5
sudo -H -u emq bash -c 'emqx_ctl cluster status'
