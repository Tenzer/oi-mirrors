Stuff in this repository
========================

bandwidth-per-day.sh
--------------------
Bash script which totals the "size" columns of Apache combined-formatted log files. Not really specific for OpenIndiana.

pkg-to-pkgfiles.py
------------------
Python script which works a bit like `rsync`, it is however specifically to copy files from a IPS repository format, to a directory structure which is the same `pkg(1)` expects, allowing the files to be hosted directly from Apache or another simple web server.

repo-updater.sh
---------------
Bash script to update PKG repositories through rsync, if the source repository is newer than the local repository.
See the top of the script for configuration details.
