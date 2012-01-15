#!/usr/bin/bash

######################
# Configuration part #
######################

# String passed to "ls" with the path for the log files
LOGSPATH="/var/apache2/2.2/logs/access_log.*"

########################
# End of configuration #
########################

TOTALBYTES=0

for FILE in $(ls ${LOGSPATH})
do
	BYTES=0
	DATE="$(echo ${FILE} | awk -F. '{print $3}')"
	echo -n "${DATE}: "
	echo "${FILE}" | grep -q ".gz$"
	if [ ${?} -eq 0 ]
	then
		# A gzipped file
		BYTES=$(gzcat ${FILE} | awk '{total += $10} END {print total}')
	else
		# An uncompressed file
		BYTES=$(awk '{total += $10} END {print total}' ${FILE})
	fi
	echo ${BYTES} | awk '{printf "%.2f GB\n", $0/1024/1024/1024}'
	TOTALBYTES="$((${TOTALBYTES} + ${BYTES}))"
done

echo ${TOTALBYTES} | awk '{printf "TOTAL:      %.2f GB\n", $0/1024/1024/1024}'