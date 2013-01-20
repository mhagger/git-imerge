==============================================
git-mergemate -- tools to help with git merges
==============================================

git-mergemate is an experimental tool to help in various ways with
difficult git merges.  See `my blog`_ for more information.

**This tool is experimental!  If it breaks, you get to keep the
pieces.  For example, it is strongly recommended that you make a clone
of your git repository and run the script on the clone rather than the
original.**

git-mergemate is under the GNU General Public License (GPL), version 2
or later.

Usage::
    git-mergemate --help

        Output this message.

    git-mergemate diagram [--full] BRANCH1...BRANCH2 >diagram.ppm

        Determine which pairs of commits from the two branchs can be
        merged together without conflict.  Output the result as a
        PPM-formatted image, where successful merges are shown as
        green pixels and unsuccessful merges as red pixels.

    git-mergemate merge BRANCH

        Merge the commits from BRANCH into HEAD, one commit at a
        time. In other words, transform this:

            o---o---o---o          HEAD
                 \
                  A---B---C---D    BRANCH

        into this:

            o---o---o---o---A'--B'--C'--D'    HEAD
                 \         /   /   /   /
                  --------A---B---C---D       BRANCH

        This is like a rebase, except with the history of individual
        merges retained [1].

        If there is a merge conflict, stop in "conflicted" state (as
        usual with a git merge).  The user should resolve the
        conflict, commit, and then re-execute the git-mergemate command to
        continue.

    git-mergemate find-conflict BRANCH1..BRANCH2

        Use bisection to determine the earliest commit on BRANCH2 that
        causes a conflict when merged to BRANCH1.  Don't actually
        retain any merges.

    git-mergemate find-conflict BRANCH1...BRANCH2

        Use bisection to find a pair of earliest commits (one from
        each branch) that do not merge cleanly.  Don't actually retain
        any merges.

    git-mergemate reparent [PARENT...]

        Change the parents of the HEAD commit to the specified list.
        Write the name of the new commit object to stdout without
        actually pointing HEAD at it.

    In all cases, only the --first-parent commits are considered for
    merging, and git rerere is disabled.

.. _`my blog`: http://softwareswirl.blogspot.de/

