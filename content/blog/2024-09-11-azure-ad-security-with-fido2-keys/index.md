---
title: Strengthening Azure AD Security with FIDO2 Keys
date: 2024-09-11T06:24:59.453Z
authors:
  - name: Mads Zaulich
    link: https://www.linkedin.com/in/zaulich/
    fieldGroup: authors_group
    image: /images/zaulich.jpg
tags: []
excludeSearch: false
heroImage: /images/Blogposts/images.jpg
draft: true
linkTitle: ""
slug: 2024/strengthening-azure-ad-security-with-fido2-keys
description: FIDO2 Security Keys offer a authentication solution for Azure AD. This enhances both security and user experience by eliminating the need for passwords.
---
![](images.jpg)
## What are FIDO2 Security Keys?

FIDO2 is an open authentication standard that supports passwordless authentication. These keys can be used to authenticate users in a highly secure manner, using public key cryptography.

### Benefits of FIDO2 Keys:

1. **Passwordless authentication**: No need to remember or manage passwords.
2. **Phishing resistance**: FIDO2 keys use cryptographic methods that make them resistant to phishing attacks.
3. **Ease of use**: A simple tap or fingerprint scan is all that’s required for authentication.

## How to Enable FIDO2 Keys in Azure AD

1. **Register FIDO2 keys**: Users can register their FIDO2 security keys in the Azure AD portal.
2. **Assign user roles**: Ensure that users have the appropriate roles and permissions to use passwordless authentication.
3. **Configure Conditional Access**: You can create Conditional Access policies to enforce FIDO2 authentication for high-risk scenarios.

Example PowerShell command to enable FIDO2 authentication for Azure AD:

```powershell
# Enable FIDO2 Security Keys in Azure AD
Connect-AzureAD
Set-AzureADPolicy -Id "Fido2Policy" -DisplayName "Enable FIDO2" -PolicyDefinition 
'{"fido2Authentication": true}'
