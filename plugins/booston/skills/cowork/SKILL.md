---
name: cowork
description: 우리 회사 프로젝트를 같은 회사 개발자와 같이 개발하도록 세팅한다(GitHub·Vercel·Supabase). "공동개발", "동료 초대", "같이 개발", "프로젝트 받아서 실행", "/booston:cowork" 요청에 사용. 초대(주인 쪽), 합류(동료 쪽), 넘겨주기(동료가 만든 Supabase·GitHub 프로젝트를 회사로 옮기기) 세 가지.
---

# 공동개발 세팅

GitHub·Vercel·Supabase를 쓰는 프로젝트에 같은 회사 개발자를 들이고(초대), 그 개발자가 받아서 실행하게(합류) 돕는다.

먼저 어느 쪽인지 정한다. 사용자가 말하지 않았으면 현재 폴더로 판단한다:
- **초대**: 사용자가 이 프로젝트의 주인이고 동료를 들이려 한다.
- **합류**: 사용자가 동료이고 프로젝트를 처음 받아 실행하려 한다.
- **넘겨주기**: 동료가 새 프로젝트를 만들거나, 만든 것을 회사로 넘기려 한다(또는 주인이 넘겨받은 뒤 점검).

## 초대 (주인 쪽)

1. **상태 확인** (읽기만): 프로젝트 폴더에서
   - `git remote get-url origin` (없으면 GitHub에 없음)
   - `.vercel/project.json` (Vercel 연결 여부, projectName)
   - `supabase/` 폴더, `supabase/.temp/project-ref` (Supabase 연결 여부)
   - `.gitignore`에 `.env*`가 있는지. 없으면 먼저 추가.
   결과를 표 한 줄로 보여준다.
2. **동료 정보 받기**: GitHub 아이디, 이메일. 없으면 물어본다.
3. **아래 작업은 다른 사람에게 권한을 주거나 외부에 올리는 일이므로 항목을 보여주고 사용자가 "응"이라고 한 뒤에만 실행한다.**
   - GitHub에 없으면: `gh repo create <GitHub 계정 또는 조직>/<이름> --private --source=. --push`
   - GitHub 초대: `gh api -X PUT repos/<owner>/<repo>/collaborators/<동료아이디> -f permission=push`
   - Vercel 초대: `vercel teams switch <팀>` 후 `vercel teams invite <이메일>` (Pro 팀은 1명당 월 $20. 이 사실을 확인받을 때 같이 말한다)
   - Supabase: CLI로 초대할 수 없다. 대시보드 Organization → Team → Invite, 역할 **Developer**를 안내한다 (초대 링크 24시간 유효). Vercel을 통해 만든 Supabase 조직이면 Vercel 팀 초대로 들어갈 수 있다고 안내하되 확인은 사용자에게 맡긴다.
   - **초대 전에 사용자에게 꼭 알린다:** Vercel 팀 멤버는 `vercel link` 한 번으로 그 프로젝트의 **Development 환경변수 전부**를 받는다. `vercel env ls --scope <팀>`으로 Development에 걸린 이름을 보여준다.
     - **배포 전(실사용자 데이터 없음)**: 그대로 연결해도 된다. 대신 "배포 직전에 운영 키(Supabase 서비스 키·DB 비밀번호·서명/결제/AI 키)를 새로 발급해 Production 칸에만 넣기"를 할 일로 남긴다(일정표나 할 일 목록이 있으면 거기에, 사용자 확인 후).
     - **배포 후(실사용자 있음)**: Development 값이 운영 값과 같으면 테스트용으로 바꾸거나 빼라고 먼저 권한다(바꾸는 건 사용자 확인 후).
4. **CLAUDE.md에 "같이 개발하기" 칸을 추가/갱신**하고 커밋한다 (아래 틀). 실행 명령·환경변수 **이름**만 적고 값은 절대 적지 않는다. 환경변수 이름은 `vercel env ls --scope <팀>`에서 가져온다. Vercel 팀 id는 `.vercel/project.json`의 `orgId`를 적는다(비밀값 아님).
5. 동료에게 보낼 짧은 안내문을 출력한다: 저장소 주소 + "booston 플러그인을 설치하고 Claude Code에서 `/booston:cowork 합류` 라고 하세요".

## 합류 (동료 쪽)

1. `gh auth status`, `vercel whoami`, `supabase --version` 확인. 로그인 안 돼 있으면 사용자가 직접 `! gh auth login`, `! vercel login`, `! supabase login` 하도록 안내.
   - **대기 중인 GitHub 초대 한 번에 수락**: `gh api user/repository_invitations --jq '.[] | "\(.id) \(.repository.full_name)"'`로 목록을 보여주고, 사용자가 "응" 하면 각각 `gh api -X PATCH user/repository_invitations/<id>`로 수락한다.
   - 저장소를 **이름만** 말했으면(예: "labseal") `gh api user/repos --paginate --jq '.[].full_name' | grep -i <이름>`으로 주소를 찾는다. 여러 개면 고르게 한다. 이름도 없으면 목록을 보여주고 고르게 한다.
