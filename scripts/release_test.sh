#!/usr/bin/env bash
set -euo pipefail

release_script="$(pwd)/scripts/release.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
# Fixtures must not inherit signing requirements, hooks, or user aliases.
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null

setup() {
    mkdir "$scratch/$1"
    cd "$scratch/$1"
    git init --quiet --initial-branch=release-test
    git config user.name 'Release test'
    git config user.email release@example.com
    mkdir -p burke_services_renderer public/2016
    printf 'const Version = "1.0"\n' > burke_services_renderer/main.go
    echo content > source.md
    echo notes > notes.txt
    cat > Makefile <<'MAKEFILE'
compile:
	cat burke_services_renderer/main.go source.md > public/index.html
	cp public/index.html public/2016/donations.html
MAKEFILE
    printf '#!/usr/bin/env bash\nprintf "1.1\\n"\n' > next-version
    chmod +x next-version
    make compile > /dev/null
    git add .
    git commit --quiet --message initial
    initial=$(git rev-parse HEAD)
}

release() {
    bash "$release_script" ./next-version public/index.html public/2016/donations.html
}

expect_failure() {
    if release > "$scratch/output" 2>&1; then
        echo "Release unexpectedly succeeded in $PWD" >&2
        exit 1
    fi
    [[ $(git rev-parse HEAD) == "$initial" ]]
    [[ $(git tag --list 1.1) == '' ]]
    [[ $(cat burke_services_renderer/main.go) == 'const Version = "1.0"' ]]
}

setup dirty-html
echo unrelated >> public/index.html
expect_failure

setup staged-html
echo unrelated >> public/2016/donations.html
git add public/2016/donations.html
expect_failure

setup staged-unrelated
echo unrelated > unrelated.txt
git add unrelated.txt
expect_failure

setup dirty-renderer
echo '// unrelated' >> burke_services_renderer/main.go
if release > "$scratch/output" 2>&1; then
    echo 'Release accepted a dirty renderer' >&2
    exit 1
fi
[[ $(git rev-parse HEAD) == "$initial" ]]

setup stale-html
echo updated >> source.md
git add source.md
git commit --quiet --message 'update source without regenerating HTML'
initial=$(git rev-parse HEAD)
expect_failure

setup primary-checkout
git branch --move master
expect_failure

setup existing-tag
git tag 1.1
if release > "$scratch/output" 2>&1; then
    echo 'Release accepted an existing tag' >&2
    exit 1
fi
[[ $(git rev-parse HEAD) == "$initial" ]]
[[ $(cat burke_services_renderer/main.go) == 'const Version = "1.0"' ]]

setup failed-render
cat >> Makefile <<'MAKEFILE'
	awk '/"1[.]1"/ { exit 1 }' burke_services_renderer/main.go
MAKEFILE
git add Makefile
git commit --quiet --message 'fail rendering after the bump'
initial=$(git rev-parse HEAD)
if release > "$scratch/output" 2>&1; then
    echo 'Release accepted a failed render' >&2
    exit 1
fi
[[ $(git rev-parse HEAD) == "$initial" ]]
[[ $(git tag --list 1.1) == '' ]]
[[ $(cat burke_services_renderer/main.go) == 'const Version = "1.1"' ]]

setup success
# Unstaged work outside the release files must remain out of the commit.
echo unrelated >> notes.txt
echo unrelated > unrelated.txt
release > "$scratch/output" 2>&1 || { cat "$scratch/output" >&2; exit 1; }
[[ $(git rev-list --count "$initial..HEAD") == 1 ]]
[[ $(git rev-parse '1.1^{commit}') == "$(git rev-parse HEAD)" ]]
[[ $(cat burke_services_renderer/main.go) == 'const Version = "1.1"' ]]
for page in public/index.html public/2016/donations.html; do
    [[ $(head -n 1 "$page") == 'const Version = "1.1"' ]]
done
git diff --exit-code HEAD -- burke_services_renderer public
[[ $(git show HEAD:notes.txt) == notes ]]
[[ $(git status --porcelain) == $' M notes.txt\n?? unrelated.txt' ]]
echo 'Release tests passed.'
