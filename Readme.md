### Problem Statement: 
You have been given a web application codebase and your task is to create a Kubernetes deployment
that can effectively run and scale the application. The web application consists of a frontend
component and a backend component, both of which need to be containerized and deployed using
Kubernetes.

1. Containerize web application
2. Design Kubernetes Deployments
3. Implement K8s Services
4. Configure HPA
5. Deployment & Testing

NOTE: The assumtions are added at the end of this file. 

##### 1. Containerize Web Application
```
Here, we are creating docker images of the frontend & backend applications and storing them in ECR repo. More details can be found at Docker/Readme.md.

```
##### 2. Design Kubernetes Deployments
```
Created K8s deployment manifests for frontend & backend at /K8s/Application/*-deploy.yml. We have configured resources & limits for each component. 
For logging we are running filebeat as daemonset (not as sidecar as it would increase redundancy in every deployment manifest) which can further send the logs to Logstash and we can implement ELK stack. For monitoring we are setting up Prometheus & Grafana (/K8s/Monitoring directory).
```

##### 3. Implement K8s Services
```
The service manifests are created at /K8s/Application/*-svc.yml. The frontend svc is hosted as NodePort since we want to expose it to the outer world, while backend service is created as ClusterIP to enable within cluster communication.

Frontend service: NodeIP:30000 (NodePort)
Backend service: backend-service.app.svc.cluster.local or backend-service.app (ClusterIP)
Grafana service: NodeIP:3001 (NodePort)
Prometheus service: NodeIP:30002 (NodePort)

We can also implement Ingress in order to enable load-blancing & routing paths that directes the incoming traffic to different path based on routes or host (we still have to run the svc as NodePort). The prerequistic is enabling ingress-controller first & then creating ingress resource manifest. More can be read at K8s official documentation.
```

##### 4. Application Scaling
```
Scaling the backend Application on the basis of load is required and we configure a HPA at /K8s/Application/Load-Testing/hpa.yml if cpu usage goes beyond 80%. We configure min & max replicas which will overwrite the replicas defined by deployment.
As a prerequistic we have to install metrics server for HPA first for which mainfest is stored at /K8s/Application/Load-Testing/metrics-server.yml
We run a infinite-calls pod to load test our backend service /K8s/Application/Load-Testing/infinite-calls-pod.yml.
```
##### 5. Deployment & Testing

```
# Deploying applications & services
cd K8s/Application
kubectl apply -f app-backend-deploy.yml
kubectl apply -f app-frontend-deploy.yml
kubectl apply -f backend-svc.yml
kubectl apply -f frontend-svc.yml

## HPA
cd K8s/Load-Testing
kubectl apply -f /Load-Testing/metrics-server.yml
kubectl apply -f /Load-Testing/hpa.yml

# Testing if the deployments are up and running in app namespace
kubectl get pods -n app
kubectl get svc -n app -o wide
kubectl get pod -n kube-system | grep metrics-server
kubectl get hpa -n app
kubectl top pods
kubectl top nodes

## LOAD TESTING
We can have different methods to test the applications for load.
1. Running a infinite-calls pod that will generate load on our application. 
2. Using a tool like Apache JMeter which requires some configuration like preparing JMeter test plan, creating docker image, run Jmeter pod, execute JMeter test from within the pod & analyze the scaling in & out of backend-pods.
 
Using method-1, the inifinte-calls mainfest can be found at /Load-Testing/inifinute-calls-pod.yaml
Run to apply:

kubectl apply -f /Load-Testing/infinite-calls-pod.yml
# now see the scaling in & out of backend pods. Delete the infinit-calls-pod in case we are done testing scaling-in & watch scale down.
```


### Assumptions
1. We have K8s setup. 
2. Frontend application is built with Nodejs while backend is built with Apache Tomcat.
3. Deploying the applications in `app` namespace which can be created with `kubectl create ns app`.
4. We can create service account for grafana, prometheus, filebeat to restrict access but for now that is not included in the setup.