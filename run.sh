#!/bin/sh
sed -i -e "s#user: kemal#user: $DB_USER#" \
       -e "s#password: kemal#password: $DB_PASSWORD#" \
       -e "s#host: localhost#host: $DB_HOST#" \
       -e "s#port: 5432#port: $DB_PORT#" \
       -e "s#dbname: invidious#dbname: $DB_NAME#" \
      /invidious/config/config.yml
/invidious/invidious
