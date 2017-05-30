#!/usr/bin/env bash

echo "Counting following files:"
find ./ -name "*.nim" | grep -v nimcache | grep -v '\./dot' | grep -v '\.git' | grep -v '\.cfg'

find ./ -name "*.nim" | grep -v nimcache | grep -v '\./dot' | grep -v '\.git' | grep -v '\.cfg' | xargs cat | wc -l
