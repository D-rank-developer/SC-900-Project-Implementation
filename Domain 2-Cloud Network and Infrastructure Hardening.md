# Cloud Network and Infrastructure Hardening

A hands-on SC-900 project I completed in the Azure portal, built to put myself on the defending side of exactly the kind of finding I flagged in the ToR Legacy assessment, an exposed VM or a misconfigured network security group.

> Several screenshots below still show my real tenant name (University of Roehampton in the top-right nav), UPN, and a couple of subscription/object IDs. Worth blurring those before this repo goes fully public.

## The problem I set out to solve

An exposed VM or weak perimeter controls are exactly what I found and reported in the ToR Legacy assessment, an origin IP left reachable, no segmentation, no compensating controls if the first layer failed. I wanted to build the defended version of that same scenario myself, subnet segmentation, NSGs that actually deny by default, remote access with no public IP anywhere in the chain, secrets in a vault instead of config files, and a security posture I could benchmark against a named standard rather than just asserting it's "secure."

## Environment

I started in a subscription tied to Azure for Students, which turned out to carry its own default region and quota restrictions I hadn't accounted for. Partway through I moved onto a separate personal "Azure subscription 1" to get past those restrictions, so a couple of the early screenshots below show one subscription and the later ones show another, that's not a mistake, it's the actual environment switch I had to make mid-project.

## What I did

### 1. Resource group and network foundation

I created `rg-network-hardening-lab` in UK South to hold everything.

![Create a resource group, rg-network-hardening-lab in UK South](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec1.png)
*Resource group created first, so cleanup later is one click instead of a resource-by-resource hunt.*

Then I built `vnet-hardening-lab` with a `web-subnet` and a `data-subnet` inside it.

![VNet review and create screen, two address spaces and subnets configured](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec2.png)
*Review + create showing the VNet split into a web-subnet and a private subnet, Bastion, Firewall, and DDoS Network Protection all still Disabled at this stage, deliberately.*

![VNet deployment succeeded confirmation](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec3.png)
*Deployment complete, this is the point where I'd moved over to the personal Azure subscription 1 to get past the earlier region restriction.*

### 2. Default NSG rules, then a custom rule at priority 200

I created `nsg-web-subnet` and associated it with `web-subnet`.

![NSG creation succeeded](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec4.png)

![Associating nsg-web-subnet with web-subnet](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec5.png)

Before touching anything, I looked at what ships by default.

![Default inbound rules, AllowVnetInBound, AllowAzureLoadBalancerInBound, DenyAllInBound](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec6.png)
*Three rules I didn't create, at priorities 65000, 65001, and 65500, none of them deletable, only overridable.*

Then I added my own rule scoped to my own IP, at priority 200.

![Custom AllowMyAdminAccess rule at priority 200, sitting above the defaults](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec7.png)
*My rule now evaluates before DenyAllInBound ever gets a chance to. Lower number wins, and once traffic matches a rule, evaluation stops there.*

### 3. Two Application Security Groups, and a rule that references them instead of raw IPs

I created `asg-web` and `asg-data`.

![First Application Security Group deployment succeeded](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec8.png)

![Second Application Security Group deployment succeeded](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec9.png)

Then a second NSG for the data tier.

![nsg-data-subnet creation succeeded](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec10.png)

![Associating nsg-data-subnet with data-subnet](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec12.png)

![nsg-data-subnet inbound rules before the ASG rule was added](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec15.png)

Then the actual rule that references the ASGs by name instead of an IP list:

![AllowMyDataAcess rule, priority 210, port 1433, source asg-web](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec18.png)
*This is the whole point of ASGs. If I add three more web VMs later, I add each one's NIC to asg-web, this rule already covers them, no IP list to maintain, no NSG edit needed.*

### 4. Deploying the VM

The first real attempt at this hit a genuine wall, a `LowPriorityCores` quota error from an Azure Spot instance setting I hadn't meant to leave on, requesting far more cores than a small lab VM should ever need. Once I switched that off and explicitly picked a small B-series size, it deployed cleanly.

![VM deployment succeeded, vm-hardening-lab](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec19.png)
*No public IP anywhere in this VM's configuration, that was the whole point.*

### 5. Bastion: the trap I nearly fell into

This is the step where I actually walked straight into the exact mistake I'd been warned about. I went through the VM's Connect blade and, without realising it, ended up provisioning the paid Standard tier rather than the free Developer SKU.

![VM Connect blade showing Bastion (Basic, Standard, or Premium) already configured](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec777.png)

