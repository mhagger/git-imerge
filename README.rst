==================================================
git-imerge -- incremental merge and rebase for git
==================================================

Perform the merge between two branches incrementally.  If conflicts
are encountered, figure out exactly which pairs of commits conflict,
and present the user with one pairwise conflict at a time for
resolution.

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

**git-imerge is experimental!  If it breaks, you get to keep the
pieces.  For example, it is strongly recommended that you make a clone
of your git repository and run the script on the clone rather than the
original.  Feedback and bug reports are welcome!**


Using results
=============

When an incremental merge is finished, you can discard the
intermediate merge commits and create a simpler history to record
permanently in your project repository using either the ``finish`` or
``simplify`` command.  The incremental merge can be simplified in one
of three ways:

``merge``
    keep only a simple merge of the second branch into the first
    branch, discarding all intermediate merges.  The result is similar
    to what you would get from ::

        git checkout BRANCH1
        git merge BRANCH2

``rebase``
    keep the versions of the commits from the second branch rebased
    onto the first branch.  The result is similar to what you would
    get from ::

        git checkout BRANCH2
        git rebase BRANCH1

``rebase-with-history``
    like rebase, except that each of the rebased commits is recorded
    as a merge from its original version to its rebased predecessor.
    This is a style of rebasing that does not discard the old version
    of the branch, and allows an already-published branch to be
    rebased.  See [2]_ for more information.


Simple operation
================

For basic operation, you only need to know three ``git-imerge``
commands.  To merge ``BRANCH`` into ``MASTER`` or rebase ``BRANCH``
onto ``MASTER``, ::

    git checkout MASTER
    git-imerge start --name=NAME --goal=GOAL --first-parent BRANCH
    while not done:
        <fix conflict presented to you>
        git commit
        git-imerge continue
    git-imerge finish

where

``NAME``
    is the name for this merge (and also the default name of the
    branch to which the results will be saved)

``GOAL``
    describes how you want to simplify the results:

    * ``merge`` for a simple merge

    * ``rebase`` for a simple rebase

    * ``rebase-with-history`` for a rebase that retains history.  This
      is equivalent to merging the commits from BRANCH into MASTER, one
      commit at a time. In other words, it transforms this::

          o---o---o---o          MASTER
               \
                A---B---C---D    BRANCH

      into this::

          o---o---o---o---A'--B'--C'--D'    MASTER
               \         /   /   /   /
                --------A---B---C---D       BRANCH

      This is like a rebase, except that it retains the history of
      individual merges.  See [2]_ for more information.


License
=======

``git-imerge`` is released as open-source software under the GNU
General Public License (GPL), version 2 or later.


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


