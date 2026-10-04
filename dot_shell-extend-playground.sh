# pg: start, stop, resize and keep up playground, the dev pod on the home-ops
# cluster (abernix/playground). Uses the kubectl context in $PG_CONTEXT
# (default home-ops), which reaches the cluster over the tailnet.
#
#   pg up        start at the usual size (2 vCPU / 16 GB node)
#   pg up big    start, or restart, on the 8 vCPU / 32 GB node
#   pg down      stop (the home disk stays)
#   pg keep 8    keep it up past the 03:00 nightly stop for 8 more hours (max 168)
#   pg status    what's running, where, and until when
#   pg ssh       ssh in ($PG_HOST, default playground-next until cutover)

# The namespace warns at Pod Security "restricted" for the Tailscale sidecar on
# every write; that is expected, so it is filtered out.
_pg_kubectl() {
  kubectl --context "${PG_CONTEXT:-home-ops}" -n playground "$@" \
    2> >(grep -v '^Warning: would violate PodSecurity' >&2)
}

_pg_size() {
  _pg_kubectl patch deploy/playground --type=json -p "[
    {\"op\":\"replace\",\"path\":\"/spec/template/spec/nodeSelector\",\"value\":{\"cloud.google.com/compute-class\":\"$1\"}},
    {\"op\":\"replace\",\"path\":\"/spec/template/spec/containers/0/resources\",\"value\":{\"requests\":{\"cpu\":\"$2\",\"memory\":\"$3\"},\"limits\":{\"memory\":\"$3\"}}}]" >/dev/null
}

pg() {
  case "$1" in
    up)
      if [ "$2" = big ]; then _pg_size burst 6 24Gi; else _pg_size playground 1200m 11Gi; fi &&
        _pg_kubectl scale deploy/playground --replicas=1 >/dev/null &&
        echo "starting; about 2 minutes from cold. pg status to check."
      ;;
    down)
      _pg_kubectl scale deploy/playground --replicas=0 >/dev/null && echo "stopping"
      ;;
    keep)
      local hours="${2:-8}" until
      case "$hours" in ''|*[!0-9]*) echo "pg keep <hours>" >&2; return 1;; esac
      [ "$hours" -le 168 ] || { echo "at most 168 hours" >&2; return 1; }
      until=$(( $(date -u +%s) + hours * 3600 ))
      until="$(date -u -r "$until" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "@$until" +%Y-%m-%dT%H:%M:%SZ)"
      _pg_kubectl annotate deploy/playground "playground.home-ops/keep-until=$until" --overwrite >/dev/null &&
        echo "kept up until $until"
      ;;
    status)
      _pg_kubectl get deploy/playground -o jsonpath='replicas: {.spec.replicas}  size: {.spec.template.spec.nodeSelector.cloud\.google\.com/compute-class}  keep-until: {.metadata.annotations.playground\.home-ops/keep-until}{"\n"}'
      _pg_kubectl get pods -l app=playground -o wide 2>/dev/null
      ;;
    ssh)
      shift; ssh "jesse@${PG_HOST:-playground-next}" "$@"
      ;;
    *)
      echo "pg up [big] | down | keep <hours> | status | ssh" >&2
      return 1
      ;;
  esac
}
