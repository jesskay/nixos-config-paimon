#!/usr/bin/env bash

main_x11 () {
	maim -u \
		| (feh -F - & maim -u -s ; kill %?feh) \
		| xclip -selection clipboard -t image/png
}

main_wayland () {
	grim - \
		| (feh -F - & grim -g "$(slurp)" - ; kill %?feh) \
		| wl-copy
}

if [[ "$WAYLAND_DISPLAY" = "" ]] ; then
	main_x11
else
	main_wayland
fi
