<aside>
💡 환경 : AWS EC2
사용 : Dokcer 위에 Jenkins, Nginx를 이용한 FrontEnd 빌드
그 외… 도커 및 jenkins를 사용하면서 알게된 점을 기록

</aside>

- 목차

# Jenkins

## Jenkins란?

- 굉장히 유명하고 개발자들이 많이 사용하는 CI 도구

## Jenkins를 사용하는 이유

1. 개발자들이 많이 사용하고 있어서 참고할 자료가 굉장히 많다. 그래서 문제가 생겼을 때, 해결하기 수월하다.
2. 개발자의 편의를 위해서 많은 plugin을 제공해준다. 
3. GUI로 관리해서 편하다.
4. JAVA 기반이라 JDK, Gradle, Maven 설정을 할 수 있다. 그래서 JAVA기반의 프로젝트를 빌드하기 쉽다. 
    1. 젠킨스를 처음 설치할 때, 자바 버전을 설정할 수 있는데 이것이 JDK임. 본인 프로젝트와 맞는 버전으로 설정한 후 설치해야함

### Docker 사용 이유

- 젠킨스를 설치하는 과정이 굉장히 복잡함
- 하지만, 도커를 사용하면 이 과정을 한 반에 처리할 수 있음
- 즉, 개발자에게 굉장한 편의를 주기때문에 사용

## Dokcer위에 Jenkins설치

```jsx
sudo docker run -d --name jenkins -p 8080:8080 jenkins/jenkins:jdk
```

- jdk 부분에 본인 프로젝트에 맞는 jdk를 쓰면 됨
- lts라고 쓰면 jdk 11 버전
- 안쓰면 가장 최신 버전

## Jenkins 설정

- {본인 EC2 서버}:8080로 접속 가능

### 초기 비밀번호

- 첫 접속을 하면 초기 비밀번호를 치라고 나오는데, 아래 명령어를 통해서 확인 가능

```jsx
// jenkins 컨테이너에 접속
$ sudo docker exec -it jenkins bash
// 초기 관리자 키 확인
// 방법 1.
$ cat /var/jenkins_home/secrets/initialAdminPassword
// 방법 2. 
$ sudo docker logs jenkins
```

- sudo docker logs jenkins를 하면 중간에 초기 비밀번호가 있음

### plugin 설치

- 기본 plugin을 설치할 수 있음
    
    ![jenkinsPlugin.jpg](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c3b7bdba-dc9c-4db4-92d4-5c1cae457c68/jenkinsPlugin.jpg)
    
- 만약에 다 실패하고 에러가 `connection time out`이라면 EC2를 초기화 하고 다시 하는 것을 추천

### 유저 설정

![유저 설정.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9ce2aa8b-c86f-4019-81d0-3a462fab220d/%EC%9C%A0%EC%A0%80_%EC%84%A4%EC%A0%95.png)

- 해당 화면에서 각각의 빈칸에 알 맞는 값을 넣어서 유저 설정을 진행하면 됨

## 젠킨스 아이템 (FreeStyle vs Pipeline)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/b959456c-da08-432f-bd0e-fca05190e6db/Untitled.png)

![1.png](./cicd/backend/1.png)

### Freestyle

- 전통적으로 젠킨스에서 사용된 아이템 방식으로 GUI기반으로 빌드 단계를 설정한다.
- 복잡한 스크립트 없이 간단하게 만들 수 있다.

### Pipeline

- 스크립트를 사용해, 스크립트를 재사용 가능하다.
- 빌드, 테스트, 배포 등 전체 CI/CD 에 대해 단일 파일로 관리가 가능하다.
- 이번 프로젝트에서는 프론트엔드, 백엔드 그리고 앞으로 있을 프로젝트에서의 스크립트 재사용성을 위해서 파이프 라인을 사용하였다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/28f4befd-f804-4232-9075-29558d19f00c/Untitled.png)

![2.png](./cicd/backend/2.png)

- pipeline을 사용하기 위해서는 다음과 같은 곳에 스크립트를 작성해야 한다.
1. 젠킨스 웹 내에서 스크립트를 작성하여 관리 → Pipeline Script(default)
2. 프로젝트 내에서 Jenkinsfile에 스크립트를 작성하여 관리 → Pipeline Script from SCM

