#Why use gitSync ?
#=================

 - Switch to your configuration and native conf in all device equiped to internet and shell access in 2s:
 - copy/paste install cmd, enter gitTake for get your config and gitClean for reinitialise all same at start.  

 - Sync a dir with many git projects and all yours scattered config files/folders in one repository in one commande "gitSync".


##Installation:

```
git clone https://github.com/lp177/gitSync.git ~/.gitSync
echo "\nsource ~/.gitSync/gitSync.sh" >> ~/.zshrc
source ~/.zshrc

```

Edit the value of myGit variable in the new ~/.gitSync/gitSync.sh file with your repository address.


##CMD

### gitSync

Synchronize your Sync folder indicate with $dirSync with the repository $myGit.
Previous this sync all path in $favorites are sync in $dirSync for go push with your projects.

### gitSyncAuto

Do a gitSync all the $interval_auto_sync seconde(s)

### gitSyncTake

Repatriate your $myGit repo in $dirSync and purpose you to infect this current device with your $favorites conf

### gitSyncClean

Reinitialise the previous conf delete your ssh git key, $dirSync, and finaly all traces.

### gitSyncUninstall

Uninstall gitSync and purpose you to rm work folders
