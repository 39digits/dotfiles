#
# A 2-line ZSH oh-my-zsh prompt with git info for use with a modified
# SpaceGray Dark iTerm2 color profile (see below for color profile).
#
# Authors:
#   Christopher Hamilton <christopher@39digits.com>
#
# iTerm2 Color Chart
# !!! Confirm if still correct.
#   color0 	(black) 	= #31434A
#   color1 	(red)     = #D11C24
#   color2 	(green) 	= #738A05
#   color3 	(yellow) 	= #A57706
#   color4 	(blue) 	  = #2176C7
#   color5 	(magenta) = #C61C6F
#   color6 	(cyan) 	  = #259286
#   color7 	(white) 	= #DFD6B3
#   color8 	(bright black) 	= #37494F
#   color9 	(bright red) 	  = #BD3613
#   color10 (bright green) 	= #2A393E
#   color11 (bright yellow) = #536870
#   color12 (bright blue) 	= #708284
#   color13 (bright magenta)= #5956BA
#   color14 (bright cyan) 	= #2076C8
#   color15 (bright white) 	= #FCF4DC
#   foreground 		= #708284
#   background 		= #001E27
#   bold          = #819090
#   selection     = #002831
#   selected text = #819090
#
#  %B %b  =  Bold / Unbold
#  %F{number-or-color-name} %f  = Set color of text. ("Bright" colors seem to require using the numbers)

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
GIT_SHOW=true

GIT_BRANCH_SHOW=true
# "Bright Black" aka dark grey
GIT_BRANCH_COLOR="8"

GIT_STATUS_SHOW=true
# "Bright White"
GIT_STATUS_COLOR="15"
GIT_STATUS_UNTRACKED="?"
GIT_STATUS_ADDED="+"
GIT_STATUS_MODIFIED="!"
GIT_STATUS_RENAMED="»"
GIT_STATUS_DELETED="✘"
# GIT_STATUS_STASHED="$"
GIT_STATUS_STASHED="●"
GIT_STATUS_UNMERGED="="
GIT_STATUS_AHEAD="⇡"
GIT_STATUS_BEHIND="⇣"
GIT_STATUS_DIVERGED="⇕"

# function +vi-git_status {
#   # Check for untracked files or updated submodules since vcs_info does not.
#   if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
#     hook_com[unstaged]='%F{red}●%f'
#   fi
# }

# ------------------------------------------------------------------------------
# Git Functions
# ------------------------------------------------------------------------------
#
# Git branch
#
39digits_git_branch() {
  [[ $GIT_BRANCH_SHOW == false ]] && return

  local git_current_branch="$vcs_info_msg_0_"
  [[ -z "$git_current_branch" ]] && return

  git_current_branch="${git_current_branch#heads/}"
  git_current_branch="${git_current_branch/.../}"

  echo -n "%F{$GIT_BRANCH_COLOR}${git_current_branch}%f"
  # echo -n " ${git_current_branch}"
}
#
# Git status
#
# OhMyZSH git library doesn't cover as wide a range of git status indicators
# See git help status to know more about status formats
39digits_git_status() {
  [[ $GIT_STATUS_SHOW == false ]] && return

  39digits::is_git || return

  local INDEX git_status=""

  INDEX=$(command git status --porcelain -b 2> /dev/null)

  # Check for untracked files
  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    git_status="$GIT_STATUS_UNTRACKED$git_status"
  fi

  # Check for staged files
  if $(echo "$INDEX" | command grep '^A[ MDAU] ' &> /dev/null); then
    git_status="$GIT_STATUS_ADDED$git_status"
  elif $(echo "$INDEX" | command grep '^M[ MD] ' &> /dev/null); then
    git_status="$GIT_STATUS_ADDED$git_status"
  elif $(echo "$INDEX" | command grep '^UA' &> /dev/null); then
    git_status="$GIT_STATUS_ADDED$git_status"
  fi

  # Check for modified files
  if $(echo "$INDEX" | command grep '^[ MARC]M ' &> /dev/null); then
    git_status="$GIT_STATUS_MODIFIED$git_status"
  fi

  # Check for renamed files
  if $(echo "$INDEX" | command grep '^R[ MD] ' &> /dev/null); then
    git_status="$GIT_STATUS_RENAMED$git_status"
  fi

  # Check for deleted files
  if $(echo "$INDEX" | command grep '^[MARCDU ]D ' &> /dev/null); then
    git_status="$GIT_STATUS_DELETED$git_status"
  elif $(echo "$INDEX" | command grep '^D[ UM] ' &> /dev/null); then
    git_status="$GIT_STATUS_DELETED$git_status"
  fi

  # Check for stashes
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    git_status="$GIT_STATUS_STASHED$git_status"
  fi

  # Check for unmerged files
  if $(echo "$INDEX" | command grep '^U[UDA] ' &> /dev/null); then
    git_status="$GIT_STATUS_UNMERGED$git_status"
  elif $(echo "$INDEX" | command grep '^AA ' &> /dev/null); then
    git_status="$GIT_STATUS_UNMERGED$git_status"
  elif $(echo "$INDEX" | command grep '^DD ' &> /dev/null); then
    git_status="$GIT_STATUS_UNMERGED$git_status"
  elif $(echo "$INDEX" | command grep '^[DA]U ' &> /dev/null); then
    git_status="$GIT_STATUS_UNMERGED$git_status"
  fi

  # Check whether branch is ahead
  local is_ahead=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*ahead' &> /dev/null); then
    is_ahead=true
  fi

  # Check whether branch is behind
  local is_behind=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*behind' &> /dev/null); then
    is_behind=true
  fi

  # Check wheather branch has diverged
  if [[ "$is_ahead" == true && "$is_behind" == true ]]; then
    git_status="$GIT_STATUS_DIVERGED$git_status"
  else
    [[ "$is_ahead" == true ]] && git_status="$GIT_STATUS_AHEAD$git_status"
    [[ "$is_behind" == true ]] && git_status="$GIT_STATUS_BEHIND$git_status"
  fi

  if [[ -n $git_status ]]; then
    echo -n "%B%F{$GIT_STATUS_COLOR}$git_status%f%b"
  fi
}
#
# Git prompt
#
39digits_git() {
  [[ $GIT_SHOW == false ]] && return

  local git_branch="$(39digits_git_branch)" git_status="$(39digits_git_status)"

  [[ -z $git_branch ]] && return

  echo -n "(${git_branch}${git_status}) "
}