- 현재 프로젝트에서는 1번 방법을 사용하였다.

## CredentialsId 설정

### Credentials란?

- 젠킨스에서 보안 관련 정보를 저장하는데 사용된다.
- name, value의 값으로 원하는 이름을 사용해서 중요한 정보를 사용할 수 있다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/54d3425c-895f-492d-9267-c38ebdac26ad/Untitled.png)

![4.png](./cicd/backend/4.png)

- 사용자 정보를 클릭하게 되면 왼쪽 화면에 이렇게 뜨게 된다.
- Credentials를 누르면 다음과 같이 현재까지 등록한 보안 자격 증명들이 표시된다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c3c2d39a-16ed-44d5-8395-ca30b6fc3a8f/Untitled.png)

![5.png](./cicd/backend/5.png)

# BackEnd

## Backend CI

### ‘Git Clone’

```jsx
stage('Git Clone') {
  steps {
	  git branch: 'develop', 
		credentialsId: 'CocoChachaBe',
		url: 'https://lab.ssafy.com/s09-webmobile2-sub2/S09P12A810.git'
  }
}
```

- git branch 는 git clone을 할 프로젝트의 branch를 선택하면 된다.
- url은 clone을 할 프로젝트의 url을 넣어주면 된다.
- credentialsId는 젠킨스에서 설정한 credentials에서 현재 클론을 받을 프로젝트 access token에 해당하는 name을 적어주면 된다.
    - credentialsId를 사용하는 이유는 프로젝트가 private로 설정되어 있어서 access token이 필요해서 사용한다.
    - credentialsId를 사용하지 않고 가능한 방법도 있다.
    
    ![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/7ea2fcd3-fbb9-4bd5-9085-be5ed6470ac1/Untitled.png)
    
    ![6.png](./cicd/backend/6.png)
    
    - GitLab Connection을 통해서 연결이 가능하다.

### ‘BE-build’

```jsx
stage('BE-Build') {
    steps {
        dir("./BE/chaeum-backend") {
            sh '''
            chmod +x ./gradlew
            ./gradlew clean build
            '''
        }
    }
}
```

- dir(”./BE/chaeum-backend”)
    - 빌드 파일인 gradlew 가 들어있는 폴더로 들어가기 위해 작성됐다.
- chmod +x ./gradlew
    - gradlew 파일의 실행 권한이 없어서 권한을 부여해주었다
- ./gradlew clean build
    - 이미 빌드가 되어 있다면 지우고 새롭게 빌드를 하기 위한 코드이다.
    - ci/cd 가 지속적으로 이루어지기 때문에 새롭게 빌드를 하기위해 clean을 넣어주었다.

## Backend CD

### CD설정 구축하기

### ssh를 위한 플러그인 설치

- 해당 플러그인을 설치하는 이유는 참고한 블로그에서 아래와 같은 이슈 해결을 위한 방법이다.
    
    <aside>
    🚫 **Publish Over SSH 접속 불가 이슈**
    
    구글에서 Jenkins Pipeline 생성을 다룬 게시글들을 검색하여 찾아보면 스프링이 실행될 운영서버 EC2의 접근을 위한 SSH 플러그인으로 Publish Over SSH를 사용하는 것을 볼 수 있었다. 하지만 Publish Over SSH 플러그인은 현재 아래 링크의 설명에서 볼 수 있듯이 최신의 openssh 버전이 ssh-rsa 방식의 암호화 키를 비활성화 시킨 것을 알 수 있다. 우리의 운영서버 EC2로의 접근을 하기 위한 pem는 rsa 방식으로 암호화되었기에 해당 플러그인에서 연결이 불가능하다는 것을 확인하여 다른 플러그인을 사용하기로 결정했다.
    
    </aside>
    
- 젠킨스 관리 → 플러그인 → available plugins 에서 ssh agent 검색 후 install

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/81af53cf-5482-40e5-b5d2-2d96fab61370/Untitled.png)

![7.png](./cicd/backend/7.png)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/ec61d34c-0739-49cb-a10b-b051faf64840/Untitled.png)

![8.png](./cicd/backend/8.png)

- credentials에 SSH Username with private key를 선택한다.
- private key direct를 선택하고 pem키를 다음과 같이 넣어준다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c9762671-64c3-4280-aa9b-7037a6b40eb4/Untitled.png)

