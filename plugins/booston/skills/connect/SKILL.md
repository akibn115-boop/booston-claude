---
name: connect
description: 부스트온 AI 빌더스 멤버 앱과 이 컴퓨터를 연결한다. 사용자가 부스트온 연결 코드(bo_로 시작)를 붙여 넣거나, "부스트온 연결", "연결 코드 등록"이라고 할 때 쓴다.
argument-hint: "[연결 코드]"
allowed-tools: Bash(mkdir -p ~/.booston*), Bash(chmod *), Bash(curl *), Bash(cat ~/.booston/*), Bash(test -f ~/.booston/*), Bash(printf off > ~/.booston/auto), Bash(rm -f ~/.booston/auto)
---

# 부스트온 연결

부스트온 멤버 앱(https://booston-ai-builders.vercel.app)에 해결 기록을 올리려면 연결 코드가 필요하다. 연결 코드는 대표가 앱의 **내 정보 → Claude Code에 연결하기** 화면에서 만든다.

## 순서

1. 연결 코드를 받는다. `$ARGUMENTS`에 있으면 그것을 쓰고, 없으면 대표에게 붙여 넣어 달라고 한다.
   - 형식은 `bo_` 뒤에 소문자 16진수 48자다. 형식이 다르면 앱에서 다시 복사해 달라고 한다.
   - 코드 전체를 화면에 다시 적지 않는다. 확인할 때는 끝 4자리만 말한다.
2. 이 컴퓨터에만 저장한다. 본인만 읽을 수 있게 한다.
   ```bash
   mkdir -p ~/.booston && chmod 700 ~/.booston
   printf '%s' '<연결 코드>' > ~/.booston/token && chmod 600 ~/.booston/token
   ```
3. 연결을 확인한다.
   ```bash
   B=$(cat ~/.booston/url 2>/dev/null || echo https://booston-ai-builders.vercel.app)
   curl -sS "$B/api/plugin/me" -H "Authorization: Bearer $(cat ~/.booston/token)"
   ```
   - 성공하면 `member`의 이름·회사·기수로 "○○ 대표님(회사, N기)으로 연결됐습니다"라고 알린다. 우리 회사 ERP가 아직 없으면(`erp`가 null) `/booston:erp`로 등록할 수 있다고 알려 준다.
   - 401이면 코드가 폐기됐거나 잘못 붙여 넣은 것이다. 앱에서 새 코드를 만들어 달라고 한다.
4. 다 되면 두 가지를 알려 준다.
   - 작업을 마치고 Claude Code를 닫으면 오늘 대화가 **자동으로 초안**으로 정리돼 앱에 쌓인다. 초안은 대표만 보고, 앱에서 '공개'를 눌러야 다른 대표에게 보인다. 매출·금액·숫자·실명·연락처는 지우고 저장한다.
   - 바로 올리고 싶으면 "부스트온에 기록해줘" 또는 `/booston:record`.

## 자동 초안 끄기·켜기

대표가 "자동 초안 꺼줘"라고 하면 `printf off > ~/.booston/auto`, "다시 켜줘"라고 하면 `rm -f ~/.booston/auto`. 마지막 자동 초안 결과는 `~/.booston/last-auto.json`에서 볼 수 있다.

## Windows에서 Bash가 없을 때

PowerShell로 같은 일을 한다.
```powershell
New-Item -ItemType Directory -Force "$HOME\.booston" | Out-Null
Set-Content -NoNewline -Path "$HOME\.booston\token" -Value '<연결 코드>'
$t = Get-Content "$HOME\.booston\token"
Invoke-RestMethod -Uri "https://booston-ai-builders.vercel.app/api/plugin/me" -Headers @{ Authorization = "Bearer $t" }
```

## 다른 주소로 연결(점검용)

대표나 운영진이 다른 주소를 쓰라고 하면 `~/.booston/url` 파일에 그 주소만 적는다. 지우면 기본 주소로 돌아간다.
