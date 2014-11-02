{% from "magento/settings.jinja" import magento with context %}

requirements:
  pkg.installed:
    - pkgs:
      - apache2
      - memcached
      - php5
      - php5-common
      - php5-mcrypt
      - php5-curl
      - php5-cli
      - php5-mysql
      - php5-gd
      - php5-memcached
      - php5-dev
      - php-apc
      - mysql-client

# Only move, and extract magento files if magento file doesn't exitst
{% if 1 == salt['cmd.retcode']('test -f /var/www/installed_by_salt') %}

# Get the magento tarball
/tmp/magento-{{ magento.source.version }}.tar.gz:
  file.managed:
    - source: {{ magento.source.url }}
    - source_hash: md5={{ magento.source.hash }}

unzip_magento:
  cmd.run:
    - name: tar -zxf magento-{{ magento.source.version }}.tar.gz
    - cwd: /tmp
    - require:
      - file: /tmp/magento-{{ magento.source.version }}.tar.gz

move_magento_files:
  cmd.run:
    - name: mv magento/* magento/.htaccess magento/.htaccess.sample /var/www
    - cwd: /tmp
    - require:
      - cmd: unzip_magento

mark:
  cmd.run:
    - name: touch /var/www/installed_by_salt
    - require:
      - cmd: move_magento_files

cleanup:
  cmd.run:
    - name: rm -rf magento*
    - cwd: /tmp
    - require:
      - cmd: move_magento_files
{% endif %}

# Provide a config template. The magento installer will use
# to create the actual local.xml config file.
/var/www/app/etc/local.xml.template:
  file.managed:
    - source: salt://magento/files/magento/local.xml.template
    - template: jinja

/var/www:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755
    - recurse:
      - user
      - group
      - mode

/etc/apache2/sites-enabled/000-default:
  file.absent:
    - name: /etc/apache2/sites-enabled/000-default

/etc/apache2/sites-enabled/default:
  file.managed:
    - name: /etc/apache2/sites-enabled/default
    - source: salt://magento/files/apache/sites-enabled/default

apache-service:
  service:
    - name: apache2
    - running
    - watch:
      - file: /etc/apache2/sites-enabled/default

/etc/memcached.conf:
  file.managed:
    - name: /etc/memcached.conf
    - source: salt://magento/files/memcached/memcached.conf
    - template: jinja

memcached-service:
  service:
    - name: memcached
    - running
    - watch:
      - file: /etc/memcached.conf

