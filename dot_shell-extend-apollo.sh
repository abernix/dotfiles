apollo_root="$HOME/Dev/apollo"
apollo_platform_devkit_root="${apollo_root}/apollo-platform-devkit"

alias apod="cd ${apollo_platform_devkit_root}"
alias apov="cd ${apollo_platform_devkit_root}/packages/rover"
alias apou="cd ${apollo_platform_devkit_root}/packages/router"
alias apot="cd ${apollo_platform_devkit_root}/packages/apollo-tooling"
alias apos="cd ${apollo_platform_devkit_root}/packages/apollo-server"
alias apof="cd ${apollo_platform_devkit_root}/packages/federation"
alias gql="cd ${apollo_platform_devkit_root}/packages/graphql-js"
alias apig="cd ${monorepo_root}/mdg/engine/api/gateway"

unique_clone_dir() {
  name=$1
  i=1
  while [[ -e $name-$i ]] ; do
      let i++
  done
  name=$name-$i
  echo "$name"
}

astsclone() {
  our_clone_target="$(unique_clone_dir "apollo-server-typescript-express")"
  git clone https://github.com/abernix/apollo-server-typescript-express/ \
    "$our_clone_target"
  (cd "${our_clone_target}" && rm -rf .git/ && npm install)
  echo "$our_clone_target"
}

tsrepro() {
  cd "$(mktemp -d)"
  echo Created "$(astsclone)"
}
