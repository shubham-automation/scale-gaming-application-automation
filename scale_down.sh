#!/bin/sh

prometheus_url=$PROMETHEUS_URL

scale_down()
{

  check_user_connection=$(curl -s -q $prometheus_url/api/v1/query\?query\=signalserver_nodejs_active_handles_total)
  idle_pods=$(echo $check_user_connection | jq '.data.result[] | select(.value[1] == "8")')
  get_user_request_count=$(curl -s -q $prometheus_url/api/v1/query\?query\=matchmaker_streamer_demand_ratio | jq -r '.data.result[].value[1]')
  echo "Total Connected Users: $get_user_request_count"

  if [[ -n "$idle_pods" ]]; then
    idle_pod_names=$(echo $idle_pods | jq -r '.metric.kubernetes_pod_name')
    echo "Idle Pods: $idle_pod_names"
    current_pod_count=$(kubectl get po -n poc -l app=stream | grep Running | wc -l)
    require_pod_replicas=`echo | awk "{print $get_user_request_count * $current_pod_count}"`
    echo "required pod replicas: $require_pod_replicas"
    echo "Scaling down the application to $require_pod_replicas replicas....!!!!"
    kubectl delete po $idle_pod_names -n poc --grace-period=0 --force && kubectl scale deploy stream -n poc --replicas=$require_pod_replicas
    echo "Successfully scaled down the application to $require_pod_replicas replicas....!!!!"
  else
  	echo "No need to scale down the application, current replicas is $current_pod_count"
  fi

}

scale_down