# Fork maintenance

This repository tracks [bilawalsidhu/gods-eye-view](https://github.com/bilawalsidhu/gods-eye-view).
Upstream is MIT licensed, so mirroring it here is permitted. Note that some
bundled datasets carry stricter terms, including CC BY NC SA 3.0 on the
TeleGeography submarine cable data, so commercial use requires removing those
files or licensing them separately. See `LICENSE` for the full breakdown.

## Node version

`package.json` requires Node 24.14.0 or later in the 24.x line, or 26.x. Node
25 is end of life and the setup doctor warns about it. A `.nvmrc` pins the
major version, so `nvm use` selects a supported runtime.

## Updating this clone

```bash
./scripts/sync-upstream.sh --check   # how far behind, changes nothing
./scripts/sync-upstream.sh           # merge upstream/main, reinstall if the lockfile moved, run the doctor
```

The script adds the `upstream` remote on first run, refuses to merge over a
dirty working tree, and skips `npm ci` when `package-lock.json` did not change.
It finishes with `npm run doctor` so the result is verified rather than assumed.

The equivalent by hand:

```bash
git remote add upstream https://github.com/bilawalsidhu/gods-eye-view.git
git fetch upstream main
git merge upstream/main
npm ci
npm run doctor
```

## Updating this repository on GitHub

`.github/workflows/sync-upstream.yml` runs daily at 07:17 UTC and on demand
from the Actions tab. It targets this repository's own default branch,
whatever it is called, so no branch has to be renamed or created by hand.

While the default branch is an untouched mirror of upstream, the job fast
forwards it directly. Once it carries commits of its own, a fast forward is no
longer possible, so the job pushes `upstream/main` to a `sync/upstream-<date>`
branch and opens a pull request instead. The default branch is never
overwritten.

Two things to know about GitHub scheduled workflows:

1. They run only from the default branch, so this file has to be on the
   default branch for the schedule to fire.
2. GitHub disables the schedule after 60 days with no repository activity. Run
   it manually from the Actions tab to re-enable it.

## Verifying after an update

```bash
npm run doctor
npm run format:check
npm run check:boundaries
npm test
npm run build
```

That is the same set the upstream CI workflow runs, against Node 24.14.0 and
26.x.
