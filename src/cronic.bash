# Cronic v2 - cron job report wrapper
# Copyright 2007 Chuck Houpt. No rights reserved, whatsoever.
# Public Domain CC0: http://creativecommons.org/publicdomain/zero/1.0/

set -eu

OUT=/tmp/cronic.out.$$
ERR=/tmp/cronic.err.$$
TRACE=/tmp/cronic.trace.$$

set +e
"$@" >$OUT 2>$TRACE
RESULT=$?
set -e

PATTERN="^${PS4:0:1}\\+${PS4:1}"
if grep -aq "$PATTERN" $TRACE
then
    ! grep -av "$PATTERN" $TRACE > $ERR
else
    ERR=$TRACE
fi

if [ $RESULT -ne 0 -o -s "$ERR" ]
    then
    echo "Cronic detected failure or error output for the command:"
    echo "$@"
    echo
    echo "RESULT CODE: $RESULT"
    echo
    echo "ERROR OUTPUT:"
    cat "$ERR"
    echo
    echo "STANDARD OUTPUT:"
    cat "$OUT"
    if [ $TRACE != $ERR ]
    then
        echo
        echo "TRACE-ERROR OUTPUT:"
        cat "$TRACE"
    fi
fi

rm -f "$OUT"
rm -f "$ERR"
rm -f "$TRACE"