![9.png](./cicd/backend/9.png)

- 다음과 같이 설정하면 aws에 접근 가능하다
- 그렇다면 이제 파이프라인에 대해 알아보자

## ‘Deploy’

```jsx
stage('Deploy') {
    steps {
        sshagent(credentials: ['aws_key']) {
            sh '''
                ssh -o StrictHostKeyChecking=no ubuntu@i9a810.p.ssafy.io uptime
                chmod +x ./backend/deploy.sh
                ssh -t -t ubuntu@i9a810.p.ssafy.io /home/ubuntu/jenkins/jenkins1/workspace/CocoChachaBE/backend/deploy.sh
            '''
        }
    }
}
```

- ssh -o StrictHostKeyChecking=no ubuntu@i9a810.p.ssafy.io uptime
    - 젠킨스 서버에서 운영 서버에 접근할 수 있도록 StrickHostKeyChecking을 비활성화한다.
- 블로그 글에서는 scp를 통해서 jar 파일을 운영서버로 옮기는 작업이 있는데 바인드 마운트를 통해서 이 작업을 하지 않아도 됐다.
- chmod +x ./backend/deploy.sh
    - deploy.sh의 실행권한을 부여해줬다.
- ssh -t -t ubuntu@i9a810.p.ssafy.io /home/ubuntu/jenkins/jenkins1/workspace/CocoChachaBE/backend/deploy.sh
    - deploy.sh의 절대 경로를 사용해서 deploy.sh를 실행 시켜주었다.

### deploy.sh 파일

```jsx
#!/bin/bash

pid=$(pgrep -f chaeum-backend)

if [ -n "${pid}" ]
then
        kill -15 ${pid}
        echo kill process ${pid}
else
        echo no process
fi

chmod +x /home/ubuntu/jenkins/jenkins1/workspace/CocoChachaBE/BE/chaeum-backend/build/libs/chaeum-backend-0.0.1-SNAPSHOT.jar
nohup java -jar /home/ubuntu/jenkins/jenkins1/workspace/CocoChachaBE/BE/chaeum-backend/build/libs/chaeum-backend-0.0.1-SNAPSHOT.jar &

sudo disown -h

echo "끝."
```

- /bin/bash 를 통해서 다음 코드들을 실행시키게 했다.
- pid ~ fi 까지의 코드는 chaeum-backend 라는 이름으로 프로세스가 돌아가고 있는지 확인 후 있다면 프로세스를 죽이는 코드이다.
- jar파일의 실행 권한을 부여해주고 백그라운드에서 실행시키기 위해서 nohup & 을 사용하였다.
    - 하지만 이 과정에서 nohup & 부분의 코드가 실행되지 않는 오류가 있어서 sudo disown -h 코드를 통해서 실행을 강제로 해주었다.
    - sudo disown -h 는 실제로 존재하지는 않는 코드라서 배포가 완료 되지만 젠킨스에서는 오류가 뜬걸로 나왔다. 이걸 해결 하기 위해서 에러가 아닌 의미 없는 에코 코드를 추가 해주었다.

## Webhook 설정

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/fae49fc4-be1d-4523-92e8-1912664d4732/Untitled.png)

![3.png](./cicd/backend/3.png)

- Build Triggers에서 Build when a change is pushed to GitLab. GitLab webhook 을 선택한다.
- 고급을 클릭해서 Secret token을 발급 받을 수 있다.
    - 발급을 하게 되면 gitlab 프로젝트 웹훅 설정에 들어간다.
    
    ![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/ffd31e9a-0a5b-4e7f-8d9b-b8093584dc16/Untitled.png)
    
    ![10.png](./cicd/backend/10.png)
    
    - URL에는 젠킨스에서 Build when a change~~ 에서 제일 옆에 보면 있는 URL을 넣어주면 된다.
    - secret token은 젠킨스에서 받은 secret token을 설정해주면 된다
- 다음과 같이 설정이 끝났다면 깃랩 웹훅 설정에서 원한는 트리거를 설정해주면 된다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/256faff6-7751-4b63-bae7-a9b55e1f9dd7/Untitled.png)

![11.png](./cicd/backend/11.png)

