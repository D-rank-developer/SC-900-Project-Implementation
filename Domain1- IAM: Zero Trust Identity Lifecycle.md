# Identity and Access Management: Zero Trust Identity Lifecycle

A hands-on SC-900 project I completed in a personal Microsoft 365 E5 trial tenant, built to demonstrate that I can implement least privilege and MFA enforcement, not just describe them.

> A few of the screenshots below still show my real tenant ID and UPN (the tenant properties pane, both role permission panes, and my own admin profile). Worth blurring those in the repo before pointing this at anyone external.

## The problem I set out to solve

Compromised or over-privileged accounts are still the single most common entry point into a breach. I wanted hands-on proof, not just exam theory, that I can stand up the identity controls that actually stop that: least-privilege admin roles, Conditional Access instead of an all-or-nothing default, self-service password recovery that doesn't create its own attack surface, a password policy that blocks the words attackers try first, just-in-time privileged access instead of standing admin rights, and risk-based monitoring to catch what slips through.

![Flow Diagram for the domain](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/96dc438dcee2e68d1a6314caa0ba689a1142b6c8/Resources/Gemini_Generated_Image_pbwc3mpbwc3mpbwc.jpg)
*Detailed flow diagram I designed for the task at hand.*

## Environment

I signed up for a personal Microsoft 365 E5 trial tenant using a non-work email, separate from my NNPC, CyBlack, and Roehampton accounts, and became the tenant's Global Administrator by default. Everything below was done inside that isolated trial tenant.

![My Global Administrator profile, confirming the role assignment](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec-9001.png)
*My own admin profile, Roles: Global Administrator, the account everything below is built around.*

