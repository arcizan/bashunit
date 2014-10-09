#!/bin/bash
######################################################################
### test_example.sh
######################################################################

. ./bashunit.sh

function setup_once(){
	echo "$FUNCNAME is called"
}

function teardown_once(){
	echo "$FUNCNAME is called"
}

function setup_everytime(){
	echo "$FUNCNAME is called"
}

function teardown_everytime(){
	echo "$FUNCNAME is called"
}

function test_success(){
	output=$(echo success)
	true
	ret=$?
	assert           "[[ 'success' == '$output' ]]"
	assert_equal     'success' "$output"
	assert_not_equal 'failure' "$output"
	assert_equal     '0'       "$ret"
	assert_not_equal '00'      "$ret"
	assert_eq        00        $ret
	assert_ne        01        $ret
}

function test_failure(){
	output=$(echo failure)
	false
	ret=$?
	assert           "[[ 'success' == '$output' ]]"
	assert_equal     'success' "$output"
	assert_not_equal 'failure' "$output"
	assert_equal     '01'      "$ret"
	assert_not_equal '1'       "$ret"
	assert_eq        00        $ret
	assert_ne        01        $ret
}

regist_all_tests
run_tests

######################################################################
### Local Variables:
### mode: shell-script
### coding: utf-8-unix
### tab-width: 4
### End:
######################################################################
