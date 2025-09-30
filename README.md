# 🛡️ Security Automation & Cloud Portfolio

This repository is a **living portfolio** of projects, scripts, and policies I’ve built to demonstrate my skills in **Microsoft Entra ID**, **Microsoft Graph PowerShell**, **Azure Cloud Engineering**, and **Threat Hunting**.  
Everything here is **modular, reusable, and tenant-agnostic** — designed to show *how* I solve problems, not tied to any single environment.

---

## 📂 Repo Structure

### 🔑 Identity & Access Management
- **[graph-remediation/](./graph-remediation)**  
  PowerShell utilities for incident response in Entra ID using Microsoft Graph.  
  Includes:
  - Revoke sign-in sessions
  - Reset user passwords with strong random generation
  - Disable user accounts
  - Clear MFA methods / force re-registration
  - Remove users from groups (e.g., MFA enforcement groups)

### 🛡️ Threat Hunting & Defender
- **[defender-hunting/](./defender-hunting)**  
  KQL hunting queries and regex detection patterns for Microsoft Defender XDR and Sentinel.  
  Examples:
  - Phishing email subject regexes  
  - Clicked phishing detection in Defender  
  - Suspicious sign-in anomaly queries  

### ☁️ Cloud Engineering / Azure
- **[azure-homelab/](./azure-homelab)**  
  Starter templates and Infrastructure-as-Code experiments for Azure.  
  - Bicep/ARM templates for secure lab environments  
  - Azure Functions demos (serverless security automation)  
  - Azure Monitor workbooks for sign-ins & audit logs  

### 📄 Policies & Governance
- **[policies/](./policies)**  
  Security and governance templates I’ve authored (sanitized for portfolio).  
  - Zero Trust access policies  
  - Conditional Access best practices  
  - Incident response playbooks  

### 📊 Presentations & Writeups
- **[docs/](./docs)**  
  Technical summaries, notes, and slide decks.  
  - Conference technical notes (e.g., KnowBe4 sessions)  
  - Career benchmarking / market analysis reports  
  - Cloud security research write-ups  

---

## 🛠️ Skills Demonstrated

- **Identity & Access Management (IAM)** with Microsoft Entra ID  
- **Microsoft Graph API** automation via PowerShell SDK  
- **Azure Cloud Engineering** (PaaS, monitoring, IaC basics)  
- **Threat Hunting** with KQL & regex in Microsoft Defender XDR/Sentinel  
- **Security Operations Automation** (incident response workflows)  
- **Governance & Policy Writing** (Zero Trust, CA policies, IR SOPs)  

---

## 🚀 Usage

All scripts are designed to be **modular and safe**:
- Support `-WhatIf` dry runs  
- Require explicit parameters (no hardcoding)  
- Store sensitive outputs securely (never print plaintext passwords)  

## Projects

- [01-bicep-rg-baseline](./01-bicep-rg-baseline) – Deploys a secure Azure Storage Account at **resource group scope** using **Bicep**, with GitHub Actions CI/CD validation (syntax check + what-if deployment).
