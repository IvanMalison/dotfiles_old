function get_cols() {
    FS=' '
    while getopts "F:" OPTCHAR; do
        case $OPTCHAR in
            F)
                FS=$OPTARG
                ;;
        esac
    done
    shift $((OPTIND-1))
    awk -f "$HOME/.lib/get_cols.awk" -v "cols=$*" -v "FS=$FS"
}

function find_all_ssh_agent_sockets() {
    find /tmp -type s -name agent.\* 2> /dev/null | grep '/tmp/ssh-.*/agent.*'
}

function set_ssh_agent_socket() {
    export SSH_AUTH_SOCK=$(find_all_ssh_agent_sockets | tail -n 1 | awk -F: '{print $1}')
}

# Determine size of a file or total size of a directory
function fs() {
    if du -b /dev/null > /dev/null 2>&1; then
	local arg=-sbh
    else
	local arg=-sh
    fi
    if [[ -n "$@" ]]; then
	du $arg -- "$@"
    else
	du $arg .[^.]* *
    fi
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
    local port="${1:-8000}"
    sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# All the dig info
function digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

function parse_git_branch() {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function parse_git_dirty() {
    [[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
}

function current_shell() {
    ps -p $$ | tail -1 | awk '{print $NF}' | xargs which | xargs readlink -f
}

function is_zsh() {
    test -n "$(current_shell | grep -o zsh)"
}
