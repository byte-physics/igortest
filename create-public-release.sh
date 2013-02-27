#!/bin/sh

set -e

revision=HEAD
newVersion=1.0

filesToWatch="procedures docu helper INSTALL.txt"

if [ ! -z "$(git status -s --untracked-files=no $filesToWatch)" ]; then
	echo "Aborting, please commit the changes first"
	exit 0
fi

basename=UnitTestingFramework-v$newVersion
zipFile=$basename.zip
folder=releases/$basename

rm -rf $folder
rm -rf $zipfile

mkdir -p $folder

cp -r procedures docu/examples INSTALL.txt helper $folder

# copy and rename manual
cp docu/refman.pdf $folder/Manual-$basename.pdf

# copy autorun script into example6 folder
cp $folder/helper/autorun-test.bat $folder/examples/Example6

git rev-parse $revision > internalVersion

cd releases && zip -m -z -q -r $basename.zip $basename/* < ../internalVersion && cd ..

rmdir $folder
rm internalVersion

