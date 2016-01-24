#!/bin/bash

#echo "`date` ARG0='$0' ARG1='$1' ARG2='$2' ARG3='$3' ARG4='$4' ARG5='$5' ARG6='$6' ARG7='$7' ARG8='$8'" > "/tmp/Ali_splunk-script.out"

DAY=$(date '+%d')
DATE=$(date -d "1 day ago" '+%Y-%m-%d')
CUR_DATE=$(date '+%Y-%m-%d')
QUERY=$4
ROOT="/home/quixey/report/$QUERY"
SOURCE=$8
FILE=$ROOT/total.log
ERROR_LOG="/home/quixey/report/err_log"
SPLUNK="/opt/splunk/var/run/splunk"

# For debug 
echo "4th is, $4" >> $ERROR_LOG
echo "8th is, $8" >> $ERROR_LOG
if [ ! -d $ROOT ];then
  mkdir $ROOT >> $ERROR_LOG 2>&1
fi
# End of debug info

cp $SOURCE $ROOT/${DATE}.gz >> $ERROR_LOG 2>&1
gunzip -f $ROOT/${DATE}.gz >> $ERROR_LOG 2>&1
cd $ROOT

# copy the last file of yesterday to base
TS_OF_FILE=$(ls -lrt --full-time ${FILE}_* | tail -1 | awk '{print $6}')
LAST_FILE=$(ls -lrt --full-time ${FILE}_* | tail -1 | awk '{print $9}')
if [[ "$CUR_DATE" > "$TS_OF_FILE" ]]; then
	cp -f $LAST_FILE ${FILE}
else
	rm -f $LAST_FILE
fi

# generate a new file when today is 2, 17
if [ $DAY -eq 2 -o $DAY -eq 17 ]; then
  mv $FILE ${FILE}_${DATE}_bak >> $ERROR_LOG 2>&1
  touch $FILE >> $ERROR_LOG 2>&1
fi

date >> $ERROR_LOG 2>&1
# calculate the accumulate stats as of yesterday
/usr/bin/awk 'BEGIN {
  while ((getline L < "'"${ROOT}/${DATE}"'") > 0)
  {
    split(L,ft,",")
    code=ft[1]
    if (code == "status")
	continue
    count=ft[2]
    data_today[code]=count
  }

  while ((getline T < "'"$FILE"'") > 0)
  {
    split(T,t,",")
    code=t[1]
    if (code == "Status")
        continue
    count=t[2]
    tl[code]=count
  }

  for (c in data_today)
  {
    if (c in tl )
        tl[c] += data_today[c];
    else
        tl[c] = data_today[c];
  }

  printf "%s,%s\n","Status","count"

  sum=0
  for (c in tl)
  {
        if (c != "total" && c != "503 error rate") 
	{
                sum += tl[c]
		printf "%s,%d\n",c,tl[c]
	}
  }
  tl["total"]=sum
  printf "%s,%d\n", "total", tl["total"]
  printf "%s,%.5f%%\n", "503 error rate", tl["503"]/tl["total"]*100 
}' >> ${FILE}_$DATE

# put the result to Splunk.web
cp -f ${FILE}_$DATE $SPLUNK/${QUERY}.log
