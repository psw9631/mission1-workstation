# 미션 1: 개발 워크스테이션 구축

## 프로젝트 개요

Fedora KDE 환경에서 터미널, 파일 권한, Docker, Git/GitHub를 학습한다.
필수 과제와 보너스 과제를 직접 수행하고, 명령과 실제 출력으로 결과를 검증한다.
다른 사람이 재현할 수 있도록 실행 절차와 증거를 기록한다.

## 실행 환경

- OS: Fedora Linux 45 (KDE Plasma Desktop Edition)
- Shell: Bash
- 작업 경로: ~/Projects/mission1
- Docker 버전: 추후 확인
- Git 버전: 추후 확인
- 터미널 프로그램: 추후 확인

작업 경로의 `~`는 각 사용자의 홈 디렉터리를 뜻한다.

## 수행 체크리스트

### 필수 과제

- [x] 현재 위치·숨김 파일 확인, 절대·상대 경로 이해
- [x] 디렉터리 생성·이동·삭제
- [x] 파일 생성·읽기·쓰기·복사·이름 변경·이동·삭제
- [x] 파일 권한 변경 전후 및 쓰기 차단 검증
- [x] 디렉터리 권한 변경 전후 및 접근 차단 검증
- [ ] 터미널·권한 실습의 명령과 실제 출력 기록
- [ ] Git 사용자 정보·기본 브랜치 설정 및 설정 결과 기록
- [ ] Docker 설치·버전·데몬 동작 확인
- [ ] 이미지 다운로드·목록 및 컨테이너 실행·중지·목록 확인
- [ ] 컨테이너 로그·리소스 사용량 확인
- [ ] hello-world 실행
- [ ] Ubuntu 컨테이너 내부 명령 및 attach/exec 차이 관찰
- [ ] 웹 소스와 Dockerfile 직접 작성, 커스텀 이미지 빌드·실행
- [ ] 포트 매핑 및 브라우저 접속 증거 기록
- [ ] 바인드 마운트 변경 전후 비교
- [ ] 볼륨 데이터의 컨테이너 삭제 전후 영속성 검증
- [ ] VSCode GitHub 로그인·저장소 연동
- [ ] 트러블슈팅 2건 이상 기록
- [ ] README의 검증 절차·증거 링크·재현성·민감정보 점검
- [ ] GitHub 저장소 링크로 최종 결과 제출

### 보너스 과제

- [ ] Compose 단일 서비스 실행
- [ ] Compose 멀티 컨테이너 실행 및 서비스 간 통신 검증
- [ ] Compose up/down/ps/logs 사용
- [ ] 환경 변수로 서버 포트 또는 모드 변경 및 검증
- [ ] GitHub SSH 키 설정 및 SSH로 푸시

## 검증 기록

### 파일 권한: 쓰기 제한과 복구

목적: 소유자의 쓰기 권한을 제거하면 파일에 내용을 추가할 수 없는지 확인한다.

#### 1. 변경 전후 권한 확인

```text
$ ls -l notes.txt
-rw-r--r--. 1 suwan suwan 49 11월  5일  13:12 notes.txt

$ chmod u-w notes.txt

$ ls -l notes.txt
-r--r--r--. 1 suwan suwan 49 11월  5일  13:12 notes.txt
```

소유자의 쓰기 권한을 제거하여 권한이 644에서 444로 바뀌었다.
파일 크기는 49바이트로 유지됐다.

#### 2. 쓰기 차단과 내용 유지 확인

```text
$ printf 'Permission test\n' >> notes.txt
bash: notes.txt: 허가 거부

$ cat notes.txt
Mission 1: terminal practice
I am learning Bash.
```

쓰기 시도는 거부됐고, 기존 두 줄만 남았다.
Bash가 추가 출력을 위해 파일을 열려고 했지만 쓰기 권한이 없어 실패했다.
이는 권한 동작을 확인하기 위해 의도적으로 만든 오류다.

#### 3. 권한 복구

```text
$ chmod u+w notes.txt

$ ls -l notes.txt
-rw-r--r--. 1 suwan suwan 49 11월  5일  13:12 notes.txt
```

소유자의 쓰기 권한을 복구하여 다시 644가 됐다.

검증 결과: 일반 사용자 suwan으로 실행했을 때 파일 쓰기 권한에 따라
내용 추가가 차단됐으며, 실험 후 원래 권한으로 복구했다.

