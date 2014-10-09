######################################################################
### bashunit.sh
######################################################################

[[ -z "$BASH" || "$__BASHUNIT_SH__" == 'true' ]] && return

declare -r __BASHUNIT_SH__='true'
declare -a __TEST_FUNCTIONS__=()

shopt -s expand_aliases

function regist_test(){
	__TEST_FUNCTIONS__=( ${__TEST_FUNCTIONS__[@]} $1 )
}

function regist_all_tests(){
	__TEST_FUNCTIONS__=( $(typeset -F | awk '/^declare -f '"${1:-test_}"'.+$/ {print $3}') )
}

function run_tests(){
	(
		local         _setup_once_function=$(typeset -F setup_once        )
		local      _teardown_once_function=$(typeset -F teardown_once     )
		local    _setup_everytime_function=$(typeset -F setup_everytime   )
		local _teardown_everytime_function=$(typeset -F teardown_everytime)
		local _test_function _test_cnt=0 _success_cnt=0 _failure_cnt=0 _failure_record_file

		_failure_record_file=$(mktemp) || exit $?

		trap 'exit 2' 1 2 3 15
		trap 'rm -f -- "$_failure_record_file"' 0

		echo -e "$(uname -a)\n$BASH $BASH_VERSION (${BASH_VERSINFO[@]})\n\nExecuting $0 ...\n"

		$_setup_once_function

		for _test_function in "${__TEST_FUNCTIONS__[@]}"; do
			$_setup_everytime_function

			printf -- "%-65s" "$_test_function"
			$_test_function

			((_test_cnt++))
			if is_failed; then
				echo '[NG]'; print_failure; clear_failure
				((_failure_cnt++))
			else
				echo '[OK]'
				((_success_cnt++))
			fi

			$_teardown_everytime_function
		done

		$_teardown_once_function

		echo -e "\nRan $_test_cnt test(s) (Passed $_success_cnt / Failed $_failure_cnt)"

		exit $((_failure_cnt == 0 ? 0 : 1))
	)
}

function _assert(){
	eval "$2" && return 0

	record_failure 'Line: %d\nFailed: [%s]\n\n' "$1" "$2"

	return 1
}
alias assert='_assert "$LINENO"'

function _assert_eq(){
	[[ "$2" -eq "$3" ]] && return 0

	record_failure 'Line: %d\nExpected number: [%s]\nActual number:   [%s]\n\n' "$1" "$2" "$3"

	return 1
}
alias assert_eq='_assert_eq "$LINENO"'

function _assert_ne(){
	[[ "$2" -ne "$3" ]] && return 0

	record_failure 'Line: %d\nUnexpected number: [%s]\nActual number:     [%s]\n\n' "$1" "$2" "$3"

	return 1
}
alias assert_ne='_assert_ne "$LINENO"'

function _assert_equal(){
	[[ "$2" == "$3" ]] && return 0

	record_failure 'Line: %d\nExpected string: [%s]\nActual string:   [%s]\n\n' "$1" "$2" "$3"

	return 1
}
alias assert_equal='_assert_equal "$LINENO"'

function _assert_not_equal(){
	[[ "$2" != "$3" ]] && return 0

	record_failure 'Line: %d\nUnexpected string: [%s]\nActual string:     [%s]\n\n' "$1" "$2" "$3"

	return 1
}
alias assert_not_equal='_assert_not_equal "$LINENO"'

function _assert_equal_pattern(){
	[[ "$3" == $2 ]] && return 0

	record_failure 'Line: %d\nExpected string: [%s]\nActual string:   [%s]\n\n' "$1" "$2" "$3"

	return 1
}
alias assert_equal_pattern='_assert_equal_pattern "$LINENO"'

function _assert_not_equal_pattern(){
	[[ "$3" != $2 ]] && return 0

	record_failure 'Line: %d\nUnexpected string: [%s]\nActual string:     [%s]\n\n' "$1" "$2" "$3"

	return 1
}
alias assert_not_equal_pattern='_assert_not_equal_pattern "$LINENO"'

function record_failure(){
	printf -- "$@" >> "$_failure_record_file"
}

function print_failure(){
	cat -- "$_failure_record_file"
}

function clear_failure(){
	: >| "$_failure_record_file"
}

function is_failed(){
	[[ -s "$_failure_record_file" ]] && return 0
	return 1
}

######################################################################
### Local Variables:
### mode: shell-script
### coding: utf-8-unix
### tab-width: 4
### End:
######################################################################
