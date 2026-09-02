# Data Protection and Loss Prevention

A hands-on SC-900 project in Microsoft Purview, built to prove I can classify and protect sensitive data end to end, not just describe sensitivity labels and DLP as exam concepts.

> A few screenshots below show my real tenant name (secprojects.onmicrosoft.com), UPN, and internal object IDs. Worth blurring before this goes fully public.

## The problem I set out to solve

Unclassified, unprotected sensitive data walking out the door, financial or health records specifically, is the same failure mode my ClinMal-Detect dissertation argues causes downstream financial and insurance harm. This project is the preventative control side of that same problem: label it, protect it, and catch it in transit before it ever leaves.

## Environment

A Microsoft 365 E5 trial tenant (`secprojects.onmicrosoft.com`), worked almost entirely through PowerShell this time rather than clicking through the Purview wizards, since I'd already proven I could do it by hand in the identity and network projects.

## What I did

### 1. Confirmed the tenant and opened Purview

![Microsoft 365 admin center home, secprojects.onmicrosoft.com tenant, Office 365 E5 license](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/sec1.png)

![Microsoft Purview portal homepage](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/sec2.png)

### 2. Getting PowerShell actually working, the real story

This wasn't a clean run. My first attempt was in Cloud Shell, and it hit the exact same wall I'd debugged before, the module already "in use" the moment it tries to install.

![Cloud Shell, PackageManagement and PowerShellGet "currently in use" warnings blocking the install](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/444.png)

Rather than keep fighting Cloud Shell, I switched to a local administrator PowerShell window, where the install finally landed clean.

![Local PowerShell, ExchangeOnlineManagement 3.10.1 installed and imported successfully](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/sec455.png)

![Connect-ExchangeOnline succeeded, Get-Mailbox returned a real result to prove the connection works](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/sec123.png)

![Connect-IPPSSession succeeded, the Security & Compliance PowerShell connection this whole project depends on](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/segway.png)

### 3. Created test users and a mail-enabled security group

I needed a real group to be the encryption rights target for the Confidential label, so I built one through the Admin Center rather than fighting PowerShell module conflicts for something this simple.

![All staff and All Company groups visible in Active teams and groups](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/sscce.png)

![All staff group membership, four test users added](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/sdfdsf.png)

### 4. Created the three sensitivity labels with `New-Label`

![New-Label output for Public and General, priority 0 and 1](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/surakingdom.png)

Confidential followed the same pattern with encryption switched on and rights scoped to the All staff group, no forwarding, restricted permissions, the property that makes a label meaningfully different from a folder name.

### 5. Published them with a label policy requiring justification to downgrade

![New-LabelPolicy output, all three labels bundled into "Lab Sensitivity Policy"](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/sec12334.png)
*`Set-LabelPolicy` followed this with `-Settings @{ requiredowngradejustification = "true" }`, scoped to Exchange, SharePoint, and OneDrive locations.*

### 6. Built the DLP policy for credit card numbers, in test mode

![Set-LabelPolicy justification setting, plus New-DlpCompliancePolicy and New-DlpComplianceRule output for the Credit Card Lab Policy](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/serfdsd.png)
*Created with `-Mode TestWithoutNotifications` and `-BlockAccess $false`, the tuning discipline before enforcement.*

### 7. Verified everything actually landed, and caught two real gotchas in the output itself

![Get-Label, Get-LabelPolicy, and Get-DlpCompliancePolicy output confirming everything created](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/dfsfsdfswf.png)

This one screenshot proved two things I'd only read about:

- **`Get-Label` shows a label called `Personal` that I never created.** That's the modern label scheme, Microsoft auto-creates a default set on tenants provisioned after October 2025, confirmed with my own eyes rather than taken on faith.
- **`Get-DlpCompliancePolicy` shows my Credit Card Lab Policy sitting at `DistributionStatus: Pending`**, alongside default policies like "Default DLP policy - Protect sensitive M365 Copilot interactions." That's the 24-hour provisioning window, also confirmed directly rather than assumed.

### Bonus: a first look at Compliance Manager

![Compliance Manager, Create assessment wizard, NIST 800-53 rev.5 selected](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2d0d6bb7fb2f2ed365c5328d52834a8cf9eddec6/Resources/resource4/nist4.png)
*Went a little further than this project strictly needed and started a NIST assessment out of curiosity, this is really where Project 5 picks up, evidence that the governance work started organically rather than as a separate cold start.*

## What I found

| Control | What I configured | What I observed |
|---|---|---|
| Sensitivity labels | Public, General, Confidential (encrypted, no-forward) via PowerShell | Modern label scheme had already auto-created a `Personal` label, confirmed by `Get-Label` |
| Label policy | Justification required on downgrade, scoped to Exchange/SharePoint/OneDrive | Bundled correctly, `Get-LabelPolicy` confirms all three labels attached |
| DLP policy | Credit Card Number detection, test mode, no blocking | `DistributionStatus: Pending` confirmed the 24-hour provisioning window directly from the API, not just from documentation |
| Encryption rights | Scoped to the All staff mail-enabled security group | Rights model requires a real mail-enabled group, not a Microsoft 365 group, for `-EncryptionRightsDefinitions` to work |

## What I'd do differently in production

I'd script the whole thing end to end in one repeatable module rather than switching between the Admin Center and PowerShell mid-project, the group creation step is the one piece I'd go back and script too, once I'd confirmed `Connect-ExchangeOnline` actually worked, `New-DistributionGroup` would have kept the whole build in one place.
