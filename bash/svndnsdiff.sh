#!/bin/bash

svn diff db.gen* | grep -v "^ "

exit 0
