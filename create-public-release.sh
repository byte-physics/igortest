#!/bin/sh

set -e

newVersion=1.06
revision=UnitTestingFramework-v$newVersion

filesToWatch="procedures docu helper INSTALL.txt"

for i in `ls procedures/*.ipf`; do
	sed -i "s/#pragma version=.*/#pragma version=$newVersion/" $i
done

sed -i "s/^PROJECT_NUMBER.*$/PROJECT_NUMBER         = $newVersion/" docu/Doxyfile

if [ ! -z "$(git status -s --untracked-files=no $filesToWatch)" ]; then
	echo "Aborting, please commit the changes first"
	exit 0
fi

basename=$revision
zipFile=$basename.zip
folder=releases/$basename

rm -rf $folder
rm -rf $zipfile

mkdir -p $folder

cp -r procedures docu/examples Readme.md License.txt helper $folder

# copy and rename manual
cp docu/refman.pdf $folder/Manual-$basename.pdf

# copy autorun scripts into example6 folder
cp $folder/helper/autorun*.bat $folder/examples/Example6

git rev-parse $revision > internalVersion

cd releases && zip -m -z -q -r $basename.zip $basename/* < ../internalVersion && cd ..

rmdir $folder
rm internalVersion
