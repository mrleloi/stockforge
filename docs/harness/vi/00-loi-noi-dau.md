# Lời Nói Đầu

> *"Harness không phải là một tính năng. Nó là nền tảng (substrate) mà các tính năng tồn tại trên đó."*
> — Nguyên tắc vận hành, dự án StockForge

## Cuốn Sách Này Là Gì

Đây là sách hướng dẫn vận hành cho **StockForge Harness Framework** — hệ thống đa tầng biến Claude Code từ "một LLM với công cụ thao tác file" thành một đội ngũ kỹ thuật có kỷ luật, tự giám sát.

Harness là những gì chạy *xung quanh* Claude. Nó quản lý:

- **Cái gì được nạp** khi một session bắt đầu.
- **Quy tắc nào được thực thi** khi agent cố gắng ghi một file.
- **Cái gì được ghi nhớ** khi một session kết thúc.
- **Cái gì được escalate** khi có điều gì đó trông không ổn.
- **Cái gì được verify** trước khi bất kỳ thay đổi nào được ship.
- **Cái gì được cải thiện** khi cùng một sai lầm xảy ra hai lần.

Bóc harness ra và bạn có một LLM hallucinate, drift khỏi spec, quên context, lặp lại thất bại, và âm thầm phá hủy công việc. Đắp harness vào và bạn có một autonomous loop kỹ thuật có khả năng cộng dồn (compound).

Cuốn sách này tài liệu hóa từng tầng (layer).

## Cuốn Sách Này Không Phải Là Gì

Cuốn sách này *không* dạy:

- Cách dùng Claude Code (đọc tài liệu chính thức tại `https://docs.claude.com/en/docs/claude-code`).
- Cách xây StockForge như một sản phẩm (đọc [`PROJECT_CHARTER.md`](../../../PROJECT_CHARTER.md)).
- Cách đầu tư cổ phiếu Việt Nam (harness là framework; logic đầu tư nằm ở `packages/`).

