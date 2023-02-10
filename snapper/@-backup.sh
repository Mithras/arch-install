#!/bin/bash

snapper -c @ create -c number -d manual \
&& snapper -c @ list
