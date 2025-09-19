# Ìºç Terraform State Management

Managing state is one of the most important parts of working with Terraform.  
This document explains **what Terraform state is**, the **problems with local state**, how to use a **remote backend**, and how to manage state with commands like `import`, `state rm`, etc.

---

## 1. Ì≥Ç Terraform State (`terraform.tfstate`)

- The `terraform.tfstate` file is Terraform‚Äôs **source of truth** about what infrastructure exists.  
- It contains **resource IDs, metadata, and dependencies**.  
- Every `terraform plan` or `terraform apply` relies on `.tfstate` to know what to create, update, or destroy.  

### ‚ö†Ô∏è Problems with keeping state locally
- **Sensitive Data** ‚Üí `.tfstate` contains secrets and IDs. Never commit it to GitHub.  
- **Conflicts** ‚Üí Multiple users running Terraform can corrupt state.  
- **Drift** ‚Üí State may not match real infrastructure due to:
  - Manual changes in the console  
  - Failed or incomplete `terraform apply`  
  - Direct edits to `.tfstate`  
  - Misuse of workspaces  

---

## 2. ‚úÖ Solution: Remote Backend (S3 + DynamoDB)

To overcome local state issues, use a **remote backend**.

- Store `.tfstate` in **Amazon S3** ‚Üí centralized and durable.  
- Use **DynamoDB** for **state locking** ‚Üí prevents multiple users from applying at the same time.  
- Works with a **Lock & Release mechanism**:  
  - Terraform creates a **LockID** entry in DynamoDB when applying.  
  - Others must wait until the lock is released.  

---

### Ìª†Ô∏è Example Setup: S3 + DynamoDB as Remote Backend

```hcl
resource "aws_s3_bucket" "remote-backend-bucket" {
  bucket        = "remote-backend-bucket-for-storing-statefile"
  force_destroy = true

  tags = {
    Name = "remote-backend-bucket"
  }
}
```
```hcl
resource "aws_dynamodb_table" "remote-backend-table" {
  name         = "remote-backend-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "remote-backend-table"
  }
}
```

### Ì≥Ç Backend Configuration (backend.tf)
```hcl
terraform {
  backend "s3" {
    bucket         = "remote-backend-bucket-for-storing-statefile"
    key            = "terraform.tfstate"   # object name in S3
    region         = "us-east-2"
    dynamodb_table = "remote-backend-table" # state locking
  }
}
```

### Ì≥çLocal Backend Example (for testing only)
```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```
### Ì¥é Terraform State Commands
```
$ terraform state list

$ terraform state show <resource_name>
```
### Remove a resource from state
```hcl
terraform state rm <resource_name>
```

- Removes the resource from Terraform‚Äôs state file.
‚ö†Ô∏è Does not delete the resource from the cloud ‚Äî Terraform just ‚Äúforgets‚Äù it.

### Ì¥Ñ Terraform Import
If a resource exists in AWS but Terraform doesn‚Äôt know about it, use import.
```hcl
$ terraform import <resource_address> <RESOURCE_ID>
```

### Example: Importing Key Pair
```bash
$ terraform import aws_key_pair.deployer id_rsa
Import successful!
```
Now the resource appears in terraform state list and Terraform manages it.

### Ì≥å Steps for Import
Define a resource block in .tf file.

Option-1
```hcl
resource "aws_instance" "my_new_instance" {
  ami = "unknown"
}
```

Option-2
```hcl
resource "aws_instance" "my_new_instance" {}
```

```hcl
$ terraform import aws_instance.my_new_instance <RESOURCE_ID>
```

Run `terraform state list` to confirm it‚Äôs tracked.


## Ì∑ÇÔ∏è Terraform Workspaces

Workspaces in Terraform allow you to manage **multiple state files** within the same configuration directory.
They are useful for managing **different environments** (e.g., dev, test, prod) without duplicating Terraform code.

---

### workspace life cycle
```bash
terraform workspace list
terraform workspace show
terraform workspace new <new_workspace_name> # to create a new workspace
terraform workspace select <workspace_to_switch> # to switch to selected workspace
```
## 1. Local Backend Workspaces

By default, Terraform uses the **local backend**, storing state in a file named `terraform.tfstate` on your machine.

- This backend **supports workspaces** (`terraform workspace new`, `terraform workspace select`, etc.).
- Each workspace creates a separate state file under `terraform.tfstate.d/` locally.
  Example:

```
{
  "version": 4,
  "terraform_version": "1.12.1",
  "serial": 1,
  "lineage": "599e800a-1fb8-b526-c934-f656c291b984",
  "outputs": {},
  "resources": [],
  "check_results": null
}

```

‚úÖ So you can use workspaces even without a remote backend.

---

### Example: AWS S3 as Remote Backend

When a new workspace is created, Terraform creates a **separate state file** in the configured S3 bucket.

```bash
$ aws s3 ls s3://remote-backend-bucket-for-storing-statefile --recursive --human-readable --summarize
2025-09-19 12:20:52  181 Bytes env:/test_workspace/terraform.tfstate
2025-09-19 12:16:47   24.0 KiB terraform.tfstate

Total Objects: 2
 Total Size: 24.2 KiB
```
## Deleting a Workspace
‚ö†Ô∏è You cannot delete the currently active workspace.
First, switch to another workspace (usually default).


#### Example: Deleting test_workspace
```bash
$ terraform workspace list
  default
* test_workspace

$ terraform workspace delete test_workspace
Workspace "test_workspace" is your active workspace.

You cannot delete the currently active workspace. Please switch
to another workspace and try again.

$ terraform workspace select default
Switched to workspace "default".

$ terraform workspace delete test_workspace
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
Deleted workspace "test_workspace"!

$ terraform workspace list
* default
```

### Ì∑ëÔ∏è Deleting a Workspace with Resources

If resources exist in a workspace, Terraform will not let you delete it.

You may use the `-force` flag to delete, but ‚ö†Ô∏è **this is not recommended**
(because you will lose state tracking of those resources).

---

### ‚úÖ Safer Approach
1. Select the workspace you want to delete.
2. Run `terraform destroy` to remove all resources in that workspace.
3. Switch to another workspace using `terraform workspace select default`
4. Delete the workspace using `terraform workspace delete <name>`.


ÔøΩÔøΩ **Note:** The `default` workspace cannot be deleted.
