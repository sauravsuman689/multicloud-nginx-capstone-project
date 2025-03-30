# Multicloud-nginx-deployment-capstone-project
This project consist of source code of multi cloud nginx deployment with custom webpage using jenkins cicd pipeline.

Below is the architecture diagram of this project which demonstrate the overall multi cloud infrastructure components involved, data flow and failover.

### Scenario 1:

<img width="794" alt="image" src="https://github.com/user-attachments/assets/ba03343b-f464-4b75-af1b-ba5f696b0761" />

### Scenario 2:

<img width="791" alt="image" src="https://github.com/user-attachments/assets/508489b9-2aaf-4d13-8238-1f6979a09280" />


## Step 1: Deploy Infra on both aws and azure cloud platform.
	
	Using the terraform code, installed the below required infra on both the cloud.
		1. VPC/Vnet
		2. Subnets
		3. IGW/NAT
		4. Security Group
		5. VMs ( 2 aws vms: 1 tools machine and 1 apps machine, 1 azure vm: apps machine)

## Step 2: Install ansible on aws tools machine, write playbook to deploy nginx on both the aws and azure app machine.
	   Verify the nginx web ui in the browser using the public IP of the app machines. 

## Step 3: Create custom html page for both the nginx, write ansible playbook to copy the custom html file to ngnix html lovcation and restart nginx.
	   Verify the nginx web ui in the browser using the public IP of the app machines.

## Step 4: Install Jenkins on the aws tools machine.
		1. Create a github repo which consists of 2 custom nginx html file.
		2. Create a declarative pipeline which will pull the custom html files and copy it to the remote aws and azure app machines.
		3. The jenkins jobs also restart the nginx.
		4. Verify the updated nginx webpage in the browser.


		 
