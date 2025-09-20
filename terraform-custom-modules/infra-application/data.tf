# Asks AWS: “What region is my provider configured for?”
data "aws_region" "current" {}


# Asks AWS: “Who am I right now?” (using the credentials Terraform is running with).
data "aws_caller_identity" "current" {}

# lookup security group by name (replace var.sg_lookup_name or adjust to filter by tag)
data "aws_security_groups" "by_name" {
  # If provider supports `name` attribute in your version, you can use:
  # name = var.sg_lookup_name
  filter { 
  name = "group-name" 
  values = [var.sg_name] # or the literal name you expect }
}
}