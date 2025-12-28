# Terraform Destroy Workflow Guide

## Overview
The destroy workflow provides a safe, multi-step process to destroy infrastructure with manual approval gates.

**Features**:
- ✅ Two-stage process: Plan → Approval → Destroy
- ✅ Works on all branches (main, develop, feature/*)
- ✅ Manual approval required before destruction
- ✅ Plan artifact saved for audit trail
- ✅ Support for dev, staging, and prod environments

---

## Workflow Process

### Stage 1: Terraform Plan Destroy
**Job**: `terraform-plan`
- Checks out code
- Runs `terraform plan -destroy` 
- Uploads plan as artifact (7-day retention)
- No approval needed at this stage

### Stage 2: Manual Approval + Apply Destroy
**Job**: `terraform-apply-destroy`
- Waits for Stage 1 to complete
- **REQUIRES MANUAL APPROVAL** via GitHub environment
- Downloads destroy plan from artifact
- Runs `terraform apply` on the plan

---

## How to Use

### Trigger Destroy Workflow

1. Go to **GitHub** → **Actions** tab
2. Click **"Terraform Destroy"** workflow
3. Click **"Run workflow"** button
4. Select environment:
   - `dev`
   - `staging`
   - `prod`
5. Click **"Run workflow"** ✅

### Review & Approve Destruction

1. Workflow runs `terraform plan -destroy`
2. You'll see a notification: **"Waiting for approval to proceed"**
3. Click **"Review deployments"** or go to **Environments**
4. Review the plan in the workflow logs
5. Click **"Approve and deploy"** ⚠️
6. Destruction begins automatically

---

## Approval Gates

### Environment Protection (Feature Branches & Main)

By default, all environments require approval:
- `destroy-dev`
- `destroy-staging`
- `destroy-prod`

To enable approval on specific environments:
1. Go to **Settings** → **Environments**
2. Create or edit environment: `destroy-dev`
3. Enable **"Required reviewers"**
4. Add team members who can approve

Example:
```
Environment: destroy-prod
Required reviewers: @platform-team, @devops-lead
```

---

## Workflow Stages Explained

### Stage 1: Plan (No Approval)
```yaml
terraform-plan:
  - Checkout code
  - Init Terraform
  - Run: terraform plan -destroy -out=destroy.tfplan
  - Upload artifact (7 days retention)
```

**Time**: ~2-5 minutes
**Artifact**: `destroy-plan-{environment}` (stored for audit)

### Stage 2: Apply (Requires Approval)
```yaml
terraform-apply-destroy:
  needs: terraform-plan
  environment: destroy-{environment}  # ← Approval gate here
  - Download plan artifact
  - Run: terraform apply destroy.tfplan
```

**Approval**: Manual via GitHub UI or API
**Time**: ~5-15 minutes

---

## Examples

### Destroy Dev Environment

1. **Trigger**:
   - Actions → Terraform Destroy
   - Environment: `dev`
   - Run workflow

2. **Plan Output** (in logs):
   ```
   Plan: 0 to add, 0 to change, 42 to destroy.
   ```

3. **Approval** (appears after plan completes):
   - Review job shows pending approval
   - Click "Approve and deploy"
   - Destruction starts

4. **Completion**:
   - All resources in `kustomer-dev-rg` deleted
   - Workflow completes (green checkmark)

### Destroy Prod Environment (with safeguards)

For production, add environment approval:

1. **Setup** (one-time):
   ```
   Settings → Environments → Create "destroy-prod"
   Required reviewers: @devops-lead
   ```

2. **Trigger**:
   - Actions → Terraform Destroy
   - Environment: `prod`
   - Run workflow

3. **Plan Phase** (~2 min):
   - Shows all resources to be destroyed
   - Logs show full plan

4. **Approval Phase**:
   - Notification: Waiting for @devops-lead approval
   - Authorized reviewer clicks "Approve and deploy"
   - **ONLY THEN** destruction proceeds

5. **Apply Phase** (~10 min):
   - Runs terraform apply on plan
   - All prod resources destroyed

---

## Safety Features

### 1. Plan Review Before Execution
- Stage 1 runs plan without making changes
- You can review what will be destroyed
- Abort if plan looks wrong (just don't approve)

### 2. Manual Approval Gate
- Requires human approval via GitHub UI
- Can be configured per environment
- Prevents accidental destruction

### 3. Artifact Trail
- Destroy plan saved as artifact (7 days)
- Can download and review offline
- Useful for compliance/audit

### 4. Environment-Based Approval
- Different approval requirements per environment
- Dev: Auto-approve (optional)
- Prod: Require senior review

---

## Troubleshooting

### Workflow Stuck on Approval
**Issue**: Workflow waiting for approval but you don't see button

**Solution**:
1. Go to **Actions** tab
2. Click the running workflow
3. Find the blue "Waiting for approval" section
4. Click **"Review deployments"**
5. Click **"Approve and deploy"**

### Plan Shows Wrong Resources
**Issue**: Plan shows destroying resources you wanted to keep

**Solution**:
1. Do NOT approve
2. Workflow will timeout (default 30 days) or manually cancel
3. Fix your code/infrastructure
4. Retrigger workflow

### Approval Never Arrives
**Issue**: No approval button appears after plan completes

**Solution**:
1. Check if environment exists: Settings → Environments
2. Create if missing: `destroy-{environment}`
3. Enable approval: Check "Required reviewers"
4. Add yourself as reviewer
5. Re-run workflow

---

## Environment Configuration Examples

### Minimal Setup (No Extra Approvals)
```
No special configuration needed.
Default approval: You (workflow trigger)
```

### Team Approval (Dev)
```
Environment: destroy-dev
Required reviewers: @platform-team (any team member can approve)
```

### Strict Approval (Prod)
```
Environment: destroy-prod
Required reviewers: @devops-lead (specific person)
```

---

## Best Practices

✅ **DO**:
- Always review the plan before approving
- Require approval for prod environments
- Document why destruction was needed
- Use same-day approval (don't wait days)

❌ **DON'T**:
- Auto-approve without reviewing
- Destroy prod without management approval
- Leave destroy environment unattended
- Skip approval gates to save time

---

## Artifact Management

Plans are saved as artifacts:
- **Name**: `destroy-plan-{environment}`
- **Retention**: 7 days
- **Size**: ~1-5 MB per plan
- **Access**: Actions → Workflow → Artifacts section

Download after destroy to verify what was deleted:
```bash
terraform show destroy.tfplan > destroyed_resources.txt
```

---

## Workflow Limitations

- ⏳ Approval timeout: 30 days default
- 🔄 Parallel runs: One per environment
- 📊 Plan size: ~5 MB max
- 🕐 Total time: 15-30 minutes (plan + approve + apply)

---

## Branch Behavior

### Feature Branches
- Can trigger destroy on feature branches
- Useful for testing cleanup logic
- Requires same approval as main

### Develop Branch
- Same rules as main
- Can destroy dev/staging environments
- Prod requires additional approval

### Main Branch
- Can destroy any environment
- Strongest safeguards recommended
- Prod destruction should require senior approval

---

## Next Steps

1. **Configure approvals** (optional):
   - Settings → Environments
   - Add `destroy-prod` environment
   - Set "Required reviewers"

2. **Test on dev**:
   - Run on dev environment first
   - Verify approval process works
   - Confirm cleanup successful

3. **Document procedures**:
   - Add to team runbook
   - Document required approvers per environment
   - Share with team

4. **Monitor destruction**:
   - Check Azure Portal for deleted resources
   - Verify resource groups are gone
   - Confirm backups if needed

---

**Last Updated**: December 27, 2025  
**Status**: ✅ Production Ready  
**Approval**: Manual via GitHub Environments
