#! /bin/bash
TEST_PATH=`dirname $0`
SHA=`cat $TEST_PATH/fixtures/rssf.lua | $TEST_PATH/../bin/redis-cli -x SCRIPT LOAD`
$TEST_PATH/../bin/redis-cli EVALSHA $SHA 0
