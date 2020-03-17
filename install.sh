#! /bin/bash
#

# links 
VUNDLE_REPO="https://github.com/VundleVim/Vundle.vim.git"
ZSH_SYNTAX_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"

# lookup for distro info
DISTRO=`awk '!/=/ {print toupper($1)}' /etc/*-release | head --lines 1 || (sw_vers -productVersion && echo "MACOS")`

if [ "$DISTRO" == "MACOS" ]
then
	PKGMAN="brew install"
elif [ "$DISTRO" == "MANJARO" ]
then
	PKGMAN="sudo pacman -S --noconfirm"
elif [ "$DISTRO" == "CENTOS" ]
then
	PKGMAN="sudo yum install --yes"
else
	echo "Could not determine distribution."
	exit 1
fi

# repos list
PACKAGES="python3
git
neovim
zsh
"

# install packages
for PACKAGE in ${PACKAGES}
do
	${PKGMAN} ${PACKAGE}
done

# create cache for zsh and config direcotry (if not present)
mkdir -f ~/.cache ~/.cache/zsh ~/.config

# install zsh syntax
git clone ${ZSH_SYNTAX_REPO} temp
cd temp
sudo make install
cd ..
rm -rf temp

# copy configfiles
for SOURCE in `find * -mindepth 1 -maxdepth 1 -not -path ".*/.*/*"`
do
	DESTINATION=~/.`echo "${SOURCE}" | cut -d "/" -f "2-"`
	cp ${SOURCE} ${DESTINATION} -rf
done

# clone vundle vim plugin and install all plugins
git clone ${VUNDLE_REPO} ~/.vim/bundle/Vundle.vim
vim -c PluginInstall q
