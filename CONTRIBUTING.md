# Contributing to CloudOps Bootstrap

Thank you for your interest in contributing. This document provides guidelines and standards for all contributions.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Branch Strategy](#branch-strategy)
- [Commit Convention](#commit-convention)
- [Pull Request Process](#pull-request-process)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)

---

## Code of Conduct

- Be respectful and constructive in all communications
- Focus on the technical merits of contributions
- Follow the project's established patterns and conventions

## Branch Strategy

We follow **GitHub Flow** with environment branches:

```
main              ← Production-ready code (protected)
├── develop       ← Integration branch for staging
├── feature/*     ← New features (e.g., feature/finops)
├── fix/*         ← Bug fixes (e.g., fix/budget-alert)
└── hotfix/*      ← Urgent production fixes
```

### Rules

| Branch | Merges Into | Requires PR | Requires Review |
|--------|-------------|-------------|-----------------|
| `feature/*` | `develop` | Yes | 1 reviewer |
| `fix/*` | `develop` | Yes | 1 reviewer |
| `develop` | `main` | Yes | 2 reviewers |
| `hotfix/*` | `main` | Yes | 1 reviewer |

### Creating a Branch

```bash
# Feature
git checkout -b feature/my-feature develop

# Bug fix
git checkout -b fix/issue-description develop

# Hotfix (from main)
git checkout -b hotfix/critical-fix main
```

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |
| `ci` | CI/CD pipeline changes |
| `chore` | Maintenance tasks (dependencies, tooling) |
| `infra` | Infrastructure (Terraform) changes |

### Examples

```bash
feat(finops): add budget alerts and cost anomaly detection
fix(aks): correct autoscaling min/max node validation
docs(readme): update architecture diagram
infra(monitoring): add diagnostic settings for AKS
ci(workflows): update GitHub Actions to v4
```

## Pull Request Process

### Before Opening a PR

1. **Rebase** on the latest target branch
2. **Test** your changes locally
3. **Lint** code and run `terraform validate` / `terraform fmt`
4. **Update** documentation if behavior changes
5. **Check** that `.gitignore` excludes sensitive files

### PR Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Feature
- [ ] Bug fix
- [ ] Infrastructure change
- [ ] Documentation
- [ ] CI/CD

## Checklist
- [ ] Code follows project conventions
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No secrets or credentials in code
- [ ] Terraform: `terraform fmt` and `terraform validate` pass
```

### Review Criteria

- Code correctness and security
- Terraform best practices (naming, tagging, validation)
- Test coverage for new functionality
- Documentation completeness

## Code Standards

### Terraform

- **Format**: Run `terraform fmt -recursive` before committing
- **Validate**: Run `terraform validate` before pushing
- **Naming**: Use `kebab-case` for resource names, `snake_case` for variables
- **Variables**: Always include `description`, `type`, and `validation` where applicable
- **Tags**: All resources must include `local.common_tags`
- **Modules**: Place reusable modules in `IaC/modules/`
- **Outputs**: All significant resource IDs and endpoints must be exported

### Java

- **Style**: Follow Google Java Style Guide
- **Build**: `mvn clean verify` must pass
- **Tests**: JUnit 5 with minimum 80% line coverage (JaCoCo)
- **Dependencies**: Keep `pom.xml` dependencies up to date

### Python

- **Style**: PEP 8, enforced by flake8
- **Build**: `pytest` must pass with coverage
- **Tests**: pytest with minimum 80% coverage
- **Dependencies**: Pin versions in `requirements.txt`

## Testing Requirements

### Infrastructure

```bash
cd IaC/
terraform fmt -check -recursive
terraform validate
terraform plan               # Verify no unexpected changes
```

### Applications

```bash
# Java
cd java-app/
mvn clean test

# Python
cd python-app/
pip install -r requirements-dev.txt
pytest --cov=app
flake8 app/
```

## Documentation

- Update relevant README files when changing behavior
- Use Markdown for all documentation
- Keep a clean project structure in the root README
- FinOps changes: update `FINOPS_CONCEPT.md` and/or `FINOPS_PRODUCTION_GUIDE.md`
- Infrastructure changes: update `IaC/README.md`

---

## Questions?

Open a GitHub Issue or contact the platform team.
