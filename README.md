# 부스트온 AI 빌더스 — Claude Code 플러그인

ERP를 만들다 막히고 풀어 간 과정을 **해결 기록**으로 정리해 [부스트온 멤버 앱](https://booston-ai-builders.vercel.app)에 올립니다. 우리 회사 ERP의 영역별 진척도 함께 올립니다.

## 설치 (한 번만)

Claude Code에서 차례로 입력하세요.

```
/plugin marketplace add akibn115-boop/booston-claude
/plugin install booston@booston
```

그다음 멤버 앱의 **내 정보 → Claude Code에 연결하기**에서 연결 코드를 만들고, Claude Code에 입력하세요.

```
/booston:connect
```

## 쓰기

| 이렇게 말하거나 | 명령 | 하는 일 |
|---|---|---|
| "부스트온에 기록해줘" | `/booston:record` | 방금 대화에서 막혔던 일과 풀어 간 과정을 해결 기록 초안으로 만들고, 확인받은 뒤 올립니다 |
| "우리 회사 ERP 진척 올려줘" | `/booston:erp` | 지금 프로젝트를 보고 영역별 진행 상황·만든 방법·써 볼 수 있는 주소를 정리해 올립니다 |

## 안심하고 쓰도록

- **확인받기 전에는 아무것도 올리지 않습니다.** 초안을 먼저 보여 줍니다.
- 직원 실명은 직함으로, 거래처 이름은 "거래처 A"로 바꾸고, 비밀번호·API 키·DB 주소·전화번호는 넣지 않습니다. 서버에서도 한 번 더 가립니다.
- 연결 코드는 이 컴퓨터의 `~/.booston/token`에만 저장됩니다(본인만 읽기). 컴퓨터를 바꾸거나 코드가 새어 나갔다면 앱에서 폐기하고 새로 만드세요.
- `curl`만 씁니다. Node 같은 추가 설치가 필요 없습니다. Windows에서 Git Bash가 없으면 PowerShell로 같은 일을 합니다.

## 업데이트

```
/plugin marketplace update booston
```
