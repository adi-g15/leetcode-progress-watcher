#!/bin/bash
# cd to directory containing this file
cd "$(dirname "$0")"

# if .nvm/nvm.sh exists, source it
if [ -f $HOME/.nvm/nvm.sh ]; then
  source $HOME/.nvm/nvm.sh
fi

cp records.json records.json.bak || true
npm run start

### AFTER THIS LINE, IT'S RELEVANT FOR GITHUB ACTION ###

: ${GIT_REMOTE:=""}

: ${GITHUB_ACTOR:=""}
GITHUB_REPO_OWNER=${GITHUB_REPOSITORY%/*}
GITHUB_REPO_NAME=${GITHUB_REPOSITORY#*/}

ensure_env() {
	: ${!1:?"env \$${1} is not set"}
}

# PRE-REQUISITES:
# 1. GIT_REMOTE be defined containing token
# 2. npm install already run
githubaction() {
    ensure_env GIT_REMOTE
    ensure_env GITHUB_ACTOR

    ## Step 1: Update the records, assuming currently in the cloned directory
    npm run start

    ## Step 2: Commit the files
    git add records.json
    git config user.email "bot.noreply@github.com"
    git config user.name "adityag-gitbot"

    git commit -m "Auto-Updated at $(date +'%Y/%m/%d %H:%M:%S')"

    ## Step 3: Push, assuming remote 'origin' already set (by default, it is)
    git push origin main	# Pushing to current branch itself
}

set -xe
"$@"

