#Url of my repository
myGit="https://github.com/lp177/42.git"
#Command sh execute previous the push
previousSync="cp ~/.zshrc ~/ExtSync/;cp ~/.vimrc ~/ExtSync/;git add -f .vimrc .zshrc"

#Dir wanted for Sync
dirSync="Sync"
#Dir target for temporary storage
tmpSync="ExtSync"

mkdir ~/$dirSync ~/$tmpSync &> /dev/null
cd ~/$tmpSync
git init &> /dev/null && git remote add origin $myGit &> /dev/null
cd -
alias Sync177="cd ~/$tmpSync;diff -qr ~/$dirSync ~/$tmpSync | grep 'Only.*$tmpSync' | sed 's/Only.*$tmpSync: //' | sed '/.git/d' | xargs git rm -rf --ignore-unmatch;rsync -r ~/$dirSync/* --delete ~/$tmpSync;find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf;find */ -name .git | sed 's/\/\//\//' | xargs rm -rf;$previousSync;git add ./*;git commit -am 'Update `date`';git push origin master;cd -"
alias gitSync="Sync177;Sync177"