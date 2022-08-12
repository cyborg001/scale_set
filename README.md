# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1- Once you all the dependencies ready, you will create an azure resource group which has to be created before
we deploy project. For this you can use the next code: 'az group -n udacity-rg -l eastus'. This will create a 
resource group named 'udacity-rg' which you will use to group the others reources.

2- Create the policy 'tagging-policy' using the command: az policy definition create -n "tagging-policy" --display-name "deny no tagss" --description "This policy denies every resource which doesnt have tags" --rules tagging.json. It is 
suposed tha file tagging.json which contains the rules is in the same directory or you have to to call it with full name(path).

3- assign the policy using: az policy assignment create --policy  "tagging-policy"

4- create image with packer and file server.json with this command: packer build server.json. In case that server.json is not in same directory call its pathname. Before this you have to set the variables block, the rg variable which means resource group show match the resource group created in first step. eg: 

"variables": {
		"client_id": "",
		"client_secret": "",
		"subscription_id": "1e4e092c-b55e-45ea-8cc8-4e0ef3f7f19c",
		"rg": "udacity-rg",
		"location": "East US"
	},
the client_id, client_secret and suscription_id must be the ones in your azure account. You can also leave client_id and client_secrect blanck and follow az cli instrucctions.

5- Once you created your image with packer the next step is you should configure your variables.tf file for getting terraform plan ready. Remember to fill your username and password for the virtual machines, to set the id of the image and the n_instances variable to set the number of instances to be created, the rg variable which represents the resource group must match the name of the resource group created in first step.

6- run the command: terraform plan -o solution.plan. this will validate the code and create the plan that you will aplly to deploy your resources.

7- run terraform apply. This will deploy the resources in your azure account.



### Output
terraform plan will get the output:
Plan: 10 to add, 0 to change, 0 to destroy.