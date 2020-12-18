# <img src="https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/Parabricks%20Logo.png" width="200" height="200"> Runbook

## Deployment via web console

### Table of Contents
- [Deployment via web console](#deployment-via-web-console)
  - [Log In](#log-in)
  - [Virtual Cloud Network](#virtual-cloud-network)
  - [Compute Instance](#compute-instance)
  - [Block Storage](#block-storage)
  - [Mounting a Block Storage or NVME SSD Drive](#mounting-a-block-storage-or-nvme-ssd-drive)
- [Parabricks Configuration](#parabricks-configuration)
  - [Running_Parabricks](#running-parabricks)

### Log In
You can start by logging in the Oracle Cloud console. If this is the first time, instructions to do so are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your instance. Click on the current region in the top right dropdown list to select another one. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Region.png" height="50">

### Virtual Cloud Network
Before creating an instance, we need to configure a Virtual Cloud Network. 
 1. Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Networking --> Virtual Cloud Networks. Make sure to select your compartment on the lower left side <img src="https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/VCN%20Compartment.png" heigh="100">. Then click <img src="https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/VCN_Start_Wizard.png" height="20">.

 2. On the next page, select the following: 
    * VNC with Internet Connectivity --> Start VCN Wizard
    * VCN Name
    * Compartment of your VCN will be pre-populated

 3. Scroll down and click Next and then review your VCN parameters and click Create.

### Compute Instance

 1. Create a new instance by selecting the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/menu.png" height="20"> on the top left, then select Marketplace.

    <img src="https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/Marketplace.png" height="200">

 2. On the next page, type GPU into the search bar and select NVIDIA GPU Cloud Machine Image <img src="https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/GPU%20Search%20Bar.png" height="300">. 

 3. Once you selected the image, choose the version and compartment where you'd like to launch the instance. Once you're done click <img src="https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/Launch%20instance.png" height="100">
 
 4. Fill out the following information on this page
    * Name of your instance.
    * Compartment
    * Availability Domain: Each region has one or more availability domains. Some instance shapes are only available in certain ADs.
    * Instance Shape: 
      * For 8 A100 GPU, select BM.GPU4.8
      * For 8 V100 GPU, select BM.GPU3.8
      * Other shapes are available as well, [click for more information](https://cloud.oracle.com/compute/bare-metal/features).
    * Virtual Cloud Network: Select the network that you previously created.
    * SSH key: Attach your public key file. For more information, click [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm).

 4. Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/create.png" height="25">.

 5. After a few minutes, the instances will turn green, meaning it is up and running. Click on the instance name in the console to identify the public IP. You can now connect using `ssh ubuntu@xx.xx.xx.xx` from the machine using the key that was provided during the creation. 

### Block Storage

 1. Create a new Block Volume by selecting the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/menu.png" height="20"> on the top left, then select Block Storage --> Block Volumes.

 2. Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/create_bv.png" height="25">.

 3. On the next page, select the following: 
     * Name
     * Compartment
     * Size (in GB)
     * Availability Domain: Make sure to select the same as your Compute Instance. 

 4. Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/create_bv.png" height="25">.

 5. Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/menu.png" height="20"> on the top left, then select Compute and Instances.

 6. Click on the instance to which the drive will be attached.

 7. On the lower left, in the Resources menu, click on "Attached Block Volumes".

    <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/resources.png" height="200">

 8. Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/attach_BV.png" height="25">

 9. All the default settings will work fine. Select the Block Volume that was just created and specify `/dev/oracleoci/oraclevdb` as the device path. 
  Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/attach.png" height="25">.

    **Note: If you do not see the Block Volume, it may be because you did not place it in the same AD as your running instance**

 10. Once it is attached, hit the 3 dots at the far right of the Block Volume description and select "iSCSi Commands and Information". 

     <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/ISCSi.png" height="150">

 11. Copy and execute the commands to attach the block volume to the instance. 

     <img src="https://github.com/oci-hpc/oci-hpc-runbook-gromacs/blob/master/images/iscsi_commands.png" height="200">


### Mounting a Block Storage or NVME SSD Drive
You will need to mount it to your running instance to be able to use it. 

 1. After logging in using ssh, run the command `lsblk`. 
    The block volume should appear as attached.

 2. Create a partition:
    ```
    sudo fdisk -l <device path>
    ```
    For example: `sudo fdisk -l /dev/oracleoci/oraclevdb`
    
 3. Create an NFS fileshare system:
    ```
    sudo mkfs -t ext4 <device path>
    ```

 4. Create a folder on the `/mnt` drive to mount the block volume. For example:
    ```
    sudo mkdir /mnt/parabricks 
    ```
 5. Create a mount point: 
     ```
    sudo mount <device path> <mount point>
    ```
    For example: `sudo mount /dev/oracleoci/oraclevdb /mnt/parabricks`
    
 6. Run `lsblk`
    The disk should appear as correctly mounted on the mountpoint.
 
 7. Change the permissions of the volume. For example:
    ```
    sudo chmod 777 /mnt/parabricks
    ```

## Parabricks Configuration
This guide will show you how to configure Parabricks on Oracle Linux 7.6 or CentOS which are available on Oracle Cloud Infrastructure.

 1. [Request access](https://www.nvidia.com/en-us/docs/nvidia-parabricks-researchers/) to the Parabricks installer Python file for a 90-day trial.
 
 2. Download the Parabricks installer file into your mounted share drive on the instance.
 
 3. Untar `parabricks.tar.gz`
    ```
    tar -xzf parabricks.tar.gz
    ```
 4. Run the installer
    ```
    sudo ./parabricks/installer.py
    ```
 5. Verify your pbrun version:
    ```
    sudo pbrun version
    ```
    
### Running Parabricks

 1. Download a sample dataset to run a benchmark and untar it:
    ```
    wget "https://objectstorage.us-ashburn-1.oraclecloud.com/p/cGH2qx5swTiahEmUlo8VKO8NwtWqmyauCKkz6nBTGtMeOYb3vtYc7kkBR-wj-uNX/n/hpc_limited_availability/b/parabricks/o/parabricks_assets.tar.gz"
    tar -xvzf parabricks_assets.tar.gz
    ```

 2. Refer to the README.md file for command line parameters to run Parabricks. 

