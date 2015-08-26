read -p "pseudo:" -r
echo

$try_path="$HOME/.gitSync/gitSync.sh"
if [ ! -f $try_path ]; then
	$try_path="./gitSync.sh"
	if [ ! -f $try_path ]; then
		read -p "Location of gitSync:" -r
		echo
		$try_path = $REPLY
	fi
fi

if [ -f $try_path ]
then
	read -p "Git pseudo:" -r
	echo
	$addr="myGit=\"https://github.com/\""
	$addr=$addr$REPLY"/"
	read -p "Git repository name for sync:"
	echo
	$addr=$REPLY".git"
	sed -i "0s/.*/$addr/" $try_path
