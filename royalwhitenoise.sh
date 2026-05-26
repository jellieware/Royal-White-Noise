cleanup() {
    echo "Cleaning up..."
    pkill play
    pkill -f royalwhitenoise.sh
    exit
}
#!/usr/bin/env bash
# Requires sox to be installed: sudo apt install sox libsox-fmt-all

# Each "input" starts with '|' so SoX treats it as a command/generator
while true; do
  play --buffer 32768 -n -c 2 synth 10:00 \
    brownnoise pinknoise whitenoise \
    lowpass -1 250 \
    vol 1 \
    remix 1 2
done >/dev/null 2>&1 &

if pgrep play > /dev/null; then

function start_spinner {
    set +m
    echo -n "$1"
    { while : ; do for X in 'Playing     ' 'Playing.    ' 'Playing..   ' 'Playing...  ' 'Playing.... ' 'Playing.....'; do echo -en "\r$X" ; sleep 1 ; done ; done & } 2>/dev/null



spinner_pid=$!
}

function stop_spinner {
    { kill -9 $spinner_pid && wait; } 2>/dev/null
    set -m
    echo -en "\033[2K\r"
}
trap cleanup SIGINT
spinner_pid=
start_spinner ""
wait
kill "$spinner_pid" &>/dev/null

fi

wait
