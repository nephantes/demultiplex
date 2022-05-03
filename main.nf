$HOSTNAME = ""
params.outdir = 'results'  


if (!params.reads){params.reads = ""} 
if (!params.barcodes){params.barcodes = ""} 

Channel.fromPath(params.reads, type: 'any').map{ file -> tuple(file.baseName, file) }.set{g_1_reads_g_0}
g_2_upfile_g_0 = file(params.barcodes, type: 'any')


process demultiplex {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /barcode\/.*.fastq$/) "fastq/$filename"}
input:
 set val(name),file(reads) from g_1_reads_g_0
 file barcode from g_2_upfile_g_0

output:
 set val(name),file("barcode/*.fastq")  into g_0_outfqs00

shell:
'''
#!/usr/bin/env perl
my $barcode="!{barcode}";
my $reads="!{reads}";

my $outdir   = "barcode";
`mkdir -p $outdir`;
die "Error 15: Cannot create the directory:".$outdir if ($?);

my $com="/project/umw_biocore/bin/novo/novocraft/novobarcode -b $barcode -f $reads -d $outdir > /dev/null";  
runCommand($com);

sub runCommand {
    my ($com) = @_;
    if ($com eq ""){
        return "";
    }
    my $error = system(@_);
    if   ($error) { die "Command failed: $error $com\n"; }
    else          { print "Command successful: $com\n"; }
}
'''
}


workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
