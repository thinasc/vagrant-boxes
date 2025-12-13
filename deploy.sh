#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

curl -# \
  --user $FORGEJO_USER:$FORGEJO_TOKEN \
  --upload-file $ORIGIN $DESTIN \
  >/dev/null
