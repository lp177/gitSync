#Url of my repository
myGit="https://github.com/myID/Mygit.git"

#Dir wanted for Sync
dirSync="Sync"
#Dir target for temporary storage
tmpSync="ExtSync"
#Command sh execute previous the push
previousSync="cp ~/.zshrc ~/$tmpSync/;cp ~/.vimrc ~/$tmpSync/;git add -f .vimrc .zshrc"

mkdir ~/$dirSync ~/$tmpSync &> /dev/null
cd ~/$tmpSync
git init &> /dev/null && git remote add origin $myGit &> /dev/null
cd -
alias Sync177="cd ~/$tmpSync;diff -qr ~/$dirSync ~/$tmpSync | grep 'Only.*$tmpSync' | sed 's/Only.*$tmpSync: //' | sed '/.git/d' | xargs git rm -rf --ignore-unmatch;rsync -r ~/$dirSync/* --delete ~/$tmpSync;find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf;find */ -name .git | sed 's/\/\//\//' | xargs rm -rf;$previousSync;git add ./*;git commit -am 'Update `date`';git push origin master;cd -"
alias gitSync="Sync177;Sync177"

#Any problem with a ***lovely merge requiered and other infamous?
#Go Raz repo and gitSync with this alias:
alias gitReset="cd ~/$tmpSync;git pull;git pull origin master;git pull;git commit -am \"reset\";git push origin master;git rm -rf *;rm -rf *;git push origin master;cd -;gitSync"
#Git reset is the power to impose the respect of your repository at the scope of all, use this warm with abuse
