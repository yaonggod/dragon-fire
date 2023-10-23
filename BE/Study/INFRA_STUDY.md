# 도커 설정

## 도커 설치

### 1. 패키지 리스트 최신으로 업데이트

```bash
sudo apt-get update
```

### 2. 도커 다운로드를 위해 필요한 https 관련 패키지 설치

```bash
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
```

- curl, apt-transport-https, ca-certificates, software-properties-common

### 3. 도커 레포지토리 접근을 위한 GPG Key 설정

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

### 4. 도커 레포지토리 등록

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
```

### 5. 방금 등록한 도커 레포지토리를 포함하여 패키지 리스트 다시 업데이트

```bash
sudo apt-get update
```

### 6. 도커 설치

```bash
sudo apt-get install docker-ce
```

### 7. 실행중인지 확인

```bash
sudo systemctl status docker
```

## 도커-컴포즈 설치

### 1. 도커 컴포즈 설치

---

# https 설정 방법

## 👀 https를 적용하지 않고 SSL 인증서 발급받기

### docker-compose.yml

nginx.conf 파일은 사용자 환경에 맞게 경로를 잡아주시면 됩니다.

./data 폴더는 수동으로 생성하지 않아도 됩니다.

```
version: '3'
services:
  nginx:
    image: nginx:latest
		container_name: nginx
    restart: unless-stopped
    volumes:
      - ./conf/nginx.conf:/etc/nginx/nginx.conf
      - ./data/certbot/conf:/etc/letsencrypt
      - ./data/certbot/www:/var/www/certbot
    ports:
      - 80:80
      - 443:443
  certbot:
    image: certbot/certbot
		container_name: certbot
    restart: unless-stopped
    volumes:
      - ./data/certbot/conf:/etc/letsencrypt
      - ./data/certbot/www:/var/www/certbot
```

### conf/nginx.conf

```
server {
     listen 80;
     listen [::]:80;

     server_name domain; // 등록한 도메인으로 변경

     location /.well-known/acme-challenge/ {
             allow all;
             root /var/www/certbot;
     }
}
```

### docker-compose를 실행합니다.

```
docker-compose -f docker-compose.yml up -d
docker ps// nginx와 certbot 컨테이너가 살아있는지 확인
```

### 인증서 발급받는 스크립트를 다운로드하고 도메인, 이메일 주소, 디렉터리를 변경합니다.

인증서 발급에 실패한 경우 실패 시 메시지나 docker log를 통해 원인을 찾을 수 있습니다.

```bash
sudo vi init-letsencrypt.sh // 도메인, 이메일 수정
sudo chmod +x init-letsencrypt.sh
sudo ./init-letsencrypt.sh // 인증서 발급
```

init-letsencrypt.sh

```jsx
#!/bin/bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

domains="도메인 주소"
rsa_key_size=4096
data_path="../certbot"
email="이메일 주소" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo

echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload
```

## **👌 HTTPS 적용하기**

https://node-js.tistory.com/32

https://zinirun.github.io/2021/03/31/docker-nginx-certbot/

## 호스트 서버에서 인증서 받기

<aside>
🚫 만약 도커 컨테이너에서 돌아가지 않는다면 호스트 서버에서 인증을 받아서 nginx에서 바인드 마운트를 사용해서 인증서를 사용하는 방법을 이용하자.

</aside>

### 호스트 서버에 certbot 설치

```bash
sudo apt-get update
sudo apt-get install letsencrypt

```

### 호스트 서버에서 certbot

```bash
sudo certbot certonly --nginx --webroot-path=/var/www/html -d 도메인이름
```

### Nginx 설정 파일

```bash
events {
    worker_connections 4096;
}

http {
    upstream backend {
        server j9a604.p.ssafy.io:8080;
    }

    upstream fastapi {
        server j9a604.p.ssafy.io:8081;
    }

    server {
         listen 80;
         listen [::]:80;

         server_name j9a604.p.ssafy.io; # 등록한 도메인으로 변경

         location /.well-known/acme-challenge/ {
             root /var/www/certbot;
         }

         location / {
            return 301 https://$host$request_uri;
         }
    }

    server {
        listen 443 ssl;

        ssl_certificate /etc/letsencrypt/live/j9a604.p.ssafy.io/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/j9a604.p.ssafy.io/privkey.pem; # managed by Certbot
        include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

        server_name j9a604.p.ssafy.io;

        location / {
            root   html;
            index  index.html index.htm;
        }

        location /api {
            rewrite ^/api(/.*)$ $1 break;
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /fastapi {
            rewrite ^/fastapi(/.*)$ $1 break;
            proxy_pass http://fastapi;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

    }
}
```

```bash
events{
    worker_connections 4096;
}

http {
    server {
         listen 80;
         listen [::]:80;

         server_name j9a604.p.ssafy.io; #  등록한 도메인으로 변경

         location /.well-known/acme-challenge/ {
             root /var/www/certbot;
             }

         location / {
            return 301 https://$host$request_uri;
        }
    }

    server {
        listen 443 ssl;

        ssl_certificate /etc/letsencrypt/live/j9a604.p.ssafy.io/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/j9a604.p.ssafy.io/privkey.pem; # managed by Certbot
        include /etc/letsencrypt/options-ssl-nginx.conf;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

        server_name j9a604.p.ssafy.io;

        location / {
            root   html;
            index  index.html index.htm;
        }
    }
}
```

---

# jenkins 도커

## 이미지 pull

```jsx
sudo docker pull jenkins/jenkins:lts-jdk11
```

## 컨테이너 올리기

```jsx
sudo docker run -d -p 8888:8080 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /home/ubuntu/jenkins:/var/jenkins_home \
--name jenkins \
-e TZ=Asia/Seoul \ 
-u root \
--restart=on-failure \
jenkins/jenkins:lts-jdk11 \
```

## spring pipeline

```jsx
pipeline {
    agent any
    
    stages {
        stage('Git Clone') {
            steps {
                git branch: 'develop-BE', 
                credentialsId: 'youkids',
                url: 'https://lab.ssafy.com/s09-bigdata-recom-sub2/S09P22A604'
            }
        }
        stage('BE-Build') {
            steps {
                dir("./backend") {
                    sh '''
                    cp /var/jenkins_home/workspace/docker/application-dev.yml ./src/main/resources
                    
                    chmod +x ./gradlew
                    ./gradlew clean build
                    
                    mv ./build/libs/youkids-0.0.1-SNAPSHOT.jar /var/jenkins_home/workspace/Youkids
                    cp /var/jenkins_home/workspace/docker/Dockerfile /var/jenkins_home/workspace/Youkids
                    '''
                }
            }
        }
       
        stage('Docker Image Build') {
            steps {
                sh '''
                    docker stop youkids || true
                    docker rm youkids || true
										docker build -t youkids:v1 .
								'''
            }
        }
        
        stage('Docker Container') {
            steps {
                  sh '''
                      docker run -d -p 8080:8080 --name youkids youkids:v1
                  '''
                }
            }
        }
    }
}
```
