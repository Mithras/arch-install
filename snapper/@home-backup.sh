#!/bin/bash

snapper -c @home create -c number -d manual \
&& snapper -c @home list
