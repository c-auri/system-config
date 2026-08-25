# Aliases, functions, prompt, completions, shell options, third-party configs.
# See ~/docs/shell-startup.md for context.

# return early if shell is non-interactive
[[ $- != *i* ]] && return

################################################################################
################################### CORE #######################################
################################################################################

[[ -f /etc/bash_completion ]] && ! shopt -oq posix && source /etc/bash_completion
[[ -f $XDG_CONFIG_HOME/alacritty/completion ]] && source $XDG_CONFIG_HOME/alacritty/completion

shopt -s checkwinsize
shopt -s histappend
HISTCONTROL=ignoreboth

export EDITOR=nvim
export VISUAL=nvim

export LESS="-R -i"

eval "$(dircolors $XDG_CONFIG_HOME/.dircolors)"
export EZA_COLORS="ur=37:uw=37:ue=37:ux=37:gr=37:gw=37:gx=37:tr=37:tw=37:tx=37:sn=2;32:da=2;36:di=1;97:xx=2;37"

[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS='--layout reverse --style minimal --bind page-up:preview-up,page-down:preview-down'

alias clip='xclip -selection clipboard'

alias con='/usr/bin/git --git-dir=$XDG_CONFIG_HOME/.git --work-tree=$HOME'
alias sb='source ~/.bashrc'

################################################################################
################################### PROMPT #####################################
################################################################################

function __prepare_prompt
{
    prev_cmd_exit_code=$?
    fresh_terminal=${1:-false}

    set_win_title=""
    user="\[$(tput setaf ${USER_COLOR:-14})\]${USER_ALIAS:-$(whoami)}\[$(tput setaf 8)\]:"
    git_root=$(git-root 2>/dev/null)

    if [[ $PWD == $HOME ]]
    then
        dir="~"
    elif [[ -n $git_root && $git_root == $PROJECTS_DIR/* ]]
    then
        project=$(basename "$git_root")
        rel="${PWD#$git_root}"
        rel_stripped="${rel#/}"

        if [[ -z $rel ]]
        then
            suffix=""
        elif [[ $rel_stripped != */* ]]
        then
            suffix="/$rel_stripped"
        else
            suffix="/../$(basename "$PWD")"
        fi

        set_win_title="\[\e]2;$project$suffix\a\]"

        if [[ -z $suffix ]]
        then
            dir="\[$(tput setaf 15)\]$project"
        elif [[ $suffix == /../* ]]
        then
            dir="\[$(tput setaf 8)\]$project/../\[$(tput setaf 15)\]$(basename "$PWD")"
        else
            dir="\[$(tput setaf 8)\]$project/\[$(tput setaf 15)\]$rel_stripped"
        fi
    else
        dir=$(basename "$PWD")
    fi

    if [[ -z $set_win_title ]]
    then
        set_win_title="\[\e]2;$dir\a\]"
        dir="\[$(tput setaf 15)\]$dir"
    fi

    git=$(git status 2>/dev/null | shorten-git-status)
    if [[ -n $git ]]
    then
        git="\[$(tput setaf 3)\][$git]"
    fi

    if [[ $prev_cmd_exit_code == 0 ]]
    then
        sym_clr="\[$(tput setaf 15)\]"
    else
        sym_clr="\[$(tput setaf 9)\]"
    fi

    if $fresh_terminal
    then
        PS1=""
    else
        PS1="\n"
    fi

    PS1="$PS1$set_win_title\[$(tput bold)\]$user $dir $git\n$sym_clr❯ \[$(tput sgr0)\]"
}

# The __prepare_prompt function should be called before each prompt is printed.
# This is what the global PROMPT_COMMAND variable is designed to do.

# But there is one caveat:
# In a fresh terminal the prompt should be printed right onto the first line,
# but all subsequent prompts should be preceeded by a newline.

# To achieve this, delay assignment to PROMPT_COMMAND by one command cycle:
PROMPT_COMMAND="export PROMPT_COMMAND=__prepare_prompt"

# and call the preparation with fresh_terminal=true for the first command:
__prepare_prompt true

# Also, refresh the prompt preparation before calling clear:
function clear
{
    PROMPT_COMMAND='export PROMPT_COMMAND=__prepare_prompt'
    __prepare_prompt true
    command clear
}

################################################################################
################################# FILE SYSTEM ##################################
################################################################################

alias ls='eza --group-directories-first'
alias la='ls -a'
alias ll='ls -l --git --no-user'
alias lla='ll -a'

function lt
{
    local ignore_files=()
    local git_root=$(git-root 2>/dev/null)

    [[ -f $XDG_CONFIG_HOME/fd/ignore ]]        && ignore_files+=("$XDG_CONFIG_HOME/fd/ignore")
    [[ -n $git_root && -f $git_root/.ignore ]] && ignore_files+=("$git_root/.ignore")
    [[ -f .ignore && $PWD != $git_root ]]      && ignore_files+=(.ignore)

    local ignore_glob=""

    if [[ ${#ignore_files[@]} -gt 0 ]]
    then
        # eza matches globs against names rather than paths, so patterns with a slash in them are ignored
        ignore_glob=$(sed 's/[[:space:]]*#.*//; s:/$::; /^$/d; /\//d' "${ignore_files[@]}" | paste -sd '|' -)
    fi

    ls --tree -I "$ignore_glob" "$@"
}

alias mkdir='mkdir -p'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -I --preserve-root'

function mcd
{
    mkdir -p $1
    cd $1
}

alias f='fuzzy-open-file'

function up
{
    cd $(printf "%0.s../" $(seq 1 $1));
}

function df
{
    dir=$(fuzzy-find-dir)
    if [[ -n $dir ]]
    then
        cd $dir
    fi
}

alias notes='cd ~/notes'

################################################################################
##################################### GIT ######################################
################################################################################

alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gA='git add -A'
alias gc='git commit'
alias gC='git commit -a'
alias gam='git commit --amend'
alias gw='git show'
alias gf='git fetch -p'
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gsw='git switch'
alias grc='git rebase --continue'

# these are custom git aliases, see .gitconfig and .local/bin/git-utils
alias gg='git graph'
alias gaf='git add-fuzzy'
alias gwf='git show-fuzzy'
alias gff='git fixup-fuzzy'
alias gsf='git switch-fuzzy'
alias gsm='git switch-to-main'
alias gum='git update-main'
alias gri='git rebase-interactive'
alias grom='git rebase-origin-main'

cdp() { cd ~/projects/; }
cdr() { cd $(git root); }

################################################################################
################################# DEVELOPMENT ##################################
################################################################################

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_HTTPREPL_TELEMETRY_OPTOUT=1

alias dn='dotnet'
alias dnr='dotnet run'

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]]          && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

source "$HOME/.cargo/env"
