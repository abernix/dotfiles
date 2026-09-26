# mise-secret NAME [--project]
#
# Prompt for a secret (not echoed, not saved in shell history) and store it in
# ~/.config/mise/secrets.env, which mise loads and redacts. With --project,
# store it in ./.secrets.env instead; ./mise.local.toml needs to load it.
#
# Keep that file well-formed: mise prints the offending line, value included,
# when it can't parse it.
mise-secret() {
  setopt localoptions noxtrace noverbose
  local name="" project="" arg
  for arg in "$@"; do
    case "$arg" in
      --project) project=1 ;;
      *) name="$arg" ;;
    esac
  done
  if [[ ! "$name" =~ '^[A-Za-z_][A-Za-z0-9_]*$' ]]; then
    echo "usage: mise-secret NAME [--project]" >&2
    return 1
  fi

  local file="$HOME/.config/mise/secrets.env"
  [[ -n "$project" ]] && file="$PWD/.secrets.env"

  local value
  IFS= read -rs "value?$name: "
  echo
  if [[ -z "$value" ]]; then
    echo "Empty value; nothing changed." >&2
    return 1
  fi
  if [[ "$value" == *[\'\\$'\n'$'\r']* ]]; then
    echo "Values can't contain single quotes, backslashes or newlines." >&2
    return 1
  fi

  (
    umask 077
    mkdir -p "${file:h}"
    touch "$file"
    tmp="$(mktemp "${file}.XXXXXX")" || exit 1
    trap 'rm -f "$tmp"' EXIT INT TERM HUP
    grep -Ev "^(export[[:space:]]+)?${name}[[:space:]]*=" "$file" > "$tmp"
    (( $? <= 1 )) || exit 1
    printf "%s='%s'\n" "$name" "$value" >> "$tmp" || exit 1
    chmod 600 "$tmp" && mv "$tmp" "$file"
  ) || { echo "Couldn't update ${file/#$HOME/~}; nothing changed." >&2; return 1; }

  echo "Saved $name to ${file/#$HOME/~}."
  if [[ -n "$project" ]] && ! grep -qsF '.secrets.env' mise.local.toml; then
    if [[ -e mise.local.toml ]]; then
      echo "Add this to the [env] table in ./mise.local.toml:" >&2
      echo '  _.file = { path = ".secrets.env", redact = true }' >&2
    else
      printf '[env]\n_.file = { path = ".secrets.env", redact = true }\n' > mise.local.toml
      echo "Created ./mise.local.toml to load it; run \`mise trust\` if asked."
    fi
  fi
}
