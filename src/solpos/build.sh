#!/bin/sh

set -v
valac-0.22 --target-glib $(pkg-config --modversion glib-2.0) --vapidir=. --includedir=. --pkg solpos solpos.c stest00_vala.vala -o stest00_vala -X -I. -X -lm