- 왼쪽 밑에 보면 gitlab push 트리거가 보이면서 잘 설정된 것을 볼 수 있다.
- 이렇게 되면 CICD 구축 완료!

---

# FrontEnd

## 배포 서버에 Nginx 설치하기

### Nginx 설치

- 우리는 Docker를 통해서 NGINX를 설치함
- 또한 Nginx에서 빌드를 하기때문에 해당 파일을 ubuntu환경에서 가져오기 위해서 바인드 마운트를 진행함
    - 바인드 마운트 : **컨테이너 안과 밖(ubuntu) 환경을 공유해서 해당 폴더에 있는 파일은 컨테이너 안과 밖에서 사용할 수 있게 해주는 기술**로, 컨테이너 안의 파일을 사용하기 위해서 해당 기술을 사용함

```jsx
docker run -d --name webserver -p -v {host 폴더}:{container 폴더} 80:80 nginx
```

### Nginx 설정 바꿔주기

- 먼저 nginx로 들어가기
    
    ```jsx
    sudo docker exec -it webserver /bin/bash
    ```
    
- 아래의 경로로 가서 파일 수정
    
    ```jsx
    /etc/nginx/conf.d/default.conf
    ```
    
    - 최신 버전에는 해당 위치에 설정 파일이 다 있는데, 옛날에는 아니었음
        - `/etc/nginx/sites-available/default`옛날에는 해당 위치였음
- 아래 처럼 수정함
    
    ```jsx
    location / {
            root   /build/build;
            index  index.html index.htm;
        }
    ```
    
    - root는 빌드가 될 위치로 해주면 됨
    - 처음에 이 말이 이해가 안됐음 ⇒ 아직 빌드를 안했는데 어떻게 빌드할 곳을 알지??
    - 하지만, nginx는 빌드를 한 파일을 올려서 구동을 시키는 서버라는 것을 이해한 후, 추후에 빌드가 된 파일을 해당 위치에 옮기면 된다는 것을 깨달음
    - 그렇지만, 또 문제가 생겼는데 도커 컨테이너 안이라서 빌드한 파일을 해당 위치로 옮길 수가 없었음 ⇒ 이 때를 위해서 **바인드 마운트**를 사용함

## Jenkins에 NodeJS 플러그인 설치

```jsx
Jenkins관리 -> System Configuration에 Plugins -> Available plugins에서 NodeJS 검색 후 설치
```

### NodeJS 설정해주기

