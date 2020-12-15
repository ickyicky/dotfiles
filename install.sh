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
DISTRO=`awk -F "=| " '/ID/ {print toupper($2)}' /etc/*-release | awk '{print $1}' | sed 's/"//g' | head --lines 1`

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

echo "Dotfiles copied, would you also like to install depending packages? (y/n)"
read RESPONSE

if [[ "$RESPONSE" == "Y" ]] || [[ "$RESPONSE" == "y" ]]
then
	# distro dependent stuff like additional packages, pkg manager
	if [[ "$DISTRO" == "MAC" ]]
	then
		PKGMAN="brew install"
		ADDITIONAL_PACKAGES="macvim"
		# if not present, install brew
		brew --help || /bin/bash -c "$(curl -fsSL ${BREW_SCRIPT_LINK})"
	elif [[ "$DISTRO" == "MANJARO" ]] || [[ "$DISTRO" == "ARCH" ]] || [[ "$DISTRO" == "MANJAROLINUX" ]]
	then
		PKGMAN="sudo pacman -S --noconfirm"
		ADDITIONAL_PACKAGES="xclip
		gconf
		base-devel"
	elif [[ "$DISTRO" == "CENTOS" ]] || [[ "$DISTRO" == "FEDORA" ]] || [[ "${DISTRO}" == "RHEL" ]]
	then
		PKGMAN="sudo yum install -y"
		ADDITIONAL_PACKAGES="python3-neovim"
	elif [[ "$DISTRO" == "DEBIAN" ]] || [[ "$DISTRO" == "UBUNTU" ]]
	then
		PKGMAN="sudo apt-get install -y"
	else
		echo "${DISTRO} not recognized, specify package manager yourself:"
		read PKGMAN
	fi
	
	# repos list
	PACKAGES="${ADDITIONAL_PACKAGES}
	neovim
	python3
	git
	zsh
	exa
	cmake
	neofetch
	"
	
	PIP_PACKAGES="pynvim
	black
	ipython"
	
	# install packages
	for PACKAGE in ${PACKAGES}
	do
		echo "Installing ${PACKAGE}..."
		${PKGMAN} ${PACKAGE}
	done
	
	# install pip packages
	for PACKAGE in ${PIP_PACKAGES}
	do
		echo "Installing ${PACKAGE}..."
<<<<<<< HEAD
		sudo pip3 install ${PACKAGE} > /dev/null
=======
		sudo pip3 install ${PACKAGE}
>>>>>>> 1df26df1b4cd2a97ede0ab0f94864953fc602b6d
	done
fi

# create cache for zsh
mkdir -p ~/.cache ~/.cache/zsh

echo "Install zsh syntax highlighting? (y/n)"
read RESPONSE

if [[ "$RESPONSE" == "Y" ]] || [[ "$RESPONSE" == "y" ]]
then
	# install zsh syntax
	echo "Installing zsh syntax highlighting..."
	git clone ${ZSH_SYNTAX_REPO} temp > /dev/null 
	cd temp
	sudo make install > /dev/null 
	cd ..
	rm -rf temp
fi


echo "Set zsh as default shell? (y/n)"
read RESPONSE

if [[ "$RESPONSE" == "Y" ]] || [[ "$RESPONSE" == "y" ]]
then
	# set zsh as default shell, sometimes (on CentOS 8 theres no chsh) so we need to run usermod instead
	echo "Setting zsh as default shell..."
	ZSH_PATH=`which zsh`
	chsh -s ${ZSH_PATH} || sudo usermod --shell ${ZSH_PATH} ${CURRENT_USER} || echo "Setting zsh as default shell failed, do it yourself kiddo"
fi


echo "Install Vundle? (y/n)"
read RESPONSE

if [[ "$RESPONSE" == "Y" ]] || [[ "$RESPONSE" == "y" ]]
then
	# clone vundle vim plugin and install all plugins
	echo "Installing Vundle"
	git clone ${VUNDLE_REPO} ~/.vim/bundle/Vundle.vim 2>/dev/null
	nvim -c PluginInstall q
	# install ymcd
	~/.vim/bundle/YouCompleteMe/install.py
fi

echo "Install nerd font (it takes a while...)? (y/n)"
read RESPONSE

if [[ "$RESPONSE" == "Y" ]] || [[ "$RESPONSE" == "y" ]]
then
	# install nerd font, best way, but SOO inefficient... it downloads 6 gb...
	echo "Installing nerd font..."
	git clone ${NERD_FONT_REPO} temp > /dev/null 
	cd temp
	./install.sh ${FONT} > /dev/null 
	cd ..
	rm -rf temp
fi

# create Projects directories
mkdir -p ~/Projects/Personal ~/Projects/Work ~/Projects/Studies
echo "Success!"

echo "Install gnome-terminal theme(requires cerating one custom profile before)? (y/n)"
read RESPONSE

if [[ "$RESPONSE" == "Y" ]] || [[ "$RESPONSE" == "y" ]]
then
	git clone https://github.com/aaron-williamson/base16-gnome-terminal.git ~/.config/base16-gnome-terminal
	export GCONFTOOL="gconftool-2"
	echo "Apply gnome terminal afterwards from settings-profiles"
	source ~/.config/base16-gnome-terminal/color-scripts/base16-ocean-256.sh
fi
