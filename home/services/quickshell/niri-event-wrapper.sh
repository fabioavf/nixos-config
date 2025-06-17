#!/run/current-system/sw/bin/bash
# Wrapper to force line buffering for niri event stream

exec stdbuf -oL /etc/profiles/per-user/fabio/bin/niri msg --json event-stream