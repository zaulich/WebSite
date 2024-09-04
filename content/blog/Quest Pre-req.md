---
title: PowerShell Graph API
date: 2023-03-15
authors:
  - name: imfing
    link: https://github.com/imfing
    image: https://github.com/imfing.png
tags:
  - Quest
  - GraphAPI
  - Automation
excludeSearch: false
---

In this post, we will explore how to use PowerShell to interact with Microsoft Graph API for automating tasks in Microsoft 365.
<!--more-->
# Quest Pre-req

## Phase 1

### Domain Rewirte:

- [ ]  License for On Demand Migration Domain Rewrite
- [ ]  AAD Account with Global Admin (for each tenant)
- [ ]  Azure AD PowerShell Accounts
    - [ ]  Three (3) PowerShell accounts are automatically created to read and update objects in the cloud. To do this an OAuth token is used from the account used to add the Cloud Environment.
    - [ ]  At least one (1) E1 or above license must be available to be assigned to the PowerShell account for Domain Move/Domain Rewrite Projects.
    - [ ]  The accounts must be excluded from MFA requirements.
- [ ]  **Are we sure no mailuser object is synced with a local AD (*Hybrid*)**
- [ ]  Certificate from each domain (no wildcard supported)
- [ ]