#!/bin/bash
#
export BOOTSTRAP_TEST_MODE=1
export NON_INTERACTIVE=1
export BASH_TAP_ROOT=$(dirname $0)
#
. $(dirname $0)/bash-tap-bootstrap
#
plan tests 5
for i in \
    $DESTDIR/etc/logrotate.d/obs-server\
    $DESTDIR$SBINDIR/obs_admin\
    $DESTDIR$SBINDIR/obs_serverstatus
do
  [[ -e $i ]]
  is $? 0 "Checking $i"

done

for i in \
    $DESTDIR$SBINDIR/rcobssrcserver\
    $DESTDIR$SBINDIR/rcobsdodup
do
  [[ -L $i ]]
  is $? 0 "Checking $i"
done
