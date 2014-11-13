#!/bin/bash
{%- from "magento/settings.jinja" import magento with context -%}
{%- set interface = salt['pillar.get']('interfaces:public', 'eth0') -%}
{%- set locale = "en_US" -%}
{%- set timezone = "America/Los_Angeles" -%}
{%- set default_currency = "USD" -%}
{%- set ip = salt['network.ip_addrs'](interface)[0] %}
randomstr=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-32};echo;)
for i in `seq 1 10`; do
    output="$( \
        php -f install.php -- \
            --license_agreement_accepted yes \
            --locale {{ locale }} \
            --timezone '{{ timezone }}'\
            --default_currency {{ default_currency }} \
            --url 'http://{{ ip }}' \
            --use_rewrites no \
            --use_secure no \
            --use_secure_admin no \
            --secure_base_url '' \
            --admin_lastname demo \
            --admin_firstname demo \
            --admin_email 'demo@somedomain.com' \
            --admin_username admin \
            --admin_password $randomstr \
            --skip_url_validation \
            --db_host '{{ magento.db_write_host }}:{{ magento.db_write_port }}' \
            --db_name '{{ magento.db_name }}' \
            --db_user '{{ magento.db_user }}' \
            --db_pass '{{ magento.db_password }}' \            
        )"

    # End if already installed
    if [[ $output =~ "Magento is already installed" ]]; then
        echo "Magento is already installed"
        exit 0
    fi

    # End on success
    if [[ $output =~ "SUCCESS: " ]]; then
        echo "Magento successfully preinstalled"
        exit 0
    fi
    sleep 5
done
echo "Magento not preinstalled"
exit 1
