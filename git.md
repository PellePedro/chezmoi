# Git 

To sign Git commits from the command line, you typically use GPG, but newer Git versions also support SSH keys and age (via age-plugin-yubikey). Here’s how to do it using SSH and age:


✅ Process 

1.	Tell Git to use SSH for signing:

git config --global gpg.format ssh


2.	Register your SSH key with Git:

git config --global user.signingkey "$(ssh-add -L | head -n 1)"


3.	Enable commit signing:

git config --global commit.gpgsign true


4.	Verify signing works:

git commit -S -m "signed with SSH key"


