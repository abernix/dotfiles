# Git: Show most inactive branches.
alias gitstale='git branch --remote --no-color --merged | command grep -vE "^(\*|\s*(master|develop|dev)\s*$|.* -> )" | command xargs -n1 -I::B:: git --no-pager show -s --pretty="tformat:%ci %<(20,trunc)%cr %<(20,mtrunc)%an ::B::" ::B:: | sort -r'

alias gapan='git add --intent-to-add . && git add --patch'

# Git Last Branches
alias glb='gb --sort=-committerdate H -10'
alias gfix='$EDITOR `git diff --name-only | uniq`'

# Checkout the root branch
gct(){ git checkout "$(git rev-parse --abbrev-ref ${1:-origin}/HEAD | cut -d/ -f2)" }
