# binlog_delete

### 목표
bin로그 삭제 자동화
### 실행방법
sh ./binlog_delete.sh (-l/-d)
```
sh ./binlog_delete.sh -d > /dev/null 2>&1
```
### 실행모드
-d : 삭제모드
-l : dry run(삭제 대상 리스트 출력 모드)
