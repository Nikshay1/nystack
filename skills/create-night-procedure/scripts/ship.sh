#!/usr/bin/env bash
# The only way a night run pushes, opens, or merges. Enforces the config's
# per-repository authority and numbers, so the permission rules can deny every
# raw `git push`, `gh pr create`, and `gh pr merge`.
#
# Usage (inside a run started by run-night.sh):
#   ship.sh open  <owner/repo> <worktree> <branch> <title> <body-file>
#   ship.sh fix   <owner/repo> <worktree> <pr-number>
#   ship.sh merge <owner/repo> <pr-number>
#
# Needs NIGHT_CONFIG, NIGHT_STATE, NIGHT_MODE (exported by run-night.sh).
# Every action is recorded in $NIGHT_STATE/shipped.tsv (night, action, repo,
# branch, PR). A night runs from noon to noon: NIGHT_ID is the date 12 hours
# before the run started, so reruns the same night share the budget and the
# next night starts fresh. Calls are serialised by a lock.
# Exit 3 means refused; the reason is on stderr.
set -euo pipefail

die() { echo "ship.sh refused: $*" >&2; exit 3; }
[ -n "${NIGHT_CONFIG:-}" ] && [ -n "${NIGHT_STATE:-}" ] && [ -n "${NIGHT_MODE:-}" ] \
  || die "run only inside a night run (NIGHT_CONFIG, NIGHT_STATE, NIGHT_MODE unset)"
[ "$NIGHT_MODE" = run ] || die "plan mode ships nothing"

mkdir -p "$NIGHT_STATE"
exec 8>"$NIGHT_STATE/ship.lock"
flock 8

login="$(jq -r '.github_login' "$NIGHT_CONFIG")"
log_file="$NIGHT_STATE/shipped.tsv"
touch "$log_file"
night="${NIGHT_ID:-$(date -d "12 hours ago" +%F)}"

repo_config() { jq -c --arg r "$1" '.repos[] | select(.repo == $r)' "$NIGHT_CONFIG"; }
level() { case "$1" in local) echo 0 ;; draft) echo 1 ;; ready) echo 2 ;; merge-own) echo 3 ;; *) echo -1 ;; esac; }
record() { printf '%s\t%s\t%s\t%s\t%s\n' "$night" "$1" "$2" "$3" "$4" >> "$log_file"; }
count() { awk -F'\t' -v n="$night" -v a="$1" -v r="$2" '$1 == n && $2 == a && (r == "" || $3 == r)' "$log_file" | wc -l; }

load_repo() {
  rc="$(repo_config "$1")"
  [ -n "$rc" ] || die "$1 is not in the config"
  auth="$(jq -r '.authority' <<<"$rc")"
  fork="$(jq -r '.fork_remote' <<<"$rc")"
  default_branch="$(jq -r '.default_branch' <<<"$rc")"
  fork_repo="$(jq -r --arg l "$login" --arg n "${1#*/}" '.fork_repo // ($l + "/" + $n)' <<<"$rc")"
}

check_pr_number() { [[ "$1" =~ ^[1-9][0-9]*$ ]] || die "PR must be a number, got '$1'"; }

check_fork() {
  local wt="$1" url want re
  want="${fork_repo//./\\.}"
  re="^(https://github\\.com/|git@github\\.com:|ssh://git@github\\.com/)${want}(\\.git)?/?$"
  local urls
  urls="$(git -C "$wt" remote get-url --all "$fork" 2>/dev/null; git -C "$wt" remote get-url --push --all "$fork" 2>/dev/null)" \
    || die "no remote '$fork' in $wt"
  [ -n "$urls" ] || die "no remote '$fork' in $wt"
  while IFS= read -r url; do
    [[ "$url" =~ $re ]] || die "remote '$fork' points at '$url', not github.com/$fork_repo"
  done <<<"$urls"
}

check_branch() {
  [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._/-]*$ ]] || die "branch name '$1' is not allowed"
  [[ "$1" != *..* ]] || die "branch name '$1' is not allowed"
  [ "$1" != "$default_branch" ] || die "will not push to the default branch"
}

open_pr_count() {
  gh pr list -R "$1" --author "$login" --state open --limit "$(( $2 + 1 ))" --json number --jq length
}

