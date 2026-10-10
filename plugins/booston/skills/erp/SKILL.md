---
name: erp
description: 지금 만들고 있는 프로그램을 보고 '우리 회사 ERP'의 영역별 진행 상황(영업·재고·구매·생산·현장·회계·정산·고객관리·인사·총무), 만든 방법, 써 볼 수 있는 주소를 부스트온 멤버 앱에 올린다. "우리 회사 ERP 진척 올려줘", "ERP 등록해줘", "부스트온 ERP 업데이트" 같은 말에 쓴다.
allowed-tools: Bash(curl *), Bash(cat ~/.booston/*), Bash(test -f ~/.booston/*), Bash(ls *), Bash(git log *), Bash(rm -f /tmp/booston-*)
---

# 우리 회사 ERP 진척 올리기

부스트온에서는 대표마다 자기 회사 ERP 하나를 만든다. 앱의 '대표별 ERP' 화면에 여섯 영역이 어디까지 왔는지 보인다.

## 1. 지금 상태 받기

```bash
test -f ~/.booston/token && echo ok || echo none
```
`none`이면 `/booston:connect`를 먼저 하자고 안내하고 멈춘다.

```bash
B=$(cat ~/.booston/url 2>/dev/null || echo https://booston-ai-builders.vercel.app)
curl -sS "$B/api/plugin/me" -H "Authorization: Bearer $(cat ~/.booston/token)"
```
`erp`가 앱에 등록된 현재 상태다(null이면 아직 없음). `modules`는 `{영역: {status, note}}`이고 status는 `none`(안 함) / `building`(만드는 중) / `using`(쓰는 중)이다.

## 2. 지금 프로젝트 살펴보기

- 폴더 구조, README, 화면·라우트 파일 이름, `git log --oneline -20` 정도만 본다. `.env`와 비밀번호 파일은 열지 않는다.
- 어떤 영역의 기능이 있는지 추정한다. 예: 견적·거래처·주문 → 영업 / 입출고·발주 → 재고·구매 / 작업일지·작업지시 → 생산·현장 / 정산·대사·미수금 → 회계·정산 / 문의·재구매 → 고객관리 / 근태·연차·급여 → 인사·총무.
- 만든 방법을 한 줄로 정리한다. 예: "Claude Code로 만든 웹앱, 데이터는 구글 시트, Vercel 배포".
- 배포 주소가 보이면 후보로 둔다. 실제 고객 데이터가 보이는 주소라면 넣지 않는다.

## 3. 대표에게 확인받기

영역마다 지금 상태와 바꿀 상태를 표로 보여 준다(바뀌는 것만 굵게). 각 영역의 세부 기능은 한 줄 메모로 붙인다. 만든 방법, 한 달 비용, 써 볼 수 있는 주소도 함께 보여 준다.

- '쓰는 중'은 **실제로 회사에서 직원이 쓰고 있을 때만**이다. 코드만 있으면 '만드는 중'으로 둔다. 애매하면 대표에게 묻는다.
- ERP가 아직 없으면 ERP 이름, 업종, 직원 수, 전에 쓰던 도구(엑셀·종이 등)를 짧게 물어 함께 등록한다.

> 이대로 우리 회사 ERP에 반영할까요?

**대표가 분명히 반영하라고 하기 전에는 보내지 않는다.**

## 4. 보내기

바꿀 칸만 보낸다. `modules`도 바뀌는 영역만 보내면 나머지는 그대로 남는다.

```json
{
  "modules": { "재고·구매": { "status": "using", "note": "입출고, 발주 알림" } },
  "stack": "Claude Code로 만든 웹앱, 구글 시트",
  "monthly_cost": "월 4만 원",
  "demo_url": "https://example.vercel.app"
}
```
처음 등록할 때는 `title`(ERP 이름)이 꼭 필요하고, `industry`, `staff`, `tools_before`, `users`, `summary`도 보낼 수 있다.

```bash
B=$(cat ~/.booston/url 2>/dev/null || echo https://booston-ai-builders.vercel.app)
curl -sS -X POST "$B/api/plugin/erp" \
  -H "Authorization: Bearer $(cat ~/.booston/token)" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data-binary @/tmp/booston-erp.json
rm -f /tmp/booston-erp.json
```

성공하면 응답의 `url`을 알려 준다. 400이면 `error`대로 고쳐 다시 보낸다.

영역 상태가 바뀌었다면, 그 과정에서 막혔던 일을 `/booston:record`로 해결 기록으로 남길지 한 번만 묻는다.
