PATH_TRY="$HOME/.gitSync/gitSync.sh"
if [ ! -f $PATH_TRY ]; then
	PATH_TRY="gitSync.sh"
	if [ ! -f $PATH_TRY ]; then
		read -p "Location of gitSync:" -r
		echo
		PATH_TRY = $REPLY
	fi
fi

if [ -f $PATH_TRY ]
then
	read -p "Git pseudo:" -r
	echo
	addr="myGit='https://github.com/"
	addr=$addr$REPLY"/"
	read -p "Git repository name for sync:"
	echo
	addr=$REPLY".git'"
	sed -i "0s|.*|$addr|" $PATH_TRY
fi
