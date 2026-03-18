# FinOps Production & Enterprise Guide

## Anleitung für Produktion und Unternehmenseinsatz

---

## Inhaltsverzeichnis

1. [Schnellstart](#1-schnellstart)
2. [Produktions-Checkliste](#2-produktions-checkliste)
3. [Schritt-für-Schritt Deployment](#3-schritt-für-schritt-deployment)
4. [Enterprise-Konfiguration](#4-enterprise-konfiguration)
5. [Dashboards & Reporting](#5-dashboards--reporting)
6. [Betriebshandbuch](#6-betriebshandbuch)
7. [Monatlicher FinOps-Review](#7-monatlicher-finops-review)
8. [Eskalations-Prozesse](#8-eskalations-prozesse)
9. [Enterprise Scaling](#9-enterprise-scaling)
10. [Chargeback/Showback Modell](#10-chargebackshowback-modell)
11. [Compliance & Audit](#11-compliance--audit)
12. [Troubleshooting](#12-troubleshooting)
13. [FAQ](#13-faq)

---

## 1. Schnellstart

### Voraussetzungen

- Azure Subscription mit **Cost Management + Billing** Berechtigung
- Terraform >= 1.5.0
- Azure CLI installiert und authentifiziert
- Berechtigungen: `Contributor` + `Resource Policy Contributor` auf der Subscription

### Minimale Konfiguration (5 Minuten)

```bash
# 1. terraform.tfvars konfigurieren
cp terraform.tfvars.example terraform.tfvars

# 2. FinOps-Variablen anpassen
```

```hcl
# In terraform.tfvars die FinOps-Sektion ausfüllen:
finops_monthly_budget   = 1000
finops_alert_emails     = ["ihr-team@firma.de"]
finops_budget_currency  = "EUR"
```

```bash
# 3. Terraform ausführen
terraform init
terraform plan -out=finops.tfplan
terraform apply finops.tfplan
```

### Erwartete Ressourcen nach Deployment

```
✅ Resource Group Budget          (mit 5 Alert-Schwellenwerten)
✅ Subscription Budget            (gesamt-Subscription)
✅ Cost Anomaly Alert             (KI-basiert)
✅ FinOps Action Group            (E-Mail-Benachrichtigungen)
✅ Advisor Cost Alert             (Optimierungs-Empfehlungen)
✅ 5× Tag-Pflicht-Policies        (Environment, CostCenter, Owner, Project, ManagedBy)
✅ 3× Tag-Vererbungs-Policies     (CostCenter, Environment, Project)
✅ Daily Cost Export               (nach Storage Account)
✅ FinOps Storage Account          (für Exportdaten)
```

---

## 2. Produktions-Checkliste

### Vor Go-Live

- [ ] **Budget festgelegt** — Realistische Budgets basierend auf Proof-of-Concept-Daten
- [ ] **Alert-Empfänger konfiguriert** — Echte E-Mail-Adressen eingetragen
- [ ] **Tagging-Standards kommuniziert** — Alle Teams kennen die Pflicht-Tags
- [ ] **Baseline erstellt** — Aktuelle Kosten als Referenzwert dokumentiert
- [ ] **FinOps-Rollen zugewiesen** — Mindestens ein FinOps Lead benannt
- [ ] **Eskalationspfade definiert** — Wer wird bei 90%+ Budget informiert?
- [ ] **Review-Termin geplant** — Monatlicher FinOps-Review im Kalender

### Nach Go-Live (erste 30 Tage)

- [ ] **Alert-Tests durchgeführt** — Mindestens einen Test-Alert ausgelöst
- [ ] **Dashboard eingerichtet** — Azure Cost Analysis als Shared View
- [ ] **Tag-Compliance geprüft** — Policy Compliance Dashboard kontrolliert
- [ ] **Erste Anomalie untersucht** — Prozess validiert
- [ ] **Kostenexporte verifiziert** — Storage Account enthält Export-Daten
- [ ] **Erster Review durchgeführt** — Erkenntnisse dokumentiert

### Regelmäßige Wartung

- [ ] **Monatlich:** Budget-Review und Anpassung
- [ ] **Monatlich:** Advisor-Empfehlungen prüfen und umsetzen
- [ ] **Quartalsweise:** Reserved Instance-Nutzung evaluieren
- [ ] **Quartalsweise:** Tag-Standards aktualisieren
- [ ] **Jährlich:** Budget-Planung für nächstes Geschäftsjahr

---

## 3. Schritt-für-Schritt Deployment

### Schritt 1: Azure-Berechtigungen prüfen

```bash
# Prüfen ob Cost Management API aktiviert ist
az provider show --namespace Microsoft.CostManagement --query "registrationState"

# Falls nicht registriert:
az provider register --namespace Microsoft.CostManagement

# Policy-Berechtigung prüfen
az role assignment list --assignee $(az account show --query user.name -o tsv) \
  --query "[?roleDefinitionName=='Resource Policy Contributor']"
```

### Schritt 2: Variablen konfigurieren

Öffnen Sie `terraform.tfvars` und passen Sie die FinOps-Sektion an:

```hcl
# ===========================================================
# MUSS angepasst werden
# ===========================================================
finops_alert_emails     = ["finops@ihre-firma.de", "cto@ihre-firma.de"]
finops_monthly_budget   = 2000   # Ihr monatliches Budget in EUR
finops_subscription_budget = 8000 # Gesamtbudget der Subscription

# ===========================================================
# KANN angepasst werden (sinnvolle Defaults vorhanden)
# ===========================================================
finops_budget_currency       = "EUR"
finops_alert_thresholds      = [50, 75, 90, 100, 110]
finops_enable_tagging_policy = true
finops_enable_anomaly_alerts = true
finops_enable_advisor_alerts = true
finops_required_tags         = ["Environment", "CostCenter", "Owner", "Project", "ManagedBy"]
```

### Schritt 3: Plan & Apply

```bash
# Terraform initialisieren
terraform init

# Plan erstellen und FinOps-Ressourcen prüfen
terraform plan -target=module.finops -out=finops.tfplan

# Nur FinOps-Modul deployen (empfohlen beim ersten Mal)
terraform apply finops.tfplan

# Oder alles zusammen deployen
terraform plan -out=full.tfplan
terraform apply full.tfplan
```

### Schritt 4: Deployment verifizieren

```bash
# Budget prüfen
az consumption budget list --resource-group $(terraform output -raw resource_group_name)

# Policy Assignments prüfen
az policy assignment list --resource-group $(terraform output -raw resource_group_name) \
  --query "[?contains(displayName, 'tag')]" -o table

# Cost Export prüfen
az costmanagement export list --scope "subscriptions/$(az account show --query id -o tsv)"

# Anomaly Alert prüfen
az rest --method get \
  --url "https://management.azure.com/subscriptions/$(az account show --query id -o tsv)/providers/Microsoft.CostManagement/scheduledActions?api-version=2022-10-01"
```

---

## 4. Enterprise-Konfiguration

### Multi-Subscription Setup

Für Unternehmen mit mehreren Subscriptions:

```hcl
# Enterprise terraform.tfvars

# Produktions-Subscription
finops_monthly_budget             = 5000
finops_subscription_budget        = 20000
finops_enable_subscription_budget = true

# Alle Alert-Schwellenwerte aktivieren
finops_alert_thresholds = [25, 50, 75, 90, 95, 100, 110, 120]

# Erweiterte Alert-Empfänger
finops_alert_emails = [
  "finops-team@enterprise.com",
  "cloud-governance@enterprise.com",
  "cfo-office@enterprise.com"
]

# Strenge Tag-Governance
finops_enable_tagging_policy = true
finops_required_tags = [
  "Environment",
  "CostCenter",
  "Owner",
  "Project",
  "ManagedBy",
  "BusinessUnit",
  "Department",
  "ApplicationID",
  "Compliance"
]
```

### Management Group-Level Governance

Für unternehmensweite Governance empfehlen wir zusätzliche Azure Policies auf Management Group-Ebene:

```hcl
# Beispiel: Management Group Policy (separat deployen)
resource "azurerm_management_group_policy_assignment" "require_costcenter" {
  name                 = "require-costcenter-enterprise"
  management_group_id  = data.azurerm_management_group.root.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b466-ce391587003f"

  parameters = jsonencode({
    tagName = { value = "CostCenter" }
  })
}
```

### Webhook-Integration (Teams/Slack/PagerDuty)

Erweitern Sie das FinOps Action Group mit Webhooks:

```hcl
# In modules/finops/main.tf ergänzen (nach email_receiver):
webhook_receiver {
  name                    = "teams-finops"
  service_uri             = "https://outlook.office.com/webhook/..."
  use_common_alert_schema = true
}

webhook_receiver {
  name                    = "pagerduty-finops"
  service_uri             = "https://events.pagerduty.com/integration/..."
  use_common_alert_schema = true
}
```

---

## 5. Dashboards & Reporting

### Azure Cost Analysis Views einrichten

#### View 1: Kosten nach Umgebung

1. Azure Portal → **Cost Management** → **Cost Analysis**
2. View: **AccumulatedCosts**
3. Gruppierung: **Tag: Environment**
4. Zeitraum: **MonthToDate**
5. Speichern als: `FinOps - Kosten nach Umgebung`

#### View 2: Kosten nach Service

1. View: **CostByService**
2. Gruppierung: **ServiceName**
3. Zeitraum: **Last3Months**
4. Speichern als: `FinOps - Kosten nach Service`

#### View 3: Kosten nach Team

1. View: **AccumulatedCosts**
2. Gruppierung: **Tag: Owner**
3. Zeitraum: **MonthToDate**
4. Speichern als: `FinOps - Kosten nach Team`

#### View 4: Tag-Compliance

1. Azure Portal → **Policy** → **Compliance**
2. Filter: Scope = Resource Group
3. Filter: Policy = enthält "tag"

### Automatische Reports

Die täglichen Cost Exports werden automatisch nach `{project}{env}finops` Storage Account exportiert:

```
Storage Account
└── cost-exports/
    └── {environment}/
        └── YYYY-MM-DD/
            └── cost-export.csv
```

### Power BI Dashboard (optional)

```
1. Power BI Desktop öffnen
2. Get Data → Azure → Azure Blob Storage
3. Storage Account: {project}{env}finops
4. Container: cost-exports
5. Transformieren und Visualisieren
```

---

## 6. Betriebshandbuch

### Tägliche Aufgaben

| Aufgabe | Verantwortlich | Werkzeug |
|---|---|---|
| Alert-E-Mails prüfen | FinOps Team | E-Mail/Teams |
| Cost Analysis Dashboard öffnen | FinOps Analyst | Azure Portal |
| Anomalie-Meldungen bearbeiten | On-Call Engineer | Azure Portal |

### Wöchentliche Aufgaben

| Aufgabe | Verantwortlich | Werkzeug |
|---|---|---|
| Kostentrend der Woche analysieren | FinOps Analyst | Cost Analysis |
| Advisor Empfehlungen prüfen | Cloud Engineer | Azure Advisor |
| Budget-Forecast prüfen | FinOps Lead | Cost Management |
| Tag-Compliance überprüfen | FinOps Analyst | Azure Policy |

### Auf Budget-Alert reagieren

```
Alert empfangen
    │
    ├── 50% Schwellenwert
    │   └── Informativ: Kostentrend in Weekly Review ansprechen
    │
    ├── 75% Schwellenwert
    │   └── Aktion: Team informieren, Advisor-Empfehlungen prüfen
    │       └── Right-Sizing Möglichkeiten evaluieren
    │
    ├── 90% Schwellenwert
    │   └── Dringend: Sofortige Analyse starten
    │       ├── Unerwartete Ressourcen identifizieren
    │       ├── Skalierung prüfen
    │       └── Quick Wins umsetzen
    │
    ├── 100% Schwellenwert
    │   └── Eskalation: Management informieren
    │       ├── Budget-Erhöhung beantragen ODER
    │       └── Kostensenkungsmaßnahmen einleiten
    │
    └── 110% Forecast
        └── Prognose: Proaktive Maßnahmen planen
            └── Nächsten Monat Budget-Überschreitung verhindern
```

### Auf Anomalie-Alert reagieren

1. **Alert öffnen** — Link in der E-Mail folgen
2. **Ursache identifizieren** — Welche Ressource verursacht die Anomalie?
3. **Bewerten** — Geplant (z.B. Deployment) oder unerwartet?
4. **Handeln** — Wenn unerwartet: Ressource prüfen, ggf. skalieren/stoppen
5. **Dokumentieren** — Erkenntnisse im nächsten Review teilen

---

## 7. Monatlicher FinOps-Review

### Agenda-Template

```markdown
# FinOps Monthly Review — [Monat/Jahr]

## Teilnehmer
- FinOps Lead
- Engineering Lead
- Product Owner
- Finance Partner (optional)

## Agenda (60 Min)

### 1. Kosten-Überblick (10 Min)
- [ ] Gesamtkosten vs. Budget (Actual vs. Forecast)
- [ ] Kostentrend der letzten 3 Monate
- [ ] Top 5 Kostenverursacher

### 2. Anomalien & Alerts (10 Min)
- [ ] Anzahl Budget-Alerts im letzten Monat
- [ ] Anomalien und deren Ursachen
- [ ] Nicht bearbeitete Alerts

### 3. Optimierungen (15 Min)
- [ ] Umgesetzte Optimierungen und Einsparungen
- [ ] Azure Advisor Empfehlungen (offen)
- [ ] Reserved Instance Nutzung & Empfehlung
- [ ] Right-Sizing Möglichkeiten

### 4. Tag Compliance (10 Min)
- [ ] Tag-Compliance-Rate (Ziel: >95%)
- [ ] Nicht-compliant Ressourcen
- [ ] Neue Tag-Anforderungen

### 5. Aktionspunkte (15 Min)
- [ ] Neue Optimierungsmaßnahmen definieren
- [ ] Budget-Anpassungen für nächsten Monat
- [ ] Verantwortliche für Aktionspunkte benennen

## Ergebnisse
| Aktion | Verantwortlich | Deadline |
|--------|---------------|----------|
| | | |
```

### Review-Metriken sammeln

```bash
# Aktuelle Kosten abrufen (letzter Monat)
az costmanagement query \
  --type ActualCost \
  --timeframe MonthToDate \
  --scope "subscriptions/$(az account show --query id -o tsv)" \
  --query "properties.rows"

# Advisor Empfehlungen abrufen
az advisor recommendation list \
  --category Cost \
  --query "[].{impact: impact, category: category, description: shortDescription.solution}" \
  -o table

# Budget-Status
az consumption budget list \
  --resource-group $(terraform output -raw resource_group_name) \
  --query "[].{name:name, amount:amount, currentSpend:currentSpend.amount}" \
  -o table

# Tag-Compliance (Policy)
az policy state summarize \
  --resource-group $(terraform output -raw resource_group_name) \
  --query "value[?contains(policyAssignmentName, 'tag')].{name:policyAssignmentName, compliant:results.nonCompliantResources}" \
  -o table
```

---

## 8. Eskalations-Prozesse

### Eskalationsmatrix

| Schweregrad | Auslöser | Erstreaktion | Eskalation 1 | Eskalation 2 |
|---|---|---|---|---|
| **Info** | 50% Budget | FinOps Analyst | — | — |
| **Warnung** | 75% Budget | FinOps Lead | Engineering Lead | — |
| **Kritisch** | 90% Budget | Engineering Team | CTO | CFO |
| **Überschreitung** | 100%+ Budget | Engineering + FinOps | CTO + CFO | Board |
| **Anomalie** | KI-Erkennung | On-Call Engineer | FinOps Lead | CTO |

### Eskalations-Timeframes

| Schweregrad | Max. Reaktionszeit | Max. Lösungszeit |
|---|---|---|
| Info | 5 Arbeitstage | Nächster Review |
| Warnung | 2 Arbeitstage | 5 Arbeitstage |
| Kritisch | 4 Stunden | 2 Arbeitstage |
| Überschreitung | 1 Stunde | 1 Arbeitstag |
| Anomalie | 4 Stunden | 2 Arbeitstage |

---

## 9. Enterprise Scaling

### Multi-Team Setup

```
Enterprise FinOps Structure
│
├── Central FinOps Team
│   ├── FinOps Director
│   ├── FinOps Analysts (2-3)
│   └── Cloud Architect
│
├── Team A (Product Engineering)
│   ├── CostCenter: "eng-product"
│   ├── Budget: 5.000€/Monat
│   └── Owner: team-a-lead
│
├── Team B (Data Platform)
│   ├── CostCenter: "eng-data"
│   ├── Budget: 8.000€/Monat
│   └── Owner: team-b-lead
│
└── Team C (Infrastructure)
    ├── CostCenter: "eng-infra"
    ├── Budget: 3.000€/Monat
    └── Owner: team-c-lead
```

### Multi-Team Terraform-Konfiguration

```hcl
# Für jedes Team separates Budget
module "finops_team_a" {
  source              = "./modules/finops"
  project_name        = "team-a"
  environment         = var.environment
  monthly_budget_amount = 5000
  budget_alert_emails = ["team-a@enterprise.com", "finops@enterprise.com"]
  # ... weitere Variablen
}

module "finops_team_b" {
  source              = "./modules/finops"
  project_name        = "team-b"
  environment         = var.environment
  monthly_budget_amount = 8000
  budget_alert_emails = ["team-b@enterprise.com", "finops@enterprise.com"]
  # ... weitere Variablen
}
```

### Enterprise Landing Zone Integration

```
Management Group Hierarchy
│
├── Root Management Group
│   └── Policy: Require CostCenter tag (enterprise-wide)
│
├── Production
│   ├── Subscription: Prod-Workloads
│   │   └── FinOps Module (prod settings)
│   └── Subscription: Prod-Data
│       └── FinOps Module (prod settings)
│
├── Non-Production
│   ├── Subscription: Dev
│   │   └── FinOps Module (dev settings)
│   └── Subscription: Staging
│       └── FinOps Module (staging settings)
│
└── Shared Services
    └── Subscription: Shared-Infra
        └── FinOps Module (shared settings)
```

---

## 10. Chargeback/Showback Modell

### Showback (Kostentransparenz)

Showback zeigt Teams ihre Kosten, ohne sie direkt zu belasten:

| Team | CostCenter Tag | Monatliche Kosten | % vom Gesamt |
|---|---|---|---|
| Product Engineering | `eng-product` | 5.200€ | 35% |
| Data Platform | `eng-data` | 7.800€ | 52% |
| Infrastructure | `eng-infra` | 1.900€ | 13% |
| **Gesamt** | | **14.900€** | **100%** |

### Chargeback (Kostenverrechnung)

Chargeback belastet die Kosten direkt an die verantwortlichen Kostenstellen:

```
Gesamtkosten: 14.900€/Monat
│
├── Direkte Kosten (80%)     → Per CostCenter Tag zugeordnet
│   ├── AKS Nodes            → Team mit den meisten Pods
│   ├── Databases             → Team das DB nutzt
│   └── Storage               → Team mit meistem Verbrauch
│
├── Geteilte Kosten (15%)    → Pro-Rata-Verteilung
│   ├── Networking            → Anteilig nach Traffic
│   ├── Monitoring            → Gleichmäßig verteilt
│   └── Security (Key Vault)  → Gleichmäßig verteilt
│
└── Plattform-Kosten (5%)   → Zentral getragen
    ├── Management Tools
    └── FinOps-Infrastruktur
```

### Implementierung in Azure

1. **Tags konsequent setzen** — `CostCenter` auf jeder Ressource
2. **Cost Analysis Views** — Gruppiert nach `CostCenter`
3. **Cost Export** — Tägliche CSVs für Finance
4. **Power BI Report** — Automatisierte monatliche Chargeback-Reports

---

## 11. Compliance & Audit

### FinOps Compliance Checks

| Prüfpunkt | Häufigkeit | Werkzeug |
|---|---|---|
| Alle Ressourcen haben Pflicht-Tags | Täglich (automatisch) | Azure Policy |
| Budgets sind aktuell und aktiv | Monatlich | terraform plan |
| Alert-Empfänger sind aktuell | Quartalsweise | Manuell |
| Kostenexporte funktionieren | Wöchentlich | Storage Account prüfen |
| Advisor-Empfehlungen bearbeitet | Monatlich | Azure Advisor |
| RI-Nutzung > 70% | Monatlich | RI Utilization Report |

### Audit-Trail

Alle FinOps-relevanten Änderungen werden erfasst durch:

1. **Terraform State** — Alle Infrastructure-Änderungen versioniert
2. **Azure Activity Log** — API-Calls und Ressourcenänderungen
3. **Git History** — Alle tfvars-Änderungen nachvollziehbar
4. **Cost Export History** — Tägliche Kostensnaps im Storage Account

### Regulatorische Anforderungen

| Standard | Relevante FinOps-Kontrollen |
|---|---|
| **ISO 27001** | Zugriffskontrolle auf Kosteninformationen |
| **SOC 2** | Change Management für Budget-Änderungen |
| **DSGVO** | Keine personenbezogenen Daten in Tags |
| **BSI C5** | Nachvollziehbarkeit aller Kostenänderungen |

---

## 12. Troubleshooting

### Häufige Probleme

#### Budget-Alerts kommen nicht an

```bash
# Action Group testen
az monitor action-group test-notifications create \
  --resource-group <rg-name> \
  --action-group ag-finops-<env> \
  --alert-type budget

# E-Mail-Adresse prüfen
az monitor action-group show \
  --resource-group <rg-name> \
  --name ag-finops-<env> \
  --query "emailReceivers"
```

**Mögliche Ursachen:**
- E-Mail-Adresse falsch konfiguriert
- E-Mails landen im Spam-Ordner
- Azure-Absender (`azure-noreply@microsoft.com`) blockiert

#### Policy-Compliance zeigt Fehler

```bash
# Nicht-compliant Ressourcen auflisten
az policy state list \
  --resource-group <rg-name> \
  --filter "complianceState eq 'NonCompliant'" \
  --query "[].{resource:resourceId, policy:policyAssignmentName}" \
  -o table

# Tag manuell nachsetzen
az resource tag --tags CostCenter=engineering \
  --ids <resource-id>
```

#### Cost Export enthält keine Daten

```bash
# Export-Status prüfen
az costmanagement export show \
  --name <export-name> \
  --scope "subscriptions/<subscription-id>"

# Storage Account Zugriff prüfen
az storage blob list \
  --account-name <finops-storage-account> \
  --container-name cost-exports \
  --output table
```

#### Terraform-Fehler: "Budget already exists"

```bash
# Existierendes Budget importieren
terraform import module.finops.azurerm_consumption_budget_resource_group.main \
  <budget-resource-id>
```

---

## 13. FAQ

### Allgemein

**Q: Was kostet die FinOps-Implementierung selbst?**
A: Minimal. Azure Cost Management ist kostenlos. Der FinOps Storage Account kostet ca. 0,50€/Monat für Exports. Azure Policies sind kostenlos.

**Q: Können wir FinOps schrittweise einführen?**
A: Ja. Starten Sie mit Budgets und Alerts (`finops_enable_tagging_policy = false`), und aktivieren Sie Policies später.

**Q: Funktioniert das mit bestehenden Ressourcen?**
A: Ja. Budgets und Alerts funktionieren sofort. Tag-Policies gelten nur für neue Ressourcen, außer Sie triggern eine Remediation.

### Budget

**Q: Was passiert, wenn das Budget überschritten wird?**
A: Nichts automatisch — es werden nur Alerts gesendet. Azure stoppt keine Ressourcen. Für automatische Aktionen benötigen Sie Logic Apps oder Azure Automation.

**Q: Kann ich verschiedene Budgets pro Monat haben?**
A: Nein, Azure Budgets haben einen festen Betrag. Für saisonale Schwankungen empfehlen wir den höchsten erwarteten Monat als Budget.

**Q: Welche Währungen werden unterstützt?**
A: USD, EUR, GBP, und alle von Azure unterstützten Billing-Währungen.

### Tags

**Q: Was passiert mit bestehenden Ressourcen ohne Tags?**
A: Die Require-Tag-Policy (`Deny`) betrifft nur neue Ressourcen und Änderungen. Für bestehende Ressourcen nutzen Sie die Inherit-Tag-Policy oder manuelle Remediation.

**Q: Können wir die Pflicht-Tags anpassen?**
A: Ja, über die Variable `finops_required_tags` in `terraform.tfvars`.

### Enterprise

**Q: Wie skaliert das für 100+ Subscriptions?**
A: Nutzen Sie Management Group Policies für enterprise-weite Tag-Governance und separate FinOps-Module pro Subscription/Team.

**Q: Können wir Power BI statt Azure Portal nutzen?**
A: Ja. Die täglichen Cost Exports in den Storage Account können direkt in Power BI eingebunden werden.

---

## Nächste Schritte

1. **Jetzt:** `terraform.tfvars` mit echten Werten konfigurieren
2. **Tag 1:** `terraform apply` und Deployment verifizieren
3. **Woche 1:** Dashboard einrichten, erste Alerts empfangen
4. **Monat 1:** Erster FinOps Review, Baseline dokumentieren
5. **Monat 2:** Erste Optimierungen umsetzen (Right-Sizing, Advisor)
6. **Quartal 1:** Reserved Instance Evaluation
7. **Quartal 2:** Chargeback/Showback Modell einführen
