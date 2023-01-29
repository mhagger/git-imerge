import errno
import subprocess

from setuptools import setup

with open("README.md", "r") as fh:
    long_description = fh.read()

data_files = []
try:
    completionsdir = subprocess.check_output(
        ["pkg-config", "--variable=completionsdir", "bash-completion"]
    )
except OSError as e:
    if e.errno != errno.ENOENT:
        raise
except subprocess.CalledProcessError:
    # `bash-completion` is probably not installed. Just skip it.
    pass
else:
    completionsdir = completionsdir.strip().decode('utf-8')
    if completionsdir:
        data_files.append((completionsdir, ["completions/git-imerge"]))


setup(
    name="git-imerge",
    description="Incremental merge and rebase for Git",
    url="https://github.com/mhagger/git-imerge",
    version="1.2.0",
    author="Michael Haggerty",
    author_email="mhagger@alum.mit.edu",
    long_description=long_description,
    long_description_content_type="text/markdown",
    license="GPLv2+",
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
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Version Control :: Git",
    ],
)
