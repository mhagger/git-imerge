#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8

from distutils.core import setup

setup(
    name = 'gitimerge',
    description = 'Incremental merge for git',
    author='Michael Haggerty',
    author_email='mhagger@alum.mit.edu',
    url='https://github.com/mhagger/git-imerge',
    packages=['gitimerge'],
    license='GPL',
    scripts=['bin/git-imerge']
)

