======================
Ideas for things to do
======================

Bugs
====

* Find some bugs and fix them :-)

* Check that the capstone merge in a block outline is merged
  correctly.

  * Since the ancestry of its two parents is incomplete, Git would
    probably try to do a recursive merge.  See if we can somehow do
    better without filling in the whole diagram.

  * Compare the merges that would come from continuing each side of
    the outline, and verify that they are identical.


Convenience features
====================

* Add a two-argument form of the ``start`` and ``init`` commands to
  specify both branches in one go.  (Or maybe not, if we want to leave
  the way open to supporting octipus merges!)  Maybe ``--onto=X`` like
  rebase?

* Improve the handling of log messages.  Incorporate log messages from
  manual merge conflicts into suggested log messages for the
  simplified commits.

* Maybe remember the names of the two original branches for use in log
  messages etc.  (Should they be stored locally in ``git config`` or
  shareably in the state blob?)

* Allow the user to specify which conflict he would like to resolve
  next, and set it up for him.

* Allow the user to block certain merges, meaning that they should
  never be skipped over or merged automatically.

* Think about where to leave HEAD in the various scenarios.

* Add a ``git imerge pause`` that puts an imerge on hold and resets
  the working copy to a reasonable state.

* Allow the user to specify a test that is run automatically after
  each automatic merge, (à la ``git bisect run``).


New merge goals and styles
==========================

* Add an option that allows the user to resolve conflicts in larger
  chunks; for example, add a rebase-with-history-type merge where each
  branch commit is merged directly to its final location on the last
  master commit.  (Perhaps ``--conflicts={pairwise|fewest}``.)

* Permit switching between goal/conflict choices when they are
  meaningful while prohibiting nonsensical ones.


Collaboration
=============

* Add ``git imerge push REMOTE`` to push the status of an in-progress
  merge to REMOTE.

* Add ``git imerge pull REMOTE`` to pull the current state of an
  incremental merge from REMOTE.

* Add some kind of ``fetch``-like functionality that stores the result
  into a remote namespace.

* The analogue of "non-fast-forward" for incremental merges is
  different than for other references.  A ``push``/``pull`` should be
  prohibited if:

  * Any of the branches is updated in a non-fast-forward fashion.

  * Any commit I1-I2 is updated (at all!) when there is an existing
    commit I1'-I2' with I1' >= I1 and I2' >= I2.

  * As a safety precaution, the DAG of the retrieved merges should
    probably be checked for self-consistency (see ``git imerge fsck``
    below).

* Add smarter ways to reconcile two versions of an in-progress merge
  that are not fast-forwards of each other.  Probably this should work
  with two arbitrary local merges (one of which is probably from a
  remote).


Flexibility
===========

* Allow commits to be skipped over when merging if, for example, they
  are broken (analogous to ``git bisect skip``).  This should be
  allowed when an imerge is being initialized and also after an imerge
  is in progress.

* Allow arbitrary manual merge commits to be recorded, and be smarter
  about how such commits are integrated.

* Allow recorded merges to be retroactively rejected, adjusting
  subsequent merges accordingly.

  * In first version, just discard all commits that depended on it.

  * In later versions, salvage parts of the subsequent merges when
    possible.


Relax ``--first-parent`` limitation
-----------------------------------

* Allow recursive merges: if one of the ``--first-parent`` merges is
  itself a merge, maybe it can be "exploded" into individual commits
  and these commits merged with the second branch as part of the first
  merge or as a subsidiary merge.

* Allow more complicated topologies in the two branches to be merged,
  and somehow form the appropriate Cartesian product of their commits
  with the correct ancestry.


Tools
=====

* ``git imerge info`` -- show a detailed, human-readable summary of
  all intermediate commits related to this imerge.

* ``git imerge parse M-N`` -- show SHA-1 of the specified merge if
  it has been done.  Maybe also ``git imerge parse NAME/M-N``.

* ``git imerge show M-N`` -- show more, human-readable info about
  the specified imerge.

* ``git imerge list -v`` -- add more information to the display; for
  example, the goals, status, etc. of each imerge.

* ``git imerge status`` -- show the current imerge status (issue #22).
  If the user has been asked to do a merge, show the log messages for
  the two original commits again.


Miscellaneous
=============

* Add a command ``git imerge fsck`` (for lack of a better name) that
  checks the consistency of the intermediate commits (especially their
  DAG).

* Maybe expand diagram to 2x2 characters per merge, to make room for
  more information (e.g., block boundaries could go in the
  interstices).

* Add commit numbers along the axes of merge diagrams.  For the top
  axis, maybe display the numbers vertically or maybe only show every
  fifth number.

* Maybe fix PPM output.

* Maybe keep a record of all merge attempts, successful and failed.

* When running subprocesses, set a more specific value to environment
  variable GIT_IMERGE reflecting exactly what git-imerge is doing at
  the time (e.g., 'autofill', 'automerge', etc.).  See issue #17.

* Add better tools and hints for getting out of a screwed-up merge
  attempt (see, e.g., issue #29).


Testing
=======

* Add a tool that can create two branches with conflicts at
  arbitrary places.  (This is pretty easy--if commit I1-I2 should
  conflict, then make commits I1 and I2 both create a file
  ``conflict-i1-i2`` with differing contents.

* Test various conflict topologies:

  * conflict at (1,1)

  * conflict at (i1,1) or (1,i2)

  * conflict at (1,-1) or (-1,1)

  * conflict at (i1,-1) or (-1,i2)

  * conflict at (-1,-1)

  * adjacent conflicts in various places

* Cook up some way to make conflicts that unexpectedly appear and
  disappear when merged as part of a block vs. pairwise.  (Maybe this
  can be done using commits involving file renames followed by the
  addition of replacements.)  Test such scenarios.


GUI
===

* Maybe add a web interface (implementing using Python's built-in
  webserver) would be easiest.


