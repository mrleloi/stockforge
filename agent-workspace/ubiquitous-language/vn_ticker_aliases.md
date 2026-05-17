---
artifact_type: ubiquitous-language-alias-table
version: v0.1.0
as_of: 2026-05-17
source: project-owner manual curation (VN30 HOSE universe; option (a) per plan-032 § STEP 0.2)
coverage: VN30 universe only (Phase 1 thin-slice anchor per Charter § First Sub-Scope + glossary § VN30)
adr_reference: agent-workspace/memory/decisions/073-vn-ticker-resolver.md (ADR D-073 PROPOSED; plan-032 DD-3)
expansion_trigger: alias-table grows to n>100 tickers OR >=3 unresolved ticker mentions surface in production logs (E.4-V2)
---

# VN Ticker Aliases — VN30 Universe Seed (v0.1.0)

> Hand-curated alias table for Vietnamese stock ticker resolution.
> Each entry maps alias text variants to the canonical 3-character HOSE/HNX/UPCoM ticker symbol.
> Format follows UL glossary entry pattern (`agent-workspace/ubiquitous-language/glossary.md`).
> Maintained without Python knowledge; edit this file and bump `version:` in frontmatter.
>
> **Source authority**: Project-owner manual curation + HOSE listed-stocks portal cross-reference.
> **Coverage**: VN30 index universe (30 constituents) — Phase 1 thin-slice anchor.
> **Consumed by**: `apps/_shared/entities/vn_ticker_resolver.py` (runtime loader; reads at class instantiation).

---

## VN30 Constituent Aliases

