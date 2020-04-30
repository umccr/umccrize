## Cancer gene coverage

localrules: conpair


rule run_conpair:
    input:
        tumor_bam = lambda wc: batch_by_name[wc.batch].tumor.bam,
        normal_bam = lambda wc: batch_by_name[wc.batch].normal.bam,
        ref_fa = hpc.get_ref_file(run.genome_build, key='fa')
    output:
        concord = directory('work/{batch}/conpair/concordance'),
        contam = directory('work/{batch}/conpair/contamination'),
        tmp = directory('work/{batch}/conpair/.snakemake'),
    threads: 2
    resources:
        mem_mb=10000
    benchmark:
        'benchmarks/{batch}/conpair/{batch}-conpair.tsv'
    params:
        genome = run.genome_build,
        out_dir = 'work/{batch}/conpair',
        tumor_name = lambda wc: batch_by_name[wc.batch].tumor.name,
        normal_name = lambda wc: batch_by_name[wc.batch].normal.name,
    shell:
        'conpair -T {input.tumor_bam} -N {input.normal_bam} --ref-fa {input.ref_fa} -g {params.genome} -j {threads} '
        '-o {params.out_dir} -tn {params.tumor_name} -nn {params.normal_name}'
        ' || touch work/{wildcards.batch}/conpair/failed'


rule conpair:
    input:
        expand(rules.run_conpair.output, batch=batch_by_name.keys())
    output:
        temp(touch('log/conpair.done'))
