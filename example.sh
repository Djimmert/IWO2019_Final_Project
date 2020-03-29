#!/bin/bash
# Description:
#
# Usage: ./example.sh WORD_LIST
WORD_LIST=$1

if [ -z "$WORD_LIST" ]
then
	echo "specify a keyword file"
	echo "Usage: ./example.sh WORD_LIST"
	exit
fi

zless "/net/corpora/twitter2/Tweets/2020/02/20200224:13.out.gz" | /net/corpora/twitter2/tools/tweet2tab -i id | head -n5
zless "/net/corpora/twitter2/Tweets/2020/02/20200224:13.out.gz" | /net/corpora/twitter2/tools/tweet2tab -i words | grep -iw -f "$WORD_LIST" | head -n5
