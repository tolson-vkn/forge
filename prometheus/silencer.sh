#!/bin/bash

# This is a script i've used as part of kube cronjobs. Sometimes
# you can't solve an alert problem for a while, so you do this.
# I only alert for one day just in case alert manager state is lost.
# DON'T TREAT THIS AS A LONG TERM SOLUTION

set -xe
printf -v COMMENT "%s\\\n" "This alert is a known <ISSUE>" \
                           "Message By Silencer: https://github.com/tolson-vkn/forge/blob/master/prometheus/silencer.sh"

curl -XPOST "http://localhose:9093/api/v2/silences" \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
--data @<(cat <<EOF
{
  "matchers": [
    {
      "name": "alertname",
      "value": "NexusZeroInstances",
      "isRegex": false
    }
  ],
  "startsAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "endsAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ" -d "1 day")",
  "createdBy": "silencer",
  "comment": "$COMMENT"
}
EOF
)

