==================================================
git-imerge -- incremental merge and rebase for git
==================================================

Perform a merge between two branches incrementally.  If conflicts are
encountered, figure out exactly which pairs of commits conflict, and
present the user with one pairwise conflict at a time for resolution.

``git-imerge`` has two primary design goals:

* Reduce the pain of resolving merge conflicts to its unavoidable
  minimum, by finding and presenting the smallest possible conflicts:
  those between the changes introduced by one commit from each branch.

* Allow a merge to be saved, tested, interrupted, published, and
  collaborated on while it is in progress.

I think that it is easiest to understand the concept of incremental
merging visually, and therefore I recommend the video of my
`git-imerge presentation from the GitMerge 2013 conference`_ (20 min)
as a good place to start.  The full slides for that talk are available
in this repository under ``doc/presentations/GitMerge-2013``.  At the
same conference, I was interviewed about ``git-imerge`` by Thomas
Ferris Nicolaisen for his `GitMinutes Podcast #12`_.

.. _`git-imerge presentation from the GitMerge 2013 conference`:
   http://www.youtube.com/watch?v=FMZ2_-Ny_zc

.. _`GitMinutes Podcast #12`:
   http://episodes.gitminutes.com/2013/06/gitminutes-12-git-merge-2013-part-4.html

To learn how to use the ``git-imerge`` tool itself, I suggest the blog
article `git-imerge: A Practical Introduction`_ and also typing
``git-imerge --help`` and ``git-imerge SUBCOMMAND --help``.  If you
want more information, the theory and benefits of incremental merging
are described in minute detail in a series of blog articles [1]_, as
are the benefits of retaining history when doing a rebase [2]_.

.. _`git-imerge: A Practical Introduction`:
   http://softwareswirl.blogspot.com/2013/05/git-imerge-practical-introduction.html

Multiple incremental merges can be in progress at the same time.  Each
incremental merge has a name, and its progress is recorded in the Git
repository as references under ``refs/imerge/NAME``.  The current
state of an incremental merge can be visualized using the ``diagram``
command.

An incremental merge can be interrupted and resumed arbitrarily, or
even pushed to a server to allow somebody else to work on it.

``git-imerge`` comes with a Bash completion script. It can be installed
by copying ``git-imerge.bashcomplete`` to the place where usually completion
scripts are installed on your system, e.g. /etc/bash_completion.d/.


Requirements
============

``git-imerge`` requires:

* A Python interpreter; either

  * Python 2.x, version 2.6 or later.  If you are using Python
    2.6.x, then you have to install the ``argparse`` module yourself,
    as it was only added to the standard library in Python 2.7.

  * Python 3.x, version 3.3 or later.

  The script tries to use a Python interpreter called ``python`` in
  your ``PATH``.  If your Python interpreter has a different name or
  is not in your ``PATH``, please adjust the first line of the script
  accordingly.

* A recent version of Git.

Bash completion requires Git's completion being available.


Instructions
============

To start a merge or rebase operation using ``git-imerge``, you use
commands that are similar to the corresponding ``git`` commands:

.. list-table:: Starting an incremental merge or rebase
   :header-rows: 1

   * - ``git-imerge`` command
     - ``git`` analogue
     - Effect
   * - ``git-imerge merge BRANCH``
     - ``git merge BRANCH``
     - Merge ``BRANCH`` into the current branch.
   * - ``git-imerge rebase BRANCH``
     - ``git rebase BRANCH``
     - Rebase the current branch on top of ``BRANCH``
   * - ``git-imerge revert COMMIT``
     - ``git revert COMMIT``
     - Add a new commit that undoes the effect of ``COMMIT``
   * - ``git-imerge revert COMMIT1..COMMIT2``
     - ``git revert COMMIT1..COMMIT2``
     - Add new commits that undo the effects of ``COMMIT1..COMMIT2``
   * - ``git-imerge drop COMMIT``
     - ``git rebase --onto COMMIT^ COMMIT``
     - Entirely delete commit ``COMMIT`` from the history of the
       current branch
   * - ``git-imerge drop COMMIT1..COMMIT2``
     - ``git rebase --onto COMMIT1 COMMIT2``
     - Entirely delete commits ``COMMIT1..COMMIT2`` from the history
       of the current branch

(``git-imerge drop`` is also analogous to running ``git rebase
--interactive``, then deleting the specified commit(s) from the
history.)

A few more options are available if you start the incremental merge
using ``git imerge start``::

    git-imerge start --name=NAME --goal=GOAL [--first-parent] BRANCH

where

``NAME``
    is the name for this merge (and also the default name of the
    branch to which the results will be saved).

``GOAL``
    describes how you want to simplify the results (see next
    section).

After the incremental merge is started, you will be presented with any
conflicts that have to be resolved.  The basic procedure is similar
to performing an incremental merge using ``git``::

    while not done:
        <fix the conflict that is presented to you>
        <"git add" the files that you changed>
        git-imerge continue

When you have resolved all of the conflicts, you finish the
incremental merge by typing::

    git-imerge finish

That should be enough to get you going.  All of these subcommands have
additional options; to learn about them type::

    git-imerge --help
    git-imerge SUBCMD --help


Simplifying results
-------------------

When the incremental merge is finished, you can simplify its results
in various ways before recording it in your project's permanent
history by using either the ``finish`` or ``simplify`` command.  The
"goal" of the incremental merge can be one of the following:

``merge``
    keep only a simple merge of the second branch into the first
    branch, discarding all intermediate merges.  The end result is
    similar to what you would get from ::

        git checkout BRANCH1
        git merge BRANCH2