### ACB
**Canonical ticker**: ACB
**Aliases**: acb, ACB, Asia Commercial Bank, Ngân hàng Thương mại Cổ phần Á Châu, TMCP A Chau, Ngan hang A Chau, NHTMCP A Chau
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### BCM
**Canonical ticker**: BCM
**Aliases**: bcm, BCM, Becamex, Becamex IDC, Binh Duong Industrial, CTCP Becamex IDC, Cong ty Becamex, Cong ty Co phan Becamex IDC Corp
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### BID
**Canonical ticker**: BID
**Aliases**: bid, BID, BIDV, Bank for Investment and Development, Ngân hàng Đầu tư và Phát triển Việt Nam, Ngan hang Dau tu Phat trien Viet Nam, Ngan hang BIDV
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### BVH
**Canonical ticker**: BVH
**Aliases**: bvh, BVH, Bảo Việt, Bao Viet, Tập đoàn Bảo Việt, Tap doan Bao Viet, Bao Viet Holdings, Bảo Việt Holdings
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### CTG
**Canonical ticker**: CTG
**Aliases**: ctg, CTG, VietinBank, Vietinbank, Ngân hàng Công Thương Việt Nam, Ngan hang Cong Thuong Viet Nam, NHTMCP Cong Thuong Viet Nam, Vietnam Joint Stock Commercial Bank for Industry and Trade
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### FPT
**Canonical ticker**: FPT
**Aliases**: fpt, FPT, Tập đoàn FPT, Tap doan FPT, FPT Corporation, CTCP FPT, Cong ty Co phan FPT, FPT Corp
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### GAS
**Canonical ticker**: GAS
**Aliases**: gas, GAS, PV Gas, PetroVietnam Gas, Tổng Công ty Khí Việt Nam, Tong Cong ty Khi Viet Nam, PVN Gas, Vietnam Gas
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### GVR
**Canonical ticker**: GVR
**Aliases**: gvr, GVR, Vietnam Rubber Group, Tập đoàn Công nghiệp Cao su Việt Nam, Tap doan Cao su Viet Nam, Cao su Viet Nam, VRG
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### HDB
**Canonical ticker**: HDB
**Aliases**: hdb, HDB, HDBank, HD Bank, Ngân hàng HD, Ngan hang Phat trien Nha TP HCM, NHTMCP Phat trien TP Ho Chi Minh
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### HPG
**Canonical ticker**: HPG
**Aliases**: hpg, HPG, Hòa Phát, Hoa Phat, Hoa Phat Group, Tập đoàn Hòa Phát, Tap doan Hoa Phat, CTCP Tap doan Hoa Phat, Hoa Phat Steel
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### MBB
**Canonical ticker**: MBB
**Aliases**: mbb, MBB, MB Bank, MB, Ngân hàng Quân đội, Ngan hang Quan doi, Military Commercial Joint Stock Bank, MBBank, Ngan hang MB
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### MSN
**Canonical ticker**: MSN
**Aliases**: msn, MSN, Masan, Masan Group, Tập đoàn Masan, Tap doan Masan, CTCP Tập đoàn Masan, Masan Corporation
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### MWG
**Canonical ticker**: MWG
**Aliases**: mwg, MWG, The Gioi Di Dong, Thế Giới Di Động, Mobile World, CTCP The Gioi Di Dong, MobileWorld, Mobile World Investment
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### NVL
**Canonical ticker**: NVL
**Aliases**: nvl, NVL, NovaLand, Novaland, CTCP Tap doan Dau tu Dia oc No Va, Nova Real Estate, Nova Land
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### PDR
**Canonical ticker**: PDR
**Aliases**: pdr, PDR, Phát Đạt, Phat Dat, Phat Dat Real Estate, CTCP Phat Dat, Bat dong san Phat Dat
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### PLX
**Canonical ticker**: PLX
**Aliases**: plx, PLX, Petrolimex, Tập đoàn Xăng dầu Việt Nam, Tap doan Xang dau Viet Nam, Vietnam National Petroleum Group, CTCP Xang dau Viet Nam
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### POW
**Canonical ticker**: POW
**Aliases**: pow, POW, PV Power, PetroVietnam Power, Tổng Công ty Điện lực Dầu khí, Tong Cong ty Dien luc Dau khi, PVN Power
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### SAB
**Canonical ticker**: SAB
**Aliases**: sab, SAB, Sabeco, Bia Saigon, Tổng Công ty Cổ phần Bia Rượu NGK Sài Gòn, Saigon Beer, Saigon Beer Alcohol Beverage, Bia Sai Gon
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### SHB
**Canonical ticker**: SHB
**Aliases**: shb, SHB, Saigon Hanoi Bank, Ngân hàng SHB, Ngan hang Sai Gon Ha Noi, NHTMCP Sai Gon Ha Noi
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### SSB
**Canonical ticker**: SSB
**Aliases**: ssb, SSB, SeABank, Sea Bank, Ngan hang SeABank, NHTMCP Dong Nam A, Southeast Asia Bank, Southeast Asia Commercial Bank
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### SSI
**Canonical ticker**: SSI
**Aliases**: ssi, SSI, SSI Securities, Chung khoan SSI, Cong ty CP Chung khoan SSI, SSI Research, SSI brokerage
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### STB
**Canonical ticker**: STB
**Aliases**: stb, STB, Sacombank, Ngan hang Sacombank, NHTMCP Sai Gon Thuong Tin, Sai Gon Thuong Tin Bank, Sai Gon Commercial Bank
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### TCB
**Canonical ticker**: TCB
**Aliases**: tcb, TCB, Techcombank, Tech Com Bank, Ngân hàng Kỹ Thương, Ngan hang Ky Thuong Viet Nam, NHTMCP Ky Thuong VN
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### TPB
**Canonical ticker**: TPB
**Aliases**: tpb, TPB, TPBank, TP Bank, Ngân hàng Tiên Phong, Ngan hang Tien Phong, NHTMCP Tien Phong
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### VCB
**Canonical ticker**: VCB
**Aliases**: vcb, VCB, Vietcombank, Ngan hang Ngoai thuong Viet Nam, NHTMCP Ngoai Thuong Viet Nam, Bank for Foreign Trade of Vietnam, Viet Com Bank
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### VHM
**Canonical ticker**: VHM
**Aliases**: vhm, VHM, Vinhomes, vinhomes, VINHOMES, Vin Homes, Cong ty Co phan Vinhomes, CTCP Vinhomes, Công ty Cổ phần Vinhomes
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### VIB
**Canonical ticker**: VIB
**Aliases**: vib, VIB, Vietnam International Bank, Ngan hang Quoc te Viet Nam, NHTMCP Quoc te Viet Nam, VIBank
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### VIC
**Canonical ticker**: VIC
**Aliases**: vic, VIC, Vingroup, vingroup, VINGROUP, Tập đoàn Vingroup, Tap doan Vingroup, Vin Group, CTCP Vingroup
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### VNM
**Canonical ticker**: VNM
**Aliases**: vnm, VNM, Vinamilk, vinamilk, VINAMILK, Cong ty Co phan Sua Viet Nam, CTCP Sua Viet Nam, Vietnam Dairy Products, Vina Milk
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

### VPB
**Canonical ticker**: VPB
**Aliases**: vpb, VPB, VPBank, VP Bank, Ngân hàng Việt Nam Thịnh Vượng, Ngan hang Viet Nam Thinh Vuong, NHTMCP Viet Nam Thinh Vuong
**Source**: HOSE listing | **As-of**: 2026-05-17 | **BC**: BC-1

---

## Expansion Path

This alias table ships with VN30 universe only (30 tickers, ~6 aliases each on average).

**E.4-V2 expansion trigger** (per ADR D-073 + plan-032 § A.3):
- Alias-table grows to n>100 tickers, OR
- >=3 unresolved ticker mentions surface in production extractor logs

**Candidate next additions** (NOT in scope v0):
- HNX-30 universe (~30 tickers)
- UPCoM large-cap (~50 tickers)
- HOSE mid-cap complement beyond VN30

**How to extend**: Append a new `### <TICKER>` block following the format above. Bump `version:` in frontmatter. No Python code change required — resolver reloads on next instantiation.

**Source authority for new entries**: HOSE listed-stocks portal (https://www.hsx.vn/) + project-owner domain knowledge.

**ADR reference**: `agent-workspace/memory/decisions/073-vn-ticker-resolver.md`
