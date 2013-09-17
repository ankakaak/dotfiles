# Terminal colors
        RED="\[\033[0;31m\]"
     ORANGE="\[\033[0;33m\]"
     YELLOW="\[\033[0;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[0;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 COLOR_NONE="\[\e[0m\]"
 
 
 # Basic environment
 export TERM=xterm-256color
 export PS1="${LIGHT_GREEN}\h:\W \$${COLOR_NONE} "
 export EDITOR=/usr/bin/nano

 # My path
 if [[ -e "$HOME/.path" ]]; then
     path=""
     while read -r; do
         if [[ ! -z "$path" ]]; then path="$path:"; fi
         path="$path$REPLY"
     done < "$HOME/.path"
     export PATH="$path"
 fi
 
 # Local system stuff
 if [ -e ~/.bash_local ]; then
     source ~/.bash_local
 fi
 

 if [ -e /Applications/TrueCrypt.app/Contents/MacOS/TrueCrypt ]; then
     alias truecrypt="/Applications/TrueCrypt.app/Contents/MacOS/TrueCrypt -t"
 fi

########################
# Bash history tweaks
########################

#Thanks to https://github.com/runarmyklebust/bashstuff

# Set larger history
HISTSIZE=9000
HISTFILESIZE=$HISTSIZE

# Ignore duplicates and commands with leading spaces
HISTCONTROL=ignorespace:ignoredups

# Appended to the histfile instead of overwriting on exit
shopt -s histappend

#history() {
#  _bash_history_sync
#  builtin history "$@"
#}

_bash_history_sync() {
  # Append this session to history
  builtin history -a
  HISTFILESIZE=$HISTSIZE     
}

export PROMPT_COMMAND="_bash_history_sync; $PROMPT_COMMAND"


# ACOC Stuff
# Config i ~/.acoc.conf
#
# PS: acoc i ~/bin brukes, dette er en modifisert utgave som støtter DYNAVAL
#
# Legges i toppen siden aliase's med acoc bør gjøres før senere aliase'r for de samme kommandoene ...?
# Installation (pre-requisite is Ruby):
#	1. Download acoc (http://www.caliban.org/ruby/acoc.shtml) and unpack into ~/bin/acoc-0.7.1
#	2. Install Term::ANSIColor: (gem install term-ansicolor FUNKET IKKE, ikke på Mac'n ihvertfall)
#		a) download from http://raa.ruby-lang.org/project/ansicolor/
#		b) untar and run from dir: ruby install.rb
# 	3. Install Masahiro Tomita's Ruby/TPty library (recommeneded, but not required):
#		a) download from http://raa.ruby-lang.org/project/ruby-tpty/
#		b) untar and run from dir: ruby extconf.rb && make install
#	4. Install from ~/bin/acoc-0.7.1: make install
#		a) legges til /usr/local/bin/acoc
#		b) hvis den ikke bruker default Ruby versjon (f.eks /usr/bin/ruby), endre #! i toppen av scriptet (eks fra /usr/bin/ruby til /usr/local/bin/ruby)
#
# if acoc found as command in path, make these aliases
if [ $(type -t acoc) ];then
	echo "Aliasing with acoc..."
	alias ping="acoc ping -c 5"
	alias df="acoc df"
	alias traceroute="acoc traceroute"
    alias svn="acoc svn"
    alias mvn="acoc mvn"
	alias curl="acoc curl"
    # gnu diff options:
    #   -w (--ignore-all-space)
    #   -u NUM (output NUM lines of unified context - default is 3)
    alias diff="acoc diff -uw"
    # Brukes for å tail'e log4j logger med acoc fargelegging
    #alias med acoc, spesifiseres vha \less)
    # Kan ikke lage en funksjon med navn less, siden alias'et overstyrer funksjonen
    # Løsningen er å gjøre det manuelt: less fil.log | \less
    alias less='acoc less'
    alias cat='acoc cat'
    #alias acoc-refresh="cp -f $(cygpath --unix $CYGWIN_USERHOME_SRC)/.acoc.conf ~/"

    function colorString() {
        usage="Usage: colorString [-c acoc_color] string..."
        # Håndter -c opsjonen for å angi acoc farge
        if [ "$1" == -c ]; then
            export DYNAVAL_COL=${2:?$usage}
            shift 2
        fi

        arg1=${1:?$usage}
        export DYNAVAL=$@
        #echo DYNAVAL=$DYNAVAL
        acoc echo ${DYNAVAL}
        # remove var to avoid trouble
        unset DYNAVAL DYNAVAL_COL
    }
    function colorMe() {
        arg1=${1:?Må spesifisere en string som skal fargelegges}
        export DYNAVAL="$@"
        acoc echo "Stringen ${DYNAVAL} vil fargelegges i all kommando-output i ditt nye shell"
        acoc bash --login -i
        unset DYNAVAL
    }
else
    # Define acoc functions so everything works when acoc is not installed
    function colorString() {
        if [ "$1" == -c ]; then
            shift 2
        fi
        echo $@
    }
fi


# Aliases
if [[ "$(uname)" == "Darwin" ]]; then
    alias l="ls -FG"
    alias ls="ls -FG"
    alias la="ls -ahFG"
    alias ll="ls -lahFG"
    alias d="pwd && echo && ls -FG"
else
    alias l="ls --color -F"
    alias ls="ls --color -F"
    alias la="ls --color -ahF"
    alias ll="ls --color -lahF"
    alias d="pwd && echo && ls --color -F"
fi

alias rm='rm -i'

alias beep="echo -e '\a'"

alias reload="colorString -c green sourcing .bashrc && source ~/.bashrc"


#Teh up function
up() {
	LIMIT=$1

	if [ -z "$LIMIT" ]; then
		LIMIT=1
	fi

	SEARCHPATH=$PWD

	# If argument is not numeric, try match path
	if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] ; then
	 	if ! [[ "$SEARCHPATH" =~ ^.*$LIMIT.*$ ]] ; then
			echo "expression not found"
		else
			while [ true ]; do 
				SEARCHPATH=$SEARCHPATH/..
				cd $SEARCHPATH
				if [[ ${PWD##*/} =~ ^.*$LIMIT.*$ ]]; then
					break;
				elif [[ -z ${PWD##*/} ]]; then
					break;
				fi 
			done
		fi
	else 
		# go n directories up
		for ((i=1; i <= LIMIT; i++))
			do
				SEARCHPATH=$SEARCHPATH/..
			done
		cd $SEARCHPATH
	fi
}


# Re-acquire forwarded SSH key
# from http://tychoish.com/rhizome/9-awesome-ssh-tricks/
function ssh-reagent {
    for agent in /tmp/ssh-*/agent.*; do
        export SSH_AUTH_SOCK=$agent
        if ssh-add -l 2>&1 > /dev/null; then
            echo Found working SSH Agent:
            ssh-add -l
            return
        fi
    done
    echo Cannot find ssh agent - maybe you should reconnect and forward it?
}

#  colors
#export CLICOLOR=true
#export LSCOLORS=${LSCOLORS:-ExFxCxDxBxegedabagacad}
#export CLICOLOR=1
#export LSCOLORS=GxFxCxDxBxegedabagaced


