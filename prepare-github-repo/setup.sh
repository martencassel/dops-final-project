#!/bin/sh

mkdir jenkins-demo
cd jenkins-demo
git init
git remote add origin https://github.com/martencassel/jenkins-demo.git
git add *
git commit -m 'code ready for pipeline testing'