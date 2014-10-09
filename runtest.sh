#!/bin/bash
######################################################################
### runtest.sh
######################################################################

if [[ "$#" -eq 0 ]]; then
	names="-name 'test_*.sh'"
else
	for arg in "$@"; do
		names="${names:+$names -o }-iname '*${arg}*'"
	done
fi

test_scripts=( $(eval "find . -type f ! -name '.*' \( $names \) -print | sort") )
separator="----------------------------------------------------------------------"
ret=0

if [[ "${#test_scripts[@]}" -eq 0 ]]; then
	echo "${0}: Found no test" 1>&2; exit 1
fi

start_time=$(date '+%s')

for test_script in "${test_scripts[@]}"; do
	echo -e "${separator}\n"

	$test_script || ret="$?"

	echo
done

end_time=$(date '+%s')

cat <<- EOF
	$separator
	Start Time   $start_time ($(date -d "@$start_time" '+%F %T %z'))
	End Time     $end_time ($(date -d "@$end_time" '+%F %T %z'))
	Elapsed Time $((end_time - start_time)) second(s)
	Exit Status  $ret
	$separator
EOF

exit $ret

######################################################################
### Local Variables:
### mode: shell-script
### coding: utf-8-unix
### tab-width: 4
### End:
######################################################################
