{% from "magento/settings.jinja" import magento with context %}

# Include standard mysql config
include:
  - mysql

# Set up the user for replication to this master
#magento_slave_user:
#  # Create the user
#  mysql_user.present:
#    - name:     {{ magento.slave_user }}
#    - password: {{ magento.slave_password }}
#    - host:     {{ magento.slave_host }}
#    - connection_default_file: /root/.my.cnf

#  # Assign permissions
#  mysql_grants.present:
#    - user: {{ magento.slave_user }}
#    - host: {{ magento.slave_host }}
#    - database: '*.*'
#    - grant: replication slave, reload, replication client, select
#    - connection_default_file: /root/.my.cnf

magento_db:
  mysql_database.present:
    - name: {{ magento.db_name }}
    - connection_default_file: /root/.my.cnf

# Set up the database user magento will use
magento_db_user:
  # Create the user
  mysql_user.present:
    - name:     {{ magento.db_user }}
    - password: {{ magento.db_password }}
    - host:     {{ magento.db_host }}
    - connection_default_file: /root/.my.cnf

  # Assign permissions
  mysql_grants.present:
    - user:     {{ magento.db_user }}
    - host:     {{ magento.db_host }}
    - database: '{{ magento.db_name }}.*'
    - grant: all
    - connection_default_file: /root/.my.cnf
