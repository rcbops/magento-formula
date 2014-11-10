{%- from "magento/settings.jinja" import magento with context -%}

# Include standard mysql config
include:
  - magento.db

# Set up the user for replication to this master
magento_slave_user:
  # Create the user
  mysql_user.present:
    - name:     {{ magento.slave_user }}
    - password: {{ magento.slave_password }}
    - host:     {{ magento.slave_host }}
    - connection_default_file: /root/.my.cnf
    - require:
      - sls: magento.db

  # Assign permissions
  mysql_grants.present:
    - user: {{ magento.slave_user }}
    - host: {{ magento.slave_host }}
    - database: '*.*'
    - grant: replication slave, reload, replication client, select
    - connection_default_file: /root/.my.cnf
    - require:
      - sls: magento.db

magento_db:
  mysql_database.present:
    - name: {{ magento.db_name }}
    - connection_default_file: /root/.my.cnf
    - require:
      - sls: magento.db
