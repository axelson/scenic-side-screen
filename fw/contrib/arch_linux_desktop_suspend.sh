#!/bin/sh

# Fully suspend (even ssh will no longer work)
# systemctl suspend

# Turn off the screen only
export DISPLAY=":0"
# https://www.reddit.com/r/linux4noobs/comments/lu1plx/hi_i_get_this_authorization_required_but_no/
xhost si:localuser:root
xset dpms force off
