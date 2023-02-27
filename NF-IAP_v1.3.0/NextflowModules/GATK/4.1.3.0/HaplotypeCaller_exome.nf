// exome only 
process HaplotypeCaller {
    tag {"GATK HaplotypeCaller ${sample_id}.${int_tag}"}
    label 'GATK_4_1_3_0'
    label 'GATK_4_1_3_0_HaplotypeCaller'
    clusterOptions = workflow.profile == "sge" ? "-l h_vmem=${params.mem}" : ""
    container = 'library://sawibo/default/bioinf-tools:gatk4.1.3.0'
    shell = ['/bin/bash', '-euo', 'pipefail']
    input:
        tuple (sample_id, path(bam), path(bai))

    output:
        tuple (sample_id,path("${sample_id}${ext}"), path("${sample_id}${ext}.idx"), emit: htcaller_vcfs)

    script:
        //int_tag = interval_file.toRealPath().toString().split("/")[-2]
        ext = params.optional =~ /GVCF/ ? '.g.vcf' : '.vcf'
        """
        gatk --java-options "-Xmx${task.memory.toGiga()-4}g -Djava.io.tmpdir=\$TMPDIR" \
        HaplotypeCaller \
        ${params.optional} \
        -I $bam \
        --output ${sample_id}${ext} \
        -R $params.genome_fasta \
        -L /hpc/hub_clevers/general/reference/whole_exome_illumina_coding_v1.Homo_sapiens_assembly38.baits.interval_list
        """
}
