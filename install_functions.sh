function backup {
    local file="$1"
    if [[ -L "$file" ]]; then
        rm "$file"
    elif [[ -e "$file" ]]; then
        mv "$file" "$file.bak"
    fi
}

function link_with_backup {
    local filename="$1"
    local source="$DOTFILES/$filename"
    local target="$HOME/$filename"
    backup "$target"
    ln -s "$source" "$target"
}

# SSH autocomplete depends on ~/.ssh/config and known_hosts existing
function create_ssh_config {
    mkdir -p "$HOME/.ssh"
    for file in config known_hosts; do
        if [ ! -e "$HOME/.ssh/$file" ]; then
            touch "$HOME/.ssh/$file"
        fi
    done
}

function install_leiningen {
    (
		if ! type -p java >/dev/null 2>&1; then
			echo "Error installing leiningen: java not present!"
		else
			mkdir -p $HOME/.lein
			TARGET="$HOME/.lein/lein"
			LEIN_SCRIPT_URL="https://raw.github.com/technomancy/leiningen/stable/bin/lein"
			HTTP_CLIENT=""
		
			if ! type -p wget >/dev/null 2>&1; then
				if ! type -p curl >/dev/null 2>&1; then
					echo "Has NOT curl"
				else
					echo "Has curl"
					HTTP_CLIENT="curl -f -L -o"
				fi
			else
				echo "WGET found!"
				HTTP_CLIENT="wget -O"
			fi

			if [ "$HTTP_CLIENT" = "" ]; then
				echo "Error installing leiningen: Neither wget nor curl found"
			else
				$HTTP_CLIENT "$TARGET" "$LEIN_SCRIPT_URL"
			fi
		fi
    )
}

function unset_git_user {
    for var in user.name user.email user.initials; do
        if ( git config --list --global | grep "$var" &> /dev/null ); then
            git config --global --unset "$var"
        fi
    done
}
