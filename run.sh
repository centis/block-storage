#!/bin/bash
# Copyright 2014 CloudHarmony Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
  cat << EOF
Usage: run.sh [options]

Conducts block storage testing based on the SNIA Solid State Storage (SSS) 
Performance Test Specification (PTS) Enterprise v1.1. More information about
this specification is available here:

http://snia.org/sites/default/files/SSS_PTS_Enterprise_v1.1.pdf

The SNIA test specification allows for some user configurable parameters. 
Additionally, this script allows for some specification parameters to be 
overridden. Each of the arguments listed below may also be specified using 
environment variables prefixed with 'bm_param_'

ARGUMENTS:

--active_range              LBA range to use for testing represented as a 
                            percentage. Default is 100, or 100% per the SNIA
                            test specification. To test across a smaller 
                            range, this parameter may be reduced. If the
                            test targets are not devices, test size is total 
                            free space - 100 MB. WARNING: if multiple volume
                            type targets are specified, active range will be 
                            limited to the least amount of free space on all 
                            targets

--fio                       Optional explicit path to the fio command - 
                            otherwise fio in PATH will be used

--fio_*=                    Optional fio runtime parameters. By default, fio 
                            parameters are generated by the test script per 
                            the SNIA test specification. Use this parameter to 
                            override default fio settings 
                            (e.g. fio_ioengine=sync)

--font_size                 The base font size pt to use in reports and graphs. 
                            All text will be relative to this size (i.e. 
                            smaller, larger). Default is 9. Graphs use this 
                            value + 4 (i.e. default 13). Open Sans is included
                            with this software. To change this, simply replace
                            the reports/font.ttf file with your desired font

--help/-h                   Print help and exit

--highcharts_js_url         URL to highcharts.js. Highcharts is used to render
                            3D charts in reports. Use 'no3dcharts' to disable 
                            3D charts. Default for this parameter is
                            http://code.highcharts.com/highcharts.js
                            
--highcharts3d_js_url       URL to highcharts-3d.js. Highcharts is used to 
                            render 3D charts in reports. Use 'no3dcharts' to 
                            disable 3D charts. Default for this parameter is
                            http://code.highcharts.com/highcharts-3d.js
                            
--jquery_url                URL for jquery. jquery is used by Highcharts.
                            Highcharts is used to render 3D charts in reports. 
                            Use 'no3dcharts' to disable 3D charts. Default for 
                            this parameter is
                            http://code.jquery.com/jquery-2.1.0.min.js
                            
--meta_burst                Optional flag designating if the testing was 
                            performed using within the burst capabilities of 
                            the test volumes. See --wd_sleep_between for 
                            details on automating burst testing
                            
--meta_compute_service      The name of the compute service this test pertains
                            to. Used for report headers. May also be specified 
                            using the environment variable bm_compute_service
                            
--meta_compute_service_id   The id of the compute service this test pertains
                            to. Added to saved results. May also be specified 
                            using the environment variable 
                            bm_compute_service_id

--meta_cpu                  CPU descriptor to use for report headers. If not 
                            specified, it will be set using the 'model name' 
                            attribute in /proc/cpuinfo
                            
--meta_drive_interface      Optional drive interface descriptor to use for 
                            report headers (e.g. SATA 6Gb/s)

--meta_drive_model          Optional drive model descriptor to use for report
                            headers (e.g. Intel DC S3700)

--meta_drive_type           Optional drive type descriptor to use for report 
                            headers (e.g. SATA, SSD, PCIe)
                            
--meta_encryption           Optional flag designating if the test volume had
                            encryption enabled
                            
--meta_host_cache           Optional host caching designation for the test 
                            volumes (if applicable). One of the following 
                            values: read or rw
                            
--meta_instance_id          The compute service instance type this test pertains 
                            to (e.g. c3.xlarge). Used for report headers
                            
--meta_memory               Memory descriptor to use for report headers. If not 
                            specified, the amount of memory will be used (as 
                            reported by 'free')
                            
--meta_notes_storage        Optional notes to display in the Storage Platform 
                            header column

--meta_notes_test           Optional notes to display in the Test Platform 
                            header column
                            
--meta_os                   Operating system descriptor to use for report 
                            headers. If not specified, this meta data will be 
                            derived from the first line of /etc/issue

--meta_piops                Optional argument designating the number of 
                            provisioned IOPs associated with the test volumes
                            
--meta_provider             The name of the cloud provider this test pertains
                            to. Used for report headers. May also be specified 
                            using the environment variable bm_provider
                            
