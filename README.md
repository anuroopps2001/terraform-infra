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
