{% from "magento/settings.jinja" import magento with context %}

/root/preinstall.sh:
  file.managed:
    - source: salt://magento/files/magento/preinstall.sh
    - template: jinja
    - mode: 600

{% if magento.is_web_primary %}

# Primary nodes should run preinstaller and have the magento cron job
salt://magento/files/magento/preinstall.sh:
  cmd.script:
    - user: www-data
    - cwd: /var/www
    - template: jinja
    - creates: /var/www/app/etc/local.xml

/bin/sh /var/www/cron.sh:
  cron.present:
    - user: www-data
    - minute: '*/5'

{% else %}

# Primary nodes should not be preinstalled and should not have the magento cron job

/bin/sh /var/www/cron.sh:
  cron.absent:
    - user: www-data

{% endif %}

/var/www/app/etc/local.xml:
  file.absent:
    - require:
      - cron: /bin/sh /var/www/cron.sh
{% if magento.is_web_primary %}
      - cmd: salt://magento/files/magento/preinstall.sh
{% endif %}

