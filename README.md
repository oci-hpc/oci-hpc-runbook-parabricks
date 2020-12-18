# <img src="https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/Parabricks%20Logo.png" width="200" height="200"> Runbook

# Introduction
This Runbook provides the steps to deploy a GPU machine on Oracle Cloud Infrastructure, install Parabricks, and run a benchmark using Parabricks software.

Parabricks is a computational framework supporting genomics applications from DNA to RNA. It is a GPU-based solution that speeds up the process of analyzing whole genomes–all 3 billion base pairs in human chromosomes–from days to under an hour. Parabricks can be used to establish patterns in protein folding, protein-ligand binding, and cell membrane transport, making it a very useful application for drug research and discovery.

Parabricks supports running on GPU's and supports parallel processing. It began as an Ann Arbor, Michigan-based startup and is now part of the NVIDIA Healthcare team. More information can be found [here](https://www.nvidia.com/en-us/healthcare/clara-parabricks/). 

# Architecture
The architecture for this runbook is simple, a single machine running inside of an OCI VCN with a public subnet.
Since a GPU instance is used, block storage is attached to the instance and installed with the Parabricks application and sample/reference data. The instance is located in a public subnet and assigned a public ip, which can be accessed via ssh. 

![](https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/OCI%20Architecture.png)

# Login
Login to the instance using `ubuntu` as a username:

   `ssh -i id_rsa {username}\@{public-ip-address}`
   
Note that if you are using resource manager, obtain the private key from the output and save on your local machine.

# Deployment
Deploying this architecture on OCI can be done in different ways:
* The [resource Manager](https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/Documentation/ResourceManager.md#deployment-through-resource-manager) lets you deploy the infrastructure from the console. Only relevant variables are shown but others can be changed in the zip file. 
* The [web console](https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/Documentation/ManualDeployment.md#deployment-via-web-console) lets you create each piece of the architecture one by one from a web browser. This can be used to avoid any terraform scripting or using existing templates. 

# Licensing
Please obtain a Parabricks license [here](https://developer.nvidia.com/clara-parabricks). 

# Running the Application
If the provided terraform scripts are used to launch the application, Parabricks is installed in the `/mnt/block/parabricks` folder and the example benchmarking model is available in the `/mnt/block/parabricks_assets/data` folder. The following scripts run the germline pipleine, the architecture shown below. 

![](https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/Germline%20Pipeline%20Architecture.png)

Run Parabricks germline pipeline on OCI GPU shapes via the following command (Suggestion: Make a separate folder called `/mnt/block/results` to run command inside):

`sudo pbrun germline --ref <ref file> --in-fq <sample file 1> <sample file 2> --num-gpus <number of gpus used> --out-bam <.bam output file> --out-variants <.vcf output file> 2>&1 | tee <.txt output file>`

where:

- pbrun = program that reads the input file and execues the pipeline
- --ref (required) = The reference genome in fasta format
- --in-fq (required) = Pair ended fastq files
- --out-bam (required) = Path to the file that will contain BAM output
- --out-variants (required) = Name of VCF/GVCF/GVCF.GZ file after Variant Calling
- --num-gpus = The number of GPUs to be used for this analysis task

Example for BM.GPU3.8:

`sudo pbrun germline --ref /mnt/block/parabricks_assets/Ref/Homo_sapiens_assembly38.fasta --in-fq /mnt/block/parabricks_assets/data/sample_1.fq.gz /mnt/block/parabricks_assets/data/sample_2.fq.gz --num-gpus 8 --out-bam germline.bam --out-variants germline.bam 2>&1 | tee germline.txt`

Once the benchmark is complete, go to the `.txt` file you wrote the output to. The benchmark will show the time it took for the following programs n the germline pipeline to run:
- Sorting Phase - I
- Sorting Phase - II 
- Marking Duplicates, BQSR 
- HaplotypeCaller

If you'd like to automate this pipeline, please refer to the [automation script](https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/Resources/germline_automation.sh). 

`scp myfile.txt {username}\@{public-ip-address}:/remote/folder/`

To write out to Object Storage, please add your PRE-AUTHENTICATED REQUEST URL for your Object Storage bucket in line 14 of the automation script. To see how to create an Object Storage bucket, refer [here](https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/Documentation/ResourceManager.md#add-parabricks-installer-to-object-storage).

# Benchmark Example
This is the performance comparison between BM.GPU4.8(A100), BM.GPU3.8(V100), and VM.GPU3.4(V100). The sample data (48G and 49G) used in this benchmark was [NA12878](https://www.ebi.ac.uk/ena/browser/view/ERR194147) from ILLUMINA.

![](https://github.com/oci-hpc/oci-hpc-runbook-parabricks/blob/main/images/A100%20vs%20V100%20on%20OCI.png)
