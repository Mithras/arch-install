#!/usr/bin/env bash
set -e

snapper -c @home create -c number -d manual
snapper -c @home list
