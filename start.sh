#!/bin/sh

root=~/prod/file

export PORT=3000

cd ${root}
/usr/local/bin/forever start -a -l stdout.log /usr/bin/npm start