```jsx
Jenkins관리 -> Tools 아래에 NodeJS installations가 있음
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/174d75fa-711a-49d0-ba50-5f510a1fe0b7/Untitled.png)

- 버전에 맞게 골라주면 됨

## 프론트 CI/CD item 생성

- 백엔드 처럼 만들면 되기 때문에 pipeline만 작성할 것

```jsx
pipeline {
    agent any
    stages {
        stage('Git Clone') {
            steps {
                git branch: 'develop', 
                credentialsId: 'CocoChachaBe',
                url: 'https://lab.ssafy.com/s09-webmobile2-sub2/S09P12A810'
            }
        }
        stage('FE-build') {
            steps {
                dir("./FE/chaeum-frontend") {
                    nodejs(nodeJSInstallationName: 'NodeJS18.16.1') {
                        sh 'npm install && npm run build'
                    }
                }
            }
        }
        stage('Compression') {
            steps {
                dir("./FE/chaeum-frontend") {
                    sh '''
                    rm -rf node_modules
                    tar -cvf build.tar build
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                sshagent(credentials: ['aws_key']) {
                    sh '''
                        pwd
                        chmod +x ./frontend/deploy.sh
                        ssh -t -t ubuntu@i9a810.p.ssafy.io /home/ubuntu/jenkins/jenkins1/workspace/euinyunTestFE/frontend/deploy.sh
                    '''
                }
            }
        }
    }
}
```

### stage (’Git Clone’)

```jsx
git branch: 'develop', 
credentialsId: 'CocoChachaBe',
url: 'https://lab.ssafy.com/s09-webmobile2-sub2/S09P12A810'
```

- 해당 파이프 라인이 실행될 브랜치를 정해주면 됨
    - 우리는 git flow를 따라가서 develop에 가면 배포를 하기 때문에 develop branch로 들어오면 실행하게 해줌
    - credentialsId은 git clone을 하기 위해서 필요한 access_token
    - url은 git url

### stage(’FE-build’)

```jsx
dir("./FE/chaeum-frontend") {
		nodejs(nodeJSInstallationName: 'NodeJS18.16.1') {
			sh 'npm install && npm run build'
      }
}
```

- git url에서 해당 주소로 들어가면 frontend 파일이 있음
- 빌드를 위해서 nodejs를 설정 해준 후, 빌드 진행
- npm install해준 후, npm run build 로 빌드 진행
    - npm install은 우리한테 node_modulues가 없기 때문에 진행해줌

### stage(’Compression’)

```jsx
dir("./FE/chaeum-frontend") {
		sh '''
		rm -rf node_modules
		tar -cvf build.tar build
		'''
}
```

- 크기가 큰 node_modules 를 제거
- node_modules를 제거 후 build라는 위치에 build.tar로 압축해줌

### stage(’Deploy’)

```jsx
sshagent(credentials: ['aws_key']) {
		sh '''
				chmod +x ./frontend/deploy.sh
				ssh -t -t ubuntu@i9a810.p.ssafy.io /home/ubuntu/jenkins/jenkins1/workspace/euinyunTestFE/frontend/deploy.sh
		'''
		}
}
```

- 처음에 실행을 하면 권한이 없어서 `permission denied` 에러가 발생함
    - 실행 권한을 주면 됨 ⇒ chmod +x
- deploy.sh파일을 실행해주면 됨

### deploy.sh

```jsx
mv ./jenkins/jenkins1/workspace/euinyunTestFE/FE/chaeum-frontend/build.tar /home/ubuntu/nginx/build

tar -xvf /home/ubuntu/nginx/build/build.tar -C /home/ubuntu/nginx/build
rm -rf /home/ubuntu/nginx/build/build.tar
sudo docker restart webserver
```

- mv를 통해서 파일의 위치를 옮겨줌
- tar -xvf를 통해서 압축을 해제해줌
    - -C /home/ubuntu/nginx/build라는 위치에 풀리게함
    - 이 위치가 nginx에서 설정한 build/build와 바인드 마운트 된 주소임
    - 즉, 빌드된 파일이 build/build안에 위치하게 됨
- rm을 통해서 압축 파일은 제거해줌
- 그리고 nginx를 재 실행해줌

위 과정을 수행하면 프론트엔드 CI/CD는 마무리가 됨

---

# 백엔드 배포시 도커를 이용한 방법

일단 젠킨스를 도커랑 바인드 마운트

[https://velog.io/@chang626/docker-container에서-docker-image-빌드-진행-과정-jenkins-host-docker.sock을-연결-2](https://velog.io/@chang626/docker-container%EC%97%90%EC%84%9C-docker-image-%EB%B9%8C%EB%93%9C-%EC%A7%84%ED%96%89-%EA%B3%BC%EC%A0%95-jenkins-host-docker.sock%EC%9D%84-%EC%97%B0%EA%B2%B0-2)

```jsx
pipeline {
    agent any
    
    tools {
        gradle 'gradle'
    }
    
    stages {
        stage('Git Clone') {
            steps {
                git branch: 'master',
                credentialsId: 'CocoChachaBe',
                url: 'https://lab.ssafy.com/s09-webmobile2-sub2/S09P12A810.git'
            }
        }
        stage('BE-Build') {
            steps {
                dir("./BE/chaeum-backend") {
                    sh '''
                    chmod +x ./gradlew
                    ./gradlew clean build
                    '''
                }
            }
        }
        
       stage('Remove Existing Image') {
            steps {
                script {
                    def imageName = "backend"
                    def existingImage = docker.image(imageName)
                    if (existingImage != null) {
                        existingImage.remove()
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def Image = docker.build('backend', '../../jjj')
                }
            }
        }
        
        stage('Remove Docker Existing Container'){
            steps{
                script{
                    def existingContainer = docker.container(name: backend)
                    if(existingContainer != null){
                        existingContainer.stop()
                        existingContainer.remove(force: true)
                    }
                }
            }
        }
        
        stage('Run Docker Container'){
            steps{
                script{
                    Image.run('-p 8082:8080', '--name backend')
                }
            }
        }
    }
}
```

---
