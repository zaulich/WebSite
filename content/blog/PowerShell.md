---
title: PowerShell Graph API
date: 2023-03-15
authors:
  - name: imfing
    link: https://github.com/imfing
    image: https://github.com/imfing.png
  - name: GraphMaster
    link: https://github.com/graphmaster
    image: https://github.com/graphmaster.png
tags:
  - PowerShell
  - GraphAPI
  - Automation
excludeSearch: false
---

In this post, we will explore how to use PowerShell to interact with Microsoft Graph API for automating tasks in Microsoft 365.
<!--more-->

## What is Microsoft Graph API?

Microsoft Graph API is a unified API endpoint that allows you to access and manipulate a wide array of Microsoft 365 services such as Exchange, SharePoint, Teams, and more.

### Connecting to Microsoft Graph API with PowerShell

```powershell
# Install the Microsoft.Graph module
Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All"

By running the code above, you authenticate to Microsoft Graph and can start interacting with its resources.

Example Query: Get User Information
powershell
Kopier kode
# Get a list of users from Azure AD
Get-MgUser | Select-Object DisplayName, UserPrincipalName