action="${1:-}"
[ $# -gt 0 ] && shift
case "$action" in
  open)
    [ $# -eq 5 ] || die "usage: open <owner/repo> <worktree> <branch> <title> <body-file>"
    repo="$1" wt="$2" branch="$3" title="$4" body="$5"
    load_repo "$repo"
    [ "$(level "$auth")" -ge 1 ] || die "$repo authority is '$auth': keep it local and put the commands in the report"
    [ -f "$body" ] || die "no body file at $body"
    check_branch "$branch"
    check_fork "$wt"
    probe=0
    git -C "$wt" ls-remote --exit-code --heads "$fork" "refs/heads/$branch" >/dev/null 2>&1 || probe=$?
    case "$probe" in
      2) ;;
      0) die "branch '$branch' already exists on the fork; use a new branch name (fixes to open PRs go through 'fix')" ;;
      *) die "could not check the fork for branch '$branch' (git ls-remote exit $probe)" ;;
    esac
    per_repo="$(jq -r '.new_prs_per_night // 0' <<<"$rc")"
    max_open="$(jq -r '.max_open_prs // 0' <<<"$rc")"
    total="$(jq -r '.total_new_prs_per_night // 0' "$NIGHT_CONFIG")"
    [ "$(count open "$repo")" -lt "$per_repo" ] || die "$repo already has $per_repo new PRs tonight ($night)"
    [ "$(count open "")" -lt "$total" ] || die "the total of $total new PRs tonight ($night) is reached"
    open_now="$(open_pr_count "$repo" "$max_open")"
    [ "$open_now" -lt "$max_open" ] || die "$login already has $open_now open PRs in $repo (max $max_open)"
    git -C "$wt" push -u "$fork" "HEAD:refs/heads/$branch"
    draft=()
    [ "$auth" = draft ] && draft=(--draft)
    url="$(gh pr create -R "$repo" --head "${fork_repo%%/*}:$branch" --base "$default_branch" \
      --title "$title" --body-file "$body" "${draft[@]}")"
    record open "$repo" "$branch" "$url"
    echo "$url"
    ;;
  fix)
    [ $# -eq 3 ] || die "usage: fix <owner/repo> <worktree> <pr-number>"
    repo="$1" wt="$2" pr="$3"
    check_pr_number "$pr"
    load_repo "$repo"
    [ "$(level "$auth")" -ge 1 ] || die "$repo authority is '$auth'"
    [ "$(jq -r 'if .followups.push_fixes == true then "yes" else "no" end' "$NIGHT_CONFIG")" = yes ] || die "followups.push_fixes is off"
    info="$(gh pr view "$pr" -R "$repo" --json author,headRefName,headRepositoryOwner,headRepository,state)"
    [ "$(jq -r '.state' <<<"$info")" = OPEN ] || die "PR $pr is not open"
    [ "$(jq -r '.author.login' <<<"$info")" = "$login" ] || die "PR $pr is not $login's"
    [ "$(jq -r '.headRepositoryOwner.login + "/" + .headRepository.name' <<<"$info")" = "$fork_repo" ] || die "PR $pr does not come from $fork_repo"
    branch="$(jq -r '.headRefName' <<<"$info")"
    check_branch "$branch"
    check_fork "$wt"
    git -C "$wt" push "$fork" "HEAD:refs/heads/$branch"
    record fix "$repo" "$branch" "$pr"
    echo "pushed fix to $repo#$pr"
    ;;
  merge)
    [ $# -eq 2 ] || die "usage: merge <owner/repo> <pr-number>"
    repo="$1" pr="$2"
    check_pr_number "$pr"
    load_repo "$repo"
    [ "$auth" = merge-own ] || die "$repo authority is '$auth', not merge-own"
    [ "$(gh repo view "$repo" --json viewerPermission --jq .viewerPermission)" = ADMIN ] || die "$login does not administer $repo"
    [ "$(gh pr view "$pr" -R "$repo" --json author --jq .author.login)" = "$login" ] || die "PR $pr is not $login's"
    buckets="$(gh pr checks "$pr" -R "$repo" --json bucket --jq '[.[].bucket]' 2>/dev/null || echo '[]')"
    [ "$(jq 'length' <<<"$buckets")" -gt 0 ] || die "PR $pr has no checks; merge-own needs CI"
    [ "$(jq 'all(.[]; . == "pass" or . == "skipping")' <<<"$buckets")" = true ] || die "checks on PR $pr are not all passing: $buckets"
    method="$(jq -r '.merge_method // "squash"' <<<"$rc")"
    case "$method" in squash|merge|rebase) ;; *) die "unknown merge_method '$method'" ;; esac
    gh pr merge "$pr" -R "$repo" "--$method"
    record merge "$repo" "-" "$pr"
    echo "merged $repo#$pr"
    ;;
  *)
    die "usage: ship.sh open|fix|merge ..."
    ;;
esac
