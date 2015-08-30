#!/bin/bash
PATH_TRY="$HOME/.gitSync/gitSync.sh"

if [ ! -f $PATH_TRY ]; then
	PATH_TRY="gitSync.sh"
	if [ ! -f $PATH_TRY ]; then
		read -p "Location of gitSync:" -r
		echo
		PATH_TRY = $REPLY
	fi
fi

if [ ! -f $PATH_TRY ]
then
	echo "gitSync not found, move my to ~/ please"
	return 0
fi

read -p "Git server (https://github.com for syntax exemple):" -r
echo
addr="$REPLY/"
read -p "Git pseudo:" -r
echo
addr="$addr$REPLY/"
read -p "Git repository name for sync:" -r
echo
addr="myGit='$addr$REPLY.git'"
#echo "ADDR="$addr" PATH="$PATH_TRY
sed -i '2s|.*|'"$addr"'|' "$PATH_TRY"
