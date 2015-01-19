#!/bin/bash

if [ -z $1 ] ; then
    echo "Usage: $0 <tag>"
    exit 1
fi
url="`svn info | grep URL | sed -e 's/URL: //'`"

A="`echo $url | grep '\/trunk$'`"
if ! [ $? ] ; then
    echo "path does not end in '/trunk'. you must tag manually"
    exit 1
fi

TAG=$1
#A="`echo $TAG | egrep '^[0-9]{6}$'`"
#if ! [ $? ] ; then
    #TAG="RELEASE_$(date +%Y%m%d)_BUG$1_01"
#fi

dest="`echo $url | sed -e 's/\/trunk$//'`"
dest="${dest}/tags/$TAG"
svn cp $url $dest -m "tag as $TAG per bug 999999"
echo $url
echo $dest
echo "tagged as $TAG"
