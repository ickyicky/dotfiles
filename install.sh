#! /bin/bash
#

# links 
VUNDLE_REPO="https://github.com/VundleVim/Vundle.vim.git"
ZSH_SYNTAX_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
BREW_SCRIPT_LINK="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"

# lookup for distro info
DISTRO=`awk '!/=/ {print toupper($1)}' /etc/*-release | head --lines 1`
if [[ -z "$DISTRO" ]]
then
	DISTRO=`lsb_release -a | awk '/Description/ {print toupper($2)}'`
fi

# current user
CURRENT_USER=${USER}

# copy dotfiles
for SOURCE in `find * -mindepth 1 -maxdepth 1 -not -path ".*/.*/*"`
do
        DESTINATION=~/.`echo "${SOURCE}" | cut -d "/" -f "2-"`
        
	if [ -d ${SOURCE} ]
	then
		DESTINATION=${DESTINATION}/
		SOURCE=${SOURCE}/
	fi

        cp -Rf ${SOURCE} ${DESTINATION}
done

# distro dependent things
if [[ "$DISTRO" == "MACOS" ]]
then
	PKGMAN="brew install"
	ADDITIONAL_PACKAGES="homebrew/cask/iterm2"
	# if not present, install brew
	brew --help || /bin/bash -c "$(curl -fsSL ${BREW_SCRIPT_LINK})"
elif [[ "$DISTRO" == "MANJARO" ]] || [[ "$DISTRO" == "ARCH" ]]
then
	PKGMAN="sudo pacman -S --noconfirm"
elif [[ "$DISTRO" == "CENTOS" ]] || [[ "$DISTRO" == "FEDORA" ]]
then
	PKGMAN="sudo yum install -y"
elif [[ "$DISTRO" == "DEBIAN" ]] || [[ "$DISTRO" == "UBUNTU" ]]
then
	PKGMAN="sudo apt-get install -y"
	# also add python-neovim if you're planning on editing py2 code
	ADDITIONAL_PACKAGES="python3-neovim"
else
	echo "Could not determine distribution. Result: ${DISTRO}"
	exit 1
fi

# repos list
PACKAGES="${ADDITIONAL_PACKAGES}
python3
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
mkdir -p ~/.cache ~/.cache/zsh ~/.config

# install zsh syntax
git clone ${ZSH_SYNTAX_REPO} temp
cd temp
sudo make install
cd ..
rm -rf temp

# set zsh as default shell, sometimes (on CentOS 8 theres no chsh) so we need to run usermod instead
ZSH_PATH=`which zsh`
chsh -s ${ZSH_PATH} || sudo usermod --shell ${ZSH_PATH} ${CURRENT_USER}

# clone vundle vim plugin and install all plugins
git clone ${VUNDLE_REPO} ~/.vim/bundle/Vundle.vim
vim -c PluginInstall q