재현 조건: 자신이 소유하고 쓰기 가능한 디렉터리에서,
두 줄의 내용이 있는 notes.txt를 준비하고 일반 사용자로 수행한다.
사용자명, 날짜, 파일 크기는 준비한 환경과 내용에 따라 달라질 수 있다.

### 디렉터리 권한: 목록 조회와 내부 파일 접근의 차이

목적: 디렉터리의 r과 x 권한이 어떻게 다른지 확인한다.

#### 1. 실험 준비와 초기 상태

```text
$ mkdir permission-lab
$ printf 'Directory permission test\n' > permission-lab/sample.txt
$ chmod 755 permission-lab
$ ls -ld permission-lab
drwxr-xr-x. 1 suwan suwan 20 11월  5일  13:25 permission-lab

$ cat permission-lab/sample.txt
Directory permission test
```

초기 권한은 755이며, 소유자는 목록 조회와 내부 파일 접근이 가능했다.

#### 2. 소유자의 x 제거 후 비교

```text
$ chmod u-x permission-lab
$ ls -ld permission-lab
drw-r-xr-x. 1 suwan suwan 20 11월  5일  13:25 permission-lab

$ ls permission-lab
ls: 'permission-lab/sample.txt'에 접근할 수 없음: 허가 거부
sample.txt

$ cat permission-lab/sample.txt
cat: permission-lab/sample.txt: 허가 거부
```

권한이 755에서 655로 바뀌었다.
r이 남아 있어 sample.txt라는 이름은 보였지만,
x가 없어 파일에 접근하거나 내용을 읽을 수 없었다.
ls도 표시를 위한 추가 정보 조회 과정에서 접근 오류를 출력했다.

소유자에게는 소유자 권한이 적용되므로,
그룹이나 기타 사용자에게 남아 있는 x를 대신 적용받지 않는다.

#### 3. 권한 복구와 접근 재검증

```text
$ chmod u+x permission-lab
$ ls -ld permission-lab
drwxr-xr-x. 1 suwan suwan 20 11월  5일  13:25 permission-lab

$ cat permission-lab/sample.txt
Directory permission test
```

검증 결과: 디렉터리의 x를 복구하자 내부 파일을 다시 읽을 수 있었다.
파일 내용을 읽으려면 경로상 디렉터리의 x와 대상 파일의 r이 필요하다.

재현 조건: 자신이 소유한 실험용 디렉터리에서 일반 사용자로 수행한다.
상위 경로에 접근할 수 있고 sample.txt에 읽기 권한이 있어야 한다.
사용자명, 날짜, 디렉터리 크기 및 ls의 표시 방식은 환경에 따라 다를 수 있다.

### 터미널 기본 조작: 복사·이름 변경·이동·삭제

아래는 실습 당시 수행한 명령과 실제 출력이다.
cp는 실행 후 확인한 결과로 복사 성공을 검증했다.
출력이 없는 명령은 명령만 기록했다.

#### 1. 파일 복사 및 내용 확인

```text
$ cp notes.txt notes-copy.txt
$ ls -l notes.txt notes-copy.txt
-rw-r--r--. 1 suwan suwan 49 11월  5일  13:13 notes-copy.txt
-rw-r--r--. 1 suwan suwan 49 11월  5일  13:12 notes.txt

$ cat notes-copy.txt
Mission 1: terminal practice
I am learning Bash.
```

복사 후 원본과 복사본이 모두 존재하고, 크기와 내용을 확인했다.

#### 2. 이름 변경

```text
$ mv notes-copy.txt notes-backup.txt
$ ls -l notes.txt notes-backup.txt
-rw-r--r--. 1 suwan suwan 49 11월  5일  13:13 notes-backup.txt
-rw-r--r--. 1 suwan suwan 49 11월  5일  13:12 notes.txt

$ ls -l notes-copy.txt
ls: 'notes-copy.txt'에 접근할 수 없음: 그런 파일이나 디렉터리가 없습니다
```

같은 디렉터리 안에서 mv로 이름을 변경했다.
이전 이름을 찾을 수 없다는 오류는 예상된 검증 결과다.

#### 3. 하위 디렉터리로 이동

```text
$ mkdir backups
$ mv notes-backup.txt backups/
$ ls -l backups/notes-backup.txt
-rw-r--r--. 1 suwan suwan 49 11월  5일  13:13 backups/notes-backup.txt

$ ls -l notes-backup.txt
ls: 'notes-backup.txt'에 접근할 수 없음: 그런 파일이나 디렉터리가 없습니다
```

