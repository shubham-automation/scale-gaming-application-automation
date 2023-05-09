#!/bin/sh

prometheus_url=$PROMETHEUS_URL

scale_up()
{

  get_user_request_count=$(curl -s -q $prometheus_url/api/v1/query\?query\=matchmaker_streamer_demand_ratio | jq -r '.data.result[].value[1]')

  echo "Total Connected Users: $get_user_request_count"
  current_pod_count=$(kubectl get po -n poc -l app=stream | grep Running | wc -l)
  total_pod_count=`echo | awk "{print $get_user_request_count * $current_pod_count}"`
  echo "Scaling application to $total_pod_count replicas....!!!!"
  kubectl scale deploy stream -n poc --replicas=$total_pod_count
  echo "Successfully scaled up the application to $total_pod_count replicas....!!!!"
  
}

scale_up