Cuốn sách này nói *về framework*. Hãy coi nó như cách bạn xem [Rails Guides](https://guides.rubyonrails.org/) hoặc [Django docs](https://docs.djangoproject.com/) — một tài liệu tham khảo bạn đọc một lần từ đầu đến cuối khi gia nhập team, rồi quay lại bất cứ khi nào bạn cần mở rộng hệ thống.

## Tại Sao Là Một Cuốn Sách Thay Vì READMEs

Tại lần đếm cuối, harness có:

- **17** file constitution (quy tắc bất biến)
- **23** skill (quy trình tự khám phá được)
- **17** slash command (lối tắt mà người dùng có thể gọi)
- **14** subagent (persona worker với context tươi mới)
- **118** hook script (deterministic event handler)
- **6** hệ thống con bộ nhớ (memory subsystems) riêng biệt
- **3** tier quality gate
- **2** workspace (agent + human) với kênh giao tiếp tường minh
- **8** session type với budget và nghi thức (ritual) khác nhau
- **23** anti-pattern có tên (AP-1 đến AP-23)
- **12** tín hiệu harness-health (HH-1 đến HH-12)
- **12** drift signal (DR1 đến DR12)
- **84+** architecture decision record (ADR)

Các thành phần này không độc lập. Một skill gọi một subagent, subagent đó ghi một observation, một hook đọc observation đó, hook đó kích hoạt một escalation, escalation đó tôn trọng một quy tắc constitution, quy tắc đó truy ngược về một ADR. Chỉ đọc các file README sẽ để lại cho bạn từ vựng nhưng không có mô hình (model).

Cuốn sách hợp nhất từ vựng vào một mô hình.

## Ai Nên Đọc Cuốn Này

| Độc giả | Đọc theo thứ tự này |
|---|---|
| **Contributor ngày đầu tiên** | Lời Nói Đầu → Bắt Đầu Nhanh → Mô Hình Tư Duy → Kiến Trúc, sau đó lướt qua phần còn lại. |
| **Xây tính năng mới** | Chương Công Thức (Cookbook) cho artifact tương ứng (skill / hook / agent), Tham Khảo cho danh sách. |
| **Debug một harness failure** | Hệ Thống Chất Lượng → Tự Cải Thiện → Nội Tại (anti-patterns). |
| **Mở rộng framework** | Hiến Pháp → Vòng Đời → Đóng Góp. |
| **Audit drift** | Hệ Thống Bộ Nhớ → Hệ Thống Chất Lượng → các file constitution liên quan. |

Nếu bạn là một LLM agent đọc cuốn này để lập kế hoạch công việc: đọc Mô Hình Tư Duy + Kiến Trúc + chương liên quan nhất đến nhiệm vụ của bạn. Không nạp toàn bộ sách. Theo quy tắc [Bootstrap Token Ceiling](04-hien-phap.md#rule-4--bootstrap-token-ceiling) của chính harness, làm như vậy sẽ vi phạm budget của bạn.

## Cuốn Sách Này Được Xây Như Thế Nào

Cuốn sách này tự bản thân nó là một artifact của harness. Nó được tạo ra bởi:

1. Năm agent nghiên cứu song song audit hệ thống đang chạy (skills, commands, subagents, hooks, constitution, memory, lifecycle, quality, workspace).
2. Một agent nghiên cứu khảo sát các pattern tài liệu từ Rails, Django, Spring, Kubernetes, Terraform, Next.js, và meta-framework [Diataxis](https://diataxis.fr/).
3. Tổng hợp bởi main session thành mục lục hình chữ Diataxis.
4. Tác giả từng chương một với các artifact thật được trích dẫn theo file path.
5. Pass verification đối chiếu với codebase thật.

Một skill đồng hành, [`harness-docs-maintainer`](../../.claude/skills/harness-docs-maintainer/SKILL.md), giữ cuốn sách này đồng bộ với harness đang chạy. Khi bạn thêm một skill, hook, hoặc subagent, chạy `/harness-docs sync` và maintainer sẽ scan tìm drift giữa sách và thực tế. (Xem [Chương 14 — Đóng Góp](14-contributing.md#keeping-the-book-in-sync).)

## Một Ghi Chú Về Tính Trung Thực

Đây là tài liệu cho một hệ thống *thật* mà chủ dự án dùng hàng ngày. Nó không phải là khát vọng (aspirational). Chỗ nào hệ thống tốt, sách nói vậy. Chỗ nào hệ thống over-engineered, undocumented, hoặc gánh nợ kỹ thuật, sách cũng nói vậy.

Cụ thể, cuốn sách này chỉ ra:

- Các hook tồn tại nhưng đã bắt được zero failure trong nhiều tháng ([ứng viên ritual demotion](10-tu-cai-thien.md#ritual-demotion)).
- Các quy tắc constitution mâu thuẫn với nhau trong edge case.
- 23 anti-pattern mà chúng tôi đã bắt được chính mình phạm phải.
- Các ADR chúng tôi đã supersede và lý do tại sao.

Hãy coi đây là những bài học giá trị nhất của hệ thống. Thất bại của một framework có tính khai sáng hơn các tính năng của nó.

## Versioning

Cuốn sách này tài liệu hóa phiên bản harness đồng nhất với **PROJECT_CHARTER.md v1.1** (ratified 2026-05-12, [D-056](../../agent-workspace/memory/decisions/056-charter-v1-1-principle-11.md)).

Khi phiên bản charter tăng, cuốn sách này được audit lại và phát hành lại. Drift giữa sách và thực tế được xử lý như một [drift signal](09-he-thong-chat-luong.md#drift-signals) và được nổi lên (surface) tại session-end.

Audit đầy đủ lần cuối: **2026-05-19**.

## Lộ Trình Đọc

Tiếp tục đến [Chương 01 — Bắt Đầu Nhanh](01-bat-dau-nhanh.md) để có tour thực hành, hoặc nhảy thẳng đến [Chương 02 — Mô Hình Tư Duy](02-mo-hinh-tu-duy.md) nếu bạn muốn biết *tại sao* trước *làm thế nào*.

Nếu bạn đang đọc bản tiếng Anh, bản dịch song song nằm tại [`docs/harness/en/00-preface.md`](../en/00-preface.md).
