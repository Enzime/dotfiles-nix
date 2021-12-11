#!/bin/sh
git --no-pager diff --binary --no-color --cached | grep -i '^\+.*todo'

no_todos_found=$?

if [ $no_todos_found -eq 1 ]; then
  exit 0
elif [ $no_todos_found -eq 0 ]; then
  echo "error: preventing commit whilst TODO in staged changes"
  echo "hint: Remove the TODO from staged changes before"
  echo "hint: commiting again."
  echo "hint: Use --no-verify (-n) to bypass this pre-commit hook."
  exit 1
else
  echo "error: unknown error code returned by grep '$?'"
  exit 1
fi
