#!/bin/bash
eval "$(jq -r '@sh "environment=\(.environment) system=\(.system) componentKey=\(.componentKey) numberServers=\(.numberServers)"')"
test=$(curl \
  --header "Content-type: application/json" \
  --request POST \
  --data '{"environment": "'"${environment}"'","system": "'"${system}"'","vmAllocationRequest": [{"componentKey": "'"${componentKey}"'","numberServers":"'"${numberServers}"'"}]}' \
  'https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming' \
  | jq -r .components[])
printf '{"base64_encoded":"%s"}\n' $(echo "${test}" | base64 -w 0)
