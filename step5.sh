#!/bin/bash
export PATH=$PATH:/usr/local/go/bin
export GOPROXY="https://goproxy.cn,direct"
cd /work

echo "=== BUILD ===" > /tmp/test2.log
go build ./... >> /tmp/test2.log 2>&1
echo "BUILD EXIT: $?" >> /tmp/test2.log

echo "=== RUN TEST TRAVERSE ===" >> /tmp/test2.log
go test -v -run "TestTraverse" -count=1 ./... >> /tmp/test2.log 2>&1
echo "TRAVERSE EXIT: $?" >> /tmp/test2.log

echo "=== RUN TEST FParseErrWhitelist ===" >> /tmp/test2.log
go test -v -run "TestFParseErrWhitelist" -count=1 ./... >> /tmp/test2.log 2>&1
echo "FPARSE EXIT: $?" >> /tmp/test2.log

echo "=== DONE ===" >> /tmp/test2.log
cat /tmp/test2.log
