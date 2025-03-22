#!/bin/sh

# Now send blocks with information forever:
conky -c $HOME/conf-m/conky/line/conky-lemonbar.conf \
	| lemonbar -b -f -misc-spleen-medium-r-normal--12-120-72-72-c-60-iso10646-1 \
	| sh
