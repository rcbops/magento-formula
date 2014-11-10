haproxy_and_web:
  salt.state:
   - tgt: 'G@roles:web-haproxy or G@roles:web or G@roles:db-haproxy'
   - tgt_type: compound
   - highstate: True

db-master:
  salt.state:
    - tgt: 'roles:db-master'
    - tgt_type: grain
    - highstate: True

db-slave:
  salt.state:
    - tgt: 'roles:db-slave'
    - tgt_type: grain
    - highstate: True
    - require:
      - salt: db-master

service.start:
  salt.function:
    - tgt: 'roles:web'
    - tgt_type: grain
    - arg:
      - lsyncd
    - require:
      - salt: haproxy_and_web
