#!/usr/bin/env bash
set -e

snapper -c @ create -c number -d manual
snapper -c @ list
