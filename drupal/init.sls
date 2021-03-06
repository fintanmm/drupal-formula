include:
    - php

drupal:
    file.managed:
        - unless: ls {{ salt['pillar.get']('drupal:home', '/var/www/drupal') }}/sites/default/settings.php
        - name: /tmp/drupal-{{ salt['pillar.get']('drupal:version', '7.26') }}.tar.gz
        - source: http://ftp.drupal.org/files/projects/drupal-{{ salt['pillar.get']('drupal:version', '7.26') }}.tar.gz
        - source_hash: {{ salt['pillar.get']('drupal:source_hash') }}


{{ salt['pillar.get']('drupal:home', '/var/www/') }}:
    file.directory:
        - user: www-data
        - group: www-data
        - dir_mode: 755
        - file_mode: 644
        - makedirs: True
        - recurse:
            - user
            - group
            - mode

extract-drupal:
    module.run:
        - name: archive.tar
        - options: zxf
        - tarfile: /tmp/drupal-{{ salt['pillar.get']('drupal:version', '7.26') }}.tar.gz
        - dest: {{ salt['pillar.get']('drupal:home', '/var/www/') }}

rename-drupal:
    file.rename:
        - name: {{ salt['pillar.get']('drupal:home', '/var/www/') }}/{{ salt['pillar.get']('drupal:name') }}
        - source: {{ salt['pillar.get']('drupal:home', '/var/www/') }}/drupal-{{ salt['pillar.get']('drupal:version', '7.26') }}

{% if salt['pillar.get']('webserver', 'apache2') == 'apache2' %}

/etc/apache2/sites-available/{{ salt['pillar.get']('drupal:name') }}:
    file.managed:
        - source: salt://drupal/files/apache2
{% elif salt['pillar.get']('webserver') == 'nginx' %}

/etc/nginx/{{ salt['pillar.get']('drupal:name') }}:
    file.managed:
        - source: salt://drupal/files/nginx
# TODO: Add support for webserver
{% elif salt['pillar.get']('webserver') == 'lighthttpd' %}

/etc/lighthtpd/{{ salt['pillar.get']('drupal:name') }}:
    file.managed:
        - source: salt://drupal/files/lighthttpd
# TODO: Add support for webserver
{% endif %}
        - user: {{ salt['pillar.get']('webserver:user') }}
        - group: {{ salt['pillar.get']('webserver:group') }}
        - mode: 644
        - template: jinja
        - defaults:
            name: salt['pillar.get']('drupal:name')
