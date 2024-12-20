# Introduction

I use this template to build out my initial pagination logic when querying a large amount of Microsoft Graph results. It sets up a 'For Each' placeholder within which I can build what I want my Logic App to do. The other structures are needed to ensure all nextLink pages have been retrieved.

Depending on what you are querying Microsoft Graph will generally return 100 items per query, in larger environments you may quickly need to chase quite a few referrals to successive results.

The template when deployed using the button below will deploy a **Consumption** based Logic App and it will create an associated 'System assigned Managed Identity'.

Out of the box and assuming you have restricted generic access to Microsoft Graph the newly created managed identity will generally not have permissions to query [in the case of this sample template] all guest users in your organization. To address this I have included a sample PowerShell script which will retrieve the 'Object ID' of the new managed identity and assign it appropriate permissions within Microsoft Graph.

The application ID of Microsoft Graph is the same across all tenants. There are several other well-known application ID's for other Microsoft API's like SharePoint Online, Microsoft Teams, Azure Key Vault etc. You might also use a similar methodology to delegate access to them.

# Deploy to Azure

Click the button below to deploy the Logic App to Azure.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FUCDWraith%2Fazure_logic_apps%2Fmain%2Fdev-logic-msgraph-pagination-loop%2Ftemplate.json)

The Logic App is deployed in a **DISABLED** state. When you have assigned the relevant API permissions 'Enable' the Logic App in the portal (or update the template during the deployment such that it is Enabled).

# Logic App Structure
