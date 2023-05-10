#!/bin/sh

prometheus_url=$PROMETHEUS_URL

scale_up()
{

  get_user_request_count=$(curl -s -q $prometheus_url/api/v1/query\?query\=matchmaker_streamer_demand_ratio | jq -r '.data.result[].value[1]')

  echo "Total Connected Users: $get_user_request_count"
  current_pod_count=$(kubectl get po -n poc -l app=stream | grep Running | wc -l)
  
  if [ $current_pod_count -eq 0 ]; then
    echo "Scaling application to $get_user_request_count replicas....!!!!"
    kubectl scale deploy stream -n poc --replicas=$get_user_request_count
    echo "Successfully scaled up the application to $get_user_request_count replicas....!!!!"
  else
    total_pod_count=`echo | awk "{print $get_user_request_count * $current_pod_count}"`
    echo "Scaling application to $total_pod_count replicas....!!!!"
    kubectl scale deploy stream -n poc --replicas=$total_pod_count
    echo "Successfully scaled up the application to $total_pod_count replicas....!!!!"
  fi
  
}

scale_up
