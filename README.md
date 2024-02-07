[![Web-App-Dev-Ops-Project.png](https://i.postimg.cc/5yxKRr0R/Web-App-Dev-Ops-Project.png)](https://postimg.cc/G85jBqvF)


 <details><summary>TABLE OF CONTENTS</summary>

 1. [Containeriztion Process](#CONTAINERIZATION-PROCESS)
 3. [Image Information](#IMAGE-INFORMATION)
 4. [Implement infrastructure as code (IAC) using Terraform](#IMPLEMENT-INFRASTRUCTURE-AS-CODE-(IAC)-USING-TERRAFORM)
 5. [App deployment](#APP-DEPLOYEMENT)
 6. [Creating a Pipeline, service connections and deploying with Kubernetes](#CREATING-A-PIPELIN,-SERVICE-CONNECTIONS-AND-DEPLOYING-WITH-KUBERNETES)
 7. [Testing and Validation](#TESTING-AND-VALIDATION)
 8. [AKS Cluster monitoring](#AKS-CLUSTER-MONITORING)
 9. [AKS Intergration with Azure key vault for secrets management](#AKS-INTERGRATION-WITH-AZURE-KEY-VAULT-FOR-SECRETS-MANAGEMENT)
 10. [My key takeaways](#MY-KEY-TAKEAWAYS)
 11. [What was the hardest part of this project](#WHAT-WAS-THE-HARDEST-PART-OF-THIS-PROJECT)</details>


<details><summary>CONTAINERIZATION PROCESS</summary>

   Before i explain the steps taken in this project to containerize the python application template provided by [AI CORE](https:www.theaicore.com) let me explain what containerization means in the context of DevOps, **Containerizing** a Python application means creating a Docker image that has everything needed to run it: source code, dependencies and configuration.

   The first step to containerize an application is to create a new text file, named ***D***ockerfile. Take note that the file name is capitalised, if this is not the case then VSCODE will not recognise this as a docker file. The Dockerfile is also a text file and all commands run in order of the script.

   For the application provided we need to carry out 6 commands for the application to run in html from a local host, these are;

- <details><summary>BASE IMAGE</summary>

   Start with a minimal base image Choose a base image that is lightweight and has the minimum number of layers needed to support your application or service. This will reduce the size of your final image and improve its performance. Use the smallest possible base image. The base image when selected from a template is known as ***The Parent Image***, Because this is a python application it is advised to use a ```Python``` base image. To define a base you simply type ```FROM``` (Notice how the entire word is ***CAPITALIZED***) then you type the base image you would like to use <br>
    Here is an example; <br>
   ```FROM python:3.8-slim```
   
   </details>
      
- <details><summary>WORKING DIRECTORY</summary>

   The working directory is defined by using the ***WORKDIR*** command, The WORKDIR instruction sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile. If the WORKDIR doesn't exist, it will be created even if it's not used in any subsequent Dockerfile instruction. It is common practice to set the WORKDIR to ***/app***. If not specified, the default working directory is /. In practice, if you aren't building a Dockerfile from scratch (FROM scratch), the WORKDIR may likely be set by the base image you're using.
   Therefore, to avoid unintended operations in unknown directories, it's best practice to set your WORKDIR explicitly. <br>
   Here is an example; <br>
   ```WORKDIR /app```
   </details>
   
- <details><summary>COPYING THE APPLICATION FILES</summary>

   In order to copy the application files to make the container a stand alone application you need to use the ***COPY*** command, the correct syntax for this is 'COPY src-path destination-path', you will see an example later in this doc. In Docker, there are two ways to copy a file, namely, ***ADD*** and ***COPY***. Though there is a slight difference between them in regard to the scope of the functions, they more or less perform the same task. If you use the source path location as ***'.'*** then this will copy everything from the current directory your head is in. <br>
   Here is an example; <br>
   FROM ubuntu:latest
    ```
       COPY . /app
       WORKDIR /app
       RUN make /app
       CMD python /app/app.py```
   </details>

- <details><summary>INSTALL REQUIRED PACKAGES</summary>

  For the application to run as a self ***contained*** stand alone app you need to install the required packages, the can normally be found in the ***requirements.txt*** file, you can also install any dependencies you want by first using the **RUN** command followed by **pip install** and finally the dependancies or location of the dependancies, it is also optional to use a trusted host command which may look like; ***--trusted-host pypi.python.org***. The --trusted-host option marks a host as trusted. This helps when you try to reach the pypi servers from behind a firewall. Alternatively, you can add the trusted hosts to your pip.conf (macOS and Linux) or pip.ini (Windows) file, so you don't have to do it every time you need to install a package.
  Here is an example of intalling dependancies from a requirements file; <br>
  ```RUN pip install --trusted-host pypi.python.org - requirements``` <br>
  And here is an example of further dependencies and updates / upgrades; <br>

   ```
   RUN apt-get update && apt-get install -y \
       unixodbc unixodbc-dev odbcinst odbcinst1debian2 libpq-dev gcc && \
       apt-get install -y gnupg && \
       apt-get install -y wget && \
       wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key   add - && \
       wget -qO- https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
       apt-get update && \
       ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
       apt-get purge -y --auto-remove wget && \  
       apt-get clean

      # Install pip and setuptools
      RUN pip install --upgrade pip setuptools
      # TODO: Step 4 - Install Python packages specified in requirements.txt
      # If trusted host throws an error, use this code;
      #COPY requirements.txt .
      #RUN python -m pip install -r requirements.txt
      RUN pip install --trusted-host pypi.python.org -r requirements.txt

   </details>

- <details><summary>PORT EXPOSURE</summary>

  To expose a port you use the command **EXPOSE** followed by the port you wish to call in your web browser to run the application, If you **EXPOSE** a port, the service in the container is not accessible from outside Docker, but from inside other Docker containers. So this is good for inter-container communication. If you **EXPOSE** and **-p** a port, the service in the container is accessible from anywhere, even outside Docker. The number of the port defines the port that will be listening and so you can view via a html webpage. <br>
  Here is an example; <br>
  ```EXPOSE 5000```

- <details><summary>DEFINING THE STARTUP COMMAND</summary>

   Before you can execute an app in a dockerfile you need to decide two things, **your entry point** and **your executable file**. Once you have these you can define using the ***CMD*** command followed by brakets (Box Brackets) **[ ]** and your entry point / executable file name within seperated by comma's. In this example my entry point is **python** and my executable file is **app.py** <br>
   Here is an example; <br>
   ```CMD ["python", "app.py"]```

  ****Here is an example of the complete docker file;**** <br>
  ```
   FROM python:3.8-slim

   WORKDIR /app

   COPY requirements.txt /app/requirements.txt

   RUN pip install -r /app/requirements.txt

   COPY . /app

   RUN apt-get update && apt-get install -y \
    unixodbc unixodbc-dev odbcinst odbcinst1debian2 libpq-dev gcc && \
    apt-get install -y gnupg && \
    apt-get install -y wget && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    wget -qO- https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
    apt-get purge -y --auto-remove wget && \  
    apt-get clean

    RUN pip install --upgrade pip setuptools

    COPY requirements.txt .
    RUN python -m pip install -r requirements.txt
    RUN pip install --trusted-host pypi.python.org -r requirements.txt
 
    EXPOSE 5000

    CMD ["python", "app.py"]
    ```
    </details>


- <details><summary>COMMAND TO BUILD THE DOCKER</summary>

  To build the docker in an IDE such as VS CODE you can use the command; <br>
  ****docker build -t 'specify tag name' .**** (Note the dot on the end to set the directory)
  <br> Here is an example for the dcokerfile example above; <br>
  Here is an example; <br>
  ![](https://i.postimg.cc/gLZ0cQtd/docker-build-cmd.png) <br>
  **Check it is built** <br>
  If you go to your **docker desktop app** you should see a succesful build like this; <br>
  [![docker-build.png](https://i.postimg.cc/KjtHJbcg/docker-build.png)](https://postimg.cc/GThKmZyc)<br>
  </details>

- <details><summary>RUNNING A DOCKER</summary>

  To run a docker you need to use the command **docker** followed by **run**, **-p** and then define the **port** and **name of the image** like this;  docker run -p 5000:5000 'name of the image' <br>
  Here is an example; <br>
  ![](https://i.postimg.cc/vDJB28Dm/docker-run.png) <br>
  From here you will be able to type the address of the container in your web browser to open and interact with your application; <br>
  Putting the address in the browser; <br>
  ```docker build -t webapp . ```
 <br>
  **And here is the app you have just containerized** <br>
  [![the-app.png](https://i.postimg.cc/Nf3PZ522/the-app.png)](https://postimg.cc/hf0rd4rK)</details>
</details>

<details><summary>DOCKER CHEATSHEET</summary>

 - #### Images

Docker images are a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.

Here are some image commands:

- Build an image from a Dockerfile: `docker build -t image_name`
- Build an image from a Dockerfile without the cache: `docker build -t image_name . --no-cache`
- List local images: `docker images`
- Delete an image: `docker rmi image_name`
- Remove all unused images: `docker image prune`

#### Containers

A container is a runtime instance of a docker image. A container will always run the same, regardless of the infrastructure. Containers isolate software from its environment and ensure that it works uniformly despite differences for instance between development and staging.

Here are some container commands:

- Create and run a container from an image, with a custom name: `docker run --name <container_name> <image_name>`
- Run a container with and publish a container’s port(s) to the host: `docker run -p <host_port>:<container_port> <image_name>`
- Run a container in the background: `docker run -d <image_name>`
- Start or stop an existing container: `docker start|stop <container_name>` (or `<container-id>`)
- Remove a stopped container: `docker rm <container_name>`
- Open a shell inside a running container: `docker exec -it <container_name> sh`
- Fetch and follow the logs of a container: `docker logs -f <container_name>`
- Inspect a running container: `docker inspect <container_name>` (or `<container_id>`)
- List currently running containers: `docker ps`
- List all docker containers (running and stopped): `docker ps --all`
- View resource usage stats: `docker container stats`

#### Docker Hub

Docker Hub is a service provided by Docker for finding and sharing container images with your team. Learn more and find images at [Docker Hub](https://www.markdownguide.org/basic-syntax/).

Here are some Docker Hub commands:

- Login into Docker: `docker login -u <username>`
- Publish an image to Docker Hub: `docker push <username>/<image_name>`
- Search Hub for an image: `docker search <image_name>`
- Pull an image from a Docker Hub: `docker pull <image_name>`
</details></details>

<details><summary>IMAGE INFORMATION</summary>

#### Image directory
The image directory has been defined as `/app`.

#### Image dependencies
The image dependencies can be found in `requirements.txt`.

#### Image port
The image port has been defined as `5000`.

#### Executable files
The executable files can be found in `app.py`.

#### App name
The app name has been defined as `webapp`.

#### Image name on docker desktop
The image name on docker desktop is `focused_banzai`.

#### Image ID
The image ID is `804635f6346255ebeda7e631111b75c742a37e2d8ed2a2372a61d21920b35492`.

#### Image URL
The image is running on web browser `http://172.17.0.2:5000`.

#### Image details
[![image-details.png](https://i.postimg.cc/Vv29dGxs/image-details.png)](https://postimg.cc/vxLxKz8C)

#### Cleaning up the code before a push
#### Cleanup
- Remove Containers: Use the `docker ps -a` command to list all containers, including stopped ones. Remove any unnecessary containers with `docker rm container-id` to free up resources.
- Remove Images: List all images using `docker images -a` and remove any unneeded images with `docker rmi image-id` to reclaim disk space.
</details>


<details><summary>IMPLEMENT INFRASTRUCTURE AS CODE (IAC) USING TERRAFORM</summary>


 ***Initialising a Terraform project / module***

Assuming you have already installed Terraform on your machine and installed the Terraform extensions on your IDE (in this case i am continuing to use [VS Code](https://code.visualstudio.com/)), If you have not done this then please click [HERE](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) for a comprehensive guide from Hashicorp and click [HERE](https://learn.microsoft.com/en-us/azure/developer/terraform/configure-vs-code-extension-for-terraform?tabs=azure-cli) for the official guide to installing Terraform extensions on VS Code. <br>
<br>
Once you have everything installed you need to initialise a Terraform module, this can be very confusing as the best way to get started is to created a Terraform file in your project. The problem is, how do you created a Terraform file? This is reated the same way you create any file, the imprtant part that defines this as a Terraform file is the extension and is simply a dot followed by tf (.tf). The first thing you will notice is a small Terraform logo next to the newly created file and Terraform enabled on the bottom of vs as your language. <br>
<br>
The Terraform workflow consists of three main steps after creating a new Terraform file or importing a Terraform configuration file, these are; <br>
1. **Initialize** - prepares your workspace so Terraform can apply your configuration.
2. **Plan** - allows you to preview the changes Terraform will make before you apply them.
3. **Apply** - makes the changes defined by your plan to create, update, or destroy resources. <br>
<br>


Lets take a look at these individually and how to create / configure them;

**Initialize** <br>
A Terraform project should be organized into two Terraform modules: one for provisioning the necessary Azure Networking Services for an AKS cluster and one for provisioning the Kubernetes cluster itself. In this case i am using: networking-module and aks-cluster-module. These were created as folders within the Terraform main folder which i have named aks-terraform. <br>

Here is an example of the inital file structure <br>
[![terraform-file-structure.png](https://i.postimg.cc/tTkpq8VP/terraform-file-structure.png)](https://postimg.cc/0MzLZWn2) <br>

Inside the networking module directory i created a variables.tf file. In this file, i defined the input variables for the module. These variables are such an important component of a Terraform project, this is because they allow you to configure and customize networking services based on specific needs and requirements.<br>

Within the variables file i have created <br>

* A resource_group_name variable that will represent the name of the Azure Resource Group where the networking resources will be deployed in. The variable is a type "string" and has a default value. 
* A location variable that specifies the Azure region where the networking resources will be deployed to. The variable is a type "string" and has a default value.
* And a vnet_address_space variable that specifies the address space for the Virtual Network (VNet) that i will create later in the main configuration file of this module. The variable is a type list(string) and has a default value. <br>

Example <br>
 [![variables-example.png](https://i.postimg.cc/85xcQ28H/variables-example.png)](https://postimg.cc/N97BRPj9)
<br>
<br>


I then Created a main.tf configuration file within the networking-module folder, defined the essential networking resources for an AKS cluster. This includes creating an Azure Resource Group, a VNet, two subnets (for the control plane and worker nodes) and a Network Security Group (NSG). I named these resources as follows:

* Azure Resource Group: Name this resource by referencing the resource_group_name variable created earlier
* Virtual Network (VNet): aks-vnet
Control Plane Subnet: control-plane-subnet
* Worker Node Subnet: worker-node-subnet
* Network Security Group (NSG): aks-nsg

Within the NSG, i defined two inbound rules: 
* one to allow traffic to the kube-apiserver (named kube-apiserver-rule)
* two to allow inbound SSH traffic (named ssh-rule). Both rules should only allow inbound traffic from your public IP address.


It is imperetive to configure these resources and rules correctly as they are essential for the successful provisioning of the AKS cluster and ensuring its security. <br>
Example <br>
 [![main-1.png](https://i.postimg.cc/DyDhsRkL/main-1.png)](https://postimg.cc/JGbSC6hz) <br>
<br>
<br>
Inside the networking module i created an outputs.tf configuration file, this is where i will define the output variables of the module. Output variables enable you to access and utilize information from the networking module. Specifically these variables will be used to provision the networking services used by the AKS cluster later on, when i provision the cluster module.


I then defined the following output variables:

* A vnet_id variable that will store the ID of the previously created VNet. This will be used within the cluster module to connect the cluster to the defined VNet.
* A control_plane_subnet_id variable that will hold the ID of the control plane subnet within the VNet. This will be used to specify the subnet where the control plane components of the AKS cluster will be deployed to.
* A worker_node_subnet_id variable that will store the ID of the worker node subnet within the VNet. This will be used to specify the subnet where the worker nodes of the AKS cluster will be deployed to.
* A networking_resource_group_name variable that will provide the name of the Azure Resource Group where the networking resources were provisioned in. This will be used to ensure the cluster module resources are provisioned within the same resource group.
* A aks_nsg_id variable that will store the ID of the Network Security Group (NSG). This will be used to associate the NSG with the AKS cluster for security rule enforcement and traffic filtering. <br>
Example <br> [![first-outputs.png](https://i.postimg.cc/zD7XLdGF/first-outputs.png)](https://postimg.cc/4nKTqQtY)
<br>
<br>
Now i was ready to initialize the terraform, to do this i opened the terminal and input; <br>
<br>
"terraform init" <br>
<br>
<br>
If done properly you will get he message "Initializing the backend...

'Initializing provider plugins... <br>
--Finding latest version of hashicorp/azurerm... <br>
--Installing hashicorp/azurerm v3.85.0... <br>
--Installed hashicorp/azurerm v3.85.0 (signed by HashiCorp) <br>

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.' <br>
Example <br> [![init.png](https://i.postimg.cc/PxyySQBT/init.png)](https://postimg.cc/1ngDtwmj) <br>
<br>
<br>


Inside the cluster module directory i created a variables.tf configuration file. In this file i defined the input variables for this module. These will allow me to customize various aspects of the AKS cluster.


I defined the following input variables:

* A aks_cluster_name variable that represents the name of the AKS cluster you wish to create
* A cluster_location variable that specifies the Azure region where the AKS cluster will be deployed to
* A dns_prefix variable that defines the DNS prefix of cluster
* A kubernetes_version variable that specifies which Kubernetes version the cluster will use
* A service_principal_client_id variable that provides the Client ID for the service principal associated with the cluster
* A service_principal_secret variable that supplies the Client Secret for the service principal



I also added the output variables from the networking module as input variables for this module:

* The resource_group_name variable
* The vnet_id variable
* The control_plane_subnet_id variable
T* he worker_node_subnet_id variable


Including these variables was really important since the networking module plays an important role in establishing the networking resources for the AKS cluster. When configuring the cluster, it is necessary to define the specific networking resources that the cluster will utilize.
<br>
Example: <br>

[![nsg-example.png](https://i.postimg.cc/h4fst6Gx/nsg-example.png)](https://postimg.cc/dDcrWWrt)
<br>
<br>
Within the cluster module's main.tf configuration file, i defined the necessary Azure resources for provisioning an AKS cluster. This includes creating the AKS cluster, specifying the node pool and the service principal. I used the input variables defined previously to specify the necessary arguments. <br>
Example: <br>
[![validate-cluster.png](https://i.postimg.cc/brB7xSMp/validate-cluster.png)](https://postimg.cc/8fLXDcN0)
<br>
<br>
I then defined the cluster module output variables, i did this inside the cluster module by creating an outputs.tf configuration file, where i defined the output variables of this module. These will capture essential information about the provisioned AKS cluster.


I defined the following output variables:

* A aks_cluster_name variable that will store the name of the provisioned cluster
* A aks_cluster_id variable that will store the ID of the cluster
* A aks_kubeconfig variable that will capture the Kubernetes configuration file of the cluster. <br>

This file is essential for interacting with and managing the AKS cluster using kubectl. <br>
Example: <br>
[![cluster-outputs.png](https://i.postimg.cc/GpLJwSN4/cluster-outputs.png)](https://postimg.cc/SnPzcVm4)
<br>
<br>
I Initialized the cluster module to ensure it is ready to use within my main project. I Made sure i was in the correct directory (aks-cluster-module) using the cd command before running the initialization command (Terraform init). <br>
<br>
<br>

This is now the two main modules needed to create a resource group in Azure which can be monitored via trhe Azure portal at [portal.azure.com](https://portal.azure.com/), these will be;
* A virtual network
* 2 x Subnets
* A network security group
* A cluster <br>
<br> <br>

for these to be created we need to parse them in a main file within .\aks-terraform in a very similar way to calling functions in Python. <br>
Example of the code; <br>
[![main-calling-network.png](https://i.postimg.cc/dVGRGb7f/main-calling-network.png)](https://postimg.cc/75YTkQn1) <br>
[![main-calling-cluster.png](https://i.postimg.cc/W4nMH0w6/main-calling-cluster.png)](https://postimg.cc/bGZDGDMs)<br>
<br>
Within the code (specifically calling the cluster module) you will see variables defining client id and secrets which should be kept confidential by adding them to a gitignore file as shown below; <br>
[![main-calling-cluster-secrets.png](https://i.postimg.cc/s2yYmT7g/main-calling-cluster-secrets.png)](https://postimg.cc/SnTYN7gB) <br>
<br>
Main can now be initialized using the same command as you have been <br>
[![terraform-init.png](https://i.postimg.cc/X7vN9wZS/terraform-init.png)](https://postimg.cc/6TDNX4LY) <br>
[![terraform-initialized.png](https://i.postimg.cc/R0wvvdYf/terraform-initialized.png)](https://postimg.cc/8Fk2HRNP) <br>
<br>

**Plan and Apply**
-------

I was now ready to apply and build my resources within Azure using the terraform code i have created, this command is very similar to terrafrom init and it is good practice to use terraform validate and terraform plan first to preview your changes. If you use terraform plan with the -out agument then the output changes are guarenteed to be the same. <br>
*terraform validate example* <br>
```terraform validate```<br>
[![validate.png](https://i.postimg.cc/TYZ8hmgc/validate.png)](https://postimg.cc/ZCFsMWf9) <br>
*terraform plan command* <br>
```terraform plan```<br>
[![plan-command.png](https://i.postimg.cc/5NVbFHXB/plan-command.png)](https://postimg.cc/pyqgwLYr)<br>
*terraform plan change outputs* <br>
[![plan-outputs.png](https://i.postimg.cc/KjnbHbH3/plan-outputs.png)](https://postimg.cc/D4yRS9F7)<br>
*terraform apply command* <br>
```terraform apply```<br>
[![apply-command.png](https://i.postimg.cc/SQ8msLxQ/apply-command.png)](https://postimg.cc/9zW6g79s)<br>
*terraform apply outputs* (showing the creation of the resources) <br>
[![apply-outputs.png](https://i.postimg.cc/X7k3KV5T/apply-outputs.png)](https://postimg.cc/dL3zwc4B)<br>
<br>

**Access the AKS Cluster**
-------

From here you can go to Azure portal to see your brand new resources including your cluster nestled nicely into your resource group under the subscription you have been signed into during your work on vscode <br>
[![cluster-in-azure.png](https://i.postimg.cc/8CSPHRRy/cluster-in-azure.png)](https://postimg.cc/87ZSkrnW) <br>
You will still need to connect your vscode to the cluster via the terminal with the commands shown below; <br>
* (Ensure you in the right account) az account set --subscription 'your subscription id'
* (retrieve your credentials and connect) az aks get-credentials --resource-group 'your resource group' --name 'cluster name' <br>
```az account set --subscription <your subscription>```<br>
```az get credentials --resourse-group <your resource group> --name <cluster name>``` <br>
This is called being in the correct contect and merges a config file into the destination shown for future use when connecting the cluster to your pipeline. <br>
To make sure these deployments works and what exact deployements took place i like to use the deployments command <br>
* kubectl get deployments --all-namespace=true
and will list all cluster elements deployed as an output <br>
[![get-deployments.png](https://i.postimg.cc/ncVmKQKY/get-deployments.png)](https://postimg.cc/QVPVhCyH))</details>

<details><summary>APP DEPLOYEMENT</summary>

I started by creating a Kubernetes manifest file, named application-manifest.yaml. Inside this file i first defined the necessary Deployment resource, which will help deploy the containerized web application onto the Terraform-provisioned AKS cluster. The manifest included the following:

* Define a Deployment named flask-app-deployment that acts as a central reference for managing the containerized application
Specify that the application should concurrently run on two replicas within the AKS cluster, allowing for scalability and high availability
* Within the selector field, use the matchLabels section to define a label that uniquely identifies your application. For example, you could use the label app: flask-app. This label will allow Kubernetes to identify which pods the Deployment should manage.
* In the metadata section, define labels for the pod template. Reiterate the use of the label app: flask-app. This label is used to mark the pods created by the Deployment, establishing a clear connection between the pods and the application being managed.
* Configure the manifest to point to the specific container housing the application, which should be already hosted on Docker Hub. This ensures that the correct container image is utilized for deployment.
* Expose port 5000 for communication within the AKS cluster. This port servers as the gateway for accessing the application's user interface, as defined in the application code
* Implement the Rolling Updates deployment strategy, facilitating seamless application updates. Ensure that, during updates, a maximum of one pod deploys while one pod becomes temporarily unavailable, maintaining application availability. <br>
[![app-manifest-first-half.png](https://i.postimg.cc/CMPmNN9S/app-manifest-first-half.png)](https://postimg.cc/qgKsB8k5) <br>
[![app-manifest-location.png](https://i.postimg.cc/FF6Qrxqz/app-manifest-location.png)](https://postimg.cc/vD5KX5Gw) <br>
<br>
* The next taks was adding service to the yaml file so the app knows what port to operate on, this included Adding a Kubernetes Service manifest to the existing application-manifest.yaml to facilitate internal communication within the AKS cluster. Don't forget you can include multiple manifests in the same .yaml file using the --- operator in between distinct services configuration. This manifest should achieve the following key objectives:
* Define a service named flask-app-service to act as a reference for routing internal communication
Ensure that the selector matches the labels (app: flask-app) of the previously defined pods in the Deployment manifest. This alignment guarantees that the traffic is efficiently directed to the appropriate pods, maintaining seamless internal communication within the AKS cluster.
* Configure the service to use TCP protocol on port 80 for internal communication within the cluster. The targetPort should be set to 5000, which corresponds to the port exposed by your container.
* Set the service type to ClusterIP, designating it as an internal service within the AKS cluster
[![seperated-app-manifest-by.png](https://i.postimg.cc/8Pxw8C1Y/seperated-app-manifest-by.png)](https://postimg.cc/vcL5fbx7) <br>
Here is the complete file <br>
[![app-manifest-yaml.png](https://i.postimg.cc/P5ssZ5dk/app-manifest-yaml.png)](https://postimg.cc/CzNQpYZv)
[![app-manifest-location.png](https://i.postimg.cc/FF6Qrxqz/app-manifest-location.png)](https://postimg.cc/vD5KX5Gw) <br>
<br>

We were speaking about the current context earlier and now is the time to make sure you are in this, you can simply use or switch to the context of your choice using the command in powershell or using the panel on the left with the web image to see which context you are already in. All three are shown below; <br>

'Use' can' be done by running the command kubectl config use-context 'context-name' where context-name is the name of the context you want to use

<br>
Switch context <br>

```az account set --subscription <your subscription>```<br>
```kubectl config use-context <your cluster name>``` <br>
<br>
Using kubernetes extension <br>

[![context-left-panel.png](https://i.postimg.cc/25ffxHYy/context-left-panel.png)](https://postimg.cc/CRJthszp) <br>
<br>

Once you have set the correct context, you can proceed with the deployment of the Kubernetes manifests. You can apply the manifest by running the command kubectl apply -f 'manifest-file' where 'manifest-file' is the name of the file containing the Kubernetes manifest. You can monitor the deployment process by running the command kubectl get pods and kubectl get services. This will give you the status and details of the deployed pods and services. If you want to check the logs of a specific pod, you can run the command kubectl logs 'pod-name'. <br>
<br>
Webapp Deployment command; <br>

```kubectl apply -f application-manifest.yaml```


You can efficiently assess the deployment by performing port forwarding to a local machine. Here are the steps to follow:

* Start by verifying the status and details of your pods and services within the AKS cluster. Ensure that the pods are running, and the services are correctly exposed within the cluster.
* Once you've confirmed the health of your pods and services, initiate port forwarding using the kubectl port-forward 'pod-name' 5000:5000 command. Replace 'pod-name' with the actual name of the pod you want to connect to. This command establishes a secure channel to your application, allowing you to interact with it locally.
* With port forwarding in place, your web application hosted within the AKS cluster can be accessed locally at http://127.0.0.1:5000
* Visit this local address and thoroughly test the functionality of your web application. Pay particular attention to the orders table, ensuring that it is displayed correctly and that you can successfully use the Add Order functionality. <br> <br>

Get pods command; <br>
```kubectl get pods``` <br>
<br>

Get services command; <br>
```kubectl get services``` <br>
<br>

Port forwarding command; <br>
```kubectl port-forward <your application name>```<br>
<br>

The web app will now be spinning up and you can access it by typing http://127.0.0.1:5000 into the web browser which will take you to the odering page; <br>

[![order-management-app.png](https://i.postimg.cc/prp7LXd7/order-management-app.png)](https://postimg.cc/5QWpPJLq) <br>
<br>

When you interact with the app you will see new lines appear on the log; <br>

[![interacting-with-app.png](https://i.postimg.cc/1XhH75s1/interacting-with-app.png)](https://postimg.cc/r0jxKTDf) <br>
<br>

Follow the form after clicking on new order to ensure it works and see if the order was placed; <br>

[![new-order.png](https://i.postimg.cc/gJcQ1KbG/new-order.png)](https://postimg.cc/KKV0MBYW)
Success.
</details>

<details><summary>CREATING A PIPELINE, SERVICE CONNECTIONS AND DEPLOYING WITH KUBERNETES</summary>


**Creating a pipeline** <br>
This involves creating a new project within your AzureDevOps account. This serves as a foundation for your CI/CD pipeline setup. I logged into my Azure DevOps with the same organisation and email as my Azure account which was created when i was invited to the organisation at the beginning of this project; <br>
<br>
[![azure-devops.png](https://i.postimg.cc/9fDw17Ry/azure-devops.png)](https://postimg.cc/B8GvntCv) <br>
<br>

The next step was to begin the process of creating an Azure DevOps Pipeline. The first essential step involves configuring the source repository for the pipeline. i chose GitHub as the source control system where my application code is hosted, ensuring i selected the repository i've been working on so far.


As an initial configuration, i created the pipeline using a Starter Pipeline template, which will serve as the foundation for further customization in upcoming tasks. <br> [![pipeline-git.png](https://i.postimg.cc/pTs8Phcd/pipeline-git.png)](https://postimg.cc/dkTDB1YM)
 <br>

 **Service Connections** <br>
I then set up a service connection between Azure DevOps and the Docker Hub account where the application image is stored the steps were;

* Begin by creating a personal access token on Docker Hub
* Configure an Azure DevOps service connection to utilize this token
* Verify that the connection has been successfully established <br> <br>
[![new-service-connection.png](https://i.postimg.cc/L40f7PZC/new-service-connection.png)](https://postimg.cc/s17vGvm7) <br> <br>
[![service-connection-list.png](https://i.postimg.cc/TYLmXPVR/service-connection-list.png)](https://postimg.cc/TpxhVfNS) <br> <br>

**Build and run the docker** <br>
Now i had modify the configuration of my pipeline to enable it to build and push a Docker image to Docker Hub. These were the steps i learned:

* Add the Docker task with the buildandPush command to your pipeline. Use the same Docker image name as previously when you were pushing to Docker Hub from your local development environment.
* Set up the pipeline to automatically run each time there is a push to the main branch of the application repository. <br>
[![build-and-push-docker-code.png](https://i.postimg.cc/L4Cw7n8x/build-and-push-docker-code.png)](https://postimg.cc/WtZ5qprZ) <br>

It was now time to run the CI/CD pipeline and then test the newly created Docker image. I discovered there is multiple ways to do this. One in the Azure Devops by simply pressing the **RUN** button and one in the terminal by using the run command **az pipelines run --name stue2607.Web-App-DevOps-Project** both gave the same result. <br> <br>
[![terminal-run-command.png](https://i.postimg.cc/5y0GyMn5/terminal-run-command.png)](https://postimg.cc/zbsp24m3) <br> <br>
[![run-button.png](https://i.postimg.cc/Gh4V1dBd/run-button.png)](https://postimg.cc/mtG8YxN5) <br> <br>
This worked exactly as described when i watched the tutorial. <br>
[![pipeline-starter-success.png](https://i.postimg.cc/sgQ3N9mf/pipeline-starter-success.png)](https://postimg.cc/87G8Fvxx) <br> <br>

**Deployment** <br>
To be able to deploy our app via the pipeline we have to add a service connection between the pipeline and the pipeline, in the project the wording was *'Create and configure an AKS service connection within Azure DevOps. This service connection will help establish a secure link between the CI/CD pipeline and the AKS cluster, enabling seamless deployments and effective management.'* This was completed in a very similar manner to the service connection with the docker except using the Kubernetes template. <br>
[![service_connection_cluster.png](https://i.postimg.cc/3NfHLdDD/service_connection_cluster.png)](https://postimg.cc/Cn8t5M7F) <br> <br>

The next task was to Modify the configuration of the CI/CD pipeline to incorporate the Deploy to Kubernetes task with the deploy kubectl command.

I used the Azure DevOps inbuilt commands to create this and the template was very easy to follow, it produced this code within the yaml which made absolute sense; <br>
[![kubectl-in-yaml-pipeline.png](https://i.postimg.cc/sfYCNVZ8/kubectl-in-yaml-pipeline.png)](https://postimg.cc/MXpLcJ5b) <br> <br>

I had to rerun the pipeline in Azuredevops for this to take effect if i wanted to call the app and test it.
</details>

<details><summary>TESTING AND VALIDATION</summary>

After configuring the CI/CD pipeline, which includes both the build and release components, i began by monitoring the status of pods within the cluster to confirm they have been created correctly. <br>
[![get-pods.png](https://i.postimg.cc/zBSzkzjn/get-pods.png)](https://postimg.cc/gXjbzP1J) <br>

To access my application running on AKS securely, i had to initiate port forwarding using kubectl. therefore validating the effectiveness of the CI/CD pipeline in application deployment using the pod name. <br>
[![port_forwarding.png](https://i.postimg.cc/bJTPt6yg/port_forwarding.png)](https://postimg.cc/JDGSw5BH) <br> This depolyed the app and the output in the terminal to evidence this could be seen; <br>
[![web_app_deployment.png](https://i.postimg.cc/qRdBnh8J/web_app_deployment.png)](https://postimg.cc/SXDpbKT3) <br>
After using the local address with port 5000 in the web browser it returned the application; <br>
[![app-after-docker-push.png](https://i.postimg.cc/hvzCBj5m/app-after-docker-push.png)](https://postimg.cc/WqVmm2jp) <br>
As i interacted with it the outputs in the terminal could be seen to show a working connection; <br>
[![interacting-with-app.png](https://i.postimg.cc/nV2VjLMx/interacting-with-app.png)](https://postimg.cc/CdZp9Sjr) <br>
I placed an order to confirm it works and it went great.
</details>

<details><summary>AKS CLUSTER MONITORING</summary>

**Enable insights for AKS** <br>
To enable insights on my Azure AKS cluster, i needed to use Azure Monitor, which is a service that collects and analyzes various data from my cluster, such as metrics, logs, and alerts. I can also use Azure Monitor to monitor the performance, health, and availability of my cluster and its components.

There are different ways to enable Azure Monitor for my AKS cluster, depending on your preferences and requirements. Here are two of the options i learned about; <br>

* Using the Azure portal, You could enable Azure Monitor for my AKS cluster in the Azure portal by selecting the Monitoring section under your cluster settings and choosing the features you want to enable.
* Using the Azure CLI: I could use the az aks command to enable Azure Monitor for my AKS cluster by specifying the options i want to enable, for example -enable-addons.

I tried the Azure CLI first as i was more comfortable with after a lot of exploring with Azure portal, Prior to this i spent only 3 hours exploring and enabling various features to enhance my experience. I was a little nervous in case i had enabled a feature that was going to conflict with this. I used the following command;<br> ```az aks enable addons --resource-group networking-resource-group --name aks-cluster --addons monitoring``` <br>
 <br> Only to find during my exploration i had already enabled this. Phew what a relief. <br> <br>

**Create metrics explorer charts** <br>

The next tasks were to Create, configure and save the following charts in Metrics Explorer:

* Average Node CPU Usage: This chart allows you to track the CPU usage of your AKS cluster's nodes. Monitoring CPU usage helps ensure efficient resource allocation and detect potential performance issues.
* Average Pod Count: This chart displays the average number of pods running in your AKS cluster. It's a key metric for evaluating the cluster's capacity and workload distribution.
* Used Disk Percentage: Monitoring disk usage is critical to prevent storage-related issues. This chart helps you track how much disk space is being utilized.
* Bytes Read and Written per Second: Monitoring data I/O is crucial for identifying potential performance bottlenecks. This chart provides insights into data transfer rates. <br>

I completed this using query templates found in;
* monitor > logs 
from the home screen in Azure Portal; <br>

[![creating-log-queries.png](https://i.postimg.cc/05XR1Kbz/creating-log-queries.png)](https://postimg.cc/JtXdbn38) <br>

The query forms were really easy to follow. <br> <br>

I created all the above and pinned them to the dashboard as i noticed this was an option so i could edit at a later stage. <br>

[![insights-running.png](https://i.postimg.cc/1XtkNsYR/insights-running.png)](https://postimg.cc/2bscsRDg) <br> <br> 

I accessed to ensure these had pulled through and they looked great <br> <br>
There were now 5 more tasks within the monitoring chapter of the project to complete; <br>
Configure Log Analytics to execute and save the following logs:

* Average Node CPU Usage Percentage per Minute: This configuration captures data on node-level usage at a granular level, with logs recorded per minute
* Average Node Memory Usage Percentage per Minute: Similar to CPU usage, tracking memory usage at node level allows you to detect memory-related performance concerns and efficiently allocate resources
* Pods Counts with Phase: This log configuration provides information on the count of pods with different phases, such as Pending, Running, or Terminating. It offers insights into pod lifecycle management and helps ensure the cluster's workload is appropriately distributed.
* Find Warning Value in Container Logs: By configuring Log Analytics to search for warning values in container logs, you proactively detect issues or errors within your containers, allowing for prompt troubleshooting and issues resolution
* Monitoring Kubernetes Events: Monitoring Kubernetes events, such as pod scheduling, scaling activities, and errors, is essential for tracking the overall health and stability of the cluster <br> <br> 
These were fairly basic like the task before after watching some YouTube videos about this subject; <br>
[![memory-working.png](https://i.postimg.cc/0Qt3vh5T/memory-working.png)](https://postimg.cc/PpwKz3wy) <br>
[![monitor-metrics.png](https://i.postimg.cc/RV2kNr19/monitor-metrics.png)](https://postimg.cc/F7gWBBnn) <br>
[![insights-running.png](https://i.postimg.cc/1XtkNsYR/insights-running.png)](https://postimg.cc/2bscsRDg) <br> <br>
The next task in this chapter was to set up an alert rule to trigger an alarm when the used disk percentage in the AKS cluster exceeds 90%, i completed this by carrying out the following steps; <br>
* Click on All services. 
* Select Alert.
* Click on Create & select alert rule.
* In Alert rule page, click on select resource. Then, select the resource type needed.
* On the Condition tab, select the Signal name field and 
Set the condition as Greater than and the threshold as 90%. Choose the evaluation frequency and severity as per your preference.
* Click on Create alert rule. <br> <br>
Adjust the alert rules for CPU usage and memory working set percentage to trigger when they exceed 80%. CPU and memory are critical resources in your AKS cluster. When they are heavily utilized, it can lead to decreased application performance. By setting alert rules to trigger at 80%, you ensure that you are notified when these resources are approaching critical levels. <br> <br>

[![alerts-in-logs.png](https://i.postimg.cc/tgj8NhmM/alerts-in-logs.png)](https://postimg.cc/0zVt8JvY) <br>
[![cpu-usage-set-to-80.png](https://i.postimg.cc/GtHfmzHH/cpu-usage-set-to-80.png)](https://postimg.cc/q6HwmscT) <br>
[![used_disk_percentage_alert.png](https://i.postimg.cc/4xtrc8wc/used_disk_percentage_alert.png)](https://postimg.cc/nXFRbGyV) <br> <br>
Time to tidy up the dashboard and see what it looks like, This is easily found in dashboard from the home screen and is all drag and drop to move and resize. <br>
[![dashboard-working.png](https://i.postimg.cc/PrLGXfw2/dashboard-working.png)](https://postimg.cc/rKLZgkgr)
</details>

<details><summary>AKS INTERGRATION WITH AZURE KEY VAULT FOR SECRETS MANAGEMENT</summary>

**Create an Azure key vault** <br>

I began the process of securing your application code, by creating an Azure Key Vault, where i will securely store the sensitive information.

The steps i followed after reviewing this process were; <br>
* From the Azure portal menu, or from the Home page, select Create a resource.
* In the Search box, enter Key Vault. From the results list, choose Key Vault. <br>
[![key-vault.png](https://i.postimg.cc/Ls3wCnc6/key-vault.png)](https://postimg.cc/GB9X9h3Z)
* On the Key Vault section, choose Create.
* On the Create key vault section, provide the following information:
1. Name: A unique name for your key vault.
2. Subscription: Choose a subscription.
3. Resource Group: Choose an existing resource group or create a new one.
4. Location: Choose a location for your key vault.
5. ricing Tier: Choose a standard or premium tier.
* Select Review + Create and then Create. <br>
This creates a vault to store keys and passwords; <br>
[![key-vault-creation.png](https://i.postimg.cc/dVMfJ2vV/key-vault-creation.png)](https://postimg.cc/kBcsctB0) <br> <br>

**Assign key vault administrator role** <br>

Assign the Key Vault Administrator role to your Microsoft Entra ID user to grant yourself the necessary permissions for managing secrets within the Key Vault by following these steps; <br>

When inside the key vault i have just created; <br>
* Under Settings, select Access control (IAM).
* Choose Add role assignment.
* In the Add role assignment pane, choose the Key Vault Administrator role and choose Next.
* Choose your Microsoft Entra ID user as the assignee and choose Next.
* Review the role assignment and choose Save. <br>
[![key-vault-admin.png](https://i.postimg.cc/Zn2MB3dj/key-vault-admin.png)](https://postimg.cc/4Hv5jYwh) <br> <br>

**Create secrets in key vault** <br>
Create four secrets in the Key Vault to secure the credentials used within the application to connect to the backend database. These secrets include the server name, server username, server password, and the database name. Ensure that the values of these secrets are set to the hardcoded values from the application code. This can be done on Azure portal and within your vault by clicking on **secrets** and then Next, you need to add the secrets to the Key Vault using the Generate/Import option in the Secrets menu. You can specify the name and value of each secret; <br>
[![4-secrets.png](https://i.postimg.cc/02K3gtT4/4-secrets.png)](https://postimg.cc/N5Ybmxf8) <br><br>
**Enable managed identity for AKS** <br>
I watched the azure tutorial about this as i have never experienced this and learned that to enable managed identity for the AKS cluster, you need to use the Azure CLI command az aks create with the --enable-managed-identity. You can also specify a user-assigned managed identity with the --assign-identity.
For example, the following command creates a new AKS cluster with a managed identity and assigns it to a subnet and a kubelet identity <br>
*az aks create \
  --resource-group myResourceGroup \
  --name myManagedCluster \
  --network-plugin azure \
  --vnet-subnet-id subnet-id \
  --dns-service-ip 10.2.0.16 \
  --service-cidr 10.0.0.0/16 \
  --enable-managed-identity \
  --assign-identity identity-resource-id \
  --assign-kubelet-identity kubelet-identity-resource-id*<br>
  After doing this, you need to grant the managed identity access to the Key Vault resource. You can do this by adding the managed identity to an access policy in the Key Vault portal2. Alternatively, you can use the Azure CLI command az keyvault set-policy with the --object-id, This looks like; <br>
  *az keyvault set-policy \
  --name myKeyVault \
  --object-id <managed-identity-resource-id> \
  --secret-permissions get list* <br> <br>
  **Assign the permissions to managed identity** <br>
  Grant the managed identity access to your Azure Key Vault using the az keyvault set-policy command with the --secret-permissions and --key-permissions parameters which can look like this *az keyvault set-policy --name KEYVAULT_NAME --object-id USER_ASSIGNED_CLIENT_ID \
  --secret-permissions --key-permissions* and then you need to Configure your AKS cluster to use the user-assigned managed identity as the identity provider for the Secrets using commands like *az aks update --name CLUSTER_NAME --resource-group RESOURCE_GROUP \
  --enable-pod-identity --enable-addons azure-keyvault-secrets-provider \
  --pod-identity-identity-resource-group $RESOURCE_GROUP \
  --pod-identity-identity-name*, it took a bit of playing around to get this right after watching a YouTube video but once it felt like a success i checked the Azure portal to ensure this worked; <br>
  [![R7W5XOZ.png](https://i.postimg.cc/5tpWtCBR/R7W5XOZ.png)](https://postimg.cc/XZZzHXDf)<br> This can also be done in Azure portal under managed identities depending on your preferences. <br> <br>

  **Update the application code** <br>
  Integrating the Azure Identity and Azure Key Vault libraries into the Python application code to facilitate communication with Azure Key Vault, modifying the code to use managed identity credentials, ensuring secure retrieval of database connection details from the Key Vault was a new learning but very logical and relying on declaring the variables correctly when you call the application via the pipeline, the variables are shown below; <br>
  [![RMFHDNB.png](https://i.postimg.cc/TYPL2VnZ/RMFHDNB.png)](https://postimg.cc/Lhr6NZCT) <br>
  Updating the requirements was essential also to ensure the inclusion of the libraries; <br>
  [![RZZIMJ9.png](https://i.postimg.cc/Df64Kj4r/RZZIMJ9.png)](https://postimg.cc/jCWSHhX2) <br> At this stage testing the app was crucial before pushing / updating the docker image to avoid down time if the app failed; <br>
  [![RVHBFLH.png](https://i.postimg.cc/W3MW3Lcb/RVHBFLH.png)](https://postimg.cc/jwSQg1jG) As this was working fine i pushed the update to docker and carried out a rerun to rebuild the pipeline and checked the last deployment; <br>
  [![R5EPT44.png](https://i.postimg.cc/vZg4fGqh/R5EPT44.png)](https://postimg.cc/PCHfknkv) <br> <br>

  **End-to-end testing in AKS** <br>

I port forwarded the app to test it; <br>
[![final-working.png](https://i.postimg.cc/NfdSQK6s/final-working.png)](https://postimg.cc/56Fn3NKT) <br>

To show the status of a pod in kubectl, you can use the kubectl get pod command with the pod name as an argument. I used:

kubectl get pod flask-app-deployment-7d4b7484d5-d67zk

This displayed the pod name, its ready state, its status, how many restarts it has, and its age. <br>
[![final-pod-status.png](https://i.postimg.cc/wMHZjJ4v/final-pod-status.png)](https://postimg.cc/dkH4W7YP)
<br>
To show more details about the pod, such as its container status, node name, IP address, and events, you can use the kubectl describe pod command with the pod name as an argument. I used:

kubectl describe pod flask-app-deployment-7d4b7484d5-d67zk

This outputs a lot of information about the pod, which can be useful for troubleshooting or monitoring. <br>
[![final-pod-description.png](https://i.postimg.cc/nh5WQNSN/final-pod-description.png)](https://postimg.cc/G4FKWgCj) <br> 

I tehn opened it up in a browser and navigated the different pages;<br>
[![This-works-great.png](https://i.postimg.cc/85gnZMSH/This-works-great.png)](https://postimg.cc/Z9jcR90B) <br>

I processed a new order; <br>
[![final-test.png](https://i.postimg.cc/YCjV0tR1/final-test.png)](https://postimg.cc/QFGSnGRt) <br> 

And finally i went to Azure to take a look at the monitoring dashboard to ensure it was all ok; <br>
[![final-working-dashboard.png](https://i.postimg.cc/6QvmVzDq/final-working-dashboard.png)](https://postimg.cc/QBjmhgNZ) <br>
[![all-open.png](https://i.postimg.cc/SscH4Vr3/all-open.png)](https://postimg.cc/r0FfC17N) <br>
<br>
I felt with all this testing and making sure the monitoring was working i was now satisfied. A job well done. <br>
[![Satisfied.png](https://i.postimg.cc/HxkDwFCm/Satisfied.png)](https://postimg.cc/Jyv2m6nY)
</details>

<details><summary>MY KEY TAKEAWAYS</summary>


At the start of this project i felt very overwhlemed and very unprepared due to my lack of knowledge in this field, as the project started and i completed task by task finding any learning material i could including Microsofts Azure guides, YouTube Videos, Stack overflow Q&A's and talking to others around me i soon got into a flow (No Pipeline pun intended) and my confidence grew.

At the end of of the project i felt my best way to descibe end-to-end pipelines in Azure using Docker with secrets are a way to automate the process of building, testing, and deploying containerized applications in a secure and scalable manner. Some of the key takeaways from learning this approach were:

Docker allows developers to package their applications and dependencies into lightweight and portable images that can run on any platform.
Azure provides various services and tools to support Docker-based workflows, such as Azure Container Registry, Azure DevOps, Azure Key Vault, and Azure Kubernetes Service.
Secrets are sensitive information that should not be exposed in the source code or the Docker image. Azure Key Vault helps to store and manage secrets in a centralized and encrypted way, and Azure DevOps allows to inject secrets into the pipeline using variable groups or tasks.
Some of the challenges of using end-to-end pipelines in Azure with Docker and secrets are: ensuring the security and compliance of the pipeline, managing the complexity and dependencies of the Docker images, and optimizing the performance and cost of the pipeline.
</details>

<details><summary>WHAT WAS THE HARDEST PART OF THIS PROJECT</summary>

The hardest part of this project and my biggest set back was quite possibly trying to get Azure Devops to run the pipeline, the biggest issue i faced is for some reason my organisation with Azure portal and Azure devops kept defaulting to my personal account originally created befor the project began in the tutorial phase of the course. Because of this i kept getting a either an error for access to the organisation; <br>
[![RMZFYNT.png](https://i.postimg.cc/9Xy54KY9/RMZFYNT.png)](https://postimg.cc/xqjFhs7j) <br>
Or an error upon running the pipeline which explained that i did not have permission to build and run parralel pipelines. I resolved the parralemum issue by requesting a free parralel ticket from Microsoft which i am still not sure was the answer as i managed to rectify the organisation issue at the same time. Whether these were hand in hand is likely and fixing one clearly fixed the other which suggested i had Azure portal configured in correctly. <br>

This is the end of my README for a project called Web-App-DevOps-Project being completed for the AICore DevOps course.
</details>

****DevOps Pipeline Achitecture****
-----
[![devops-architecture.png](https://i.postimg.cc/K8Gxm00d/devops-architecture.png)](https://postimg.cc/RNDjRL5R)

## License

This project is licensed under the MIT License.<br>
This application code is Copyright (c) 2023 Maya Iuga

## Inpiring Quote

### “The best way to predict the future is to invent it.” - *Alan Kay*