#!/bin/bash
echo "[INFO] execute remove gitbook serve cache _book/ dir!"
rm -rf  _book/
echo "[INFO] execute gitbook build to blog directory!"
gitbook build .  ../jaydenwen123.github.io/boltdb

rm -rf _book/

git add .

git commit -m "feat:update book content"

git push origin master

echo "[INFO] execute deploy the book to website"

cd ../jaydenwen123.github.io

git add .

git commit -m "feat:update book content"

git push origin main

