#!/usr/bin/bash

######################
# Configuration part #
######################

# Names of repositories to update
REPOSITORIES="dev legacy"

# URL to remote/upstream repository
REMOTESERVER="http://pkg.openindiana.org/"

# Common path to rsync server
RSYNCSOURCE="pkg-origin.openindiana.org::pkgdepot-"

# Common path to repositories on file system
FILESYSTEMPATH="/pkg/"

# Arguments which rsync should use when updating a repository
RSYNCARGUMENTS="-a --delete"

# Common path to lock files
LOCKFILEPATH="/var/run/repo-updater"

########################
# End of configuration #
########################

set -o nounset
set -o errexit
set -o noclobber

updateavailable () {
	INFO="$(pkgrepo info -Hs ${REMOTESERVER}${1})"
	DATETIME="$(echo ${INFO} | cut -d' ' -f4)"
	REMOTE="$(/usr/gnu/bin/date --date=${DATETIME:0:26} +%s)"

	INFO="$(pkgrepo info -Hs file://${FILESYSTEMPATH}${1})"
	DATETIME="$(echo ${INFO} | cut -d' ' -f4)"
	LOCAL="$(/usr/gnu/bin/date --date=${DATETIME:0:26} +%s)"

	if [ "${REMOTE}" -gt "${LOCAL}" ]
	then
		# REMOTE is newer than LOCAL
		return 0
	else
		# REMOTE is older than LOCAL
		return 1
	fi
}

rsyncrepository () {
	echo -n "[${1}] rsync: "
	rsync ${RSYNCARGUMENTS} ${RSYNCSOURCE}${1} ${FILESYSTEMPATH}${1}/
	echo "Done"
}

rebuildrepository () {
	echo -n "[${1}] Rebuild: "
	pkgrepo rebuild -s ${FILESYSTEMPATH}${1} > /dev/null
	svcadm restart svc:/application/pkg/server:${1}
	echo "Done"
}

getlockpid () {
	if [ -f "${LOCKFILEPATH}.${1}" ]
	then
		PID=$(cat ${LOCKFILEPATH}.${1})
		if kill -0 ${PID} 2> /dev/null
		then
			# Means the process with PID=PID exists
			return 1
		else
			rm -f "${LOCKFILEPATH}.${1}"
			return 0
		fi
	else
		return 0
	fi
}

lockrepo () {
	echo "${$}" > "${LOCKFILEPATH}.${1}"
}

unlockrepo () {
	rm -r "${LOCKFILEPATH}.${1}"
}


for REPO in ${REPOSITORIES}
do
	if getlockpid ${REPO}
	then
		if updateavailable ${REPO}
		then
			# If getlockpid returns 0, it means there are no lock file
			lockrepo ${REPO}
			rsyncrepository ${REPO}
			rebuildrepository ${REPO}
			unlockrepo ${REPO}
		else
			echo "[${REPO}] No updates available"
		fi
	else
		echo "[${REPO}] Update already in progress"
	fi
done
