#this automation scripts runs gemrline pipeline with desired amount of iterations

#!/usr/bin/env bash

init_vars(){

	iterations=""
	ref_file=""
	infq_file=()
	out_bam=""
	out_variants=""
	num_gpus=""
	output_txt="" 
	objstor_par=""
	
}

handle_custom_params(){
# $1 is going to capture the 1st argument you're going to pass to this file
	while test $# -gt 0; do
		case $1 in 
			--help)
				show_options
				;;
			--iterations)
				while test $# -gt 1; do
					if [[ "$2" =~ ^-- ]]; then # check if param is a flag
						#echo "ERROR: no argument passed to $1"
						#show_options
						break
					else
						# success
						iterations=$2
					fi
					shift
				done
				shift
				;;
			--ref)
				while test $# -gt 1; do
					if [[ "$2" =~ ^-- ]]; then # check if param is a flag
						#echo "ERROR: no argument passed to $1"
						#show_options
						break
					else
						# success
						ref_file=$2
					fi
					shift
				done
				shift
				;;
			--in-fq)
				# if no more arguments in command
				if test $# -le 2; then
					show_options
				fi
				while test $# -gt 2; do
					# if more arguments in command but no more arguments passed to this flag
					if [[ "$2" =~ ^-- ]]; then
						break
					fi
					# if only one argument was passed to this flag
					if [[ "$3" =~ ^-- ]]; then # check if file is inserted
						echo "Error: only '${2}' was passed to ${1} flag when 2 arguments are required."
						show_options
					else
						# success
						infq_file+=($2 $3)
					fi
					shift
					shift
				done
				shift
				;;
			--num-gpus)
				while test $# -gt 1; do
					if [[ "$2" =~ ^-- ]]; then # check if param is a flag
						# echo "ERROR: no argument passed to $1"
						# show_options
						break
					else
						# success
						num_gpus="${2}"
					fi
					shift
				done
				shift
				;;
			--out-bam)
				while test $# -gt 1; do
					if [[ "$2" =~ ^-- ]]; then # check if param is a flag
						# echo "ERROR: no argument passed to $1"
						# show_options
						break
					else
						# success
						out_bam="${2}"
					fi
					shift
				done
				shift
				;;
			--out-variants)
				while test $# -gt 1; do
					if [[ "$2" =~ ^-- ]]; then # check if param is a flag
						# echo "ERROR: no argument passed to $1"
						# show_options
						break
					else
						# success
						out_variants="${2}"
					fi
					shift
				done
				shift
				;;
			*)
				echo "ERROR: $1 not a valid option"
				show_options
				;;
		esac
	done
}

#help function 
show_options(){

options_str=$(cat <<- EOF
Options:
Flag   			Description
--help          Use to get description of flags
--iterations    How many times do you want this automation script to run                                                
--ref           The reference genome in fasta format. We assume that the indexing required to run bwa has been completed by the user.
--in-fq			Pair ended fastq files. These can be in .fq.gz or .fastq.gz format. You can provide multiple pairs as inputs like so:--in-fq $fq1 $fq2 --in-fq $fq3 $fq4 
--out-bam		Path to the file that will contain BAM output.
--out-variants	Name of VCF/GVCF/GVCF.GZ file after Variant Calling. Absolute or relative path can be given.
--num-gpus   	The number of GPUs to be used for this analysis task.                                 
                 
EOF
)

echo -e "${options_str}\n"
exit
}

handle_valid_custom_params(){
	for (( j=("${iterations}"); j>0; j-=1 )); do
         date=$(date -u +\%b_\%d_\%Y_\%H_\%M)
         runs="run_${date}"
         mkdir -p "${runs}"
         for (( i=((${num_gpus})); i>0; i/=2 )); do
             germline_output="${date}_germline_${i}.txt"
             out_bam_output="${date}_${out_bam}_${i}.bam"
             out_variants_output="${date}_${out_variants}_${i}.vcf"
             sudo pbrun germline --ref "${ref_file}" --in-fq "${infq_file[${#infq_file[@]}-2]}" "${infq_file[${#infq_file[@]}-1]}" --num-gpus "${i}" --out-bam "${out_bam_output}" --out-variants "${out_variants_output}" 2>&1 | tee "${germline_output}"
             mv "${germline_output}" "${runs}"
         done
	    echo "Uploading logs to Object Storage"
		for file in $runs/*; do
	    	FILENAME=$file
	    	curl -X PUT --data-binary ''@$FILENAME'' $objstor_par$FILENAME
		sleep 10
		done 
    done
}


main(){
	init_vars
	handle_custom_params "$@"
	handle_valid_custom_params 
}

#pass all of the parameters to the automation script to the function (whole list)
main "$@"


# How to automate? 
 
# # --in-fq these need to be changed out - parameter
# # --num-gpu need to change the number of GPU from 1-8 - parameter
# # --need this all to come out in 1 txt file

#./germline_automation --iterations NUM OF ITERATIONS --ref REF_PATH.fasta --in-fq SAMPLE_PATH_1.fastq.gz SAMPLE_PATH_2.fastq.gz --num-gpus NUM OF GPUS --out-bam germline --out-variants germline

#sample run

#./germline_automation.sh --iterations 2 --ref /mnt/block/parabricks_assets/Ref/Homo_sapiens_assembly38.fasta  --in-fq /mnt/block/parabricks_assets/data/sample_1.fq.gz /mnt/block/parabricks_assets/data/sample_2.fq.gz --num-gpus 8 --out-bam germline --out-variants germline