# Check if the current directory is in a Git repository.
39digits::is_git() {
  # See https://git.io/fp8Pa for related discussion
  [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]
}

39digits_precmd_vcs_info() {
  vcs_info
}

# ------------------------------------------------------------------------------
# Prompt Functions
# ------------------------------------------------------------------------------
# Example prompt:
#   user@server.name  ~/Documents
#   (master●) $
39digits_prompt() {
  echo -n "
%F{white}%n@%m%f  %F{8}%~%f
$(39digits_git)$ "
}

39digits_rprompt() {
  echo -n ""
}

39digits_prompt_init() {
  autoload -Uz vcs_info
  autoload -Uz add-zsh-hook

  # This variable is a magic variable used when loading themes with zsh's prompt
  # function. It will ensure the proper prompt options are set.
  prompt_opts=(cr percent sp subst)

  # setopt prompt_subst
  setopt LOCAL_OPTIONS
  # unsetopt XTRACE KSH_ARRAYS

  # Add hook for calling vcs_info before each command.
  add-zsh-hook precmd 39digits_precmd_vcs_info

  # # Set vcs_info parameters.
  # # Formats:
  # #   %b - branchname
  # #   %u - unstagedstr (see below)
  # #   %c - stagedstr (see below)
  # #   %a - action (e.g. rebase-i)
  # #   %R - repository path
  # #   %S - path in the repository
  #
  # # Old Styles for (master●)
  # #zstyle ':vcs_info:*' enable bzr git hg svn
  # zstyle ':vcs_info:*' enable git
  # # NB:  Check for changes can have performance impacts!
  # zstyle ':vcs_info:*' check-for-changes true
  # zstyle ':vcs_info:*' unstagedstr '%F{yellow}●%f'
  # zstyle ':vcs_info:*' stagedstr '%F{green}●%f'
  # zstyle ':vcs_info:*' formats '(%F{8}%b%c%u%f) '
  # zstyle ':vcs_info:*' actionformats " - [%b%c%u|%F{cyan}%a%f]"
  # #zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b|%F{cyan}%r%f'
  # zstyle ':vcs_info:git*+set-message:*' hooks git_status
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git*' formats '%b'
  # zstyle ':vcs_info:git*' formats '%F{8}%b%f'

  PROMPT='$(39digits_prompt)'
  RPROMPT='$(39digits_rprompt)'
}

39digits_prompt_original() {
  autoload -Uz vcs_info
  autoload -Uz add-zsh-hook

  # This variable is a magic variable used when loading themes with zsh's prompt
  # function. It will ensure the proper prompt options are set.
  prompt_opts=(cr percent sp subst)

  # setopt prompt_subst
  setopt LOCAL_OPTIONS
  # unsetopt XTRACE KSH_ARRAYS

  # Add hook for calling vcs_info before each command.
  add-zsh-hook precmd 39digits_precmd_vcs_info

  # # Set vcs_info parameters.
  # # Formats:
  # #   %b - branchname
  # #   %u - unstagedstr (see below)
  # #   %c - stagedstr (see below)
  # #   %a - action (e.g. rebase-i)
  # #   %R - repository path
  # #   %S - path in the repository
  #
  # # Old Styles for (master●)
  #zstyle ':vcs_info:*' enable bzr git hg svn
  zstyle ':vcs_info:*' enable git
  # NB:  Check for changes can have performance impacts!
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' unstagedstr '%F{yellow}●%f'
  zstyle ':vcs_info:*' stagedstr '%F{green}●%f'
  zstyle ':vcs_info:*' formats '(%F{8}%b%c%u%f) '
  zstyle ':vcs_info:*' actionformats " - [%b%c%u|%F{cyan}%a%f]"
  #zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b|%F{cyan}%r%f'
  zstyle ':vcs_info:git*+set-message:*' hooks git_status


  # Old Prompt.
  PROMPT='
%F{white}%n@%m%f  %F{8}%~%f
${vcs_info_msg_0_}$ '

  RPROMPT=''
}

# ------------------------------------------------------------------------------
# ENTRY POINT
# An entry point of prompt
# ------------------------------------------------------------------------------
39digits_prompt_init "$@"
