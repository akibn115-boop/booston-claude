#!/bin/bash
# 작업을 마칠 때(SessionEnd) 오늘 대화를 해결 기록 '초안'으로 정리해 부스트온에 올린다.
# 초안은 쓴 대표만 볼 수 있고, 공개는 대표가 앱에서 직접 한다. Claude Code를 닫는 걸 막지 않도록 뒤에서 돈다.
# 끄기: ~/.booston/auto 파일에 off 라고 적는다.

[ -n "$BOOSTON_AUTO_RUNNING" ] && exit 0                       # 이 스크립트가 띄운 Claude가 끝날 때 다시 돌지 않게
[ -f "$HOME/.booston/token" ] || exit 0                         # 연결 안 했으면 아무것도 안 함
[ "$(cat "$HOME/.booston/auto" 2>/dev/null)" = "off" ] && exit 0
command -v claude >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0

input=$(cat)
field() { printf '%s' "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1; }
transcript=$(field transcript_path)
session=$(field session_id)
[ -f "$transcript" ] || exit 0

# 짧은 작업은 건너뛴다(대표가 보낸 메시지가 4개 미만)
users=$(grep -c '"type":"user"' "$transcript" 2>/dev/null || echo 0)
[ "${users:-0}" -lt 4 ] && exit 0

done_dir="$HOME/.booston/done"
mkdir -p "$done_dir"
[ -n "$session" ] && [ -f "$done_dir/$session" ] && exit 0

root="$(cd "$(dirname "$0")/.." && pwd)"
(
  export BOOSTON_AUTO_RUNNING=1
  tmp=$(mktemp -d)
  # 대표와 Claude가 주고받은 줄만, 줄마다 길이를 잘라서 넘긴다(도구 출력이 너무 길지 않게)
  grep -E '"type":"(user|assistant)"' "$transcript" | cut -c1-3000 | tail -c 150000 > "$tmp/t.jsonl"
  claude -p --model haiku --output-format text "$(cat "$root/scripts/auto-draft-prompt.md")" < "$tmp/t.jsonl" > "$tmp/out.txt" 2>/dev/null
  # 응답에서 JSON 부분만 꺼낸다
  awk 'BEGIN{p=0} /^[[:space:]]*\{/{p=1} p{print} /^[[:space:]]*\}[[:space:]]*$/{if(p) exit}' "$tmp/out.txt" > "$tmp/draft.json"
  if [ -s "$tmp/draft.json" ] && ! grep -q '"skip"[[:space:]]*:[[:space:]]*true' "$tmp/draft.json"; then
    # 반드시 초안으로 올린다
    sed -i.bak '1s/{/{"draft": true, /' "$tmp/draft.json"
    base=$(cat "$HOME/.booston/url" 2>/dev/null || echo https://booston-ai-builders.vercel.app)
    curl -sS -m 30 -X POST "$base/api/plugin/solutions" \
      -H "Authorization: Bearer $(cat "$HOME/.booston/token")" \
      -H "Content-Type: application/json; charset=utf-8" \
      --data-binary @"$tmp/draft.json" > "$HOME/.booston/last-auto.json" 2>&1
  fi
  [ -n "$session" ] && touch "$done_dir/$session"
  rm -rf "$tmp"
) >/dev/null 2>&1 &
disown 2>/dev/null
exit 0
