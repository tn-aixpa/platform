#!/bin/sh
cp home/src/$TEST_SCRIPT home/git/digitalhub-tutorials/$TEST_FOLDER/$TEST_SCRIPT
cd home/git/digitalhub-tutorials/$TEST_FOLDER
{{- include "platform.testPackages" . }}
python $TEST_SCRIPT
