function current_directory() {
    local PWD=$(pwd)
    echo "${PWD/#$HOME/~}"
}

function git_prompt_info () {
    if test -z $(parse_git_branch);
    then
        echo ""
    else
        echo " %{$FG[239]%}on%{$reset_color%} %{$FG[255]%}$(parse_git_branch)%{$reset_color%}"
    fi
}

PROMPT='%{$FG[040]%}%n%{$reset_color%} %{$FG[239]%}at%{$reset_color%} %{$FG[033]%}$(hostname -s)%{$reset_color%} %{$FG[239]%}in%{$reset_color%} %{$terminfo[bold]$FG[226]%}$(current_directory)%{$reset_color%}$(git_prompt_info) %{$FG[239]%}with $(colored_sandbox_string)%{$FG[255]%} '