2. `git clone <저장소>` 후 폴더로 이동. **CLAUDE.md의 기본 브랜치로 `git switch <브랜치>`** (clone은 main을 받는데 작업 브랜치가 develop인 프로젝트가 있다). 패키지 설치(lock 파일 보고 npm/pnpm/bun 결정).
3. Vercel 프로젝트면 `vercel link --yes --project <프로젝트> --scope <팀 id>` (팀 id는 CLAUDE.md. `--scope` 없으면 멈춘다).
   **`vercel link`는 Development 환경변수를 `.env.local`로 자동으로 내려받는다(끄는 옵션 없음).** 그래서:
   - 이미 `.env.local`이 있으면 link 전에 `.env.local.bak`으로 옮겨 두고, 끝나면 차이만 알려준다.
   - 받은 값은 출력하지 않는다. 이름만 확인한다.
4. Supabase는 `supabase link --project-ref <ref>`(ref는 CLAUDE.md 또는 주인에게 받기). 원격 DB에 `db push`·`db reset` 하지 않는다.
5. CLAUDE.md의 실행 명령으로 띄워 보고 결과를 알려준다.

## 넘겨주기 (동료가 새 프로젝트를 만들어 주인 회사 조직으로 넘김)

회사 방식: Supabase는 회사 조직(Pro)에서 운영하고, 새 프로젝트는 동료가 자기 조직에서 만들어 개발한 뒤 회사 조직으로 옮긴다.

**동료 쪽 (만들 때)**
1. Supabase 대시보드에서 **자기 조직**에 새 프로젝트를 만든다. 지역은 **Seoul(ap-northeast-2)**. 지역은 옮긴 뒤에도 못 바꾼다.
2. DB 구조는 처음부터 `supabase migration new <이름>`으로만 만든다(대시보드에서 직접 고치지 않기). 넘긴 뒤에도 기록이 이어지게.
3. 무료 조직은 활성 프로젝트 2개까지, 1주일 안 쓰면 멈춘다. 멈추면 대시보드에서 Restore.
4. 비밀키는 저장소에 넣지 않는다. Vercel 프로젝트는 처음부터 회사 Vercel 팀 안에 만든다.

**동료 쪽 (넘길 때)**
1. 회사 조직에 초대받았는지 확인(주인이 대시보드 Organization → Team → Invite). 자기 조직은 본인이 Owner여야 한다.
2. 프로젝트 Settings → General → **Transfer project** → 회사 조직 선택. 막히면 주인에게 회사 조직에서 잠시 Owner 권한을 받아 옮기고 다시 내린다.
3. Vercel Marketplace로 만든 조직에서는 일반 조직으로 옮길 수 없다. 처음부터 Supabase 대시보드에서 만든 조직을 쓴다.
4. 옮긴 뒤 주소·키는 그대로라 앱 수정은 필요 없다. 주인에게 "옮겼음 + 프로젝트 이름"을 알린다.

**주인 쪽 (받은 뒤 점검)**
1. 회사 조직 결제가 Pro인지, 옮겨 온 프로젝트의 서버 크기(컴퓨트)와 추가 요금 확인.
2. 동료 권한을 Developer로 맞춘다(넘길 때 Owner를 줬다면 되돌리기).
3. 실사용자가 생기기 전에 서비스 키·DB 비밀번호를 새로 발급해 운영(Production) 환경변수에만 넣는다.
4. GitHub 저장소도 동료 계정에 있으면 Settings → Transfer ownership으로 회사 쪽으로 옮기고, Vercel Git 연결을 확인한다.

## 같이 일하는 규칙 (두 경우 모두 마지막에 한 번 안내)

- `main`은 운영 버전. 작업은 브랜치 → PR → 합치기. PR마다 Vercel 미리보기로 확인.
- DB 구조는 대시보드에서 고치지 않는다. `supabase migration new <이름>` → 커밋 → 반영(`supabase db push`)은 정해진 한 사람만.
- `.env`·비밀키는 커밋·메신저 금지. 값은 Vercel 환경변수에서만 관리. `service_role` 키는 서버 환경변수에만.
- 같은 날 같은 파일을 둘이 고치지 않게 프로젝트·기능별 담당을 정한다.

## CLAUDE.md "같이 개발하기" 틀

```markdown
## 같이 개발하기
- 저장소: <url> / 기본 브랜치: <main|develop>
- 실행: <설치 명령> → <개발 서버 명령>
- 배포: Vercel 팀 id <orgId> / 프로젝트 <이름> (PR마다 미리보기, <브랜치> 합치면 운영 배포)  ← 없으면 "APK: <빌드 방법>"
- DB: Supabase project-ref <ref>. 구조 변경은 migration으로만, 반영 담당 <이름>
- 필요한 환경변수(이름만): <KEY1>, <KEY2>, ...
```
