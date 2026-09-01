# ============================================
# Microsoft 365 Sensitivity Labels & DLP Setup Script
# Project 4 - Governance, Risk, Compliance
# ============================================

#  Prerequisites 
# 1. A mail-enabled security group must already exist (e.g., allstaffsec@yourtenant.onmicrosoft.com)
#    containing the users who should have encryption rights.
# 2. Azure Rights Management (RMS) must be activated. If not, run the optional Step 0 below.


# Connect to Exchange Online (if not already done)
# Connect-ExchangeOnline -UserPrincipalName "admin@yourtenant.onmicrosoft.com"
# Set-IRMConfiguration -AzureRMSLicensingEnabled $true
# Wait 10-15 minutes after activation

# Step 1: Connect to Security & Compliance PowerShell 
Connect-IPPSSession -UserPrincipalName "admin@secprojects.onmicrosoft.com"   # Replace with your admin UPN

# Step 2: Create Sensitivity Labels 
# Public label (no encryption)
New-Label -Name "Public" -DisplayName "Public" `
  -Tooltip "Business data approved for public release."

# General label (no encryption)
New-Label -Name "General" -DisplayName "General" `
  -Tooltip "Internal business data, not for public release."

# Confidential label (encrypted, with footer, restricted rights)
# IMPORTANT: Replace the email with your actual mail-enabled security group's email.
$groupEmail = "allstaffsec@secprojects.onmicrosoft.com"
New-Label -Name "Confidential" -DisplayName "Confidential" `
  -Tooltip "Sensitive data. Restricted access, no forwarding." `
  -ApplyContentMarkingFooterEnabled $true `
  -ApplyContentMarkingFooterText "Classified as Confidential" `
  -EncryptionEnabled $true `
  -EncryptionProtectionType "UserDefined" `
  -EncryptionRightsDefinitions "$groupEmail:VIEW,EDIT"

# Step 3: Publish Labels with a Label Policy 
$labelPolicy = New-LabelPolicy -Name "Lab Sensitivity Policy" `
  -Labels "Public", "General", "Confidential"

Set-LabelPolicy -Identity $labelPolicy.Name `
  -AddExchangeLocation "All" `
  -AddSharePointLocation "All" `
  -AddOneDriveLocation "All" `
  -Settings @{ requiredowngradejustification = "true" }

# Step 4: Create DLP Policy for Credit Card Numbers (Test Mode) 
$dlpPolicy = New-DlpCompliancePolicy -Name "Credit Card Lab Policy" `
  -ExchangeLocation "All" `
  -SharePointLocation "All" `
  -OneDriveLocation "All" `
  -Mode TestWithoutNotifications

New-DlpComplianceRule -Name "Detect Credit Card Numbers" `
  -Policy $dlpPolicy.Name `
  -ContentContainsSensitiveInformation @{Name = "Credit Card Number"} `
  -BlockAccess $false

# --- Step 5: Verification ---
Write-Host "`n--- Labels ---" -ForegroundColor Cyan
Get-Label | Format-Table Name, DisplayName, EncryptionEnabled

Write-Host "`n--- Label Policy ---" -ForegroundColor Cyan
Get-LabelPolicy -Identity "Lab Sensitivity Policy" | Format-List Name, ExchangeLocation, SharePointLocation, OneDriveLocation, Settings

Write-Host "`n--- DLP Policy ---" -ForegroundColor Cyan
Get-DlpCompliancePolicy -Identity "Credit Card Lab Policy" | Format-List Name, Mode, ExchangeLocation, SharePointLocation, OneDriveLocation
Get-DlpComplianceRule -Policy "Credit Card Lab Policy" | Format-List Name, ContentContainsSensitiveInformation, BlockAccess

Write-Host "`nScript completed. Review the output above." -ForegroundColor Green
