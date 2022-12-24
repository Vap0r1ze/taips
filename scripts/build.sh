#!/usr/bin/env bash
# Set binaries
JQ=../../node_modules/node-jq/bin/jq

# Get package info
PKGNAME=$($JQ -r '.name[7:]' package.json)
PKG="../../node_modules/$PKGNAME"
VERSION=$($JQ -r '.version' "$PKG/package.json")

# Prepare dist folder
DIST="./dist"
rm -rf $DIST
mkdir $DIST

echo "Preparing @taips/$PKGNAME@$VERSION"

# Get declaration files
mapfile -t DECL < <(find $PKG | grep -v "^$PKG/node_modules" | grep "\.d\.ts$")
echo "Found ${#DECL[@]} declaration file(s)"

# Copy declaration files
for i in "${DECL[@]}"
do
  RELPATH="${i[@]:${#PKG}+1}"
  echo "Copying $RELPATH to $DIST"

  DIR=$(dirname $RELPATH)
  mkdir -p $DIST/$DIR
  cp $i "$DIST/$RELPATH"
done

# Create package.json
echo "Creating package.json"
$JQ -s '.[0].version = .[1].version | .[0].types = (.[1].types // .[1].typings) | .[0].private = false | .[0]' package.json "$PKG/package.json" > "$DIST/package.json"
