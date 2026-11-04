# 🚀 개발자용 작업실 구축 (Dev Workstation Lab)

> **리눅스 CLI 터미널, Docker 컨테이너 환경, Git/GitHub 버전 관리 워크스테이션 구축 및 실습 검증 보고서**  
> **작성자 (Author):** woogie0403 (`jaewook0403@gmail.com`)  
> **GitHub Repository:** [https://github.com/woogie0403/workspace-lab](https://github.com/woogie0403/workspace-lab) *(Public)*

---

## 📌 1. 프로젝트 개요 (Mission Overview)

본 프로젝트는 "내 컴퓨터에서만 코드가 돌아가는 문제"를 근본적으로 해결하고, 협업 팀원 누구나 동일한 조건에서 즉시 개발·배포·디버깅할 수 있는 **재현 가능한 개발 워크스테이션 환경 구축**을 목표로 합니다.

리눅스 CLI 환경 구축, 파일 권한 체계 검증, Docker 기반 커스텀 웹 서버 컨테이너화, 포트 포워딩, 스토리지 바인드 마운트 및 볼륨 영속성 검증, Git 버전 관리 연동까지의 전 과정을 터미널(CLI) 기반으로 수행하고 실제 동작 증거를 문서화하였습니다.

---

## 💻 2. 실행 환경 (System Environment)

| 구성 요소 | 상세 스펙 / 버전 | 비고 |
| :--- | :--- | :--- |
| **운영체제 (Host OS)** | Microsoft Windows 10 Home (Build 19045, 64-bit) | 호스트 시스템 |
| **가상화 서브시스템** | WSL 2 (Windows Subsystem for Linux 2) | Linux Kernel 5.15+ |
| **실행 쉘 (Shell)** | Ubuntu 24.04 LTS / Bash Shell | 리눅스 CLI 환경 |
| **Docker Engine** | Docker version 29.9.2, build a82e528 | Docker Desktop 4.98.0 |
| **Git Version** | git version 2.53.0 | 버전 관리 도구 |
| **터미널 에디터** | VS Code (v1.144.1) | IDE 및 워크스페이스 연동 |

---

## 📋 3. 수행 항목 체크리스트 (Task Checklist)

- [x] **터미널 기본 조작 및 폴더 구성**: `pwd`, `ls -la`, `mkdir`, `cd`, `cp`, `mv`, `rm`, `cat`, `echo`
- [x] **파일 및 디렉토리 권한 실습**: 파일 1개(644 ➡️ 755), 디렉토리 1개(755 ➡️ 700) 권한 변경 및 전/후 비교
- [x] **Docker 엔진 설치 및 데몬 점검**: `docker --version`, `docker info`
- [x] **컨테이너 기본 라이프사이클 실습**: `hello-world` 구동, `ubuntu` 컨테이너 진입 및 내부 명령 실행
- [x] **컨테이너 종료/유지 메커니즘 관찰**: `attach` vs `exec` 동작 차이 분석
- [x] **기존 베이스 기반 커스텀 Dockerfile 작성**: `nginx:alpine` 베이스 정적 웹서버 이미지 제작
- [x] **커스텀 이미지 빌드 및 확인**: `docker build -t my-custom-web:1.0 .`, `docker images`
- [x] **포트 매핑 접속 검증 (2회)**: 포트 8080 및 8081 바인딩 구동, 브라우저 주소창 접속 증거 캡처
- [x] **바인드 마운트 (Bind Mount) 실시간 반영 검증**: 호스트 파일 수정 시 컨테이너 무재빌드 즉시 반영
- [x] **도커 볼륨 (Named Volume) 데이터 영속성 검증**: 컨테이너 강제 삭제(`rm -f`) 후 신규 컨테이너에서 데이터 보존 확인
- [x] **Git 설정 및 GitHub 연동**: `git config --list`, `.gitignore` 설정, 리포지토리 초기화 및 커밋
- [x] **보안 및 개인정보 보호**: 민감 정보(PAT 토큰, 비밀번호, 비밀키 등) 노출 방지 및 마스킹

---

## 🔬 4. 단계별 수행 로그 및 증거 (Execution Logs & Evidences)

### 4-1. 터미널 조작 및 디렉토리 구성
안전한 작업 디렉토리 `~/workspace-lab`을 생성하고 파일 CRUD(생성, 복사, 이름변경, 삭제)를 수행하였습니다.

```bash
# 1. 홈 디렉토리 이동 및 작업 폴더 구조 생성
cd ~
mkdir -p workspace-lab/app workspace-lab/docs/screenshots workspace-lab/logs
cd workspace-lab
pwd
# 출력: /home/jaeuk/workspace-lab

# 2. 파일 생성 및 내용 확인
echo "Linux Terminal Practice" > sample.txt
cat sample.txt
# 출력: Linux Terminal Practice

# 3. 파일 복사, 이름변경, 삭제 검증
cp sample.txt copy.txt
mv copy.txt renamed.txt
rm renamed.txt
```

---

### 4-2. 파일 및 디렉토리 권한 실습 (`chmod`)
8진수 권한 모델을 적용하여 파일(644 ➡️ 755)과 디렉토리(755 ➡️ 700)의 권한 변경 전/후를 비교 검증하였습니다.

```bash
# [실험 1: 파일 권한 변경 (644 -> 755)]
ls -l sample.txt
# 변경 전: -rw-r--r-- 1 jaeuk jaeuk 24 Nov 4 23:57 sample.txt

chmod 755 sample.txt
ls -l sample.txt
# 변경 후: -rwxr-xr-x 1 jaeuk jaeuk 24 Nov 4 23:57 sample.txt (실행 권한 부여)

# [실험 2: 디렉토리 권한 변경 (755 -> 700)]
mkdir practice_dir
ls -ld practice_dir
# 변경 전: drwxr-xr-x 2 jaeuk jaeuk 4096 Nov 5 00:00 practice_dir

chmod 700 practice_dir
ls -ld practice_dir
# 변경 후: drwx------ 2 jaeuk jaeuk 4096 Nov 5 00:00 practice_dir (소유자 단독 접근)
```

---

### 4-3. Docker 엔진 점검 및 컨테이너 라이프사이클 (`attach` vs `exec`)

```bash
# Docker 데몬 점검
docker --version
# Docker version 29.9.2, build a82e528

# hello-world 컨테이너 실행
docker run hello-world
# 출력: Hello from Docker! This message shows that your installation appears to be working correctly.

# 백그라운드 우분투 컨테이너 실행 및 exec 진입
docker run -d --name my-ubuntu ubuntu sleep infinity
docker ps
# b6c7e51b43d1   ubuntu   "sleep infinity"   Up 16 seconds   my-ubuntu

# exec로 내부 진입 후 명령 실행
docker exec -it my-ubuntu bash
root@b6c7e51b43d1:/# echo "Inside Ubuntu Container!"
root@b6c7e51b43d1:/# exit

# exit 후 컨테이너 상태 재확인 (컨테이너 유지 입증)
docker ps
# b6c7e51b43d1   ubuntu   "sleep infinity"   Up About a minute   my-ubuntu (정상 유지!)
```

---

### 4-4. Dockerfile 커스텀 이미지 제작 및 빌드

경량 `nginx:alpine`을 베이스로 정적 콘텐츠와 메타데이터를 주입한 커스텀 이미지를 제작하였습니다.

#### `Dockerfile`
```dockerfile
FROM nginx:alpine
LABEL maintainer="woogie0403"
LABEL description="Custom Nginx Web Server for Dev Workstation"
ENV APP_ENV=production
COPY app/index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

#### 빌드 및 이미지 생성 결과
```bash
docker build -t my-custom-web:1.0 .
# [+] Building 37.2s (7/7) FINISHED
# => naming to docker.io/library/my-custom-web:1.0 done

docker images
# REPOSITORY          TAG       IMAGE ID       SIZE
# my-custom-web       1.0       0d97a99f826a   26.3MB
```

---

### 4-5. 포트 매핑 검증 (Port 8080 & 8081)

동일한 이미지를 서로 다른 호스트 포트(`8080`, `8081`)로 매핑하여 다중 실행 및 네트워크 접속을 검증하였습니다.

```bash
# 8080 포트 컨테이너 실행
docker run -d -p 8080:80 --name my-web-8080 my-custom-web:1.0

# 8081 포트 컨테이너 실행
docker run -d -p 8081:80 --name my-web-8081 my-custom-web:1.0

# 포트 매핑 상태 확인
docker ps
# 0.0.0.0:8080->80/tcp   my-web-8080
# 0.0.0.0:8081->80/tcp   my-web-8081
```

#### 🌐 브라우저 접속 화면 증거 (주소창 포함)

##### 1) Port 8080 접속 증거
![Port 8080 접속 증거](docs/screenshots/web_8080.png)

##### 2) Port 8081 접속 증거
![Port 8081 접속 증거](docs/screenshots/web_8081.png)

---

### 4-6. 바인드 마운트 (Bind Mount) 실시간 변경 검증

호스트의 `./app` 폴더를 컨테이너 웹 경로(`/usr/share/nginx/html`)에 바인드 마운트하여, 이미지 재빌드 없이 호스트 파일 수정이 컨테이너에 실시간 반영됨을 확인하였습니다.

```bash
# 바인드 마운트 컨테이너 실행 (포트 8082)
docker run -d -p 8082:80 -v $(pwd)/app:/usr/share/nginx/html --name bind-test my-custom-web:1.0

# 호스트 파일 수정 (v2.0 문구 반영)
sed -i 's/구축 완료!/구축 완료! (v2.0 바인드 마운트 성공!)/g' app/index.html

# curl 확인
curl http://localhost:8082 | grep "바인드 마운트"
# 출력: <h1>🚀 Jaeuk의 개발 작업실 구축 완료! (v2.0 바인드 마운트 성공!)</h1>
```

##### 🌐 바인드 마운트 실시간 반영 브라우저 증거
![바인드 마운트 반영 증거](docs/screenshots/web_8082_bind.png)

---

### 4-7. 도커 볼륨 (Named Volume) 데이터 영속성 검증

컨테이너가 완전히 삭제(`rm -f`)되어도 도커 볼륨에 기록된 데이터가 새 컨테이너에 그대로 유지되는 데이터 영속성을 입증하였습니다.

```bash
# 1. 독립 볼륨 생성
docker volume create mydata

# 2. 1번 컨테이너에 볼륨 연결 및 데이터 생성
docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
docker exec -it vol-test bash -lc "echo 'Jaeuk Persistence Data 2026' > /data/hello.txt && cat /data/hello.txt"
# 출력: Jaeuk Persistence Data 2026

# 3. 1번 컨테이너 강제 영구 삭제
docker rm -f vol-test

# 4. 새로운 2번 컨테이너 연결 및 데이터 보존 확인
docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
docker exec -it vol-test2 bash -lc "cat /data/hello.txt"
# 출력: Jaeuk Persistence Data 2026 (완벽 보존 확인!)
```

---

### 4-8. Git 설정 및 GitHub 연동

```bash
# Git 사용자 정보 및 기본 브랜치 설정
git config --global user.name "woogie0403"
git config --global user.email "jaewook0403@gmail.com"
git config --global init.defaultBranch main

# 설정 결과 확인
git config --list
# user.name=woogie0403
# user.email=jaewook0403@gmail.com
# init.defaultbranch=main
```

---

## 🛠️ 5. 트러블슈팅 일지 (Troubleshooting Log)

### [Issue 1] Docker Desktop 소켓 접근 권한 거부 (`permission denied`)
- **문제 현상 (Problem)**:  
  WSL2 Ubuntu 터미널에서 `docker run hello-world` 등 도커 명령 실행 시 `permission denied while trying to connect to the docker API at unix:///var/run/docker.sock` 에러 발생.
- **원인 가설 (Hypothesis)**:  
  Docker 데몬 소켓 파일(`/var/run/docker.sock`)은 `root` 및 `docker` 그룹만 읽기/쓰기가 가능한데, 신규 생성된 일반 사용자 계정(`jaeuk`)이 `docker` 그룹에 등록되지 않았거나 소켓 권한이 제한되어 발생했을 것이다.
- **확인 과정 (Investigation)**:  
  소켓 권한 확인(`ls -l /var/run/docker.sock`) 결과 `srw-rw---- 1 root docker`로 일반 사용자의 접근이 차단되어 있음을 확인.
- **해결 방안 (Solution)**:  
  사용자 계정을 도커 그룹에 등록(`sudo usermod -aG docker $USER`)하고 소켓 접근 권한을 임시 조정(`sudo chmod 666 /var/run/docker.sock`)하여 일반 사용자 세션에서도 데몬과 원활히 통신하도록 해결.

---

### [Issue 2] 터미널 명령어 줄바꿈으로 인한 인자 누락 에러 (`requires at least 1 argument`)
- **문제 현상 (Problem)**:  
  바인드 마운트 컨테이너 실행 중 `docker: 'docker run' requires at least 1 argument` 에러 및 `my-custom-web:1.0: command not found` 연쇄 발생.
- **원인 가설 (Hypothesis)**:  
  긴 명령어를 복사-붙여넣기 하는 과정에서 이미지 이름 앞부분에 개행 문자(Enter)가 삽입되어, 1차 명령어가 이미지 인자 없이 실행되고 이미지 이름이 2차 쉘 명령어로 분리 실행되었을 것이다.
- **확인 과정 (Investigation)**:  
  터미널 로그 상 두 개의 프롬프트 라인으로 분리되어 입력된 것을 시각적으로 식별.
- **해결 방안 (Solution)**:  
  개행 문자를 제거하고 단일 행 명령어로 정렬하여 `docker run -d -p 8082:80 -v $(pwd)/app:/usr/share/nginx/html --name bind-test my-custom-web:1.0`을 한 번에 실행하여 정상 컨테이너 구동 성공.

---

## 💡 6. 핵심 기술 개념 요약 (Core Concepts)

1. **절대 경로 vs 상대 경로**:
   - **절대 경로**: 루트(`/`)부터 시작하여 대상의 고유한 위치를 나타내는 경로 (예: `/home/jaeuk/workspace-lab/app`). 어디에서 실행하든 항상 같은 대상을 가리킵니다.
   - **상대 경로**: 현재 작업 위치(Current Directory, `.`)를 기준으로 표현하는 경로 (예: `./app/index.html`, `../logs`). 현재 위치가 달라지면 가리키는 대상도 바뀝니다.
2. **파일 권한 체계 (rwx & 755 / 644)**:
   - `r`(읽기=4), `w`(쓰기=2), `x`(실행=1)의 8진수 합산 표기법입니다.
   - **`755` (`rwxr-xr-x`)**: 소유자는 모든 권한(4+2+1=7), 그룹 및 기타 사용자는 읽기 및 실행(4+1=5)만 가능 (스크립트 및 폴더의 표준 권한).
   - **`644` (`rw-r--r--`)**: 소유자는 읽기/쓰기(4+2=6), 타인은 읽기(4)만 가능 (일반 텍스트 문서의 표준 권한).
3. **포트 매핑의 필요성**:
   - 컨테이너는 격리된 네트워크 네임스페이스를 가집니다. 외부 호스트(브라우저)에서 컨테이너 내부 서비스(포트 80)에 접근하기 위해서는 호스트의 특정 포트(예: 8080)와 컨테이너 포트를 연결하는 브릿지 매핑(`-p 8080:80`)이 필수적입니다.
4. **바인드 마운트 vs 도커 볼륨**:
   - **바인드 마운트**: 호스트의 특정 절대 경로 디렉토리를 컨테이너에 직접 마운트. 호스트 파일 수정 시 즉각 동기화되므로 **로컬 개발 및 코드 핫 리로딩**에 적합.
   - **도커 볼륨**: 도커 스토리지 영역(`/var/lib/docker/volumes/`)에서 도커 데몬이 자체 관리하는 영구 저장소. 컨테이너 삭제/재생성에 영향받지 않으므로 **데이터베이스 및 영구 데이터 보존**에 최적화.
5. **Git vs GitHub**:
   - **Git**: 로컬 컴퓨터에서 소스코드의 변경 이력(커밋)을 추적하고 브랜치를 관리하는 **분산 버전 관리 시스템(VCS)**.
   - **GitHub**: Git으로 관리되는 프로젝트를 클라우드 원격 저장소에 호스팅하고, 팀원들과 코드 리뷰, Issue, PR 등을 수행하는 **원격 협업 플랫폼**.

---

## 🔄 7. 재현 가이드 (Reproduction Guide)

다른 환경에서 본 프로젝트를 그대로 재현하는 방법입니다:

```bash
# 1. 저장소 클론
git clone https://github.com/woogie0403/workspace-lab.git
cd workspace-lab

# 2. 커스텀 웹 서버 이미지 빌드
docker build -t my-custom-web:1.0 .

# 3. 포트 매핑 실행 (포트 8080)
docker run -d -p 8080:80 --name my-web-8080 my-custom-web:1.0

# 4. 브라우저에서 확인
curl http://localhost:8080
# 또는 브라우저 주소창에서 http://localhost:8080 접속
```