파일이 대상 디렉터리 안에 존재하고 기존 위치에서는 사라진 것을 확인했다.

#### 4. 파일과 빈 디렉터리 삭제

```text
$ rm backups/notes-backup.txt
$ ls -l backups/notes-backup.txt
ls: 'backups/notes-backup.txt'에 접근할 수 없음: 그런 파일이나 디렉터리가 없습니다

$ rmdir backups
$ ls -la
합계 4
drwxr-xr-x. 1 suwan suwan 18 11월  5일  13:20 .
drwxr-xr-x. 1 suwan suwan 16 11월  5일  13:06 ..
-rw-r--r--. 1 suwan suwan 49 11월  5일  13:12 notes.txt
```

復사본과 빈 디렉터리는 삭제됐고 원본 notes.txt는 유지됐다.
rmdir는 비어 있지 않은 디렉터리의 삭제를 거부한다.

재현 시에는 두 줄의 내용이 있는 notes.txt를 준비하고,
같은 이름의 복사본이나 backups 디렉터리가 없는 연습 환경에서 수행한다.

### 터미널 기본 조작: 경로 이동과 빈 파일 생성

아래는 README 작성 전 실습 당시의 명령과 실제 출력이다.

#### 1. 상대 경로로 이동하고 절대 경로 확인

홈 디렉터리에서 다음 명령을 수행했다.

```text
$ cd Projects/mission1
$ pwd
/home/suwan/Projects/mission1
```

Projects/mission1은 현재 위치를 기준으로 해석하는 상대 경로다.
pwd는 이동 후 현재 위치를 절대 경로로 출력했다.
디렉터리를 만드는 mkdir와 현재 위치를 바꾸는 cd는 별개다.
이 위치에서 ..은 부모 디렉터리인 /home/suwan/Projects를 뜻한다.

#### 2. 빈 파일 생성과 검증

```text
$ touch notes.txt
$ ls -l notes.txt
-rw-r--r--. 1 suwan suwan 0 11월  5일  13:09 notes.txt

$ cat notes.txt
```

파일 크기 0바이트와 cat의 출력 없음을 통해 빈 파일임을 확인했다.
touch는 파일이 없으면 생성하고, 이미 있으면 내용을 비우지 않고
시간 정보를 갱신한다.

#### 3. 내용 쓰기와 추가 후 확인

```text
$ printf 'Mission 1: terminal practice\n' > notes.txt
$ cat notes.txt
Mission 1: terminal practice
```

이후 다음 명령으로 두 번째 줄을 추가했다.

```bash
printf 'I am learning Bash.\n' >> notes.txt
```

추가 후 확인한 실제 출력:

```text
$ cat notes.txt
Mission 1: terminal practice
I am learning Bash.
```

>는 기존 내용을 덮어쓰고, >>는 파일 끝에 추가한다.
출력 방향을 바꾸는 기호는 Bash가 해석한다.

재현 조건: 홈 디렉터리 아래 Projects/mission1을 준비한다.
빈 파일 생성부터 재현하려면 notes.txt가 없는 별도의 연습 환경을 사용한다.
현재 결과물을 비우거나 덮어쓰지 않도록 주의한다.

### 터미널·권한 실습 후 상태 확인

다음은 파일 조작과 권한 실습을 마치고 README를 작성하던 시점의 실제 출력이다.
README 크기는 이후 내용을 추가하면서 달라진다.

```text
$ pwd
/home/suwan/Projects/mission1

$ ls -la
합계 12
drwxr-xr-x. 1 suwan suwan   64 11월  5일  13:34 .
drwxr-xr-x. 1 suwan suwan   16 11월  5일  13:06 ..
-rw-r--r--. 1 suwan suwan 5822 11월  5일  13:45 README.md
-rw-r--r--. 1 suwan suwan   49 11월  5일  13:12 notes.txt
drwxr-xr-x. 1 suwan suwan   20 11월  5일  13:25 permission-lab

$ cat notes.txt
Mission 1: terminal practice
I am learning Bash.

$ ls -ld permission-lab
drwxr-xr-x. 1 suwan suwan 20 11월  5일  13:25 permission-lab
```

ls -la는 상세 정보와 숨김 항목을 포함해 목록을 표시한다.
.은 현재 디렉터리이고, ..은 부모 디렉터리다.
이름이 .으로 시작하는 항목은 기본 ls에서는 숨겨진다.

검증 결과: 현재 위치, 원본 내용 유지, 디렉터리 권한 755 복구를 확인했다.
