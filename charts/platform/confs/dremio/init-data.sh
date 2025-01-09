#!/usr/bin/env bash

curl "http://${DREMIO_URL}:9047/apiv2/bootstrap/firstuser" -X PUT \
      -H 'Authorization: _dremionull' -H 'Content-Type: application/json' \
      -d '{
         "userName": "'"$DREMIO_CODER_EMAIL"'",
         "password": "'"$ADMIN_PASSWORD"'",
         "firstName": "platform",
         "lastName": "platform",
         "email": "'"$DREMIO_CODER_EMAIL"'"
       }'
