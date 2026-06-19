#!/bin/bash
export PATH=$PATH:/usr/local/go/bin
export GOPROXY="https://goproxy.cn,direct"
cd /work

echo "=== CHECK GO ===" > /tmp/test_out.log
go version >> /tmp/test_out.log 2>&1

echo "=== GO MOD DOWNLOAD (with goproxy.cn) ===" >> /tmp/test_out.log
go mod download >> /tmp/test_out.log 2>&1
echo "MOD DOWNLOAD EXIT: $?" >> /tmp/test_out.log

echo "=== GO BUILD ===" >> /tmp/test_out.log
go build ./... >> /tmp/test_out.log 2>&1
echo "BUILD EXIT: $?" >> /tmp/test_out.log

echo "=== RUN TEST TRAVERSE ===" >> /tmp/test_out.log
go test -v -run "TestTraverse" -count=1 ./... >> /tmp/test_out.log 2>&1
echo "TRAVERSE TEST EXIT: $?" >> /tmp/test_out.log

echo "=== RUN TEST FParseErrWhitelist ===" >> /tmp/test_out.log
go test -v -run "TestFParseErrWhitelist" -count=1 ./... >> /tmp/test_out.log 2>&1
echo "FPARSE TEST EXIT: $?" >> /tmp/test_out.log

echo "=== RUN ALL TESTS ===" >> /tmp/test_out.log
go test -v -count=1 ./... >> /tmp/test_out.log 2>&1
echo "ALL TEST EXIT: $?" >> /tmp/test_out.log

echo "=== DONE ===" >> /tmp/test_out.log
cat /tmp/test_out.log