--meta_provider_id          The id of the cloud provider this test pertains
                            to. Added to saved results. May also be specified 
                            using the environment variable 
                            bm_provider_id

--meta_region               The compute service region this test pertains to. 
                            Used for report headers. May also be specified 
                            using the environment variable bm_region
                            
--meta_resource_id          An optional benchmark resource identifiers. Added 
                            to saved results. May also be specified using the 
                            environment variable bm_resource_id

--meta_run_id               An optional benchmark run identifiers. Added to 
                            saved results. May also be specified using the 
                            environment variable bm_run_id
                            
--meta_storage_config       Storage configuration descriptor to use for report 
                            headers. If not specified, 'Unknown' will be 
                            displayed in this column
                            
--meta_storage_vol_info     If testing is against a volume, this optioanl 
                            parameter may be used to designate setup of that 
                            volume (e.g. Raid, File System, etc.). Only 
                            displayed when targets are volumes. If this
                            parameter is not specified the file system type 
                            for each target volume will be included in this 
                            column
                            
--meta_test_id              Identifier for the test. Used for report headers. 
                            If not specified, this header column will be blank
                            
--meta_test_sw              Name/version of the test software. Used for report 
                            headers. If not specified, this header column will 
                            be blank
                            
--no3dcharts                Don't generate 3D charts. Unlike 2D charts rendered 
                            with the free chart utility gnuplot, 3D charts are 
                            rendered using highcharts - a commercial javascript
                            charting tool. highcharts is available for free for 
                            non-commercial and development use, and for a 
                            nominal fee otherwise. See http://www.highcharts.com
                            for additional licensing information
                            
--nojson                    Don't generate JSON result or fio output files

--nopdfreport               Don't generate PDF version of test report - 
                            report.pdf. (wkhtmltopdf dependency removed if 
                            specified)

--noprecondition            Don't perform the default 2X 128K sequential 
                            workload independent preconditioning (per the SNIA 
                            test specification). This step precedes workload 
                            dependent preconditioning
                            
--noprecondition_rotational Don't perform preconditioning for rotational 
                            test targets

--nopurge                   Don't require a purge for testing. If this 
                            parameter is not set, and at least 1 target could 
                            not be purged, testing will abort. This parameter
                            is implicit if --nosecureerase, --notrim and 
                            --nozerofill are all specified

--norandom                  Don't test using random (less compressible) data.
                            Use of random data for IO is a requirement of the 
                            SNIA test specification

--noreport                  Don't generate html or PDF test reports - 
                            report.zip and report.pdf (gnuplot, wkhtmltopdf and
                            zip dependencies removed if specified)

--nosecureerase             Don't attempt to secure erase device targets prior 
                            to test cycles (this is the first choice - hdparm 
                            dependency removed if specified). This parameter is
                            implicit if --secureerase_pswd is not provided

--notrim                    Don't attempt to TRIM devices/volumes prior to 
                            testing cycles (util-linux dependency removed if 
                            specified)

--nozerofill                Don't zero fill rotational devices (or SSD devices 
                            when TRIM is not supported) prior to testing 
                            cycles. Zero fill applies only to device targets
                            
--output                    The output directory to use for writing test artifacts 
                            (JSON and reports). If not specified, the current 
                            working directory will be used
                            
--precondition_once         If set, preconditioning will be performed once only
                            instead of prior to each test performed
                            
--precondition_passes       Number of passes for workload independent 
                            preconditioning. Per the SNIA test specification 
                            the default is 2X. Use this or the --noprecondition
                            argument to change this default behavior

--oio_per_thread            The outstanding IO per thread (a.k.a. queue depth). 
                            This translates to the fio 'iodepth' parameter. 
                            Total outstanding IO for a given test is 
                            'threads' * 'threads_oio'. Per the SNIA test 
                            specification, this is a user definable parameter. 
                            For latency tests, this parameter is a fixed value
                            of 1. Default value for this parameter is 64
                            
--randommap                 Random maps are allocated at init time to track 
                            written to blocks and duplicate block writes. When 
                            used, random maps must be allocated in memory at 
                            init time. The memory allocation for these can be 
                            problematic for large test volume (e.g. 16TB volume
                             = 4.2GB memory). If this option is not set, random
                            fio tests will be executed using the --norandommap
                            and --randrepeat=0 fio options
                            
--savefio                   Include results from every fio test job in save 
                            output

--secureerase_pswd          In order for ATA secure erase to be attempted for 
                            device purge (prior to test invocation), you must
                            first set a security password using the command:
                            sudo hdparm --user-master u --security-set-pass [pswd] /dev/[device]
                            The password used should be supplied using this 
                            test parameter. If it is not supplied, ATA secure
                            erase will not be attempted. If this parameter is 
                            not specified, the hdparm dependent will be removed

