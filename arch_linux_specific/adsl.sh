#!/bin/bash

. /etc/rc.conf
. /etc/rc.d/functions

start() {
  stat_busy "Starting ADSL connection loop"
  tmux new-session -d -s "aliceadsl" /home/venator/config/adsl_loop
  stat_done
}

stop() {
  stat_busy "Stopping ADSL connection loop (faking)"
  stat_done
}

case $1 in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
esac

