#!/bin/bash
# A sample Bash script, by Ryan
#
eval "$(jq -r '@sh "environment=\(.environment) system=\(.system) componentKey=\(.componentKey) numberServers=\(.numberServers)"')"
test1='{"environment": "'"${environment}"'","system": "'"${system}"'","vmAllocationRequest": [{"componentKey": "'"${componentKey}"'","numberServers":"'"${numberServers}"'"}]}'
#echo "$test1"
test=$(curl \
  --header "Content-type: application/json" \
  --request POST \
  --data '{"environment": "'"${environment}"'","system": "'"${system}"'","vmAllocationRequest": [{"componentKey": "'"${componentKey}"'","numberServers":"'"${numberServers}"'"}]}' \
  'https://onecloudapi.deloitte.com/servernaming/20190215/ServerNaming' \
  | jq -r .components[])
#echo -n "{test:${test}}"

#echo "${test[1]}|${test[2]}"
#echo "$test" | jq -r '.components[]|"\(.servers[0])"'
printf '{"base64_encoded":"%s"}\n' $(echo "${test}" | base64 -w 0)
#echo "$test"
#arr=( $(jq -r 'test.item2' json) )
#printf '%s\n' "${arr[@]}"
#echo -n "{\"server\":\"${test}\"}"
#echo ${test[0]}
#echo -n "{\"server\":\"["test1","test2"]\"}"
#echo -n "{test:${test}}"
#read -p "\nEnter your name : " name
