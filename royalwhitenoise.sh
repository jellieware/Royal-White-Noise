#!/bin/bash
trap "exit 1" INT
# Base noise sources
BROWN="anoisesrc=color=brown"
PINK="anoisesrc=color=pink"
WHITE="anoisesrc=color=white"

# Filtered noise sources
INFRA="anoisesrc=color=brown,lowpass=f=20"
ULTRA="anoisesrc=color=pink,highpass=f=15000"
GREY="anoisesrc=color=white,bandpass=f=1000:width_type=h:w=3000"

# 2 seconds per ear cycle (0.25 Hz LFO) for the background noise
FREQ="0.25"
L_NOISE_MOD="volume='0.4*sin(2*PI*$FREQ*t)+0.6':eval=frame"
R_NOISE_MOD="volume='0.4*cos(2*PI*$FREQ*t)+0.6':eval=frame"

# SEPARATE DELTA BEATS: Pure sine tones generated entirely outside the noise mix
# Left ear: 100 Hz tone
# Right ear: 101.5 Hz tone (Creates a clean, independent 1.5 Hz Delta brainwave beat)
L_TONE="sine=frequency=100:duration=3600,volume=0.3"
R_TONE="sine=frequency=101.5:duration=3600,volume=0.3"

# Process: Mix noises -> Split stereo -> Apply slow 2s LFO -> Mix with independent Delta Tones
ffplay -af "bs2b=fcut=650:feed=9.5" -f lavfi -i "
$BROWN[a]; $PINK[b]; $WHITE[c]; $GREY[d]; $INFRA[e]; $ULTRA[f];
[a][b][c][d][e][f]amix=inputs=6:duration=longest[mono_noise];
[mono_noise]asplit=outputs=2[m_noise_l][m_noise_r];
[m_noise_l]$L_NOISE_MOD[noise_left];
[m_noise_r]$R_NOISE_MOD[noise_right];
$L_TONE[tone_left];
$R_TONE[tone_right];
[noise_left][tone_left]amix=inputs=2:duration=longest[final_left];
[noise_right][tone_right]amix=inputs=2:duration=longest[final_right];
[final_left][final_right]amerge=inputs=2" > /dev/null 2>&1 &

if pgrep ffplay > /dev/null; then

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
