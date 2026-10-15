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

## How updates flow

A weekly Claude Code routine does the merging on GitHub. Each run clones this
repository, merges `main` from upstream into the default branch, resolves any
conflicts so the Jerry's God Eye View branding survives, runs the checks
below, and pushes only if they all pass. If a check fails or a conflict is
ambiguous, it pushes nothing and says why.

An earlier GitHub Actions job (`sync-upstream.yml`) was removed. It failed on
every run: the built in Actions token may not open pull requests unless the
repository allows it, and may never push commits that change upstream's own
`.github/workflows` files. It also could not resolve conflicts.

## Updating this clone

```bash
./scripts/sync-upstream.sh --check   # how far behind upstream, changes nothing
./scripts/sync-upstream.sh           # pull the fork, merge anything newer from upstream, reinstall if needed, run the doctor
```

The script first fast forwards from this fork on GitHub, so the clone takes
the routine's merge instead of making a second, divergent one. It then merges
anything upstream published since, reinstalls locked dependencies when
`package-lock.json` moved, and finishes with `npm run doctor`. It refuses to
run over a dirty working tree.

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
