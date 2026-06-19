#!/bin/bash
set -e

echo "=== DOWNLOADING GO ==="
python3 -c "
import urllib.request
urllib.request.urlretrieve('https://go.dev/dl/go1.21.13.linux-amd64.tar.gz', '/tmp/go.tar.gz')
print('DOWNLOAD OK')
"

echo "=== EXTRACTING GO ==="
tar -C /usr/local -xzf /tmp/go.tar.gz
export PATH=$PATH:/usr/local/go/bin

echo "=== GO VERSION ==="
go version

echo "=== GO MOD DOWNLOAD ==="
cd /work
go mod download

echo "=== BUILDING ==="
go build ./... 2>&1
echo "BUILD OK"

echo "=== RUNNING TRAVERSE TESTS ==="
go test -v -run "TestTraverse" -count=1 ./... 2>&1
echo "TRAVERSE TESTS DONE"

echo "=== RUNNING FPARSEERRWHITELIST TESTS ==="
go test -v -run "TestFParseErrWhitelist" -count=1 ./... 2>&1
echo "FPARSEERRWHITELIST TESTS DONE"

echo "=== RUNNING ALL TESTS ==="
go test -v -count=1 ./... 2>&1
echo "ALL TESTS DONE EXIT: $?"
