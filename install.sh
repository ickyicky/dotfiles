#! /bin/bash
#

# settings
FONT="SourceCodePro"

# links 
VUNDLE_REPO="https://github.com/VundleVim/Vundle.vim.git"
ZSH_SYNTAX_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
NERD_FONT_REPO="https://github.com/ryanoasis/nerd-fonts.git"
BREW_SCRIPT_LINK="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"

# lookup for distro info
DISTRO=`awk -F "=| " '/ID_LIKE/ {print toupper($2)}' /etc/*-release | awk '{print $1}' | sed 's/"//g' | head --lines 1`

# sometimes this can fail, but anyway we can always count on lsb_release
if [[ -z "$DISTRO" ]]
then
	DISTRO=`lsb_release -a | awk '/Description/ {print toupper($2)}'`
fi
# just for MACOS
if [[ -z "$DISTRO" ]]
then
	DISTRO=`sw_vers | awk '/Mac/ {print toupper($2)}'`
fi
echo "Recognized distro: ${DISTRO}"
# current user
CURRENT_USER=${USER}

# prepare directories
for SOURCE in `find * -mindepth 1 -type d -not -path ".*/.*/*"`
do
        DESTINATION=~/.`echo "${SOURCE}" | cut -d "/" -f "2-"`
        mkdir -p ${DESTINATION}
done

# copy dotfiles
for SOURCE in `find * -mindepth 1 -type f -not -path ".*/.*/*"`
do
        DESTINATION=~/.`echo "${SOURCE}" | cut -d "/" -f "2-"`
        cp -f ${SOURCE} ${DESTINATION}
done

# distro dependent things
if [[ "$DISTRO" == "MAC" ]]
then
	PKGMAN="brew install"
	ADDITIONAL_PACKAGES="homebrew/cask/iterm2
	macvim"
	# if not present, install brew
	brew --help || /bin/bash -c "$(curl -fsSL ${BREW_SCRIPT_LINK})"
elif [[ "$DISTRO" == "MANJARO" ]] || [[ "$DISTRO" == "ARCH" ]]
then
	PKGMAN="sudo pacman -S --noconfirm"
	ADDITIONAL_PACKAGES="gvim"
elif [[ "$DISTRO" == "CENTOS" ]] || [[ "$DISTRO" == "FEDORA" ]] || [[ "${DISTRO}" == "RHEL" ]]
then
	PKGMAN="sudo yum install -y"
elif [[ "$DISTRO" == "DEBIAN" ]] || [[ "$DISTRO" == "UBUNTU" ]]
then
	PKGMAN="sudo apt-get install -y"
else
	echo "${DISTRO} not supported"
	exit 1
fi

# repos list
PACKAGES="${ADDITIONAL_PACKAGES}
python3
git
zsh
"

# install packages
for PACKAGE in ${PACKAGES}
do
	echo "Installing ${PACKAGE}..."
	${PKGMAN} ${PACKAGE} > /dev/null
done

# create cache for zsh
mkdir -p ~/.cache ~/.cache/zsh

# install zsh syntax
echo "Installing zsh syntax highlighting..."
git clone ${ZSH_SYNTAX_REPO} temp > /dev/null 
cd temp
sudo make install > /dev/null 
cd ..
rm -rf temp


# set zsh as default shell, sometimes (on CentOS 8 theres no chsh) so we need to run usermod instead
echo "Setting zsh as default shell..."
ZSH_PATH=`which zsh`
chsh -s ${ZSH_PATH} || sudo usermod --shell ${ZSH_PATH} ${CURRENT_USER}

# clone vundle vim plugin and install all plugins
echo "Installing Vundle"
git clone ${VUNDLE_REPO} ~/.vim/bundle/Vundle.vim 2>/dev/null
vim -c PluginInstall q

# install nerd font, best way, but SOO inefficient... it downloads 6 gb...
echo "Installing nerd font..."
git clone ${NERD_FONT_REPO} temp > /dev/null 
cd temp
./install.sh ${FONT} > /dev/null 
cd ..
rm -rf temp