I caught it before it sat there running up a bill, and deleted it.

![Standard-tier Bastion instance mid-deletion, Tier: Standard, Provisioning state: Deleting](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec23.png)
*Region East US, Tier Standard, exactly the trap the walkthrough warned about. Caught it, deleted it, redeployed using the Developer SKU instead.*

![Bastion connect screen, Provisioning State Succeeded, credentials entered](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/gosec444.png)

![Live Bastion session, Windows desktop and Start menu inside the browser](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec29.png)

![Second live Bastion session, Edge open inside the VM](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec666.png)
*A full remote session streaming over TLS straight from the Azure portal, and there's no public IP anywhere in this chain for an attacker to even find. That's the clearest evidence of "no exposed attack surface" I could ask for.*

### 6. Key Vault, a real RBAC error, and the Standard vs Premium distinction

I created `kv-hardening-lab-ddc-443` on the Standard tier.

![Key Vault deployment in progress](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec45.png)

Then went to add a secret, and hit exactly the access-denied error the walkthrough warned me about, even as the vault's owner.

![Create a secret form, db-connection-stringx](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec90.png)

![RBAC error, "You are unauthorized to view these contents"](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec667.png)
*Being the Owner of the vault was not enough, Azure's RBAC permission model needs an explicit data-plane role.*

I added myself as **Key Vault Secrets Officer**, and made it an eligible, time-bound assignment rather than a permanent one, the same PIM pattern from my identity project.

![Add role assignment wizard, Conditions tab, Copilot troubleshooting panel open](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec6666.png)

![Role assignment details, Key Vault Secrets Officer, Eligible, time-bound for one year](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec5555.png)

![Key Vault IAM showing Owner and Key Vault Secrets Officer role assignments](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec1112.png)

![Secret db-connection-string successfully created](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec4455.png)

I stayed on the Standard pricing tier throughout, worth noting for the report why Premium exists at all: it's the tier where keys are generated and stored inside a Hardware Security Module and never leave that boundary, billed per HSM operation, not needed for a lab secret.

### 7. Defender for Cloud: secure score and real recommendations

I enabled the free foundational CSPM plan and checked coverage.

![Defender for Cloud coverage workbook](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec567.png)

The recommendations list surfaced two genuine findings tied directly to my own VM.

![Defender for Cloud recommendations, two findings on vm-hardening-lab about open network ports](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec8898.png)
*"All network ports should be restricted on network security groups" and "Management ports should be closed on your virtual machines," both flagged against vm-hardening-lab, both tracing straight back to my own AllowMyAdminAccess rule from Step 2.*

### 8. Adding a regulatory compliance standard

![Regulatory compliance standards list, CIS Controls, CIS Azure Foundations Benchmark, EU AI Act, Spain ENS, NIST SP 800-53, NIST CSF](https://github.com/D-rank-developer/SC-900-Project-Implementation/blob/2de020ae020de242587a9e63c677ea83da8626f7/Resources/resouces2/sec44456.png)
*The default Microsoft Cloud Security Benchmark is what's already driving my secure score for free. Anything in this list is a standard I'd deliberately add on top, each with its own dedicated pass/fail dashboard.*

## What I found: remediation report

| Finding | Severity | Benchmark reference | Recommendation |
|---|---|---|---|
| Management ports open to a broader source than necessary on `vm-hardening-lab` | Medium | MCSB, Network Security | Restrict the rule to the specific admin IP range only, and set a review date to remove it entirely once Bastion is confirmed working |
| All network ports flagged as insufficiently restricted on the NSG | Medium | MCSB, Network Security | Tighten scope-by-scope: only the ports genuinely needed per subnet, nothing left open by default |
| Key Vault initially relied on Owner role alone with no explicit data-plane grant | Low (but a real operational gap) | MCSB, Privileged Access | Use a scoped, time-bound Key Vault Secrets Officer assignment rather than assuming Owner covers data-plane operations, exactly what I ended up doing |

## Cleanup

Because I'd ended up working across two resource groups, `rg-network-hardening-lab` for the network layer and Key Vault, and a separate `vm-hardening-lab_group` that got created alongside the VM, cleanup meant deleting both, not just one. I confirmed £0 spend in Cost Management afterward, checking again the following day since cost data can lag.

## What I'd do differently in production

I'd pin the resource group explicitly on every single resource creation screen rather than trusting the wizard's default, that's exactly how I ended up with two resource groups instead of one. I'd also treat the Bastion tier selection as a deliberate checkpoint every time, not just once, it's an easy setting to click past without noticing, even when you already know it's there.
