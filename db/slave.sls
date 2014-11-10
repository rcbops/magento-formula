{% from "magento/settings.jinja" import magento with context %}

include:
  - magento.db

{% if magento.db_write_host %}
stop_slave:
  cmd.run:
    - name: mysql --defaults-extra-file=/root/.my.cnf -e 'STOP SLAVE'
    - require:
      - sls: magento.db
    
change_master:
  cmd.run:
    - name: mysql --defaults-extra-file=/root/.my.cnf -e "CHANGE MASTER TO MASTER_HOST='{{ magento.db_write_host }}', MASTER_USER='{{ magento.slave_user }}', MASTER_PASSWORD='{{ magento.slave_password }}';"
    - require:
      - cmd: stop_slave

dump_master:
  cmd.run:
    - name: mysqldump -h{{ magento.db_write_host }} -u{{ magento.slave_user }} -p{{ magento.slave_password }} --add-drop-database --add-drop-table --master-data --databases {{ magento.db_name }} > /root/magento.sql
    - require:
      - cmd: change_master

load_dump:
  cmd.wait:
    - name: mysql --defaults-extra-file='/root/.my.cnf' < /root/magento.sql
    - watch:
      - cmd: dump_master

start_slave:
  cmd.wait:
    - name: mysql --defaults-extra-file=/root/.my.cnf -e "START SLAVE"
    - watch:
      - cmd: load_dump

check_status:
  cmd.wait:
    - name: mysql --defaults-extra-file=/root/.my.cnf -e "SHOW SLAVE STATUS\G"
    - watch:
      - cmd: start_slave

delete_sql:
  cmd.run:
    - name: rm -rf /root/magento.sql
    - require:
      - cmd: load_dump
{% endif %}
