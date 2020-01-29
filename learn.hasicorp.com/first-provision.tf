# To deploy in Azure CLI:
#   1. create file firstdeploy.tf
#   2. $ terraform init
#   3. $ terraform plan -out firstdeploy.plan
#   4. Optional: $ terraform show firstdeploy.plan (to look at plan later)
#   5. $ terraform apply
#   6. $ terraform


# Configure the Azure provider
provider "azurerm" {
    version = "~>1.32.0"
}

# Create a new resource group
resource "azurerm_resource_group" "rg" {
    name     = "myTFResourceGroup"
    location = "eastus"
}

