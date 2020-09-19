# This file is meant to be sourced into other test scripts.

init_test_repo() {
    local path="$1"
    local description="$2"

    delete_test_repo "$path" "$description"

    mkdir -p "$path"
    git init "$path"
    echo "$description" >"$path/.git/description"
    printf '%s\n' "/*.out" "/*.css" "/*.html" >"$path/.git/info/exclude"
    git --git-dir="$path/.git" config user.name 'Loú User'
    git --git-dir="$path/.git" config user.email 'luser@example.com'

    # Reset the timestamp that will be used for commits:
    TIME=1112911993

    # This CSS file is only for convenience, to make the HTML diagrams
    # viewable:
    ln -s "$BASE/imerge.css" "$path"
}

delete_test_repo() {
    local path="$1"
    local description="$2"

    if test -d "$path"
    then
        # Be very careful before running "rm -rf":
        if test "x$(cat "$path/.git/description")" = "x$description"
        then
            echo "Removing directory $path" >&2
            rm -rf "$path"
        else
            echo "Directory $path doesn't look like our test repo!" >&2
            exit 1
        fi
    fi
}

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
