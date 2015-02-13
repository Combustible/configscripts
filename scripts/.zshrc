# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

setopt appendhistory extendedglob nomatch
unsetopt autocd beep notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/bmarohn/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

export PATH=~/bin:$PATH

umask 027

# Fix home, end keys
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
#bindkey "e[5~" beginning-of-history
#bindkey "e[6~" end-of-history
#bindkey "e[3~" delete-char
#bindkey "e[2~" quoted-insert
#bindkey "e[5C" forward-word
#bindkey "eOc" emacs-forward-word
#bindkey "e[5D" backward-word
#bindkey "eOd" emacs-backward-word
#bindkey "ee[C" forward-word
#bindkey "ee[D" backward-word
#bindkey "^H" backward-delete-word

export PATH=~/bin:$PATH


alias mv='mv -i'
alias tree='tree --charset=X'
alias less='/usr/share/vim/vim74/macros/less.sh'
alias wine32='WINEARCH=win32 WINEPREFIX=~/.wine32 wine'
alias winecfg32='WINEARCH=win32 WINEPREFIX=~/.wine32 winecfg'
alias winetricks32='WINEARCH=win32 WINEPREFIX=~/.wine32 winetricks'
alias astyle='astyle --style=linux --indent=tab=8 --convert-tabs --indent-preprocessor --min-conditional-indent=3 --max-instatement-indent=40 --pad-oper --unpad-paren --pad-header --align-pointer=name --indent-namespaces'
alias scite='SciTE'

fixwhitespace() {
    sed -i -e's|[ \t]*\([\r\n]*\)$|\1|g' "$1"
}

# Scanner macros
scs() (
	if [[ ! "$1" == "" ]]; then
		mkdir -p "$1" && cd "$1"
	fi
	scanimage -d epkowa --mode Color --depth 8 --resolution 300 --scan-area Maximum --adf-mode Simplex --adf-auto-scan=yes --format=tiff --batch="scan%d.tiff" --batch-start=$( echo $(( 100 + `cat ~/.local/last_scan` )) | tee ~/.local/last_scan )
	if [[ ! "$1" == "" ]]; then
		cd ..
	fi
)
scd() (
	if [[ ! "$1" == "" ]]; then
		mkdir -p "$1" && cd "$1"
	fi
	scanimage -d epkowa --mode Color --depth 8 --resolution 300 --scan-area Maximum --adf-mode Duplex --adf-auto-scan=yes --format=tiff --batch="scan%d.tiff" --batch-start=$( echo $(( 100 + `cat ~/.local/last_scan` )) | tee ~/.local/last_scan )
	if [[ ! "$1" == "" ]]; then
		cd ..
	fi
)
sgs() (
	if [[ ! "$1" == "" ]]; then
		mkdir -p "$1" && cd "$1"
	fi
	scanimage -d epkowa --mode Gray --depth 8 --resolution 300 --scan-area Maximum --adf-mode Simplex --adf-auto-scan=yes --format=tiff --batch="scan%d.tiff" --batch-start=$( echo $(( 100 + `cat ~/.local/last_scan` )) | tee ~/.local/last_scan )
	if [[ ! "$1" == "" ]]; then
		cd ..
	fi
)
sgd() (
	if [[ ! "$1" == "" ]]; then
		mkdir -p "$1" && cd "$1"
	fi
	scanimage -d epkowa --mode Gray --depth 8 --resolution 300 --scan-area Maximum --adf-mode Duplex --adf-auto-scan=yes --format=tiff --batch="scan%d.tiff" --batch-start=$( echo $(( 100 + `cat ~/.local/last_scan` )) | tee ~/.local/last_scan )
	if [[ ! "$1" == "" ]]; then
		cd ..
	fi
)


old_aliases() {
	alias vncdock='vncserver -localhost -geometry 1900x1140'
	alias vnclaptop='vncserver -localhost -geometry 1920x1020'
	alias vncroot='x11vnc -xkb -noxrecord -noxfixes -noxdamage -localhost -display :0 -auth /var/run/lightdm/root/:0 -forever -bg -o /var/log/x11vnc.log'
	alias wakelaptop='wakeonlan 00:1c:25:b8:f6:5b'
	alias vnclaptop='vncviewer 192.168.0.3'
	alias steam='WINEPREFIX=~/.wine-steam WINEARCH=win32 wine "C:\\Program Files\\Steam\\Steam.exe" -no-dwrite'
	alias steam-giana='WINEPREFIX=~/.wine-giana WINEARCHCRAP=win32 wine "C:\\Program Files (x86)\\Steam\\Steam.exe" -no-dwrite'
	alias wine-diablo3='WINEPREFIX=~/.wine-diablo3 wine'
	alias winecfg-diablo3='WINEPREFIX=~/.wine-diablo3 winecfg'
	alias wine-d2-1='WINEPREFIX=~/.wine-d2-1 WINEARCH=win32 wine'
	alias d2-1='WINEPREFIX=~/.wine-d2-1 WINEARCH=win32 wine "C:\\Program Files\\Diablo II\\Game.exe" -w &>/dev/null &'
}


