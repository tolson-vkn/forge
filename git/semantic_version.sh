#!/bin/bash

# Grab commit arg if set.
git_commit=$1

# Find commit
if [ -z $git_commit ]; then
    git_commit=$(git rev-parse HEAD)
fi

# Lookup latest
current_tags=$(git describe --abbrev=0 --tags)

# No tag - set inital
if [ $? == 128 ]; then
    current_tag='v0.0.0'
    echo $current_tag
fi

# Split tags to determine next version
IFS='.' read -r -s major_minor_patch <<< "$current_tag"
major=v${major_minor_patch[0]:1}
minor=v${major_minor_patch[1]}
patch=v${major_minor_patch[2]}

next_major=v$((major+1)).0.0
next_minor=v${major}.$((minor+1)).0
next_patch=v${major}.${minor}.$((patch+1))

echo "Select the next semantic version (current: ${current_tag}):"
echo "  1) ${next_major}"
echo "  2) ${next_minor}"
echo "  3) ${next_patch}"

echo -n "Enter next version [1-3]: "
read selected_option

case $selected_option in
'1')
  next_version=$next_major
  ;;
'2')
  next_version=$next_minor
  ;;
'3')
  next_version=$next_patch
  ;;
*)
  echo "Invalid option... exiting."
  exit 1
  ;;
esac

echo "+----------------------------+"
echo "| Adding new git version tag |"
echo "+----------------------------+"
echo " - Commit:      $git_commit"
echo " - Current Tag: $current_tag"
echo " - New Tag:     $next_version"

echo -n "Are you sure you want to continue [y/n]: "
read continue

if [[ "$continue" == "y" ]]; then
    echo git tag -a -m "semantic tag: ${next_version}" $next_version $git_commit
    git tag -a -m "semantic tag: ${next_version}" $next_version $git_commit
    git push origin $next_version
else
    echo "exiting..."
fi


