# About #
**lls** is a simple script I wrote while learning BASH to suit my needs.
I was not satisfied with ls command and decided to write something of my own.

The thing is that by default **ls** doesn't use "--color" mode, nor does it use the "--group-directories-first" mode. **lls** solves this, providing pleasant colorful highlighting and some easy-to-read permission TAGS for newbies^^

In addition, **lls** shows some basic file info. **Lls** doesn't use **ls** for the inside file processing, it does use **find** (the benefits of which are obvious for those, who have already tried to use **ls** in their scripts).

# Details #
**lls** accepts the following arguments:
> -h, --help this help

> -b, brief list, with file info and sizes omitted

> -a, list all files and directories

> -f, list files only

> -d, list directories only

> -x, list executables only

> -X, list all files except executables and hidden



**lls** uses simple TAGS to describe available permissions for the file or directory.

**TAGS:**

DIR open -- means that user can search into this directory.

DIR closed -- means that user can't search into this directory.

FILE open -- means that this file is writable and readable.

FILE closed -- means that this file is not writable and readable.

FILE open X -- means that this file is writable, readable and executable.

FILE closed X -- means that this file is executable only.

FILE seen X -- means that this file is readable and executable, but not writable.

FILE edit X -- means that this file is writable and executable, but not readable.

FILE edit only -- means that this file is writable only.

FILE seen only -- means that this file is readable only.

FILE zombie -- means that this file is not writable, readable or executable.