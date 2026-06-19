#!/bin/bash
# verify_traverse_fix.sh
#
# Single, self-contained verification script for the TraverseChildren
# unknown-flag fix. It builds the project, runs the targeted regression
# suite (Traverse + FParseErrWhitelist), then runs the full test suite,
# and writes all raw output under ./test_evidence/ for reviewer audit.
#
# Usage (inside a Go-enabled environment):
#   bash verify_traverse_fix.sh
#
# Output files produced under ./test_evidence/:
#   - target_tests_output.txt   : targeted Traverse/FParseErrWhitelist tests
#   - full_suite_output.txt     : full `go test ./...` run

set -u

cd "$(dirname "$0")"

mkdir -p test_evidence

echo "=== STEP 1: go build ./... ==="
go build ./...
BUILD_EXIT=$?
echo "go build exit: $BUILD_EXIT"
if [ "$BUILD_EXIT" -ne 0 ]; then
  echo "BUILD FAILED" | tee test_evidence/target_tests_output.txt
  exit "$BUILD_EXIT"
fi

echo "=== STEP 2: targeted tests (TestTraverse|TestFParseErrWhitelist) ==="
go test -v -run "TestTraverse|TestFParseErrWhitelist" -count=1 ./... 2>&1 | tee test_evidence/target_tests_output.txt
TARGET_EXIT=${PIPESTATUS[0]}
echo "targeted tests exit: $TARGET_EXIT"

echo "=== STEP 3: full test suite ==="
go test -v -count=1 ./... 2>&1 | tee test_evidence/full_suite_output.txt
FULL_EXIT=${PIPESTATUS[0]}
echo "full suite exit: $FULL_EXIT"

echo "=== SUMMARY ==="
echo "build exit:    $BUILD_EXIT"
echo "target exit:   $TARGET_EXIT"
echo "full exit:     $FULL_EXIT"
echo "Evidence written to ./test_evidence/"
