# Introduction
This Runbook provides the steps to deploy a GPU machine on Oracle Cloud Infrastructure, install Parabricks, and run a benchmark using Parabricks software.

Parabricks is a is a computational framework supporting genomics applications from DNA to RNA. It is GPU-based solution that speeds up the process of analyzing whole genomes–all 3 billion base pairs in human chromosomes–from days to under an hour. Parabricks can be used to establish patterns in protein folding, protein-ligand binding, and cell membrane transport, making it a very useful application for drug research and discovery.

Gromacs supports running on CPU's or GPU's and supports parallel processing. It was developed by the University of Gronigen and is now maintained by various contributors around the world. More information can be found here.

# Architecture
The architecture for this runbook is simple, a single machine running inside of an OCI VCN with a public subnet.
Since a GPU instance is used, block storage is attached to the instance and installed with the Parabricks application and sample/reference data. The instance is located in a public subnet and assigned a public ip, which can be accessed via ssh. 

![](/.image/OCI Architecture.png " ")

# Login
Login to the using opc as a username:

   `ssh -i id_rsa {username}\@{public-ip-address}`
   
Note that if you are using resource manager, obtain the private key from the output and save on your local machine.

# Deployment
Deploying this architecture on OCI can be done in different ways:

The resource Manager let you deploy the infrastructure from the console. Only relevant variables are shown but others can be changed in the zip file.
The web console let you create each piece of the architecture one by one from a webbrowser. This can be used to avoid any terraform scripting or using existing templates.

# Licensing
Please obtain a Parabricks license [here](https://developer.nvidia.com/clara-parabricks). 

# Running the Application
If the provided terraform scripts are used to launch the application, Parabricks is installed in the /mnt/block/Parabricks folder and the example benchmarking model is available in /mnt/block/data folder. Run Parabricks via the following commands:

Run Parabricks germline pipeline on OCI GPU shapes via the following command:

`sudo pbrun germline --ref <ref file> --in-fq <sample file 1> <sample file 2> --num-gpus <number of gpus used> --out-bam <.bam output file> --out-variants <.vcf output file> 2>&1 | tee <.txt output file>`

where:

pbrun = program that reads the input file and execues the pipeline
--ref (required) = The reference genome in fasta format
--in-fq (required) = Pair ended fastq files
--out-bam (required) = Path to the file that will contain BAM output
--out-variants (required) = Name of VCF/GVCF/GVCF.GZ file after Variant Calling
--num-gpus = The number of GPUs to be used for this analysis task

Example for BM.GPU3.8:

`sudo pbrun germline --ref /mnt/block/data/Ref/Homo_sapiens_assembly38.fasta --in-fq /mnt/block/data/sample_1.fq.gz /mnt/block/data/sample_2.fq.gz --num-gpus 8 --out-bam germline.bam --out-variants germline.bam 2>&1 | tee germline.txt`

Once the run is complete, go to the txt file you wrote the output to. The run will show the time it took for the following stages in the germline pipeline 
- Sorting Phase - I
- Sorting Phase - II 
- Marking Duplicates, BQSR 
- HaplotypeCaller

If you'd like to automate this script, please refer to the automation script. 


