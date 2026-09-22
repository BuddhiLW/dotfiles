#!/usr/bin/env bash
# Liveness probe for the blw kubectl LB. Restarts haproxy-k8s-lb.service when
# HAProxy itself is unresponsive — NOT when the cluster behind it is down.
#
# Probe = the stats listener (127.0.0.1:8405). It answers from HAProxy's own
# event loop with no backend involved, so a failure means the process is dead,
# wedged, or the frontend never bound. Backend health is HAProxy's job.
set -uo pipefail

UNIT=haproxy-k8s-lb.service
STATS_URL=http://127.0.0.1:8405/stats
ATTEMPTS=3
SLEEP=3

probe() {
  curl -fsS -m 4 -o /dev/null "$STATS_URL"
}

for i in $(seq 1 "$ATTEMPTS"); do
  if probe; then
    exit 0
  fi
  [ "$i" -lt "$ATTEMPTS" ] && sleep "$SLEEP"
done

echo "haproxy-k8s-lb unresponsive on $STATS_URL after $ATTEMPTS attempts — restarting $UNIT"
systemctl --user restart "$UNIT"
