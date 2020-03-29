#!/bin/bash
# Description:
# 
# Usage: ./ciara.sh BEGIN_DATE EVENT_DATE END_DATE WORD_LIST OUTPUT
# Date formatting: yyyy/mm/dd

#
BEGIN_DATE=$1
EVENT_DATE=$2
END_DATE=$3
# Script argument is keyword file. Check if it came through.
WORD_LIST=$4
OUTPUT=$5
TMP1=$(mktemp)
TMP2=$(mktemp)

#
if [ -z "$BEGIN_DATE" ] || [ -z "$EVENT_DATE" ] || [ -z "$END_DATE" ]
then
	echo "specify a begin, event and end date"
	echo "Usage: ./ciara.sh BEGIN_DATE EVENT_DATE END_DATE WORD_LIST OUTPUT"
	exit
fi
if [ -z "$WORD_LIST" ] || [ -z "$OUTPUT" ]
then
	echo "specify a keyword and output file"
	echo "Usage: ./ciara.sh BEGIN_DATE EVENT_DATE END_DATE WORD_LIST OUTPUT"
	exit
fi

# Wipe contents of output file 
> $OUTPUT

#
BEGIN_DATE=$(date -d "$BEGIN_DATE" +%Y%m%d)
EVENT_DATE=$(date -d "$EVENT_DATE" +%Y%m%d)
END_DATE=$(date -d "$END_DATE" +%Y%m%d)

while [[ "$BEGIN_DATE" -lt "$EVENT_DATE" ]]
do
	YEAR=$(date -d "$BEGIN_DATE" +"%Y")
	MONTH=$(date -d "$BEGIN_DATE" +"%m")
	DAY=$(date -d "$BEGIN_DATE" +"%d")
	for HOUR in {0..23}
	do
		HOUR=$(printf "%02d" $HOUR)
		echo "$HOUR"
		zless "/net/corpora/twitter2/Tweets/$YEAR/$MONTH/$YEAR$MONTH${DAY}:${HOUR}.out.gz" | /net/corpora/twitter2/tools/tweet2tab -i id | wc -l >> "${TMP1}"
		zless "/net/corpora/twitter2/Tweets/$YEAR/$MONTH/$YEAR$MONTH${DAY}:${HOUR}.out.gz" | /net/corpora/twitter2/tools/tweet2tab -i words | grep -iw -f "${WORD_LIST}" | wc -l >> "${TMP2}"
	done
	echo "$BEGIN_DATE"
	BEGIN_DATE=$(date -d "$BEGIN_DATE + 1 day" +"%Y%m%d")
done

#
echo "all tweets before event:" >> $OUTPUT
paste -s -d+ $TMP1 | bc >> $OUTPUT
echo "tweets with words before event:" >> $OUTPUT
paste -s -d+ $TMP2 | bc >> $OUTPUT

#
> $TMP1
> $TMP2

#
BEGIN_DATE=$(date -d "$BEGIN_DATE + 1 day" +"%Y%m%d")

while [[ "$BEGIN_DATE" -le "$END_DATE" ]]
do
	YEAR=$(date -d "$BEGIN_DATE" +"%Y")
	MONTH=$(date -d "$BEGIN_DATE" +"%m")
	DAY=$(date -d "$BEGIN_DATE" +"%d")
	for HOUR in {0..23}
	do
		HOUR=$(printf "%02d" $HOUR)
		echo "$HOUR"
		zless "/net/corpora/twitter2/Tweets/$YEAR/$MONTH/$YEAR$MONTH${DAY}:${HOUR}.out.gz" | /net/corpora/twitter2/tools/tweet2tab -i id | wc -l >> "${TMP1}"
		zless "/net/corpora/twitter2/Tweets/$YEAR/$MONTH/$YEAR$MONTH${DAY}:${HOUR}.out.gz" | /net/corpora/twitter2/tools/tweet2tab -i words | grep -iw -f "${WORD_LIST}" | wc -l >> "${TMP2}"
	done
	echo "$BEGIN_DATE"
	BEGIN_DATE=$(date -d "$BEGIN_DATE + 1 day" +"%Y%m%d")
done

#
echo "all tweets after event:" >> $OUTPUT
paste -s -d+ $TMP1 | bc >> $OUTPUT
echo "tweets with words after event:" >> $OUTPUT
paste -s -d+ $TMP2 | bc >> $OUTPUT
cat $OUTPUT

#
rm -f $TMP1
rm -f $TMP2