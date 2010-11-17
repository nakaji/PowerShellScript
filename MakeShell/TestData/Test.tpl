#!/bin/sh

sqlplus test/test@orcl << EOF
#INSERT<test_01.sql>
EOF
