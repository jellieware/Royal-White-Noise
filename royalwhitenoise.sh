cleanup() {
    echo "Cleaning up..."
    pkill -f royalwhitenoise.sh
    exit
}

#with delta waves
ffplay -af "loudnorm=I=-16:TP=-1.5:LRA=11,bs2b=fcut=650:feed=9.5,volume=1" -f lavfi -i "anoisesrc=d=3600:c=white:r=44100,lowpass=f=150,tremolo=f=1.5:d=0.2,volume=0.8[w];anoisesrc=d=3600:c=pink:r=44100,lowpass=f=250,volume=0.5[p];anoisesrc=d=3600:c=brown:r=44100,lowpass=f=100,volume=1.0[b];sine=f=60:d=3600:r=44100[dl];sine=f=62.5:d=3600:r=44100[dr];[dl][dr]amerge=inputs=2,volume=0.5[delta];sine=f=26:r=44100,tremolo=f=1.5:d=0.7[purr1];sine=f=38:r=44100,tremolo=f=1.6:d=0.6[purr2];[purr1][purr2]amix=inputs=2,lowpass=f=80,volume=2.5[cat];[w][p][b][delta][cat]amix=inputs=5:weights='0.3 0.6 1.0 0.8 1.2',highpass=f=20,volume=1.5" -nodisp > /dev/null 2>&1 &

#without delta waves
#-f lavfi -i "anoisesrc=d=3600:c=white:r=44100,lowpass=f=150,tremolo=f=1.5:d=0.2,volume=0.8[w];anoisesrc=d=3600:c=pink:r=44100,lowpass=f=250,volume=0.5[p];anoisesrc=d=3600:c=brown:r=44100,lowpass=f=100,volume=1.0[b];sine=f=26:r=44100,tremolo=f=1.5:d=0.7[purr1];sine=f=38:r=44100,tremolo=f=1.6:d=0.6[purr2];[purr1][purr2]amix=inputs=2,lowpass=f=80,volume=3.0[cat];[w][p][b][cat]amix=inputs=4:weights='0.3 0.6 1.0 1.5',highpass=f=20,volume=1.5" -nodisp > /dev/null 2>&1 &

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
