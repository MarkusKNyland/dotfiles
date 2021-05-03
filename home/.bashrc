# miscellaneous aliases
if [ -f $HOME/.misc_aliases ]; then
    . $HOME/.misc_aliases
fi

# include git aliases if file exists
if [ -f $HOME/.git_aliases ]; then
    . $HOME/.git_aliases
fi

# include maven aliases if file exists
if [ -f $HOME/.mvn_aliases ]; then
    . $HOME/.mvn_aliases
fi

# include directory aliases if file exists
if [ -f $HOME/.directory_aliases ]; then
    . $HOME/.directory_aliases
fi 

function commit {
	IFS='/';
	read -r -a array <<< $(git rev-parse --abbrev-ref HEAD);
	unset IFS;
	git commit -m "${array[1]}: $1";
}

function readXml {
    IFS=$'\n'
    ARRAY=($(xml sel -t -m "result/distributionAgreementRoleListDetails" -c "." -n $1 | tr -d '\040\011' | awk '{printf "%s",$0} $0~"</distributionAgreementRoleListDetails>" {print}'))
	unset IFS;

    for MATCH in "${ARRAY[@]}"; do
      echo "$MATCH";
    done | sort | uniq -d;
}

function inst {
	mvn clean install -DskipTests -U;
}

function compnogen {
	schema="${PWD##*/}-schemas/";
	mvn clean test-compile -pl "!${schema}";
}

function testnogen {
	schema="${PWD##*/}-schemas/";
	mvn clean test -pl "!${schema}";
}

function instnogen {
	schema="${PWD##*/}-schemas/";
	mvn clean install -pl "!${schema}" -DskipTests;
}

function instforjetty {
	basepath="${PWD##*/}";
	schema="${basepath}-schemas/";
	ws="${basepath}-ws/";
	dist="${basepath}-dist/";
	soapui="${basepath}-soapui/";
	mvn clean install -pl "!$schema, !$ws, !$dist, !$soapui" -DskipTests;
}

function pushash {
	IFS='/';
	read -r -a array <<< $(git rev-parse --abbrev-ref HEAD@{u});
	unset IFS;
	git push "${array[0]}" $(git rev-parse HEAD~${1-0}):"${array[1]}/${array[2]}";
}

function getDpGenVersion {
	local rsaIdPath="/c/Users/E217514/Documents/Evry-Work/ssh-keys/id_rsa"
	local latestVersion=$(ssh -i ${rsaIdPath} e217514@alp-eos-app11.man.cosng.net 'cd ../../eos/p1/corews-dp-gen/i1/releases; ls -v | tail -n 1');
	echo ${latestVersion};
}

function getDomainVersion {
	if [ -z $1 ]; then
		echo "Please provide some input to search after. E.g eul-srv" >/dev/stderr
		return 1
	fi
	local latestDpGenTag=corews-dp-gen-$(getDpGenVersion);
	git clone --depth 1 --branch ${latestDpGenTag} https://fsstash.evry.com/scm/enterprise_core-ws-dpkgs/corews-dp-gen.git >/dev/null && \
	cd corews-dp-gen/ && \
	cat pom.xml | grep $1 | awk '{$1=$1};1' && \
	cd ../ && \
	rm -rf corews-dp-gen/
}

function prodSearch {
	export DP_PACKAGE=$(echo $1 | tr '[:upper:]' '[:lower:]');
	export SUB_SYSTEM=$(echo $2 | tr '[:lower:]' '[:upper:]');
	export DATE=$3;
	export TIME=$4;
	export SEARCH_STRING=$5;
	
	# Required local config
	export USER_ID='e217514'
	export SAVE_LOCATION='C:\Users\E217514\Documents\TrashBin'
	export SSH_KEY_LOCATION='/c/Users/E217514/Documents/Evry-Work/ssh-keys/id_rsa'

	bash /c/Users/E217514/Documents/Evry-Work/Repositories/corews-utility-scripts/prodSearch.sh;
}

