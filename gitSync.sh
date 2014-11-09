#Don't forget to Up this Url with yours
myGit="https://github.com/myID/MygitRepo.git"
previousSync="cp ~/.zshrc ~/ExtSync/;cp ~/.vimrc ~/ExtSync/;git add -f .vimrc .zshrc"

mkdir ~/Sync ~/ExtSync &> /dev/null
cd ~/ExtSync
git init &> /dev/null && git remote add origin $myGit &> /dev/null
cd -
alias Sync177="cd ~/ExtSync;diff -qr ~/Sync ~/ExtSync | grep 'Only.*ExtSync' | sed 's/Only.*ExtSync: //' | sed '/.git/d' | xargs git rm -rf --ignore-unmatch;rsync -r ~/Sync/* --delete ~/ExtSync;find */ -name .git | sed 's/\/\//\//' | xargs git rm -rf;find */ -name .git | sed 's/\/\//\//' | xargs rm -rf;$previousSync;git add ./*;git commit -am 'Update `date`';git push origin master;cd -"
alias gitSync="Sync177;Sync177"
