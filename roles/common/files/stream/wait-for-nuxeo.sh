#!/usr/bin/env bash
# >ait until nuxeo is up and running

nuxeo_status() {
    status=$(curl -fs http://nuxeo:8080/nuxeo/runningstatus)
    if [[ $? -ne 0 ]]; then
      return 1
    fi
    echo ${status}
    return 0
}

until nuxeo_status; do
  >&2 echo "Waiting for Nuxeo to be up ..."
  sleep 5
done

>&2 echo "Nuxeo is up - executing command"
exec "$@"