![Legacy per-user MFA page showing my account's baseline state](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec-900p2.png)
*Per-user MFA still shows "disabled" here, the exact standing-risk baseline the rest of this project is built to close off.*

## What I did

### 1. Compared the admin roles before touching anything

Before creating a single policy, I opened **Roles and administrators** in the Entra admin centre and pulled the full permission list for three roles.

![Global Administrator role description and full permission list](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec-900%20(%20remeber%20to%20blur%20out%20the%20templated%20id).png)
*Global Administrator: no functional ceiling. The description itself notes that whoever signs up for the tenant automatically becomes Global Administrator.*

![User Administrator role description and full permission list](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec-900(%20remember%20to%20blur%20it).png)
*User Administrator: can manage all users and groups, but the permission list explicitly rules out deleting a Global Administrator.*

![Billing Administrator role description and full permission list](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec-900(do%20this%20also).png)
*Billing Administrator: scoped to purchases, subscriptions, support tickets, and service health, nothing touching users, groups, or security settings.*

Reading the actual permission strings rather than the marketing description made the least-privilege argument concrete for me: I could point to exactly what each role is blocked from doing, not just what it's allowed to do.

### 2. Stood up test identities, including a guest

I created two internal member test users, **John Obi** and **Shaffer King**, then invited a third identity as an **external guest**, **Chambers Freedom**, through Entra's "Invite external user" flow.

![Invite external user review screen for the guest account](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/external%20onboarding.png)
*The guest invite going out, User type: Guest, with a redirect back to myapplications.microsoft.com that had to be accepted from the invited inbox.*

![All users list showing all three test identities](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec-900%20external%20onboarding.png)
*All three identities live in the tenant, exactly the "external authentication, Guest UserType" pattern I'd been reading about, now something I'd actually clicked through end to end.*

### 3. Proved the Security Defaults vs Conditional Access conflict

The tenant starts with Security Defaults enabled by default.

![Tenant properties pane showing Security Defaults enabled](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec4.png)
*Baseline state before I touched anything: Security Defaults Enabled, "your organisation is protected by security defaults."*

With Security Defaults still enabled, I tried to create a Conditional Access policy named **"company compliance policy."**

![New Conditional Access policy blocked by Security Defaults](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec11.png)
*The portal blocked me outright: "You must first disable security defaults before enabling a Conditional Access policy." The two models in a single sentence.*

Security Defaults is one all-or-nothing switch applied identically to everyone, Conditional Access is granular and needs room to vary by user, app, and risk, so Microsoft doesn't let both run at once.

### 4. Built the Conditional Access policy in report-only mode

I disabled Security Defaults, then rebuilt **"company compliance policy"** properly: my test users under Assignments, **Microsoft Admin Portals** selected as the target resource, **Require multifactor authentication** as the Grant control, and the whole policy switched to **Report-only** so I could see what it would have done without actually locking anyone out.

![Conditional Access resource picker with Microsoft Admin Portals selected](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec12.png)
*Target resources set to Microsoft Admin Portals, one control selected, Report-only still active.*

That split, Assignments answering who/what/where and Access controls answering what happens, is the exact structure the exam tests, and now it's something I built rather than memorised.

### 5. Turned on self-service password reset for a real group

I created a security group called **compliance users**, added my test accounts to it, and scoped SSPR to that group specifically rather than the whole tenant.

![SSPR properties scoped to the compliance users group](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/compliance%20users.png)
*Self-service password reset enabled: Selected, scoped to the compliance users group, not the whole tenant.*

![SSPR authentication methods, admin two-method requirement](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec13.png)
*Confirms my own admin account is hard-locked to two required authentication methods with security questions unavailable, a setting I couldn't override even if I'd wanted to.*

![Live self-service password reset flow, verification step 1](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sc11.png)
*Ran the reset flow live from the end-user side, "text my device" as the verification method.*

### 6. Locked down passwords with smart lockout and a custom banned list

In Password Protection I set custom smart lockout to a **threshold of 10** attempts with a **60-second** lockout duration, then enabled the custom banned password list and added a set of terms an attacker targeting a security-flavoured organisation might actually try.

![Password Protection settings, smart lockout and custom banned list](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec16.png)
*Lockout threshold 10, duration 60 seconds, custom banned password list enforced.*

I proved it worked the honest way, one of my test users hit "Update your password" on first sign-in and got rejected outright.

![Live password rejection at first sign-in](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec17.png)
*"Your password contains a word, phrase or pattern that is banned by your organisation." Not a theoretical control, a control I watched block a real attempt.*

### 7. Walked the PIM eligible-to-active workflow

I opened Privileged Identity Management and reviewed the full built-in Entra roles catalogue, deliberately noting which ones are flagged **"Deprecated, Do Not Use"** so I wouldn't assign anything obsolete by mistake.

![Privileged Identity Management built-in Entra roles catalogue](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/sec19.png)
*The full PIM roles catalogue, including the roles explicitly flagged Deprecated, Do Not Use (Device Join, Device Managers, Device Users).*

I then assigned myself as **eligible** for a lower-privilege admin role rather than standing access, and activated it through PIM's own activation flow, MFA challenge and business justification included. The distinction that used to be a flashcard fact is now something I can describe from having done it: eligible means the privilege only applies after you deliberately activate it, active means you already have it with no extra step.

### 8. Reviewed Identity Protection's risk reports

In Identity Protection I opened **Risky users**, **Risky sign-ins**, and **Risk detections**.

![Identity Protection risky users report, donut chart at No Risk](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/f2d700e39d27a1ed54ae82a80c162913d593f3e9/Resources/pie%20graph.png)
*All accounts sitting in the green No Risk band, zero new risky users over the preceding week, exactly what a clean, freshly built trial tenant should look like.*

It also gave me a genuine reference point for the distinction the exam draws: **user risk** asks whether an identity itself looks compromised (leaked credentials, anomalous behaviour), **sign-in risk** asks whether one specific authentication attempt looks suspicious (anonymous IP, impossible travel). Nothing fired in my tenant, which is itself evidence the baseline is clean before I start layering on riskier test scenarios.

## What I found: identity security assessment

**Scope:** a personal Microsoft 365 E5 trial tenant, configured and tested end to end across role assignment, Conditional Access, SSPR, password protection, PIM, and Identity Protection. No production data, systems, or users involved at any point.

**Findings:**

| Control | What I configured | What I observed |
|---|---|---|
| Admin roles | Compared Global Admin, User Admin, Billing Admin | Confirmed User Admin is explicitly blocked from deleting a Global Admin, permission lists back up least privilege in practice, not just policy |
| Conditional Access | Report-only MFA policy on Microsoft Admin Portals | Security Defaults and CA are mutually exclusive by design |
| SSPR | Scoped to a "compliance users" group | Admin accounts are hard-locked to two auth methods, no security questions |
| Password Protection | Custom smart lockout (10 attempts / 60s) plus a custom banned list | Live-blocked a real test user's password attempt |
| PIM | One role set to eligible, then activated | Activation requires MFA plus a business justification, not silent |
| Identity Protection | Reviewed Risky users, Risky sign-ins, Risk detections | Clean tenant, all accounts at No Risk, zero new risky users |

**Gap identified:** an organisation running with none of this in place is relying entirely on static, standing admin access and a single all-or-nothing MFA switch, with no ability to react to risk signals or scope access by group. The single biggest gap is standing privileged access with no PIM layer, that's the difference between an admin account being a permanent target and a temporary, justified, monitored one.

**Recommendation:** disable Security Defaults only once Conditional Access policies are in place and validated in report-only mode first, move every admin role to PIM eligible assignments rather than permanent ones, and scope SSPR and password protection to groups deliberately rather than tenant-wide, so changes can be rolled out and tested safely before they touch everyone.

## Cleanup

I removed the test users and the guest invite, left the Conditional Access policy in report-only rather than deleting it (it enforces nothing in that state, so it's safe to keep for reference), removed the PIM role assignment, and set a reminder to cancel the trial before day 30 so it never converts to a paid subscription.

## What I'd do differently in production

I'd assign Conditional Access and PIM by group rather than by individually named user, so onboarding and offboarding is a group membership change rather than a policy edit. I'd also exclude a break-glass account from every single Conditional Access policy from day one, before any policy goes live, not as an afterthought once something has already gone wrong.
