# Kubernetes Homework

1. Развернута виртуальная машина с ОС Ubuntu, на неё установлен docker
2. Создана директория, в которой написан dockerfile
3. Далее выполнено `docker build -t webserver:1.0.0 .`, после чего `docker run -d -p 8000:8000 webserver:1.0.0`. Далее проверено, что сервер поднялся. 
Для этого осуществлён переход http://192.168.74.128:8000/ - здесь открылась страница с Hello World.

4. Создан access token, произведена авторизация и образ webserver запушен в Docker Hub(репозиторий yaskadef/kuber_web_server на https://hub.docker.com/u/yaskadef);

5. Написан Deployment manifest (deployment.yaml). В этом манифесте был установлен imagePullPolicy: IfNotPresent Далее он был применён с помощью `kubectl apply --filename deployment.yaml --namespace default`. 
Далее был получен и просмотрен deployment с именем "web" командой `kubectl get deployment web -n default --watch`. На команду был получен ответ:

| NAME | READY | UP-TO-DATE | AVAILABLE | AGE |
|:----:|:-----:|:----------:|:---------:|:---:|
|  web |  0/2  |      2     |     0     |  9s |

Далее была применена команда `kubectl logs deployment/web -n default` и был получен ответ: 

"Error from server (BadRequest): container "webserver" in pod "web-68d8669c79-n7djx" is waiting to start: trying and failing to pull image"

После оперативного гугления было выяснено, что, в соответствии с созданным манифестом, kubectl пытается скачать указанный образ. 

Для решения этой проблемы в терминале были установлены переменные окружения командой `eval $(minikube docker-env)`. Далее был создан образ в контейнере minikube. 

Следующим шагом был удалён кластер `kubectl delete deployment web`. Далее Deployment manifest был применён заново `kubectl apply --filename deployment.yaml --namespace default`.

И команда `kubectl get deployment web -n default --watch` выдала: 

| NAME | READY | UP-TO-DATE | AVAILABLE |  AGE  |
|:----:|:-----:|:----------:|:---------:|:-----:|
|  web |  2/2  |      2     |     2     | 9m16s |

6. Далее был развёрнут сервис командой `kubectl expose deployment web --target-port=8000 --port=8081 --type=NodePort --name=web-server-service-external --namespace default`.

Далее была выполнена команда `kubectl get service web-server-service-external --namespace default -o wide`, чтобы посмотреть порты:

|      PORT      |
|:--------------:|
| 8081:32535/TCP |

Следующим шагом была выполнена команда `kubectl get node -o wide`, чтобы посмотреть IP ноды:

|  INTERNAL-IP |
|:------------:|
| 192.168.49.2 |


**Далее с виртуальной машины(не из контейнера) была выполнена команда `curl -v http://192.168.49.2:32535`, её результат:**

*   Trying 192.168.49.2:32535...
* TCP_NODELAY set
* Connected to 192.168.49.2 (192.168.49.2) port 32535 (#0)
* GET / HTTP/1.1
* Host: 192.168.49.2:32535
* User-Agent: curl/7.68.0
* Accept: */*
* Mark bundle as not supporting multiuse
* HTTP 1.0, assume close after body
* HTTP/1.0 200 OK
* Server: SimpleHTTP/0.6 Python/3.12.8
* Date: Sat, 25 Jan 2025 08:57:48 GMT
* Content-type: text/html
* Content-Length: 12
* Last-Modified: Sat, 25 Jan 2025 08:20:25 GMT
Hello World
* Closing connection 0

**Дылее были выполнены команды для отчёта.**

**Команда `kubectl describe deployment web`, результат:**

Name:                   web

Namespace:              default

CreationTimestamp:      Sat, 25 Jan 2025 00:51:13 -0800

Labels:                 <none>

Annotations:            deployment.kubernetes.io/revision: 1

Selector:               app=webserver

Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable

StrategyType:           RollingUpdate

MinReadySeconds:        0

RollingUpdateStrategy:  25% max unavailable, 25% max surge

Pod Template:

Labels:  app=webserver

Containers:

webserver:

Image:         webserverkube:1.0.0

Port:          8000/TCP

Host Port:     0/TCP

Liveness:      http-get http://:80/health delay=30s timeout=1s period=10s #success=1 #failure=3

Environment:   <none>

Mounts:        <none>

Volumes:         <none>

Node-Selectors:  <none>

Tolerations:     <none>

Conditions:

Type           Status  Reason

\----           ------  ------

Available      True    MinimumReplicasAvailable

Progressing    True    NewReplicaSetAvailable

OldReplicaSets:  <none>

NewReplicaSet:   web-f86d9f (2/2 replicas created)

Events:

Type    Reason             Age    From                   Message

\----    ------             ----   ----                   -------

Normal  ScalingReplicaSet  7m15s  deployment-controller  Scaled up replica set web-f86d9f from 0 to 2

**Команда `kubectl describe service/web-server-service-external`, результат:**

Name:                     web-server-service-external

Namespace:                default

Labels:                   <none>

Annotations:              <none>

Selector:                 app=webserver

Type:                     NodePort

IP Family Policy:         SingleStack

IP Families:              IPv4

IP:                       10.107.142.171

IPs:                      10.107.142.171

Port:                     <unset>  8081/TCP

TargetPort:               8000/TCP

NodePort:                 <unset>  32535/TCP

Endpoints:                10.244.0.15:8000,10.244.0.14:8000

Session Affinity:         None

External Traffic Policy:  Cluster

Internal Traffic Policy:  Clusterы

Events:                   <none>




