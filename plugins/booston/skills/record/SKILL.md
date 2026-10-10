---
name: record
description: 이 대화에서 대표가 ERP나 업무 프로그램을 만들며 부딪힌 문제와 그걸 풀어 간 과정을 '해결 기록'으로 정리해 부스트온 멤버 앱에 올린다. "부스트온에 기록해줘", "해결 기록 올려줘", "오늘 막힌 거 기록", "부스트온에 공유" 같은 말에 쓴다.
argument-hint: "[덧붙일 메모]"
allowed-tools: Bash(curl *), Bash(cat ~/.booston/*), Bash(test -f ~/.booston/*), Bash(git log *), Bash(git status*), Bash(rm -f /tmp/booston-*), Bash(rm -f "$TMPDIR"booston-*)
---

# 부스트온 해결 기록 올리기

부스트온 AI 빌더스는 중소기업 대표들이 자기 회사 ERP를 직접 만드는 과정이다. 해결 기록은 다른 대표가 같은 고민을 만났을 때 현실적으로 참고하라고 남기는 것이다. **매끈한 성공담보다 막힌 이야기, 안 통한 방법, 아직 남은 문제가 더 쓸모 있다.**

## 0. 연결 확인

```bash
test -f ~/.booston/token && echo ok || echo none
```
`none`이면 올리지 말고, 앱의 **내 정보 → Claude Code에 연결하기**에서 연결 코드를 받아 `/booston:connect`를 먼저 하자고 안내하고 멈춘다.

연결돼 있으면 고를 수 있는 값을 받아 둔다.
```bash
B=$(cat ~/.booston/url 2>/dev/null || echo https://booston-ai-builders.vercel.app)
curl -sS "$B/api/plugin/me" -H "Authorization: Bearer $(cat ~/.booston/token)"
```

## 1. 재료 모으기

- 이 대화에서 대표가 무엇을 하려 했고, 어디서 막혔고, 무엇을 시도했고(안 된 것 포함), 결국 어떻게 됐는지 정리한다.
- `$ARGUMENTS`로 덧붙인 메모가 있으면 우선한다.
- git 저장소라면 `git log --oneline -15`로 오늘 한 일을 참고해도 된다. `.env`나 비밀번호가 든 파일은 열지 않는다.
- 대화만으로 부족하면 짧게 두세 가지만 묻는다. 예: "직원분들 반응은 어땠나요?", "처음에 시도했다가 안 된 방법이 있었나요?", "지금은 실제로 쓰고 있나요?"

## 2. 초안 만들기

| 칸 | 쓰는 법 |
|---|---|
| `category` | 아래 8가지 중 가장 가까운 하나 |
| `title` | 무슨 일이 있었는지 한 줄. 대표가 말하듯이. 40자 안쪽 |
| `situation` | 그때 회사 사정, 직원 반응, 대표로서 걱정한 것 |
| `steps` | 시간 순서대로 한 일. 단계마다 `{"text": "...", "worked": true/false/null}`. 통했으면 true, 안 통했으면 false, 애매하면 null. 실패한 시도를 빼지 않는다 |
| `result` | 지금 어떻게 됐는지. 숫자가 있으면 숫자로. 없으면 빈 문자열 |
| `remaining` | 아직 남은 문제. 없으면 빈 문자열 |
| `cost` / `duration` | 든 비용, 걸린 기간. 모르면 빈 문자열 |
| `status` | `solved`(해결됨) / `partly`(일부 해결) / `stuck`(아직 고민 중) |

고민 종류(`category`):
- `staff` 직원 반발 — 직원들이 새 시스템을 안 쓰려고 함
- `field` 현장 여건 — 현장에서 입력할 틈·환경이 안 됨
- `cost` 비용 걱정 — 돈이 얼마나 들지, 본전을 뽑을지
- `data` 데이터 정리 — 엑셀·종이 장부가 엉망
- `connect` 기존 시스템 연결 — 쓰던 프로그램·쇼핑몰·은행과 잇기
- `security` 보안 걱정 — 회사 정보가 샐까 봐
- `time` 대표 시간 부족 — 직접 만들 시간이 없음
- `upkeep` 유지·관리 — 만든 뒤 고장 나면 누가 고치나

기술 이야기만 있는 날도 있다. 그럴 때는 "그래서 회사 일에서 무엇이 막혔고 무엇이 나아졌는지"로 풀어 쓴다. 예: 엑셀 병합 셀 오류 → `data`.

글쓰기 규칙:
- '~했습니다'체. 대표 본인이 쓴 것처럼. 꾸미거나 성공담처럼 포장하지 않는다.
- 대화에 없는 사실·숫자·결과는 지어내지 않는다.
- **반드시 가린다:** 직원 실명 → "반장님", "경리 직원"처럼 직함으로 / 거래처·고객 이름 → "거래처 A" / 비밀번호, API 키, 토큰, DB 주소, 전화번호, 주민번호, 계좌·카드번호는 아예 넣지 않는다.

## 3. 대표에게 보여 주고 확인받기

초안을 읽기 쉽게 보여 준다(고민 종류, 제목, 그때 상황, 단계별 과정에 ✓·×, 결과, 남은 문제, 비용·기간, 상태). 그리고 묻는다:

> 이대로 부스트온에 올릴까요? 고칠 곳이 있으면 말씀해 주세요.

**대표가 분명히 올리라고 하기 전에는 절대 올리지 않는다.** 고쳐 달라고 하면 고친 초안을 다시 보여 준다.

## 4. 올리기

초안을 JSON 파일로 쓴 뒤 보낸다(한글이 깨지지 않게 파일로 보낸다).

```json
{
  "category": "staff",
  "title": "…",
  "situation": "…",
  "steps": [{ "text": "…", "worked": false }, { "text": "…", "worked": true }],
  "result": "…",
  "remaining": "",
  "cost": "",
  "duration": "3주",
  "status": "solved"
}
```

```bash
B=$(cat ~/.booston/url 2>/dev/null || echo https://booston-ai-builders.vercel.app)
curl -sS -X POST "$B/api/plugin/solutions" \
  -H "Authorization: Bearer $(cat ~/.booston/token)" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data-binary @/tmp/booston-record.json
rm -f /tmp/booston-record.json
```

- 성공하면 응답의 `url`을 알려 준다. `masked`가 1 이상이면 "서버에서 민감한 값 N곳을 한 번 더 가렸습니다"라고 덧붙인다.
- 화면 캡처는 응답의 `edit_url`에서 붙일 수 있다고 알려 준다.
- 400이면 `error` 내용을 고쳐 다시 보낸다. 401이면 연결 코드를 다시 받자고 안내한다.

## 5. 마무리

이번 일로 우리 회사 ERP의 영역 진행이 바뀌었으면(예: 재고·구매가 '만드는 중' → '쓰는 중') `/booston:erp`로 함께 올릴지 한 번만 묻는다.

## Windows에서 Bash가 없을 때

```powershell
$t = Get-Content "$HOME\.booston\token"
$body = Get-Content -Raw -Encoding UTF8 "$env:TEMP\booston-record.json"
Invoke-RestMethod -Method Post -Uri "https://booston-ai-builders.vercel.app/api/plugin/solutions" -Headers @{ Authorization = "Bearer $t" } -ContentType "application/json; charset=utf-8" -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
```
