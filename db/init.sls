{%- from "magento/settings.jinja" import magento with context -%}

# Include standard mysql config
include:
  - mysql

magento_haproxy_user:
  mysql_user.present:
    - name: haproxy
    - host: '%'
    - connection_default_file: /root/.my.cnf
    - allow_passwordless: True
    - require:
      - sls: mysql

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