--sequential_only           If set, all random tests will be executed using 
                            sequential IO instead
                            
--skip_blocksize            block sizes to skip during testing. This argument 
                            may be repeated. Valid options are:
                            1m, 128k, 64k, 32k, 16k, 8k, 512b

--skip_workload             workloads to skip during testing. This argument may
                            be repeated. Valid options are:
                            100/0, 95/5, 65/35, 50/50, 35/65, 5/95

--ss_max_rounds             The maximum number of test cycle iterations to 
                            allow for steady state verification. Default is 
                            x=25 (per the SNIA test specification). If steady 
                            state cannot be reached within this number of test 
                            cycles (per the ss_verification ratio), testing 
                            will terminate, and results will be designated as 
                            having not achieved steady state. This parameter 
                            may be used to increase (or decrease) the number of 
                            test cycles. A minimum value of 5 is permitted 
                            (the minimum number of cycles for the measurement 
                            window)

--ss_verification           Ratio to utilize for steady state verification. The 
                            default is 10 or 10% per the SNIA test 
                            specification. In order to achieve steady state 
                            verification, the variance between the current test 
                            cycle loop and the 4 that precede it cannot exceed 
                            this value. In cloud environments with high IO 
                            variability, it may be difficult to achieve the 
                            default ratio and thus this value may be increased 
                            using this parameter

