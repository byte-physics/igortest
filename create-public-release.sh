#!/bin/sh

set -e

revision=HEAD
newVersion=1.0

filesToWatch="procedures docu helper INSTALL.txt"

if [ ! -z "$(git status -s --untracked-files=no $filesToWatch)" ]; then
	echo "Aborting, please commit the changes first"
	exit 0
fi

baseName=unitTestingFramework-v$newVersion
zipFile=$baseName.zip
folder=public-releases/$baseName

rm -rf $folder
rm -rf $zipfile

mkdir -p $folder

cp -r procedures docu/examples INSTALL.txt helper docu/refman.pdf $folder

git rev-parse $revision > internalVersion

cd public-releases &&  zip -z -q -r $baseName.zip $baseName/* < ../internalVersion && cd ..

rm internalVersion

