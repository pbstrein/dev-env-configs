# Cloud Foundations specific
export GOPRIVATE="*.epic.com"

# Path
path+=('/usr/local/omnibus')
path+=("$HOME/go/bin") # include default go location for packages/tools
path+=("$HOME/.nvm") # include node stuff
export PATH
export 'ECCP_OMNIBUS_NAMESERVER=10.142.39.230:53 10.142.39.231:53'

# Mac M1 specific
export DOCKER_DEFAULT_PLATFORM="linux/amd64"

export GITLAB_PERSONAL_TOKEN=<token>

#for local clusters
export KUBECONFIG=./kubeconfig

# for node stuff
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm
