#!/usr/bin/env bash
# Update this clone from the upstream God's Eye View repository.
#
#   ./scripts/sync-upstream.sh            merge upstream/main into the current branch
#   ./scripts/sync-upstream.sh --check    report how far behind we are, change nothing
#
# Reinstalls locked dependencies only when package-lock.json actually moved,
# then runs the setup doctor so the result is verified rather than assumed.
set -euo pipefail

UPSTREAM_URL="https://github.com/bilawalsidhu/gods-eye-view.git"
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"

cd "$(dirname "$0")/.."

check_only=0
if [ "${1:-}" = "--check" ]; then
  check_only=1
elif [ -n "${1:-}" ]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  echo "==> adding '$UPSTREAM_REMOTE' remote -> $UPSTREAM_URL"
  git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
fi

echo "==> fetching $UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
git fetch --tags "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"

branch="$(git rev-parse --abbrev-ref HEAD)"
target="$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
behind="$(git rev-list --count "HEAD..$target")"
ahead="$(git rev-list --count "$target..HEAD")"

echo "==> $branch is $behind commit(s) behind and $ahead commit(s) ahead of $target"

if [ "$behind" -eq 0 ]; then
  echo "Already up to date. Nothing to merge."
  exit 0
fi

git --no-pager log --oneline --no-merges "HEAD..$target" | head -20
if [ "$behind" -gt 20 ]; then
  echo "... and $((behind - 20)) more"
fi

if [ "$check_only" -eq 1 ]; then
  echo "Check only. Re-run without --check to merge."
  exit 0
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is dirty. Commit or stash first, then re-run." >&2
  exit 1
fi

lock_before="$(git rev-parse "HEAD:package-lock.json")"

echo "==> merging $target into $branch"
git merge --no-edit "$target"

lock_after="$(git rev-parse "HEAD:package-lock.json")"
if [ "$lock_before" != "$lock_after" ]; then
  echo "==> package-lock.json changed, reinstalling locked dependencies"
  npm ci
else
  echo "==> package-lock.json unchanged, skipping npm ci"
fi

echo "==> verifying setup"
npm run doctor

cat <<'DONE'

Updated. Restart the dev server to pick up the changes:
  npm run dev     then open http://localhost:4173
DONE
