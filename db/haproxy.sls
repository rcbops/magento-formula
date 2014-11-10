haproxy-repo:
  pkgrepo.managed:
    - humanname: haproxy
    - name: ppa:vbernat/haproxy-1.5
    - require_in:
      - pkg:haproxy-software

haproxy-software:
  pkg.installed:
    - pkgs:
      - haproxy

/etc/haproxy/haproxy.cfg:
  file.managed:
    - source: salt://magento/files/haproxy/db-haproxy.cfg
    - template: jinja
    - makedirs: True

/etc/default/haproxy:
  file.managed:
    - source: salt://magento/files/haproxy/default-haproxy
    - makedirs: True

haproxy-service:
  service:
    - name: haproxy
    - running
    - enable: True
    - require:
      - pkg: haproxy-software
    - watch:
      - file: /etc/haproxy/haproxy.cfg
      - file: /etc/default/haproxy
