#!/bin/bash
for ADDR in $(cat urls.txt)
do
       printf "$ADDR "
       LOOKUP_RESULTS=$(nslookup $ADDR)
       FAIL_COUNT=`echo "$LOOKUP_RESULTS" | grep "can't find" | wc -l`;
       if [ $FAIL_COUNT -eq 1 ]
       then
               NAME="Can't find DNS record";
       else
               NAME=$(echo "$LOOKUP_RESULTS" | grep Address: | tail -n +2 );
       fi
       echo $NAME
done
