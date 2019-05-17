import errno
import subprocess

from setuptools import setup

data_files = []
try:
    completionsdir = subprocess.check_output(
        ["pkg-config", "--variable=completionsdir", "bash-completion"]
    )
except OSError as e:
    if e.errno != errno.ENOENT:
        raise
else:
    completionsdir = completionsdir.strip().decode('utf-8')
    if completionsdir:
        data_files.append((completionsdir, ["completions/git-imerge"]))


setup(
    name="gitimerge",
    description="Incremental merge for git",
    url="https://github.com/mhagger/git-imerge",
    author="Michael Haggerty",
    author_email="mhagger@alum.mit.edu",
    license="GPLv2+",
    version="1.1.0",
    py_modules=["gitimerge"],
    data_files=data_files,
    entry_points={"console_scripts": ["git-imerge = gitimerge:climain"]},
    python_requires=">=2.7, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*",
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "License :: OSI Approved :: GNU General Public License v2 or later (GPLv2+)",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
    ],
)
