gitSync
=======

Sync a dir with many git project in alone repository in one commande

Paste that in shell for a simply installation:

```
echo "#Url of my repository\n\
myGit=\"https://github.com/myID/Mygit.git\"" > ~/gitSync.sh
curl https://raw.githubusercontent.com/lp177/gitSync/master/gitSync.sh >> ~/gitSync.sh
echo "\nsource ~/gitSync.sh" >> ~/.zshrc
sh ~/gitSync.sh
```
