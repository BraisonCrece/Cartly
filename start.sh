#!/bin/bash

# Remove server.pid if it exists
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bin/rails server -b '0.0.0.0' -p '3000'
