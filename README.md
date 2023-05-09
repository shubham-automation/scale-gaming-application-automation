# scale-gaming-application-automation
https://aws.amazon.com/cn/blogs/china/practice-of-container-deployment-of-unreal-engine-pixel-streaming-on-g4dn-ii/?nc1=b_rp


#kubectl edit deployment stream
check metric container and its port (9000)

#add following block in prometheus-server-conf configmap in scrape_configs: section
      - job_name: 'stream'
        static_configs:
          - targets: ['stream:9000']


#change the prometheus service type to LoadBalancer

#scale down build docker image

docker login
docker build -t scale_down -f scale_down_dockerfile .
docker tag scale_down:latest chaudharishubham2911/scale-down:latest
docker push chaudharishubham2911/scale-down


#scale up build docker image

docker build -t scale_up -f scale_up_dockerfile .
docker tag scale_uplatest chaudharishubham2911/scale-up:latest
docker push chaudharishubham2911/scale-up


#apply service account, role and rolebinding

kubectl apply -f sa.yaml
kubectl apply -f role.yaml
kubectl apply -f role-binding.yaml


#change docker image name in scale-up-cron.yaml & scale-down-cron.yaml

#change prometheus url in scale-up-cron.yaml & scale-down-cron.yaml

kubectl apply -f scale-up-cron.yaml

kubectl apply -f scale-down-cron.yaml
