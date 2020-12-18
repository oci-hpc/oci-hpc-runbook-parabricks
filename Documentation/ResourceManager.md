# <img src="https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/Parabricks%20Logo.png" width="200" height="200"> Runbook
 
## Deployment through Resource Manager

### Table of Contents
 - [Log In](#log-in)
 - [Add Parabricks Installer to Object Storage](#add-parabricks-installer-to-object-storage)
 - [Resource Manager](#resource-manager)
 - [Select Variables](#select-variables)
 - [Run the Stack](#run-the-stack)
 - [Access Your GPU Node](#access-your-gpu-node)
  

### Log In
You can start by logging in the Oracle Cloud console. If this is the first time, instructions are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your instance. Click on the current region in the top right dropdown list to select another one. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Region.png" height="50">


### Add Parabricks Installer to Object Storage
*Please modify the variable.tf file and replace the values for parabricks_license and parabricks_assets with your own pre-authenticated request urls.*

  1. Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Object Storage --> Object Storage.

  2. Create a new bucket or select an existing one. To create one, click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_bucket.png" height="20">.

  3. Leave the default options: Standard as Storage tiers and Oracle-Managed keys. Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_bucket.png" height="20">.

  4. Click on the newly created bucket name and then select <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/upload_object.png" height="20">.

  5. Select your Gromacs installer tar file and click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/upload_object.png" height="20">.

  6. Click on the 3 dots to the right side of the object you just uploaded <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/3dots.png" height="20"> and select "Create Pre-Authenticated Request". 

  7. In the following menu, leave the default options and select an expiration date for the URL of your installer. Click on  <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/pre_auth.png" height="25">.

  8. In the next window, copy the "PRE-AUTHENTICATED REQUEST URL" and keep it. You will not be able to retrieve it after you close this window. If you lose it or it expires, it is always possible to recreate another Pre-Authenticated Request that will generate a different URL.


### Resource Manager
In the OCI console, there is a Resource Manager available that will create all the resources needed. The region in which you create the stack will be the region in which it is deployed.

  1. Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Resource Manager --> Stacks. Choose the Name and Compartment on the left filter menu where the stack will be run.

  2. Create a new stack: <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/stack.png" height="20">

  3. Download the [zip file](https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/Resources/parabricks-2020.zip) for terraform scripts and upload it into the stack. 

Move to the [Select Variables](#select-variables) section to complete configuration of the stack.

### Select variables

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/next.png" height="20"> and fill in the variables. 

GPU Node:
* SHAPE OF THE GPU COMPUTE NODE: Shape of the Compute Node that will be used to run Gromacs. Select a GPU shape, BM.GPU3.8 or BM.GPU4.8 for best performance.
* AVAILABILITY DOMAIN: AD of the Instance and Block Volume. The AD must have available GPU's.
* GPU Node Count: Number of GPU Nodes Required.

Block Options:
* BLOCK VOLUME SIZE ( GB ): Size of the shared block volume.

Parabricks:
* URL TO DOWNLOAD PARABRICKS INSTALLER: Replace the url with a different version or leave blank if you wish to download later.
* URL TO DOWNLOAD PARABRICKS ASSETS: URL of the model you wish to run (replace the url with a different model or leave blank if you wish to download later).

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/next.png" height="20">.
Review the information and click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create.png" height="20">.

### Run the stack

Now that your stack is created, you can run jobs. 

Select the stack that you created.
In the "Terraform Actions" dropdown menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/tf_actions.png" height="20">, run 'Apply' to launch the GPU infrastructure.

### Access your GPU Node

Once your job has completed successfully in Resource Manager, you can find the Public IP Addresses for the GPU node and the Private Key on the lower left menu under **Outputs**. Copy the Private Key onto your local machine, change the permissions of the key and login to the instance:

```
chmod 600 /home/user/key
ssh -i /home/user/key ubuntu@ipaddress
```

Once logged into your GPU node, you can install Parabricks by going into `/mnt/block/parabricks` and run the following command

```
sudo ./parabricks/installer.py
```

After installation, to run Parabricks, refer to the README.md file for specific commands on how to run Parabricks on your GPU instance.
