# Makefile example for Terraform operations

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Format Terraform configuration files
fmt:
	@echo "Formatting Terraform configurations..."
	terraform fmt

# Validate Terraform configuration files
validate:
	@echo "Validating Terraform configurations..."
	terraform validate

plan-dev:
	@echo "Planning Terraform changes for dev environment..."
	terraform plan -var-file values-dev.tfvars

# Plan Terraform changes
plan:
	@echo "Planning Terraform changes..."
	terraform plan

# Apply Terraform changes
apply:
	@echo "Applying Terraform changes..."
	terraform apply

apply-auto-approve:
	@echo "Applying Terraform changes with auto-approve..."
	terraform apply -auto-approve
# Destroy Terraform-managed infrastructure

destroy:
	@echo "Destroying Terraform-managed infrastructure..."
	terraform destroy

# Output Terraform-managed infrastructure
output:
	@echo "Outputting Terraform-managed infrastructure..."
	terraform output

# Show Terraform state or resources
state:
	@echo "Showing Terraform state..."
	terraform state list
