# Threat Detection and Incident Response

A hands-on SC-900 project in the Microsoft Defender portal, built to prove I can detect and respond to a threat end to end, not just describe what Sentinel and Defender XDR do. This one's still in progress, the sections below reflect exactly how far I've actually got, not a tidied-up version of it.

> Several screenshots below show my real tenant name (University of Roehampton), UPN, and one subscription ID. Worth blurring before this goes fully public.

## The problem I set out to solve

An undetected breach or a slow response to one is the gap between a contained incident and a genuine one. I wanted to build the whole chain myself: a data source actually flowing into a SIEM, a rule that detects something real, a case file that ties alerts and entities together instead of scattering them across consoles, and an automation layer that acts on a detection rather than just logging it.

## Environment

Same Azure subscription as my network hardening project, plus the Microsoft Defender portal (security.microsoft.com), which is where almost all of this work actually happens now rather than the old Azure Sentinel blade.

## What I've done so far

### 1. Log Analytics workspace, with Sentinel enabled on it

![Log Analytics workspace review and create, law-soc-lab in rg-soc-lab](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec1.png)
*`law-soc-lab`, East US, Pay-as-you-go per GB. This is still the one part of the whole project that happens in the classic Azure portal rather than the Defender portal.*

### 2. Connecting the workspace to the Defender portal

![Add Microsoft Sentinel to a workspace, showing the 31-day free trial banner and auto-onboarding notice](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec2.png)
*Confirms both things worth knowing going in: a 31-day free trial applies, and new workspaces created by authorised users get auto-onboarded and redirected to the Defender portal.*

![Defender portal Settings landing page, listing Microsoft Sentinel as a settings category](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec4.png)

![Microsoft Sentinel SIEM workspaces page, law-soc-lab shown as Connected and Primary](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec6.png)
*Confirmed connected, confirmed Primary. From here everything else happens in this portal, not portal.azure.com.*

### 3. Installing the Azure Activity solution from Content Hub

![Content hub, Azure Activity solution listed as Featured, not yet installed](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec111.png)

![Azure Activity solution details panel, 14 analytics rules, 15 hunting queries, 2 workbooks, 1 data connector](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec112.png)
*Picked this one deliberately, it's one of the permanently free data sources regardless of trial status.*

Connecting it actually runs an Azure Policy assignment behind the scenes:

![Assign policy wizard, "Configure Azure Activity logs to stream to specified Log Analytics workspace"](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec1999.png)

![Assign policy, Scope tab, subscription and resource group targeting](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec222.png)

![Data connectors page, Azure Activity listed alongside 8 already-connected Defender XDR sources](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec2444.png)

![Install Success toast, Azure Activity solution now shows Installed](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec8879.png)

This step turned into real troubleshooting rather than a clean click-through, worth documenting honestly since it's arguably more useful evidence than a smooth run would have been:

- The connector first showed **Connected** while Advanced Hunting kept returning empty results, no error, just nothing there.
- Digging into it turned up an actual **`InvalidAuthenticationToken`** error underneath, which decoded to a plain resource provider problem: `Microsoft.Insights` wasn't registered on the subscription. Fresh subscriptions, Azure for Students especially, don't auto-register every provider. Registering it (`Settings > Resource providers > Microsoft.Insights > Register`, or the CLI equivalent) cleared that.
- After that, the diagnostic setting itself still needed real activity to have something to ingest, Activity Log doesn't backfill history, it only captures operations from the moment the connector actually finishes connecting. I generated genuine test events deliberately: tagging the resource group twice, creating and deleting a Network Security Group, and assigning then removing a Reader role assignment to myself, six distinct logged operations across three different resource providers.
- I also hit `Failed to resolve table or column expression named 'SigninLogs'` when trying to extend into sign-in-focused hunting. That's a separate connector (Microsoft Entra ID) needing its own diagnostic setting, and on an education-managed tenant it may need Entra ID P1/P2 licensing and Global Admin permissions I might not hold here. Rather than getting stuck on it, I kept the hunting query built on `AzureActivity` instead, functionally the same "hunt for a repeated failure pattern" shape:
  ```kql
  AzureActivity
  | where ActivityStatusValue in ("Failure", "Start")
  | summarize FailedAttempts = count() by Caller, CallerIpAddress
  | where FailedAttempts > 3
  | sort by FailedAttempts desc
  ```

### 4. Building the Logic Apps playbook and wiring it to Sentinel

![Create Logic App, hosting plan selection, Consumption (Multi-tenant) chosen](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec11.png)

![Logic App review and create, soc-logic-app in rg-soc-lab, linked to law-soc-lab](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec8999.png)

![Logic app designer, Microsoft Sentinel entity trigger placed, nothing wired to it yet](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec22222.png)

![Full chain built: Microsoft Sentinel entity trigger connected to an HTTP Webhook action](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec68u866.png)
*The whole point of this step proven in one screenshot: a Sentinel-native trigger firing an actual outbound action.*

![Automation, Playbooks tab, soc-logic-app Active alongside a second AI-generated playbook, auto-klingon, Inactive](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec555j.png)
*Also had a go at Defender's newer AI Playbook Generator out of curiosity, not something the walkthrough asked for, left it Inactive since `soc-logic-app` is the one actually wired into the automation rule chain: Analytics rule → Incident → Automation rule → Playbook.*

### 5. A first look at Exposure Management

![Exposure management, Attack surface map, showing the tenant node branching to Devices, Identities, and Cloud](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/slurr.png)
*Opened this early out of curiosity. Devices and Identities both sit at 0 right now since I haven't onboarded a device yet, Cloud already shows 7 assets from the network hardening project. This map will actually mean something once Step G below is done.*

![Defender Home dashboard, Secure Score 39.73%, 0 users at risk](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/fe1e142fccaa3ded969b58681f78878fb5876327/Resources/resource2/sec3.png)

## Still to complete

- **Trigger a real incident** off the analytics rule I enabled and walk the investigation graph.
- **Onboard a device to Defender for Endpoint** (reusing the M365 E5 trial tenant), which is what will actually populate the Devices side of the Exposure Management map above.
- **Finish exploring Exposure Management** properly once there's a device and some identity data behind it, attack paths, secure score detail, initiatives.
- **Write the incident response runbook** properly: trigger, detection logic, investigation steps, response action, and the proactive hunting query documented above.
- **Clean up**: delete the Logic App, disable the analytics and automation rules, offboard any onboarded device, delete the Log Analytics workspace, and confirm £0 spend.
