#!/bin/bash
{%- from "magento/settings.jinja" import magento with context -%}
{%- set interface = salt['pillar.get']('interfaces:public', 'eth0') -%}
{%- set my_ip = salt['network.ipaddrs'](interface)[0] -%}
{%- set ip = salt['pillar.get']('magento:haproxy:host', my_ip) %}

#while [[ $(curl --write-out %{http_code} --silent --output /dev/null http://{{ ip }}/ ) -ne '200' ]]; do
while [[ ! $(curl http://23.253.229.53/install.php) =~ 'Magento is already installed' ]]; do
   sleep 20
done

sleep 60

mysql_conn="mysql -u{{ magento.db_user }} -p{{ magento.db_password }} -P{{ magento.db_write_port }} -h{{ magento.db_host }}"
tbl_name="{{ magento.db_name }}"

query="SELECT DISTINCT CONCAT(t.table_schema,'.',t.table_name) as tbl, t.engine, IF(ISNULL(c.constraint_name),'NOPK','') AS nopk, IF(s.index_type = 'FULLTEXT','FULLTEXT','') as ftidx, IF(s.index_type = 'SPATIAL','SPATIAL','') as gisidx FROM information_schema.tables AS t LEFT JOIN information_schema.key_column_usage AS c ON (t.table_schema = c.constraint_schema AND t.table_name = c.table_name AND c.constraint_name = 'PRIMARY') LEFT JOIN information_schema.statistics AS s ON (t.table_schema = s.table_schema AND t.table_name = s.table_name AND s.index_type IN ('FULLTEXT','SPATIAL')) WHERE t.table_schema NOT IN ('information_schema','performance_schema','mysql') AND t.table_type = 'BASE TABLE' AND (t.engine <> 'InnoDB' OR c.constraint_name IS NULL OR s.index_type IN ('FULLTEXT','SPATIAL')) ORDER BY t.table_schema,t.table_name;"


for i in $($mysql_conn -e "$query" $tbl_name | grep MyISAM | awk '{print $1}' | sed 's/$tbl_name\.//g'); do
    $mysql_conn -e "ALTER TABLE $i ENGINE='InnoDB';" $tbl_name
done

for i in $($mysql_conn -e "$query" $tbl_name | grep InnoDB | grep NOPK | awk '{print $1}' | sed 's/$tbl_name\.//g'); do
   $mysql_conn -e "ALTER TABLE $i ADD id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY FIRST;" $tbl_name
done

$mysql_conn -e "$query" $tbl_name
logger "Fix tables ran"