--target                    REQUIRED: The target device or volume to use for 
                            testing. This parameter may reference either the 
                            physical device (e.g. /dev/sdc) or a mounted volume
                            (e.g. /ssd). TRIM will be attempted using 
                            'blkdiscard' for a device and 'fstrim' for a volume
                            if the targets are non-rotational. For rotational 
                            devices, a zero fill will be used (i.e. 
                            'dd if=/dev/zero'). Multiple targets may be 
                            specified each separated by a comma. When multiple 
                            targets are specified, the 'threads' parameter 
                            represents the number of threads per target (i.e. 
                            total threads = # of targets * 'threads'). Multiple 
                            target tests provide aggregate metrics. With the 
                            exception of latency tests, if multiple targets are 
                            specified, they will be tested concurrently. 
                            Sufficient permissions for the device/volume must 
                            exist for the user that initiates testing. Repeat 
                            this argument to specify multiple targets
                            WARNING: If a device is specified (e.g. /dev/sdc),
                            all data on that device will be erased during the 
                            course of testing. All targets must be of the same 
                            type (device or volume). WARNING: if multiple 
                            volume type targets are specified, active range 
                            will be limited to the least amount of free space 
                            on all targets
                            
--target_skip_not_present   If set, targets specified that do not exist will be
                            ignored (so long as at least 1 target exists)

--test                      The SNIA SSS PTS tests to perform. One or more of 
                            the following:
                              iops:       IOPS Test - measures IOPS at a range 
                                          of random block sizes and read/write 
                                          mixes
                              throughput: Throughput Test - measures 128k and 
                                          1m sequential read and write 
                                          throughput (MB/s) in steady state
                              latency:    Latency Test - measures IO response 
                                          times for 3 block sizes (0.5k, 4k and 
                                          8k), and 3 read/write mixes (100/0, 
                                          65/35 and 0/100). If multiple 
                                          'target' devices or volumes are 
                                          specified, latency tests are 
                                          performed sequentially
                              wsat:       Write Saturation Test - measures how 
                                          drives respond to continuous 4k 
                                          random writes over time and total GB 
                                          written (TGBW). NOTE: this 
                                          implementation uses the alternate 
                                          steady state test method (1 minute SS
                                          checks interspersed by 30 minute WSAT
                                          test intervals)
                              hir:        Host Idle Recovery - observes whether 
                                          the devices utilizes background 
                                          garbage collection wherein 
                                          performance increases with the 
                                          introduction of host idle times 
                                          between periods of 4k random writes
                              xsr:        Cross Stimulus Recovery - tests how 
                                          the device handles transitions from 
                                          large block sequential writes to 
                                          small block random writes and back
                                          NOT YET IMPLEMENTED
                              ecw:        Enterprise Composite Workload - 
                                          measures performance in a mixed IO 
                                          environment
                                          NOT YET IMPLEMENTED
                              dirth:      Demand Intensity / Response Time 
                                          Histogram - measures performance 
                                          degradation when a device is subject 
                                          to a super saturating IO load
                                          NOT YET IMPLEMENTED
                            Multiple tests may be specified by repeating this 
                            argument. Default for this parameter is iops. Some 
                            tests like 'hir' are specific to SSD type devices

--threads                   The number of threads to use for the test cycle. 
                            Per the SNIA test specification, this is a user 
                            definable parameter. The default value for this 
                            parameter is the number of CPU cores * 2. This 
                            parameter may contain the token {cpus} which will 
                            be replaced with the number of CPU cores present. 
                            It may also contain a mathematical expression in 
                            conjunction with {cpus} - e.g. {cpus}*2. If 
                            'target' references multiple devices or volumes, 
                            this parameter signifies the number of threads per 
                            device. Thus total threads is # of targets * 
                            'threads'. Latency tests are fixed at 1 thread
                            This parameter is used to define the fio --numjobs
                            argument
                            
--threads_per_target_max    The maximum number of threads per target - default
                            is 8

--timeout                   Max time to permit for testing in seconds. Default 
                            is 24 hours (86400 seconds)
                            
--trim_offset_end           When invoking a blkdiscard TRIM, offset the lenth
                            by this number of bytes

--verbose/-v                Show verbose output - warning: this may produce a 
                            lot of output
                            
--wd_test_duration          The test duration for workload dependent test 
                            iterations in seconds. Default is 60 per the SNIA 
                            test specification
                            
--wkhtml_xvfb               If set, wkhtmlto* commands will be prefixed with 
                            xvfb-run (which is added as a dependency). This is
                            useful when the wkhtml installation does not 
                            support running in headless mode
                            
                            
TEST ARTIFACTS
Upon successful completion of testing, the following artifacts will be 
produced in the working directory ([test] replaced with one of the test 
identifiers - e.g. report-iops.json):

  [test].json        JSON formatted job results for [test]. Each test provides 
                     different result metrics. This file contains a single 
                     level hash of key/value pairs representing these metrics
  fio-[test].json    JSON formatted fio job results for [test]. Jobs are 
                     in run order each with a unique job name. For workload 
                     independent preconditioning, the job name uses the 
                     format 'wipc-N', where N is the preconditioning pass
                     (i.e. N=1 is first pass, N=2 second). Unless 
                     --precondition_passes is otherwise specified, only 2 wipc 
                     JSON files should be present (each representing one of the 
                     2X preconditioning tests). For workload dependent 
                     preconditioning and other testing, the job name is set by
                     the test. For example, for the IOPS test, the job name 
                     format is 'xN-[rw]-[bs]-rand', where N is iteration 
                     number (1-25+), [rw] is the read/write ratio (separated by 
                     underscore) and [bs] is block size. Jobs that fall within
                     the steady state measurement window will have the suffix 
                     '-ssmw' (e.g. x5-0_100-4k-rand-ssmw). there may be up to 
                     10 fio-[test].json corresponding with each of the tests 
                     and 2 files for throughput: test-throughput-128k.json and
                     test-throughput-1024k.json
  report.zip         HTML test report (open index.html). The report design
                     and layout is based on the SNIA test specification. In 
                     addition, this archive contains source gnuplot scripts and 
                     data files for report graphs. Graphs are rendered in svg 
                      format
  report.pdf         PDF version of the test report (wkhtmltopdf used to 
                     generate this version of the report)
                     
                     
USAGE
# perform IOPS test against device /dev/sdc
./run.sh --target=/dev/sdc --test=iops

# perform IOPS, Latency and Throughput tests against /dev/sdc and /dev/sdd 
# concurrently using a maximum of [num CPU cores]*2 and 32 OIO per thread
./run.sh --target=/dev/sdc --target=/dev/sdd --test=iops --test=latency --test=throughput --threads="{cpu}*2" --oio_per_thread=32

# perform IOPS test against device /dev/sdc but skip the purge step
./run.sh --target=/dev/sdc --test=iops --nopurge

# perform IOPS test against device /dev/sdc but skip the purge and workload 
# independent preconditioning
./run.sh --target=/dev/sdc --test=iops --nopurge --noprecondition

# perform 5 iterations of the same IOPS test above
for i in {1..5}; do mkdir -p ~/block-storage-testing/$i; ./run.sh --target=/dev/sdc --test=iops --nopurge --noprecondition --output ~/block-storage-testing/$i; done


EXIT CODES:
  0 block storage testing successful
  1 block storage testing failed

EOF
  exit
elif [ -f "/usr/bin/php" ]; then
  $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/run.php $@
  exit $?
else
  echo "Error: missing dependency php-cli (/usr/bin/php)"
  exit 1
fi
