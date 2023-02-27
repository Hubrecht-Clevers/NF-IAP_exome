process GenotypeGVCFs {
    tag {"GATK GenotypeGVCFs ${run_id}"}
    label 'GATK_4_1_3_0'
    label 'GATK_4_1_3_0_GenotypeGVCFs'
    clusterOptions = workflow.profile == "sge" ? "-l h_vmem=${params.mem}" : ""
    container = 'library://sawibo/default/bioinf-tools:gatk4.1.3.0'
    shell = ['/bin/bash', '-euo', 'pipefail']
    input:
        tuple (run_id, path(gvcf), path(gvcfidx))

    output:
        tuple (run_id, path("${run_id}.vcf"),path("${run_id}.vcf.idx"), emit : genotyped_vcfs)

    script:
        """
        gatk --java-options "-Xmx${task.memory.toGiga()-4}g -Djava.io.tmpdir=\$TMPDIR" \
        GenotypeGVCFs \
        -V $gvcf \
        -O ${run_id}.vcf \
        -R ${params.genome_fasta} \
        -D ${params.genome_dbsnp} \
        -L /hpc/hub_clevers/general/reference/whole_exome_illumina_coding_v1.Homo_sapiens_assembly38.baits.interval_list
        """
}

