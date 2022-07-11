# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/pstrein/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
#ZSH_THEME="intheloop"
ZSH_THEME="powerlevel10k/powerlevel10k" # follow instructions at https://github.com/romkatv/powerlevel10k

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    colored-man-pages
    docker
    git
    git-prompt
    golang
    kubectl
    terraform
    tmux
    zsh-autosuggestions
) # refresh using `src`


source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Custom functions
function update_omnibus() {
    omnibus_zip=$1
    #omnibus_version="v$(dig -t txt omnibus.vers.epiccloud.io +short | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" | awk -F: '{print $2}').0" # gets the latest omnibus version
    #omnibus_zip=omnibus_${omnibus_version}.0_linux-amd64.tar.gz
    pushd /usr/local/omnibus
    sudo curl -LSsOv /tmp/omni.tgz https://eccpbinaries.blob.core.windows.net/omnibus/${omnibus_zip}
    sudo tar -C /usr/local/omnibus/ -xvf /tmp/omni.tgz
    popd
}

function update_omnibus_latest() {
    curl -LSsv -o /tmp/omni.tgz https://eccpbinaries.blob.core.windows.net/omnibus/omnibus_latest_linux-amd64.tar.gz
    sudo tar -C /usr/local/bin/ -xvf /tmp/omni.tgz
    rm -f /tmp/omni.tgz
}


function update_elmer_values_json() {
    set -x
    git -C /home/pstrein/nebula/elmer-configuration checkout personal-cluster-template
    git -C /home/pstrein/nebula/elmer-configuration pull
    cp /home/pstrein/nebula/elmer-configuration/values.json /home/pstrein/.elmer/pstrein/values.json
}

function post_create_local_dev_cluster() {
    set -x
    cluster_name=$1
    dns_number=$2
    cluster_deployment_path="/home/pstrein/elmer-deployments/localfs/$cluster_name"

    pushd "$cluster_deployment_path/"
    cat "$cluster_deployment_path/secrets.json" | jq -r '.azure.acs.a.kubeconfig' | base64 -d > "$cluster_deployment_path/kubeconfig"
    popd
}

function setup_local_dev_cluster() {
    set -x
    cluster_name=$1
    cluster_deployment_path="/home/pstrein/elmer-deployments/localfs/$cluster_name"
    cluster_values_path="$cluster_deployment_path/elmer-configuration/values.json"
    cluster_secrets_path="$cluster_deployment_path/secrets.json"

    # cluster creation
    create_cluster -n $cluster_name -t main -c main -d
    cp "/home/pstrein/.elmer/pstrein/values.json" "$cluster_values_path"
    cp "/home/pstrein/.elmer/pstrein/secrets.json" "$cluster_secrets_path"
}


function create_local_dev_cluster() {
    set -x
    cluster_name=$1
    dns_number=$2

    setup_local_dev_cluster $cluster_name

    # initial deploy
    EPIC_ELMER_TERRAFORM_AUTO_ACCEPT_CHANGES=1 deploy_cluster $cluster_name --use-local

    # post deploy steps
    post_create_local_dev_cluster $pstrein $dns_number

    EPIC_ELMER_TERRAFORM_AUTO_ACCEPT_CHANGES=1 deploy_cluster $cluster_name --use-local
}

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# This is specific to WSL 2. If the WSL 2 VM goes rogue and decides not to free
# up memory, this command will free your memory after about 20-30 seconds.
#   Details: https://github.com/microsoft/WSL/issues/4166#issuecomment-628493643
alias drop_cache="sudo sh -c \"echo 3 >'/proc/sys/vm/drop_caches' && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\""
autoload -U compinit; compinit


# enables mouse in TMUX, assumes `echo set -g mouse on > ~/.tmux.conf`
#tmux set mouse # enabl
