# This file is meant to be sourced into other test scripts.

delete_branches() {
    for b in "$@"
    do
        git branch -D $b 2>/dev/null || true
    done
}

modify() {
    filename="$1"
    text="$2"
    echo "$text" >"$filename" &&
    git add "$filename"
}

TIME=1112911993

commit() {
    TIME=$(( TIME + 1 ))
    GIT_AUTHOR_DATE="@$TIME +0000" GIT_COMMITTER_DATE="@$TIME +0000" git commit "$@"
}

check_tree () {
    local refname="$1"
    local expected_tree="$2"
    if ! test "$(git rev-parse "$refname^{tree}")" = "$expected_tree"
    then
        echo "error: the tree for $refname is incorrect!"
        git diff "$expected_tree" "$refname"
        exit 1
    fi
}
