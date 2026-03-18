# FinOps Konzept — CloudOps Bootstrap

## Inhaltsverzeichnis

1. [Executive Summary](#1-executive-summary)
2. [Was ist FinOps?](#2-was-ist-finops)
3. [FinOps Framework & Prinzipien](#3-finops-framework--prinzipien)
4. [Architektur & Implementierung](#4-architektur--implementierung)
5. [Kostenmodell & Budget-Struktur](#5-kostenmodell--budget-struktur)
6. [Tagging-Strategie](#6-tagging-strategie)
7. [Alerting & Anomalie-Erkennung](#7-alerting--anomalie-erkennung)
8. [Governance & Policies](#8-governance--policies)
9. [Rollen & Verantwortlichkeiten](#9-rollen--verantwortlichkeiten)
10. [KPIs & Metriken](#10-kpis--metriken)
11. [Optimierungs-Strategien](#11-optimierungs-strategien)
12. [Umgebungsspezifische Konfiguration](#12-umgebungsspezifische-konfiguration)
13. [Terraform-Implementierung](#13-terraform-implementierung)
14. [Weiterführende Dokumente](#14-weiterführende-dokumente)

---

## 1. Executive Summary

Dieses Dokument beschreibt das **FinOps-Konzept** für das CloudOps Bootstrap Projekt. FinOps (Cloud Financial Operations) ist ein operatives Framework, das finanzielle Verantwortlichkeit in der Cloud-Nutzung etabliert. Die Implementierung umfasst:

- **Automatisierte Budgetkontrolle** auf Resource-Group- und Subscription-Ebene
- **Echtzeit-Kostenanomalien-Erkennung** mit Azure Cost Management
- **Tag-basierte Kostenzuordnung** (Showback/Chargeback)
- **Azure Policy Enforcement** für mandatorische Tagging-Standards
- **Tägliche Kostenexporte** für Analyse und Reporting
- **Azure Advisor Integration** für Optimierungsempfehlungen

### Geschätzte Einsparungen

| Maßnahme | Erwartete Einsparung |
|---|---|
| Right-Sizing (Advisor) | 15-30% |
| Reserved Instances | 20-40% |
| Dev/Test Abschaltung | 30-60% |
| Storage Tiering | 10-25% |
| **Gesamt** | **25-45%** |

---

## 2. Was ist FinOps?

FinOps ist eine **kulturelle Praxis**, die Technologie, Finance und Business zusammenbringt, um datengesteuerte Entscheidungen über Cloud-Ausgaben zu treffen.

### Die drei Phasen von FinOps

```
┌─────────────────────────────────────────────────────────────┐
│                    FinOps Lifecycle                          │
│                                                             │
│   ┌───────────┐    ┌───────────┐    ┌───────────────┐      │
│   │  INFORM   │───▶│ OPTIMIZE  │───▶│   OPERATE     │      │
│   │           │    │           │    │               │      │
│   │ Sichtbar- │    │ Kosten-   │    │ Kontinuier-   │      │
│   │ keit      │    │ reduktion │    │ liche Ver-    │      │
│   │ schaffen  │    │           │    │ besserung     │      │
│   └───────────┘    └───────────┘    └───────────────┘      │
│         ▲                                    │              │
│         └────────────────────────────────────┘              │
│                   Continuous Loop                            │
└─────────────────────────────────────────────────────────────┘
```

| Phase | Beschreibung | Unsere Implementierung |
|---|---|---|
| **Inform** | Transparenz über Cloud-Kosten | Budgets, Tags, Cost Exports, Dashboards |
| **Optimize** | Kosten reduzieren ohne Qualitätsverlust | Right-Sizing, Reserved Instances, Autoscaling |
| **Operate** | Prozesse und Governance etablieren | Policies, Alerts, Reviews, Automatisierung |

---

## 3. FinOps Framework & Prinzipien

### Kernprinzipien (FinOps Foundation)

| # | Prinzip | Umsetzung im Projekt |
|---|---|---|
| 1 | **Teams müssen zusammenarbeiten** | Shared Dashboards, gemeinsame Alert-Kanäle |
| 2 | **Entscheidungen auf Business Value basieren** | KPI-basierte Budgets, nicht nur technische Metriken |
| 3 | **Jeder ist für Cloud-Kosten verantwortlich** | Tag-basierte Kostenzuordnung pro Team/Projekt |
| 4 | **FinOps-Reports müssen zugänglich sein** | Tägliche Cost Exports, automatisierte Reports |
| 5 | **Ein zentrales Team treibt FinOps** | FinOps-Rollen definiert (siehe Abschnitt 9) |
| 6 | **Cloud-Variable-Cost-Modell nutzen** | Autoscaling, Spot Instances, Pay-per-Use |

---

## 4. Architektur & Implementierung

### Architekturübersicht

```
┌─────────────────────────────────────────────────────────────────┐
│                    Azure Subscription                             │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │ Azure Cost Management                                     │    │
│  │  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐  │    │
│  │  │ Subscription │  │  Resource     │  │  Cost Anomaly  │  │    │
│  │  │  Budget      │  │  Group Budget │  │  Detection     │  │    │
│  │  │  (5.000€/m)  │  │  (1.000€/m)  │  │                │  │    │
│  │  └──────┬───────┘  └──────┬───────┘  └───────┬────────┘  │    │
│  │         │                 │                   │            │    │
│  │         ▼                 ▼                   ▼            │    │
│  │  ┌─────────────────────────────────────────────────┐      │    │
│  │  │            Alert & Notification System           │      │    │
│  │  │  • Email Notifications (50%, 75%, 90%, 100%)    │      │    │
│  │  │  • Anomaly Detection Alerts                     │      │    │
│  │  │  • Azure Advisor Recommendations                │      │    │
│  │  └───────────────────────┬─────────────────────────┘      │    │
│  └──────────────────────────┼────────────────────────────────┘    │
│                             │                                     │
│  ┌──────────────────────────┼────────────────────────────────┐    │
│  │ Azure Policy             │                                 │    │
│  │  ┌────────────────────┐  │  ┌─────────────────────────┐   │    │
│  │  │ Require Tags       │  │  │ Inherit Tags from RG    │   │    │
│  │  │ • Environment      │  │  │ • CostCenter            │   │    │
│  │  │ • CostCenter       │  │  │ • Environment           │   │    │
│  │  │ • Owner            │  │  │ • Project               │   │    │
│  │  │ • Project          │  │  │                         │   │    │
│  │  │ • ManagedBy        │  │  └─────────────────────────┘   │    │
│  │  └────────────────────┘  │                                 │    │
│  └──────────────────────────┼────────────────────────────────┘    │
│                             │                                     │
│  ┌──────────────────────────┼────────────────────────────────┐    │
│  │ Cost Export Pipeline     ▼                                 │    │
│  │  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐   │    │
│  │  │ Daily Export │─▶│ Storage Acct │─▶│ Power BI /     │   │    │
│  │  │ (ActualCost) │  │ (Blob)       │  │ Azure Portal   │   │    │
│  │  └─────────────┘  └──────────────┘  └────────────────┘   │    │
│  └───────────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────┘
```

### Terraform-Module

| Modul | Datei | Funktion |
|---|---|---|
| **FinOps Core** | `IaC/modules/finops/main.tf` | Budgets, Alerts, Exports, Policies |
| **FinOps Tagging** | `IaC/modules/finops/tagging.tf` | Standardisierte Tag-Definitionen |

---

## 5. Kostenmodell & Budget-Struktur

### Budget-Hierarchie

```
Subscription Budget (5.000€/Monat)
├── Resource Group: {project}-dev-rg     (1.000€ × 1.0 = 1.000€)
├── Resource Group: {project}-staging-rg (1.000€ × 1.5 = 1.500€)
└── Resource Group: {project}-prod-rg    (1.000€ × 3.0 = 3.000€)
```

### Umgebungs-Multiplikatoren

| Umgebung | Multiplikator | Begründung |
|---|---|---|
| **dev** | 1.0x | Basis-Budget, minimale Ressourcen |
| **staging** | 1.5x | Produktionsähnlich, aber reduziert |
| **prod** | 3.0x | Volle Kapazität, Hochverfügbarkeit |

### Alert-Schwellenwerte

| Schwellenwert | Typ | Aktion |
|---|---|---|
| **50%** | Actual Cost | Information — Kostenentwicklung beobachten |
| **75%** | Actual Cost | Warnung — Team informieren, Maßnahmen planen |
| **90%** | Actual Cost | Kritisch — Sofortige Prüfung, Optimierung starten |
| **100%** | Actual Cost | Überschreitung — Eskalation an Management |
| **110%** | Forecasted | Prognose — Budget wird voraussichtlich überschritten |

---

## 6. Tagging-Strategie

### Pflicht-Tags (Mandatory)

| Tag-Name | Beschreibung | Beispielwerte | Zweck |
|---|---|---|---|
| `Environment` | Umgebung | `dev`, `staging`, `prod` | Kostenzuordnung per Umgebung |
| `CostCenter` | Kostenstelle | `engineering`, `marketing` | Chargeback/Showback |
| `Owner` | Verantwortliches Team | `platform-team`, `dev-team` | Accountability |
| `Project` | Projektname | `kustomer`, `projectx` | Projektkostenanalyse |
| `ManagedBy` | Verwaltungstool | `Terraform`, `Manual` | Governance |

### Erweiterte Tags (FinOps)

| Tag-Name | Beschreibung | Beispielwerte |
|---|---|---|
| `BusinessUnit` | Geschäftseinheit | `technology`, `sales` |
| `BudgetCode` | Budget-Code | `BU-2024-ENG` |
| `ServiceTier` | Service-Level | `bronze`, `silver`, `gold`, `platinum` |
| `Classification` | Datenklassifizierung | `public`, `internal`, `confidential` |
| `FinOpsManaged` | FinOps-Verwaltung aktiv | `true` |

### Tag-Vererbung

Azure Policy stellt sicher, dass Schlüssel-Tags automatisch von der Resource Group an Ressourcen vererbt werden:
- `CostCenter` → automatische Vererbung
- `Environment` → automatische Vererbung
- `Project` → automatische Vererbung

---

## 7. Alerting & Anomalie-Erkennung

### Alert-Architektur

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────┐
│  Azure Cost      │     │  Action Group    │     │  Empfänger   │
│  Management      │────▶│  "ag-finops"     │────▶│              │
│                  │     │                  │     │  • E-Mail    │
│ • Budget Alerts  │     │  • Email         │     │  • Teams     │
│ • Anomaly Detect │     │  • Webhook (opt) │     │  • PagerDuty │
│ • Advisor Alerts │     │  • Logic App     │     │              │
└──────────────────┘     └──────────────────┘     └──────────────┘
```

### Anomalie-Erkennung

Azure Cost Anomaly Alert erkennt automatisch:
- **Plötzliche Kostenspitzen** — z.B. vergessene VM-Skalierung
- **Ungewöhnliche Muster** — z.B. Traffic-basierte Kostenabweichungen
- **Neue Ressourcen** — z.B. nicht geplante Deployments

---

## 8. Governance & Policies

### Azure Policy Assignments

| Policy | Typ | Wirkung |
|---|---|---|
| **Require Tag** | Built-in | `Deny` — Ressource ohne Pflicht-Tag wird abgelehnt |
| **Inherit Tag** | Built-in | `Modify` — Fehlende Tags werden von RG übernommen |

### Governance-Regeln

1. **Keine Ressource ohne Tags** — Azure Policy blockiert das Erstellen
2. **Budget pro Resource Group** — Jede Umgebung hat ein eigenes Budget
3. **Tägliche Kostenexporte** — Automatisiert nach Storage Account
4. **Monatliche FinOps-Reviews** — Pflichttermin für alle Teams (siehe Guide)

---

## 9. Rollen & Verantwortlichkeiten

### RACI-Matrix

| Aktivität | FinOps Lead | Engineering | Management | Finance |
|---|---|---|---|---|
| Budget-Festlegung | C | I | A/R | C |
| Kosten-Monitoring | A/R | I | I | C |
| Optimierung umsetzen | C | A/R | I | I |
| Tag-Standards pflegen | A/R | R | I | I |
| Monatlicher Review | A/R | R | R | R |
| Anomalie-Reaktion | R | A/R | I | I |
| RI/Savings Plans | A/R | C | A | R |

> A = Accountable, R = Responsible, C = Consulted, I = Informed

### Empfohlene Rollen

| Rolle | Verantwortung |
|---|---|
| **FinOps Lead** | Gesamtverantwortung für Cloud-Kostenoptimierung |
| **FinOps Analyst** | Analyse, Reporting, Empfehlungen |
| **Cloud Engineer** | Technische Umsetzung von Optimierungen |
| **Product Owner** | Business-Value-Entscheidungen |
| **Finance Partner** | Budget-Planung, Chargeback-Prozess |

---

## 10. KPIs & Metriken

### Primäre KPIs

| KPI | Beschreibung | Ziel | Messung |
|---|---|---|---|
| **Cost per Environment** | Kosten pro Umgebung/Monat | < Budget | Azure Cost Management |
| **Budget Variance** | Abweichung vom geplanten Budget | < 10% | Budget vs. Actual |
| **Tag Compliance** | % der Ressourcen mit allen Pflicht-Tags | > 95% | Azure Policy |
| **Waste Score** | % ungenutzter/überdimensionierter Ressourcen | < 5% | Azure Advisor |
| **RI Coverage** | % der Compute-Kosten durch RIs gedeckt | > 70% | RI Utilization Report |

### Sekundäre KPIs

| KPI | Beschreibung | Ziel |
|---|---|---|
| **Cost per Request** | Infrastrukturkosten pro API-Call | Trend ↓ |
| **Cost per Customer** | Kosten pro aktivem Kunden | Trend ↓ |
| **Anomaly Response Time** | Zeit bis zur Reaktion auf Kostenanomalien | < 4h |
| **Optimization Adoption Rate** | Umgesetzte vs. empfohlene Optimierungen | > 80% |

---

## 11. Optimierungs-Strategien

### Sofortige Maßnahmen (Quick Wins)

| # | Maßnahme | Einsparung | Aufwand |
|---|---|---|---|
| 1 | **Right-Sizing** — VM-Größen an tatsächliche Nutzung anpassen | 15-30% | Gering |
| 2 | **Dev/Test Abschaltung** — Nicht-Prod außerhalb der Arbeitszeit stoppen | 30-60% | Gering |
| 3 | **Unused Resources** — Verwaiste Disks, IPs, Load Balancer entfernen | 5-15% | Gering |
| 4 | **Storage Tiering** — Cold/Archive für selten genutzte Daten | 10-25% | Mittel |

### Mittelfristige Maßnahmen

| # | Maßnahme | Einsparung | Aufwand |
|---|---|---|---|
| 5 | **Reserved Instances** — 1-3-Jahres-Reservierungen für stabile Workloads | 20-40% | Mittel |
| 6 | **Savings Plans** — Flexible Compute-Commitments | 15-30% | Mittel |
| 7 | **Autoscaling optimieren** — Min/Max Node Count tunen | 10-20% | Mittel |
| 8 | **Spot Instances** — Für fehlertolerante Workloads (Batch, CI/CD) | 60-90% | Hoch |

### Langfristige Strategien

| # | Maßnahme | Beschreibung |
|---|---|---|
| 9 | **Container Density** | Mehr Workloads pro AKS-Node durch Resource Quotas |
| 10 | **Serverless Migration** | Azure Functions für Event-driven Workloads |
| 11 | **Multi-Cloud Arbitrage** | Preisvergleich zwischen Anbietern |
| 12 | **FinOps Automation** | ML-basierte automatische Optimierung |

---

## 12. Umgebungsspezifische Konfiguration

### Development

```hcl
# terraform.tfvars (dev)
finops_monthly_budget             = 500
finops_enable_subscription_budget = false
finops_alert_thresholds           = [75, 100]
finops_enable_tagging_policy      = false  # Flexibel für Entwicklung
finops_enable_anomaly_alerts      = true
```

**Empfehlungen für Dev:**
- Kleinste VM-Größen (Standard_B2s)
- Autoscaling auf Minimum (1-2 Nodes)
- Automatische Abschaltung nach 18:00 Uhr
- Basic-SKU für ACR und Datenbanken

### Staging

```hcl
# terraform.tfvars (staging)
finops_monthly_budget             = 1500
finops_enable_subscription_budget = true
finops_alert_thresholds           = [50, 75, 90, 100]
finops_enable_tagging_policy      = true
finops_enable_anomaly_alerts      = true
```

**Empfehlungen für Staging:**
- Produktionsähnlich, aber reduzierte Skalierung
- Reservierungen NICHT für Staging
- Automatische Weekend-Abschaltung möglich

### Production

```hcl
# terraform.tfvars (prod)
finops_monthly_budget             = 3000
finops_subscription_budget        = 10000
finops_enable_subscription_budget = true
finops_alert_thresholds           = [50, 75, 90, 100, 110]
finops_enable_tagging_policy      = true
finops_enable_anomaly_alerts      = true
finops_enable_advisor_alerts      = true
```

**Empfehlungen für Prod:**
- Reserved Instances für stabile Workloads
- Premium-SKU für kritische Dienste
- Autoscaling mit Puffer für Traffic-Spitzen
- Kein automatisches Herunterfahren

---

## 13. Terraform-Implementierung

### Modul-Einbindung

```hcl
module "finops" {
  source              = "./modules/finops"
  resource_group_name = azurerm_resource_group.main.name
  resource_group_id   = azurerm_resource_group.main.id
  location            = var.location
  environment         = var.environment
  project_name        = var.project_name
  subscription_id     = data.azurerm_subscription.current.subscription_id
  tags                = local.common_tags

  # Budget
  monthly_budget_amount     = var.finops_monthly_budget
  budget_currency           = var.finops_budget_currency
  budget_alert_thresholds   = var.finops_alert_thresholds
  budget_alert_emails       = var.finops_alert_emails

  # Features
  enable_subscription_budget    = var.finops_enable_subscription_budget
  enable_tagging_policy         = var.finops_enable_tagging_policy
  enable_cost_anomaly_alerts    = var.finops_enable_anomaly_alerts
  enable_advisor_recommendations = var.finops_enable_advisor_alerts
}
```

### Erstelle Ressourcen

| Ressource | Beschreibung |
|---|---|
| `azurerm_consumption_budget_resource_group` | Budget mit Alerts für die RG |
| `azurerm_consumption_budget_subscription` | Budget für die gesamte Subscription |
| `azurerm_cost_anomaly_alert` | KI-basierte Anomalie-Erkennung |
| `azurerm_monitor_action_group` | Benachrichtigungsgruppe für FinOps |
| `azurerm_monitor_activity_log_alert` | Advisor-Empfehlungs-Alert |
| `azurerm_resource_group_policy_assignment` | Tag-Pflicht-Policies |
| `azurerm_subscription_cost_management_export` | Tägliche Kostenexporte |
| `azurerm_storage_account` + Container | Storage für Kostenexporte |

---

## 14. Weiterführende Dokumente

| Dokument | Beschreibung |
|---|---|
| [FINOPS_PRODUCTION_GUIDE.md](FINOPS_PRODUCTION_GUIDE.md) | Produktions- und Enterprise-Guide |
| [IaC/modules/finops/main.tf](IaC/modules/finops/main.tf) | Terraform FinOps-Modul |
| [IaC/modules/finops/tagging.tf](IaC/modules/finops/tagging.tf) | Tagging-Standards |
| [IaC/terraform.tfvars.example](IaC/terraform.tfvars.example) | Beispielkonfiguration |

### Externe Referenzen

- [FinOps Foundation](https://www.finops.org/)
- [Azure Cost Management Dokumentation](https://learn.microsoft.com/azure/cost-management-billing/)
- [Azure Advisor](https://learn.microsoft.com/azure/advisor/)
- [Azure Policy Tag-Governance](https://learn.microsoft.com/azure/governance/policy/tutorials/govern-tags)
