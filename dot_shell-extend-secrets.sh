# mise-secret NAME [--project]
#
# Prompt for a secret (not echoed, not saved in shell history) and store it in
# ~/.config/mise/secrets.env, which mise loads and redacts. With --project,
# store it in ./.secrets.env instead and make sure ./mise.local.toml loads it.
mise-secret() {
  local name="" project=""
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
  read -rs "value?$name: "
  echo
  if [[ -z "$value" ]]; then
    echo "Empty value; nothing changed." >&2
    return 1
  fi
  if [[ "$value" == *\'* || "$value" == *$'\n'* ]]; then
    echo "Values can't contain single quotes or newlines." >&2
    return 1
  fi

  (
    umask 077
    mkdir -p "${file:h}"
    touch "$file"
    local tmp
    tmp="$(mktemp "${file}.XXXXXX")" || exit 1
    grep -v "^${name}=" "$file" > "$tmp"
    printf "%s='%s'\n" "$name" "$value" >> "$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$file"
  ) || return 1

  if [[ -n "$project" ]] && ! grep -qs 'secrets.env' mise.local.toml; then
    printf '[env]\n_.file = { path = ".secrets.env", redact = true }\n' >> mise.local.toml
    echo "Added a .secrets.env loader to ./mise.local.toml; run \`mise trust\` if asked."
  fi
  echo "Saved $name to ${file/#$HOME/~}."
}
