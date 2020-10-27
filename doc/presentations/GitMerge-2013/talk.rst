.. include:: <s5defs.txt>

.. |bullet| unicode:: U+02022

.. footer::

   Michael Haggerty |bullet| ``mhagger@alum.mit.edu`` |bullet| GitMerge conference 2013

==========
git-imerge
==========

.. class:: center

   ``https://github.com/mhagger/git-imerge``

   **Incremental merging for Git**

   | "git-merge on steroids"
   | or
   | "git-rebase for the masses"

   | Michael Haggerty
   | ``mhagger@alum.mit.edu``
   | ``https://softwareswirl.blogspot.com/``

Overview
========

* Why you need it

* What it does

* How to use it


Why incremental merge?
======================

.. class:: incremental

   .. container::

      There are two standard alternatives for combining branches:

      * ``git merge``

      * ``git rebase``

   Both have serious problems.

``git merge`` pain
==================

.. class:: incremental

   You need to resolve **one big conflict** that mixes up a lot of little
   changes on both sides of the merge.

   (Resolving big conflicts is **hard**!)

``git merge`` pain (cont'd)
===========================

.. class:: incremental

   Merging is **all-or-nothing**.  There is **no way to save** a
   partly-done merge, so

   * You can't record your progress.

   * You can't switch to another branch temporarily.

   * If you make a mistake, you can't go back.

   If you cannot resolve the **whole** conflict, there is nothing to
   do but start over.

``git merge`` pain (cont'd)
===========================

.. class:: incremental

   * There is **no way to test** a partly-done merge.

     .. class:: incremental

        (The code won't even build until the conflict is completely resolved.)

   * It is **difficult to collaborate** on a merge with a colleague.


``git rebase`` pain
===================

.. class:: incremental

   * You have to reconcile each of the branch commits with *all* of the
     changes on master.

   * Rebasing is **all-or-nothing**; it is awkward to interrupt a rebase
     while it is in progress.

   * Rebasing is **unfriendly to collaboration**; it is problematic to
     rebase work that has been published.

``git rebase`` pain (cont'd)
============================

.. class:: incremental

   * Rebasing **discards history** (namely the old version of the
     branch).

   * Rebasing often requires similar conflicts to be **resolved multiple
     times**.


Incremental merge
=================

``git-imerge`` implements a new merging method, **incremental merge**,
that reduces the pain of merging to its essential minimum.


``git-imerge``
==============

.. class:: incremental

   ``git-imerge`` presents conflicts pairwise, **one commit from each
   branch**

   * Small conflicts are *much* easier to resolve than large
     conflicts.

   * You can view commit messages and individual diffs to see what
     each commit was trying to do.


``git-imerge`` (cont'd)
=======================

.. class:: incremental

   ``git-imerge`` **records all intermediate merges**

   ...with their correct ancestry,

   ...as commits in your repository.

   Because of this, an incremental merge...

   * ...can be **interrupted**.

   * ...can be **pushed to a server**.

   * ...can be **pulled by a colleague**, worked on, and pushed again.


``git-imerge`` (cont'd)
=======================

.. class:: incremental

   ``git-imerge`` **never shows the same conflict twice**.

   * Once a conflict has been resolved, it is stored in the DAG to
     make future merges easier.

   ``git-imerge`` lets you **test every intermediate state**.

   * If there is a problem, you can use ``git bisect`` to find the exact
     pairwise merge that was faulty.

   * You can redo that merge and continue the incremental merge from
     there (retaining earlier pairwise merges).


``git-imerge`` (cont'd)
=======================

.. class:: incremental

   ``git-imerge`` is **largely automated** and **surprisingly efficient**.

   ``git-imerge`` allows the final merge to be **simplified for the
   permanent record**, omitting the intermediate results.


The basic idea
==============

Suppose you want to merge "branch" into "master"::

    o - 0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 11    ← master
         \
          A - B - C - D - E - F - G                        ← branch

.. class:: incremental

   First draw the diagram a bit differently...


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |
        A
        |
        B
        |
        C
        |
        D
        |
        E
        |
        F
        |
        G

        ↑
      branch

.. class:: incremental

   Now start filling it in, merging one pair at a time...


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |
        A - A1
        |
        B
        |
        C
        |
        D
        |
        E
        |
        F
        |
        G

        ↑
      branch

.. class:: incremental

   "A1" is a merge commit between commit "1" on master and commit "A"
   on branch.  It has two parents, like any merge commit.

   ``git-imerge`` stores commit A1 to your repository.


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |
        A - A1
        |   |
        B - B1
        |
        C
        |
        D
        |
        E
        |
        F
        |
        G

        ↑
      branch

.. class:: incremental

   B1 is a merge between A1 and B.

   B1 only has to add the changes from commit B to state A1...

   ...or equivalently, the changes from 1 into state B.


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |
        A - A1
        |   |
        B - B1
        |
        C
        |
        D
        |
        E
        |
        F
        |
        G

        ↑
      branch

.. class:: incremental

   Most of these pairwise merges will not conflict, and ``git-imerge``
   will do them for you automatically

   ...until it finds a conflict...


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |
        A - A1
        |   |
        B - B1
        |   |
        C - C1
        |
        D
        |
        E
        |
        F
        |
        G

        ↑
      branch


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |
        A - A1
        |   |
        B - B1
        |   |
        C - C1
        |   |
        D - D1
        |
        E
        |
        F
        |
        G

        ↑
      branch


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |
        A - A1
        |   |
        B - B1
        |   |
        C - C1
        |   |
        D - D1
        |   |
        E - E1
        |
        F
        |
        G

        ↑
      branch


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |
        A - A1
        |   |
        B - B1
        |   |
        C - C1
        |   |
        D - D1
        |   |
        E - E1
        |   |
        F - F1
        |
        G

        ↑
      branch


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |
        A - A1
        |   |
        B - B1
        |   |
        C - C1
        |   |
        D - D1
        |   |
        E - E1
        |   |
        F - F1
        |   |
        G - G1

        ↑
      branch


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |
        B - B1
        |   |
        C - C1
        |   |
        D - D1
        |   |
        E - E1
        |   |
        F - F1
        |   |
        G - G1

        ↑
      branch


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |
        C - C1
        |   |
        D - D1
        |   |
        E - E1
        |   |
        F - F1
        |   |
        G - G1

        ↑
      branch


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |    |
        C - C1 - C2
        |   |
        D - D1
        |   |
        E - E1
        |   |
        F - F1
        |   |
        G - G1

        ↑
      branch

.. class:: incremental

   Falling asleep?

   (No wonder; ``git-imerge`` is doing all the work.)

   It's time for a little quiz.


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |    |
        C - C1 - C2
        |   |
        D - D1
        |   |
        E - E1
        |   |
        F - F1
        |   |
        G - G1

        ↑
      branch

.. class:: incremental

   What is the meaning of C2?

   It adds the changes from commit C to state B2...

   ...equivalently, it adds the changes from commit 2 to state C1.


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |    |
        C - C1 - C2
        |   |
        D - D1
        |   |
        E - E1
        |   |
        F - F1
        |   |
        G - G1

        ↑
      branch

**Important take-home message**:

.. class:: incremental

   * Each of these merges adds the changes from *one single* commit to
     a state that has already been committed.

   * Git knows a nearby common ancestor.


The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |    |
        C - C1 - C2
        |   |    |
        D - D1 - D2
        |   |
        E - E1
        |   |
        F - F1
        |   |
        G - G1

        ↑
      branch

The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |    |
        C - C1 - C2
        |   |    |
        D - D1 - D2
        |   |    |
        E - E1 - E2
        |   |
        F - F1
        |   |
        G - G1

        ↑
      branch

The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |    |
        C - C1 - C2
        |   |    |
        D - D1 - D2
        |   |    |
        E - E1 - E2
        |   |
        F - F1   X
        |   |
        G - G1

        ↑
      branch

OOPS!  Conflict at X.

.. class:: incremental

   ``git-imerge`` needs your help!

   Please merge E2 and F1 to make a commit F2

The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |    |
        C - C1 - C2
        |   |    |
        D - D1 - D2
        |   |    |
        E - E1 - E2
        |   |
        F - F1   X
        |   |
        G - G1

        ↑
      branch

.. class:: incremental

   The commits share E1 as a common ancestor ("merge base").

   You need to add the change made in commit F to state E2...

   ...or equivalently, add the change made in commit 2 to state
   F1.

The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |
        A - A1 - A2
        |   |    |
        B - B1 - B2
        |   |    |
        C - C1 - C2
        |   |    |
        D - D1 - D2
        |   |    |
        E - E1 - E2
        |   |    |
        F - F1 - F2
        |   |
        G - G1

        ↑
      branch

.. class:: incremental

   Continue in this manner until the diagram is complete...

The basic idea (cont'd)
=======================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |    |    |    |    |    |    |    |     |     |
        A - A1 - A2 - A3 - A4 - A5 - A6 - A7 - A8 - A9 - A10 - A11
        |   |    |    |    |    |    |    |    |    |     |     |
        B - B1 - B2 - B3 - B4 - B5 - B6 - B7 - B8 - B9 - B10 - B11
        |   |    |    |    |    |    |    |    |    |     |     |
        C - C1 - C2 - C3 - C4 - C5 - C6 - C7 - C8 - C9 - C10 - C11
        |   |    |    |    |    |    |    |    |    |     |     |
        D - D1 - D2 - D3 - D4 - D5 - D6 - D7 - D8 - D9 - D10 - D11
        |   |    |    |    |    |    |    |    |    |     |     |
        E - E1 - E2 - E3 - E4 - E5 - E6 - E7 - E8 - E9 - E10 - E11
        |   |    |    |    |    |    |    |    |    |     |     |
        F - F1 - F2 - F3 - F4 - F5 - F6 - F7 - F8 - F9 - F10 - F11
        |   |    |    |    |    |    |    |    |    |     |     |
        G - G1 - G2 - G3 - G4 - G5 - G6 - G7 - G8 - G9 - G10 - G11

        ↑
      branch

.. class:: incremental

   Done!

   A completed incremental merge contains all of the information you
   could possibly want to know about combining two branches.


Simplifying the results
=======================

.. class:: incremental

   ...in fact, it knows *too much* information.

   You probably want to eliminate some of the intermediate information
   before storing it in your project's permanent record.

   For example...


Simplifying the results (cont'd)
================================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |    |    |    |    |    |    |    |     |     |
        A - A1 - A2 - A3 - A4 - A5 - A6 - A7 - A8 - A9 - A10 - A11
        |   |    |    |    |    |    |    |    |    |     |     |
        B - B1 - B2 - B3 - B4 - B5 - B6 - B7 - B8 - B9 - B10 - B11
        |   |    |    |    |    |    |    |    |    |     |     |
        C - C1 - C2 - C3 - C4 - C5 - C6 - C7 - C8 - C9 - C10 - C11
        |   |    |    |    |    |    |    |    |    |     |     |
        D - D1 - D2 - D3 - D4 - D5 - D6 - D7 - D8 - D9 - D10 - D11
        |   |    |    |    |    |    |    |    |    |     |     |
        E - E1 - E2 - E3 - E4 - E5 - E6 - E7 - E8 - E9 - E10 - E11
        |   |    |    |    |    |    |    |    |    |     |     |
        F - F1 - F2 - F3 - F4 - F5 - F6 - F7 - F8 - F9 - F10 - F11
        |   |    |    |    |    |    |    |    |    |     |     |
        G - G1 - G2 - G3 - G4 - G5 - G6 - G7 - G8 - G9 - G10 - G11

        ↑
      branch

.. class:: incremental

   Q: Where is the simple merge of "branch" and "master"?

   A: G11


Simplifying the results (cont'd)
================================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11
        |                                                       |
        A                                                       |
        |                                                       |
        B                                                       |
        |                                                       |
        C                                                       |
        |                                                       |
        D                                                       |
        |                                                       |
        E                                                       |
        |                                                       |
        F                                                       |
        |                                                       |
        G ---------------------------------------------------- G11'  ← master

        ↑
      branch

Q: Where is the simple merge of "branch" and "master"?

A: G11


Simplifying the results (cont'd)
================================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11
        |                                                       |
        A                                                       |
        |                                                       |
        B                                                       |
        |                                                       |
        C                                                       |
        |                                                       |
        D                                                       |
        |                                                       |
        E                                                       |
        |                                                       |
        F                                                       |
        |                                                       |
        G ---------------------------------------------------- G11'  ← master

        ↑
      branch

Usually such a diagram is drawn like so::

  o - 0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 11 - G11'  ← master
       \                                               /
        A ---- B ---- C ----- D ----- E ----- F ----- G       ← branch


Simplifying the results (cont'd)
================================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |    |    |    |    |    |    |    |     |     |
        A - A1 - A2 - A3 - A4 - A5 - A6 - A7 - A8 - A9 - A10 - A11
        |   |    |    |    |    |    |    |    |    |     |     |
        B - B1 - B2 - B3 - B4 - B5 - B6 - B7 - B8 - B9 - B10 - B11
        |   |    |    |    |    |    |    |    |    |     |     |
        C - C1 - C2 - C3 - C4 - C5 - C6 - C7 - C8 - C9 - C10 - C11
        |   |    |    |    |    |    |    |    |    |     |     |
        D - D1 - D2 - D3 - D4 - D5 - D6 - D7 - D8 - D9 - D10 - D11
        |   |    |    |    |    |    |    |    |    |     |     |
        E - E1 - E2 - E3 - E4 - E5 - E6 - E7 - E8 - E9 - E10 - E11
        |   |    |    |    |    |    |    |    |    |     |     |
        F - F1 - F2 - F3 - F4 - F5 - F6 - F7 - F8 - F9 - F10 - F11
        |   |    |    |    |    |    |    |    |    |     |     |
        G - G1 - G2 - G3 - G4 - G5 - G6 - G7 - G8 - G9 - G10 - G11

        ↑
      branch

.. class:: incremental

   Q: Where is the rebase of "branch" onto "master"?

   A: The rightmost column...

Simplifying the results (cont'd)
================================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
                                                                |
                                                               A11'
                                                                |
                                                               B11'
                                                                |
                                                               C11'
                                                                |
                                                               D11'
                                                                |
                                                               E11'
                                                                |
                                                               F11'
                                                                |
                                                               G11'  ← branch

Q: Where is the rebase of "branch" onto "master"?

A: The rightmost column.



Simplifying the results (cont'd)
================================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |    |    |    |    |    |    |    |     |     |
        A - A1 - A2 - A3 - A4 - A5 - A6 - A7 - A8 - A9 - A10 - A11
        |   |    |    |    |    |    |    |    |    |     |     |
        B - B1 - B2 - B3 - B4 - B5 - B6 - B7 - B8 - B9 - B10 - B11
        |   |    |    |    |    |    |    |    |    |     |     |
        C - C1 - C2 - C3 - C4 - C5 - C6 - C7 - C8 - C9 - C10 - C11
        |   |    |    |    |    |    |    |    |    |     |     |
        D - D1 - D2 - D3 - D4 - D5 - D6 - D7 - D8 - D9 - D10 - D11
        |   |    |    |    |    |    |    |    |    |     |     |
        E - E1 - E2 - E3 - E4 - E5 - E6 - E7 - E8 - E9 - E10 - E11
        |   |    |    |    |    |    |    |    |    |     |     |
        F - F1 - F2 - F3 - F4 - F5 - F6 - F7 - F8 - F9 - F10 - F11
        |   |    |    |    |    |    |    |    |    |     |     |
        G - G1 - G2 - G3 - G4 - G5 - G6 - G7 - G8 - G9 - G10 - G11

        ↑
      branch

.. class:: incremental

   Q: Where is the rebase of "master" onto "branch"?

   A: The bottommost row...

Simplifying the results (cont'd)
================================

::

    o - 0
        |
        A
        |
        B
        |
        C
        |
        D
        |
        E
        |
        F
        |
        G - G1'- G2'- G3'- G4'- G5'- G6'- G7'- G8'- G9'- G10'- G11'  ← master

        ↑
      branch

Q: Where is the rebase of "master" onto "branch"?

A: The bottommost row.


Simplifying the results (cont'd)
================================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |    |    |    |    |    |    |    |     |     |
        A - A1 - A2 - A3 - A4 - A5 - A6 - A7 - A8 - A9 - A10 - A11
        |   |    |    |    |    |    |    |    |    |     |     |
        B - B1 - B2 - B3 - B4 - B5 - B6 - B7 - B8 - B9 - B10 - B11
        |   |    |    |    |    |    |    |    |    |     |     |
        C - C1 - C2 - C3 - C4 - C5 - C6 - C7 - C8 - C9 - C10 - C11
        |   |    |    |    |    |    |    |    |    |     |     |
        D - D1 - D2 - D3 - D4 - D5 - D6 - D7 - D8 - D9 - D10 - D11
        |   |    |    |    |    |    |    |    |    |     |     |
        E - E1 - E2 - E3 - E4 - E5 - E6 - E7 - E8 - E9 - E10 - E11
        |   |    |    |    |    |    |    |    |    |     |     |
        F - F1 - F2 - F3 - F4 - F5 - F6 - F7 - F8 - F9 - F10 - F11
        |   |    |    |    |    |    |    |    |    |     |     |
        G - G1 - G2 - G3 - G4 - G5 - G6 - G7 - G8 - G9 - G10 - G11

        ↑
      branch

.. class:: incremental

   If you have already published branch, consider simplifying into a
   "rebase with history"...

Simplifying the results (cont'd)
================================

::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11   ← master
        |                                                       |
        A ---------------------------------------------------- A11'
        |                                                       |
        B ---------------------------------------------------- B11'
        |                                                       |
        C ---------------------------------------------------- C11'
        |                                                       |
        D ---------------------------------------------------- D11'
        |                                                       |
        E ---------------------------------------------------- E11'
        |                                                       |
        F ---------------------------------------------------- F11'
        |                                                       |
        G ---------------------------------------------------- G11'

                                                                ↑
                                                              branch

.. class:: incremental

   Rebase-with-history is a useful hybrid between rebasing and
   merging:

   * It retains both the old and the new versions of branch.

   * It can be used even if branch has been published.


Efficiency
==========

.. class:: incremental

   In most cases ``git-imerge`` does not have to construct the full
   incremental merge.

   It uses an efficient algorithm, based on bisection, for filling in
   large blocks of the incremental merge quickly and homing in on the
   conflicts.


Efficiency (cont'd)
===================

A typical in-progress merge might look like this::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |    |    |    |    |    |    |    |     |     |
        A - A1 - A2 - A3 - A4 - A5 - A6 - A7 - A8 - A9 - A10 - A11
        |   |    |    |    |    |    |    |    |
        B - B1 - B2 - B3 - B4 - B5 - B6 - B7 - B8   X
        |   |    |    |    |    |    |
        C - C1 - C2 - C3 - C4 - C5 - C6   X
        |   |    |    |    |    |    |
        D - D1 - D2 - D3 - D4 - D5 - D6
        |   |    |    |    |    |    |
        E - E1 - E2 - E3 - E4 - E5 - E6
        |   |
        F - F1   X
        |   |
        G - G1

        ↑
      branch

.. class:: incremental

   * The Xs marks pairwise merges that conflict


Efficiency (cont'd)
===================

But ``git-imerge`` only needs to compute this::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |    |    |    |    |    |    |    |     |     |
        A -   --   --   --   --   -- A6 -   -- A8 - A9 - A10 - A11
        |   |    |    |    |    |    |    |    |
        B -   --   --   --   --   -- B6 - B7 - B8   X
        |   |    |    |    |    |    |
        C -   --   --   --   --   -- C6   X
        |   |    |    |    |    |    |
        D -   --   --   --   --   -- D6
        |   |    |    |    |    |    |
        E - E1 - E2 - E3 - E4 - E5 - E6
        |   |
        F - F1   X
        |   |
        G - G1

        ↑
      branch

.. class:: incremental

   (Plus a few test merges to locate the conflicts.)


Efficiency (cont'd)
===================

But ``git-imerge`` only needs to compute this::

    o - 0 - 1  - 2  - 3  - 4  - 5  - 6  - 7  - 8  - 9  - 10  - 11    ← master
        |   |    |    |    |    |    |    |    |    |     |     |
        A -   --   --   --   --   -- A6 -   -- A8 - A9 - A10 - A11
        |   |    |    |    |    |    |    |    |
        B -   --   --   --   --   -- B6 - B7 - B8   X
        |   |    |    |    |    |    |
        C -   --   --   --   --   -- C6   X
        |   |    |    |    |    |    |
        D -   --   --   --   --   -- D6
        |   |    |    |    |    |    |
        E - E1 - E2 - E3 - E4 - E5 - E6
        |   |
        F - F1   X
        |   |
        G - G1

        ↑
      branch

.. class:: incremental

   The gaps could be skipped because the merges on the boundaries were
   all successful.


git-imerge demo
===============

Time for a simple demo.


git-imerge demo
===============

Time for a simple demo.

You start like ``git merge``::

    $ git checkout master
    $ git imerge start --name=merge-branch --first-parent branch

.. class:: incremental

   Each imerge gets a name.


git-imerge demo (cont'd)
========================

``git-imerge`` uses bisection to find pairwise merges that conflict,
filling everything it can::

    Attempting automerge of 1-1...success.
    Attempting automerge of 1-4...success.
    Attempting automerge of 1-6...success.
    Attempting automerge of 9-6...failure.
    Attempting automerge of 5-6...failure.
    Attempting automerge of 3-6...success.
    Attempting automerge of 4-6...failure.
    Attempting automerge of 4-1...success.
    Attempting automerge of 4-4...failure.
    Attempting automerge of 4-3...failure.
    Attempting automerge of 4-2...success.
    Attempting automerge of 9-2...success.
    Autofilling 1-6...success.
    Autofilling 2-6...success.
    Autofilling 3-1...success.
    Autofilling 3-2...success.
    [...]
    Autofilling 3-6...success.
    Autofilling 4-2...success.
    [...]
    Autofilling 8-2...success.
    Autofilling 9-1...success.
    Autofilling 9-2...success.


git-imerge demo (cont'd)
========================

When it hits a conflict, it asks for help::

    Attempting automerge of 4-3...failure.
    Switched to branch 'imerge/merge-branch'
    Auto-merging conflict.txt
    CONFLICT (add/add): Merge conflict in conflict.txt
    Automatic merge failed; fix conflicts and then commit the result.

    Original first commit:
    commit b7fe8a65d0cee2e388e971c4b29be8c6cbb25ee1
    Author: Lou User <luser@example.com>
    Date:   Fri May 3 14:03:05 2013 +0200

        c conflict

    Original second commit:
    commit bd0373cadae08d872536bcda8214c0631e19945a
    Author: Lou User <luser@example.com>
    Date:   Fri May 3 14:03:05 2013 +0200

        d conflict

    There was a conflict merging commit 4-3, shown above.
    Please resolve the conflict, commit the result, then type

        git-imerge continue


git-imerge demo (cont'd)
========================

You can get a diagram of the current state of the merge (it is in
crude ASCII-art for now)::

    $ git imerge diagram
    **********
    *??|?????|
    *--+-----+
    *??|#?????
    *??|??????
    *??|??????
    *--+??????

    Key:
      |,-,+ = rectangles forming current merge frontier
      * = merge done manually
      . = merge done automatically
      # = conflict that is currently blocking progress
      @ = merge was blocked but has been resolved
      ? = no merge recorded


git-imerge demo (cont'd)
========================

You fix the conflict then tell ``git-imerge`` to continue::

    $ git add ...
    $ git commit
    $ git imerge continue
    Merge has been recorded for merge 4-3.
    Attempting automerge of 5-3...success.
    Attempting automerge of 5-3...success.
    Attempting automerge of 9-3...success.
    Autofilling 5-3...success.
    Autofilling 6-3...success.
    Autofilling 7-3...success.
    Autofilling 8-3...success.
    Autofilling 9-3...success.
    Attempting automerge of 4-4...success.
    Attempting automerge of 4-5...success.
    Attempting automerge of 4-6...success.
    Attempting automerge of 9-6...success.
    Autofilling 4-6...success.
    Autofilling 5-6...success.
    Autofilling 6-6...success.
    Autofilling 7-6...success.
    Autofilling 8-6...success.
    Autofilling 9-4...success.
    Autofilling 9-5...success.
    Autofilling 9-6...success.
    Merge is complete!


git-imerge demo (cont'd)
========================

Here is a diagram of the completed merge::

    $ git imerge diagram
    **********
    *??.?????|
    *??......|
    *??.*....|
    *??.?????|
    *??.?????|
    *--------+

    Key:
      |,-,+ = rectangles forming current merge frontier
      * = merge done manually
      . = merge done automatically
      # = conflict that is currently blocking progress
      @ = merge was blocked but has been resolved
      ? = no merge recorded


git-imerge demo (cont'd)
========================

Now simplify the incremental merge into a simple merge, a simple
rebase, or a rebase-with-history::

    $ git imerge finish --goal=merge
    $ git log -1 --decorate
    commit 79afd870a52e216114596b52c800e45139badf74 (HEAD, merge-branch)
    Merge: 8453321 993a8a9
    Author: Lou User <luser@example.com>
    Date:   Wed May 8 10:08:07 2013 +0200

        Merge frobnicator into floobifier.


Intermediate data
=================

During an incremental merge, intermediate results are stored directly
in your repository as special references under ``refs/imerge/NAME/``:

``refs/imerge/NAME/state``
    A blob containing a little bit of metadata.

``refs/imerge/NAME/{manual,auto}/M-N``
    Manual/automatic merge that includes all of the changes through
    commits ``M`` on master and ``N`` on branch.

``refs/heads/imerge/NAME``
    Temporary branch used when resolving merge conflicts.

``refs/heads/NAME``
    Default branch where final results are stored.


Summary
=======

As of this writing, ``git-imerge`` is very new and still experimental.
Please try it out, but use it cautiously (e.g., on a clone of your
main Git repository).

.. class:: incremental

   | Give me your feedback!
   |     Michael Haggerty
   |     ``mhagger@alum.mit.edu``

   | Get involved!
   |     ``https://github.com/mhagger/git-imerge``

   | For more details, see my blog "SoftwareSwirl":
   |     ``https://softwareswirl.blogspot.com/``
   
   Thank you for your attention!


