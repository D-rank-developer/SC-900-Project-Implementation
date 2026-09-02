# Governance, Risk, Compliance and Data Governance

Hands-on SC-900 project in Microsoft Purview, covering the compliance layer that makes everything in the first four projects defensible: proving posture to a regulator, retaining and disposing of data on schedule, catching insider risk, and knowing what data exists in the first place.

| | |
|---|---|
| **Domain** | Domain 4 (Chapters 12, 14, 15) |
| **Weight** | 20–25% of the exam |
| **Mission-critical problem** | An organisation can have every technical control in place and still fail an audit, miss a legal hold, or miss an insider risk until after the damage is done |
| **Environment** | Microsoft 365 E5 trial tenant, Microsoft Purview portal |
| **Status** | Complete |

## Table of Contents

- [The problem I set out to solve](#the-problem-i-set-out-to-solve)
- [What I did](#what-i-did)
  - [1. Compliance Manager](#1-compliance-manager-from-a-flat-01-score-to-a-live-nist-assessment)
  - [2. Service Trust Portal](#2-service-trust-portal-microsofts-own-evidence-separate-from-mine)
  - [3. Retention policy and retention label](#3-a-retention-policy-and-a-retention-label-side-by-side)
  - [4. Insider Risk Management](#4-insider-risk-management)
  - [5. Audit search](#5-audit-search)
  - [6. eDiscovery](#6-ediscovery)
  - [7. Data Governance via DSPM](#7-a-look-at-data-governance-through-dspm)
- [GRC status report](#grc-status-report)
- [What I'd do differently in production](#what-id-do-differently-in-production)

> A couple of screenshots below show my real tenant name and account details. Worth blurring before this goes fully public.

## The problem I set out to solve

An organisation can have every technical control from my other four projects in place and still fail an audit, miss a legal hold deadline, or have no idea an insider risk existed until after the damage was done. Governance is the layer that makes the rest provable, not just true.

## What I did

### 1. Compliance Manager: from a flat 0/1 score to a live NIST assessment

Before touching anything, the dial was empty.

![Compliance Manager overview, 0/1 points achieved, before any assessment was added](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/scale4.png)

![Assessments list showing the two defaults already present, AI Baseline Assessment and Data Protection Baseline for Microsoft 365, 0 of 3 regulation licences used](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sec47545.png)

I added a NIST 800-53 Rev. 5 assessment on top of those defaults.

![Create assessment wizard, Review and finish step, NIST 800-53 rev.5 selected, service scoped to Microsoft 365](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sec2333.png)

![NIST 800-53 Rev. 5 assessment detail, 58% of assessment actions completed, points and service progress broken down](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sec34545.png)
*0/8,647 points achieved on my side, 12,220/12,310 already covered by Microsoft's own managed controls. That split is the whole shared-responsibility argument made concrete, most of the assessment is already satisfied by Microsoft, the remainder is genuinely mine to close.*

![Improvement actions list, 500 items, each mapped to NIST 800-53 rev.5 with points, service, and category](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sdf33443242.png)
*Actions like "Enforce DLP rules on the scanned files" and "Review audit history for privileged access" tie this assessment directly back to Projects 3 and 4, this isn't a standalone checklist, it's grading the same controls I already built.*

### 2. Service Trust Portal: Microsoft's own evidence, separate from mine

![Service Trust Portal homepage, certifications and standards catalogue: ISO/IEC, SOC, GDPR, FedRAMP, PCI](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sec34342.png)

![SOC document search results, 35 documents](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sec23e3c.png)

![Downloaded document detail page, Microsoft 365 Microservices (Type 1) SOC 2 Type 1 Report](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/secoersdf.png)
*This is Microsoft's own third-party audit evidence, distinct from Compliance Manager, which grades my organisation's posture. One tells me what Microsoft has proven about itself, the other tells me what I still need to prove about my own tenant.*

### 3. A retention policy and a retention label, side by side

![Create retention policy, retain items for 1 year, delete automatically at the end of the period](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/rfffsdf.png)

![Retention policy locations, Exchange mailboxes and OneDrive accounts switched on](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sdfsdffe.png)

![Create retention label, "Project X – Retain 5 years"](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sec123345.png)
*Deliberately mismatched the durations, a 1-year policy against a 5-year label, so I could see the label-wins rule play out on an item carrying both rather than just reading about it.*

### 4. Insider Risk Management

![Insider Risk Management overview page, benefits and the case for proactive detection](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sdfsdfwef.png)
*The genuinely surprising fact worth having on record: this surfaces analytics before a single policy is configured, it isn't waiting for me to build a rule first.*

### 5. Audit search

![Audit search screen, date range, keyword, activity, and user filters](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sec334.png)

### 6. eDiscovery

![eDiscovery, New case dialog, eDiscovery (Premium) toggle already on by default in Advanced settings](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sdfwerw.png)
*Worth noting for anyone following this later, the modern portal bundles Standard and Premium into one case creation flow with a toggle, rather than a separate Standard vs Premium choice up front.*

### 7. A look at Data Governance through DSPM

![DSPM Posture dashboard, Data discovery, Data protection, and Data investigation metrics](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource5/sdferfsdfse.png)
*Data protection activities covered by DLP sitting at 0% is an honest, expected number this early, it's a direct readout of how much of the tenant's data actually has a policy watching it yet, not a failure state.*

## GRC status report

| Area | Finding |
|---|---|
| **Compliance score** | NIST 800-53 Rev. 5 assessment at 58%, gap almost entirely attributable to controls that are mine to implement rather than Microsoft's shared responsibility. The improvement actions list gives a concrete, prioritised path to close it. |
| **Retention gaps** | A genuine conflict now exists by design between a 1-year retention policy and a 5-year retention label on the same content, proof the label-wins rule isn't just an exam fact. |
| **Insider risk findings** | No policies configured yet, but the platform already surfaces baseline analytics. Worth escalating to a real policy once genuine usage data exists rather than test data. |
| **Audit readiness** | Audit search is live and scoped correctly, but hasn't been tested against a real historical event yet, the natural next step once more of the tenant's activity has a track record behind it. |

## What I'd do differently in production

I'd stand up Insider Risk and DLP policies before Compliance Manager rather than after, so the assessment's improvement actions reflect real controls already in place rather than grading a tenant that's still mid-build. I'd also pull the Service Trust Portal's relevant SOC reports into the evidence library for a specific Compliance Manager assessment directly, rather than treating them as two separate stops.
