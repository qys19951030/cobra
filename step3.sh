#!/bin/bash
export PATH=$PATH:/usr/local/go/bin
export GOFLAGS="-mod=mod"
export GOPROXY="https://goproxy.cn,direct"
cd /work

echo "=== CHECK GO ==="
go version

echo "=== GO MOD DOWNLOAD (with goproxy.cn) ==="
go mod download 2>&1 | tail -10
echo "MOD DOWNLOAD EXIT: $?"

echo "=== GO BUILD ==="
go build ./... 2>&1
echo "BUILD EXIT: $?"

echo "=== RUN TEST TRAVERSE ==="
go test -v -run "TestTraverse" -count=1 ./... 2>&1
echo "TRAVERSE TEST EXIT: $?"

echo "=== RUN TEST FParseErrWhitelist ==="
go test -v -run "TestFParseErrWhitelist" -count=1 ./... 2>&1
echo "FPARSE TEST EXIT: $?"
