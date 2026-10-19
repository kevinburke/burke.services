#!/usr/bin/env bash
set -euo pipefail

next_version=$1
shift
renderer=burke_services_renderer/main.go

# The primary checkout can be reset by background tooling. Refuse before
# changing any files, rather than discovering this when committing.
branch=$(git symbolic-ref --short HEAD)
if [[ $(git rev-parse --git-dir) == "$(git rev-parse --git-common-dir)" ]] &&
    [[ $branch == main || $branch == master ]]; then
    echo 'Create a release worktree before running make release.' >&2
    exit 1
fi

# A normal commit includes everything already staged, even if we only add
# release files below. Reject that state instead of sweeping it in.
git diff --cached --exit-code
dirty_release_files=$(git status --porcelain --untracked-files=all -- "$renderer" ':(glob)public/**/*.html')
if [[ -n $dirty_release_files ]]; then
    echo 'Commit or restore renderer and HTML changes before releasing.' >&2
    exit 1
fi

# Also catch Markdown/template edits or stale checked-in HTML before bumping
# the version. Rebuilding is essential: a clean diff alone cannot detect them.
"${MAKE:-make}" --always-make compile
git diff --exit-code HEAD -- ':(glob)public/**/*.html'

version=$("$next_version" minor "$renderer")
existing_tag=$(git tag --list "$version")
if [[ -n $existing_tag ]]; then
    echo "Release tag $version already exists." >&2
    exit 1
fi

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
awk -v version="$version" '
    /^const Version = "[^"]+"$/ {
        $0 = "const Version = \"" version "\""
        count++
    }
    { print }
    END { if (count != 1) exit 1 }
' "$renderer" > "$scratch/renderer.go"
cat "$scratch/renderer.go" > "$renderer"

"${MAKE:-make}" --always-make compile
git add -- "$renderer" "$@"
printf 'burke.services: release %s\n\nBump the renderer and regenerate all published HTML pages together.\n' "$version" > "$scratch/commit-message"
git commit --file "$scratch/commit-message"
git tag --annotate --message "$version" "$version"