eval "$(ssh-agent)" >/dev/null
function cwsSearch {
	# Required local config
	export USER_ID='e217514'
	export SAVE_LOCATION='/c/Users/E217514/Documents/TrashBin'
	export SSH_KEY_LOCATION='/c/Users/E217514/Documents/Evry-Work/ssh-keys/id_rsa'

	bash /c/Users/E217514/Documents/Evry-Work/Repositories/corews-utility-scripts/cwsSearch.sh "$@"
}

function journal {
	# Required local config
	export SAVE_LOCATION='/c/Users/E217514/Documents/Evry-Work/Misc/journal'
	
	bash /c/Users/E217514/Documents/journal-tui/journal-tui.sh
}

function testSearch {
	export ENDPOINT=$1
	export SUB_SYSTEM=$(echo $2 | tr '[:lower:]' '[:upper:]')
	export DATE=$3
	export TIME=$4
	export SEARCH_STRING=$5
	
	# Required local config
	export USER_ID='e217514'
	export SAVE_LOCATION='C:\Users\E217514\Documents\TrashBin'
	export SSH_KEY_LOCATION='/c/Users/E217514/Documents/Evry-Work/ssh-keys/test_id_rsa'
	
	bash ~/scripts/testSearch.sh
}

function stgParser {
	export STG_STRING=$1

	bash /c/Users/E217514/Documents/Evry-Work/Repositories/corews-utility-scripts/stgParser.sh;
}

# Finds each soap:Envelope, formats it and shows it with bat. Input is either a file or stdin 
# Lets break it down:
# First "${1:-/dev/stdin}" is evaluated and redirected as input to grep. (get first parameter if exists or read from stdin)
# Then grep for soap:envelopes with the --only-matching flag set, aka print only the matched part of a matched line
# Then read each line from grep and do magic with xmllint and bat
viewSoapEnvelopes() {
	grep -o '<soap:Envelope.*' < "${1:-/dev/stdin}" | while read line; do
		echo "$line" | xmllint --format - | bat -l xml
	done
}

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

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


alias lst="ls -AltX --group-directories-first --color=force";

export DISPLAY=localhost:0.0
export LIBGL_ALWAYS_INDIRECT=1

function useJava() {
	declare -A JAVA_DIRECTORIES

	JAVA_VERSIONS=(
		["8"]="/c/Program Files/Java/jdk1.8.0_221"
		["eight"]="/c/Users/E217514/Downloads/Programs/Java/jdk8u282-b08"
		["11"]="/c/Users/E217514/Downloads/Programs/Java/OpenJDK11U-jdk_x64_windows_hotspot_11.0.10_9/jdk-11.0.10+9"
		["15"]="/c/Program Files/Java/jdk-15.0.2"
	)

	selected_java_version="${JAVA_VERSIONS[$1]}"
	if [[ -z $selected_java_version ]]; then
		echo "Unknown Java version: $1"
		return 1
	fi
	
	# Remove active java directory
	old_java_path=$(dirname "$(which java)")
	while read -r path_directory; do
		if [ "$path_directory" != "$old_java_path" ]; then
			if [[ -z "$result" ]]; then
				result="$path_directory"
			else
				result="$result:$path_directory"
			fi
		fi
	done <<< "$(echo $PATH | tr ":" "\n")"
	PATH="$result"
	echo "Removed $old_java_path from PATH"

	# Set the new java directory 
	new_java_path="${selected_java_version}/bin"
	PATH=$(echo "${PATH}:$new_java_path")
	export JAVA_HOME="$selected_java_version"
	echo "Added $new_java_path to PATH"
}

function color_my_prompt {
	local working_directory="\[\033[1;34m\]\w"
	local git_branch="\[\033[1;36m\]\$(__git_ps1)"
	local prompt_tail="\[\033[1;33m\]\$"
	local reset_color="\[\033[0m\]"
	export PS1="${working_directory}$git_branch $prompt_tail $reset_color"
}
color_my_prompt
