# Customize to your needs...
for file in ~/.{path,exports,aliases,functions,extra,remote_clipboard,yelp,prompt}; do
    [ -r "$file" ] && source "$file"
done
export PS1="[\[\033[1;36m\]\u$@\[\033[00m\]@\h:\[\033[1;32m\]\w\[\033[00m\]]\[\033[1;33m\]\$GIT_PROMPT_BRANCH $(sandbox_prompt_info) \$ "
