# This file is meant to be sourced into other test scripts.

delete_branches() {
    for b in "$@"
    do
        git branch -D $b 2>/dev/null || true
    done
}
