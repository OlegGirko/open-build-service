#!/bin/bash
#
export BOOTSTRAP_TEST_MODE=1
export NON_INTERACTIVE=1
export BASH_TAP_ROOT=$(dirname $0)
#
. $(dirname $0)/bash-tap-bootstrap
#
if [ -n "$WITH_RC_SCRIPTS" ]; then
  plan tests 5
else
  plan tests 3
fi
for i in \
    $DESTDIR/etc/logrotate.d/obs-server\
    $DESTDIR$SBINDIR/obs_admin\
    $DESTDIR$SBINDIR/obs_serverstatus
do
  [[ -e $i ]]
  is $? 0 "Checking $i"

done

if [ -n "$WITH_RC_SCRIPTS" ]; then
  for i in \
      $DESTDIR$SBINDIR/rcobssrcserver\
      $DESTDIR$SBINDIR/rcobsdodup
  do
    [[ -L $i ]]
    is $? 0 "Checking $i"
  done
fi
