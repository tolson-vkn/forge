#!/bin/bash
file=$(mktemp);
for x in $(grep -ri 'some-thing' . | awk '{print $1}' | sed s'!./!!' | sed s'/://' | sort | uniq); do
    grep ${x%%/*} ../../../CODEOWNERS | awk '{print $2}' >> $file;
done
cat $file | sort | uniq -c;
rm $file

#  7 @company/team1
#  2 @company/team2
#  9 @company/team3
# 11 @company/team4
# 16 @company/team5

