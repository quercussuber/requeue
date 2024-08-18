#!/bin/zsh
# $ ./bootstrap.zsh [run|stop]
# This script is used to bootstrap the tickplant service. It is called by the
# first start the ticker process, then the feedhandler process, then the hdb etc
# The script also stops the processes if they are running.

#find if another process is running on 5010 and kill it if it is
echo "Stopping ticker|feed|hdb processes"
lsof -i :5010 | grep q | awk '{print $2}' | xargs kill -SIGTERM
lsof -i :5011 | grep q | awk '{print $2}' | xargs kill -SIGTERM
lsof -i :5012 | grep q | awk '{print $2}' | xargs kill -SIGTERM



# stop the processes if running in mode stop
if [[ $1 == "stop" ]]; then
    echo "Stopped tickplant processes"
    exit 0
fi

if [[ $1 == "clean" ]]; then
    echo "Cleaned logs"
    rm -v 5010
    rm -v 5012
    rm -rfv data/*
    rm sym_px
    exit 0
fi
set -e # exit on error
alias q="QHOME=~/shadow/q rlwrap -H /var/tmp/hist${PPID} /Users/emelis/shadow/q/m64/q"
TICK_LOG=logs/tick.log
q tick.q -t 1000 -c 31 317 2>&1 > ${TICK_LOG} &
TICK="${!}"
echo "TICKER PID: ${TICK} "

#find if another instance of feedhandler is running and kill it if it is
ps -ef | grep feedhandler | grep -v grep | awk '{print $2}' | xargs kill -SIGTERM
q feedhandler/feedhandler.q :5010 -t 1000 -c 31 317 2>&1 > logs/feedhandler.log &
FH="${!}"
echo "FH PID: ${FH}"

q -p 5012 -c 31 317 > logs/hdb.log &
HDB="${!}"
echo "HDB PID: ${HDB}"

ps -ef | grep orderbook | grep -v grep | awk '{print $2}' | xargs kill -SIGTERM
q orderbook/orderbook.q :5010 -t 1 -c 31 317 2>&1 > logs/orderbook.log &
ORDERBOOK="${!}"
echo "ORDERBOOK PID: ${ORDERBOOK}"

