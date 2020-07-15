#!/bin/bash

ttl=$1

if [ -z "${ttl}" ]; then
  ttl="48 hours"
fi

function get_exp_date() {
  local creationTimestamp=$1
  local ttl=$2
  date "+%FT%H:%M:%SZ" -d "${creationTimestamp} +${ttl}"
  #date -j -v "+${ttl}" -f "%FT%H:%M:%SZ" "${creationTimestamp}" +%FT%H:%M:%SZ
}

# get namespaces that have the nsReaper tag is set to enabled
IFS=$'\n'
for ns in $(kubectl get namespaces -o json | jq -r ".items[] | select( .metadata | has(\"ownerReferences\") | not) | [.metadata.name,.metadata.creationTimestamp,.metadata.annotations.ttl,.metadata.annotations.nsReaper] | @csv" | sed 's/"//g'); do
  current_date=$(date "+%FT%H:%M:%SZ" -u)
  namespace=$(echo "${ns}" | cut -d ',' -f 1)
  creationTimestamp=$(echo "${ns}" | cut -d ',' -f 2)
  ttl=$(echo "${ns}" | cut -d ',' -f 3)
  nsReaper=$(echo "${ns}" | cut -d ',' -f 4)
  delete=0

  if [ "${nsReaper}" == "enabled" ]; then
    if [ "${creationTimestamp}" != "" ]; then # Check to see creation time of namespace
      exp_date=$(get_exp_date "${creationTimestamp}" "${ttl}")
      if [[ "${exp_date}" < "${current_date}" ]]; then
        echo "${namespace} expired (at ${exp_date}) due to TTL annotation, deleting"
        delete=1
      fi
    fi
    if [ ${delete} -eq 1 ]; then
       kubectl delete namespace "${namespace}"
    fi
  fi
done

echo "namespace reaper finished"
