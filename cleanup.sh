#!/bin/bash

cd $(dirname $0)

find . -name ".build" -or -name ".swiftpm" | xargs -n 1 rm -v -r