``rebase``
    keep the versions of the commits from the second branch rebased
    onto the first branch.  The end result is similar to what you
    would get from ::

        git checkout BRANCH2
        git rebase BRANCH1

``rebase-with-history``
    like ``rebase``, except that it retains the old versions of the
    rebased commits in the history.  It is equivalent to merging the
    commits from ``BRANCH2`` into ``BRANCH1``, one commit at a
    time. In other words, it transforms this::

        o---o---o---o          BRANCH1
             \
              A---B---C---D    BRANCH2

    into this::

        o---o---o---o---A'--B'--C'--D'   NEW_BRANCH
             \         /   /   /   /
              --------A---B---C---D

    It is safe to rebase an already-published branch using this
    approach.  See [2]_ for more information.

``full``
    don't simplify the incremental merge at all: do all of the
    intermediate merges and retain them all in the permanent history.


Technical notes
===============

Suspending/resuming
-------------------

When ``git-imerge`` needs to ask the user to do a merge manually, it
creates a temporary branch ``refs/heads/imerge/NAME`` to hold the
result. If you want to suspend an incremental merge to do something
else before continuing, all you need to do is abort any pending merge
using ``git merge --abort`` and switch to your other branch. When you
are ready to resume the incremental merge, just type ``git imerge
continue``.

If you need to completely abort an in-progress incremental merge,
first remove the temporary branches ``git-imerge`` creates using
``git-imerge remove``, then checkout the branch you were in before you
started the incremental merge with ``git checkout ORIGINAL_BRANCH``.


Storage
-------

``git-imerge`` records all of the intermediate state about an
incremental merge in the Git object database as a bunch of references
under ``refs/imerge/NAME``, where ``NAME`` is the name of the imerge:

* ``refs/imerge/NAME/state`` points to a blob that describes the
  current state of the imerge in JSON format; for example,

  * The tips of the two branches that are being merged

  * The current "blocker" merges (merges that the user will have to do
    by hand), if any

  * The simplification goal

  * The name of the branch to which the result will be written.

* ``refs/imerge/NAME/manual/I-J`` and ``refs/imerge/NAME/auto/I-J``
  refer to the manual and automatic merge commits, respectively, that
  have been done so far as part of the incremental merge. ``I`` and
  ``J`` are integers indicating the location ``(I,J)`` of the merge in
  the incremental merge diagram.


Transferring an in-progress imerge between repositories
-------------------------------------------------------

It might sometimes be convenient to transfer an in-progress
incremental merge from one Git repository to another. For example, you
might want to make a backup of the current state, or continue an
imerge at home that you started at work, or ask a colleague to do a
particular pairwise merge for you. Since all of the imerge state is
stored in the Git object database, this can be done by
pushing/fetching the references named in the previous section. For
example, ::

    git push --prune origin +refs/imerge/NAME/*:refs/imerge/NAME/*

or ::

    git fetch --prune origin +refs/imerge/NAME/*:refs/imerge/NAME/*

Please note that these commands *overwrite* any state that already
existed in the destination repository. There is currently no support
for combining the work done by two people in parallel on an
incremental merge, so for now you'll just have to take turns.


Interaction with ``git rerere``
-------------------------------

``git rerere`` is a nice tool that records how you resolve merge
conflicts, and if it sees the same conflict again it tries to
automatically reuse the same resolution.

Since ``git-imerge`` attempts so many similar test merges, it is easy
to imagine ``rerere`` getting confused. Moreover, ``git-imerge``
relies on a merge resolving (or not resolving) consistently if it is
carried out more than once. Having ``rerere`` store extra information
behind the scenes could therefore confuse ``git-imerge``.

Indeed, in testing it appeared that during incremental merges, the
interaction of ``git-imerge`` with ``rerere`` was sometimes causing
merge conflicts to be resolved incorrectly. Therefore, ``git-imerge``
explicitly turns rerere off temporarily whenever it invokes git.


Log messages for pairwise merge commits
---------------------------------------

When ``git imerge continue`` or ``git imerge record`` finds a resolved
merge in the working tree, it commits that merge then incorporates it
into the incremental merge. Usually it just uses Git's autogenerated
commit message for such commits. If you want to be prompted to edit
such commit messages, you can either specify ``--edit`` on the command
line or change the default in your configuration::

    git config --global imerge.editmergemessages true


License
=======

``git-imerge`` is released as open-source software under the GNU
General Public License (GPL), version 2 or later. See file ``COPYING``
for more information.


References
==========

.. [1]
   * http://softwareswirl.blogspot.com/2012/12/the-conflict-frontier-of-nightmare-merge.html
   * http://softwareswirl.blogspot.com/2012/12/mapping-merge-conflict-frontier.html
   * http://softwareswirl.blogspot.com/2012/12/real-world-conflict-diagrams.html
   * http://softwareswirl.blogspot.com/2013/05/git-incremental-merge.html
   * http://softwareswirl.blogspot.com/2013/05/one-merge-to-rule-them-all.html
   * http://softwareswirl.blogspot.com/2013/05/incremental-merge-vs-direct-merge-vs.html
   * http://softwareswirl.blogspot.com/2013/05/git-imerge-practical-introduction.html

.. [2]
   * http://softwareswirl.blogspot.com/2009/04/truce-in-merge-vs-rebase-war.html
   * http://softwareswirl.blogspot.com/2009/08/upstream-rebase-just-works-if-history.html
   * http://softwareswirl.blogspot.com/2009/08/rebase-with-history-implementation.html


