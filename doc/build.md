# Automation to Build and Deploy IICS Design Packages


This package contains [Apache Ant Script](../build.xml) to maintain the sources in VCS Repository, build and deploy to target IICS environments

## Pre-Requisites

It is highly recommend to use the build from source as it allows you to change certain attributes of service deployment such as target Secure agent group, etc.
To build and install from source, you'll need a following set of tools

- git client installed on your system
- Java 1.8 or higher installed on the System
- [Apache Ant](https://ant.apache.org/) 1.9 or higher installed on the system or use Informatica Process Developer which includes Ant runtime
- Informatica Process Developer (Highly Recommended but optional) See [Installation Guide](https://github.com/jbrazda/Informatica/blob/master/Guides/InformaticaCloud/install_process_developer.md)

## Inspect and adjust Main build.properties configuration file

Main configuration file defines key modules locations and enables/disables supporting Tools maintained externally as a dependency.

Example main Configuration file (build.properties) 

```properties
# lib path
tools.lib=${basedir}/target/lib

#IICS Asset Management CLI
# See https://network.informatica.com/docs/DOC-18245
tools.iics.mac=${tools.lib}/iics
tools.iics.linux=${tools.lib}/iics
tools.iics.win.x86=${tools.lib}/iics.exe
tools.iics.win.amd64=${tools.lib}/iics.exe

## url.download.iics - OS Specific URL
url.download.iics.mac=https://github.com/InformaticaCloudApplicationIntegration/Tools/raw/master/IICS%20Asset%20Management%20CLI/v2/mac-x86_64/iics
url.download.iics.win=https://github.com/InformaticaCloudApplicationIntegration/Tools/raw/master/IICS%20Asset%20Management%20CLI/v2/win-x86_64/iics.exe
url.download.iics.win.x86=https://github.com/InformaticaCloudApplicationIntegration/Tools/raw/master/IICS%20Asset%20Management%20CLI/v2/win-i386/iics.exe
url.download.iics.linux=https://github.com/InformaticaCloudApplicationIntegration/Tools/raw/master/IICS%20Asset%20Management%20CLI/v2/linux-x86_64/iics

## URLs to Download IICS Migration and Reporting Tools Modules
url.download.iics.tools.transform.archive=icai_migration_tools.zip
url.download.iics.tools.transform=https://raw.githubusercontent.com/jbrazda/icai-migration-tools/master/dist/${url.download.iics.tools.transform.archive}
url.download.iics.tools.reporting.archive=v1.1.zip
url.download.iics.tools.reporting=https://github.com/jbrazda/iics-reporting-tools/archive/${url.download.iics.tools.reporting.archive}

## Directories for IICS Tools Module Installations
iics.tools.dir.reporting=${tools.lib}/reporting
iics.tools.dir.transform=${tools.lib}/transform

## Defines directory used for Downloads
tools.download.dir=${user.home}/Downloads

## IICS Script tool Modules
tools.package.transform=${iics.tools.dir.transform}/build.xml
tools.package.reporting=${iics.tools.dir.reporting}/build.xml

#Disable Use of Individual Modules
tools.reporting.disabled=false
tools.transform.disabled=false

## Configure your IICS org region. For example, us, eu, ap
iics.region=us

## Directory to generate IPD Distribution packages
iics.binaries.dir=${basedir}/target/dist
```

## Configure credentials file

Example file is listed below.
recommended location is your home directory/iics `~/iics/environment.properties` as it will contain sensitive information.
I would also recommend to create Native IICS Service user in each of your orgs that can be used to export/import resources via IICS REST API using the [IICS Asset Management CLI][iics_cli]
This tool will automatically download latest version an use it to import provided service to your target org

```properties
# This file should contain properties for Each environment
# defined in the associated release properties file property iics.environment.list
#  
# DEV Environment Credentials
iics.user.dev=deployer-iics-dev@acme.com
iics.password.dev=SET_PASSWORD

# TEST Environment Credentials
iics.user.test=deployer-iics-test@acme.com
iics.password.test=SET_PASSWORD

# PROD Environment Credentials
iics.user.prod=deployer-iics-prod@informatica.com
iics.password.prod=SET_PASSWORD
```

> WARNING Never put these properties into the project folder and keep this property file in a secure location ideally  `~/iics/environment.properties` The `~/iics` folder should be accessible only by user running the import/export/publish tasks (use '700' permission on unix systems)

Update existing or copy [conf/iclab-dev.release.properties](conf/iclab-dev.release.properties) file which defines a key Environment specific parameters

```properties
# define a comma separated list of environment org labels such as 
# dev,test,uat,prod
iics.environment.list=dev,test,prod

# This property points to file which contains credentials to login to individual environments
# and other environment Specific properties
# we recommend to use ${user.home}/iics protected directory
# never commit this file to version control with this project as it contains credentials to your IICS Orgs
# the iics.external.properties must contain set of properties 
# following this naming convention for each environment defined in the iics.environment.list
# iics.user.${environment}=
# iics.password.${environment}=
# iics.transform.properties.${environment}=
iics.external.properties.dir=${user.home}/iics
iics.external.properties=${iics.external.properties.dir}/iclab.properties

# this query is used by iics list command to retrieve available sources from repository 
# to extract the designs from IICS
# see https://network.informatica.com/docs/DOC-18245#jive_content_id_List_Command
iics.query=-q "location==Alerting"

# Defines the output file for the list command 
# the output location will be driven by the following expression
# ${basedir}/target/${selected.release.basename}/export/${iics.source.environment}/${iics.list.output}
iics.list.output=export_list.txt

# Defines the output file name for iics export command
# the output location will be driven by the 
# ${basedir}/target/${selected.release.basename}/export/${iics.source.environment}/${iics.export.output}
iics.export.output=FaultAlertService.zip

# Defines Output File name without extension
# the package.src will produce file in the location based on following expression
# ${iics.package.output}_${iics.release.basename}_${iics.target.package.config.basename}.zip
iics.package.output=FaultAlertService

# Defines Extract output directory for iics extract command
iics.extract.dir=${basedir}/src/ipd

# Defines transform directory used to copy sources from iics.extract.dir to allow pre-processing and source transformations before package.src target is called
transform.src.folder=${basedir}/target/transform/src
# Defines temporary folder used by transformation pre-processing steps such as set suspend on fault
transform.temp.folder=${basedir}/target/transform/temp
```

### Transformation Properties

Often some on-the-fly Design transformations may be desired to simplify deployment steps and automate some migration changes to deployed designs
These include following types of changes

- Migrate process from Cloud to specific Secure Agent or Agent Group
- Migrate process from Agent to Cloud
- Set Process Tracing levels
- Set Process Suspend on Fault

This set of build scripts contains optional Scripts Module Which contains set of xslt scripts which can be applied to selected designs before packaging and deployment/import to target org
This module is maintained in a separate github project [icai-migration-tools](https://github.com/jbrazda/icai-migration-tools) Script will automatically download migration tools and run the transformations steps.

When you want to use this optional step of build and deployment you will need to specify `transform.properties` which configures which transformation steps will be executed on specified design objects

#### Example Transformation Properties File

```properties
# MOVE Process to Cloud
# ---------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.to.cloud.enabled=false
# use this property to include specific processes or use Ant pattern expressions.
# migrate.processObjects.enabled=true is set
ipd.migrate.processes.to.cloud.include=*.PROCESS.xml
# you can exclude specified files from tar
ipd.migrate.processes.to.cloud.exclude=*-1.PROCESS.xml


# MOVE Processes to Agent
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.to.agent.enabled=true
# specify target Agent Name or Agent Group Name to Migrate to
ipd.migrate.processes.to.agent.name=DEMO
# Use this property to include specific processes or use Ant pattern expressions.
# This property is required when migrate.processObjects.enabled=true is set
# ipd.migrate.processes.to.agent.include=Explore/Tools/Processes/SP-Shell-CMD.PROCESS.xml
ipd.migrate.processes.to.agent.include=**/*NA.PROCESS.xml
# you can exclude specified files from migration
ipd.migrate.processes.to.agent.exclude=**/SCH-*.PROCESS.xml


# SET Process Tracing Levels
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.tracingLevelUpdate.enabled=true

# List of tracing levels to be processed
# this is an example to process all levels when you want to set levels on any selected processes
# ipd.migrate.processes.tracingLevelUpdate.levels=none,terse,normal,verbose
# note that each supported tracing level must have incudes/excludes defined
# Following example setting will set  all processes tracing level to None
ipd.migrate.processes.tracingLevelUpdate.levels=verbose

# Includes Excludes for each level
# Use this property to include specific processes to get their Logging levels updated 
# Use relative path reference starting from $basedir or use Ant pattern expressions.
# This property is required when migrate.processObjects.enabled=true is set

ipd.migrate.processes.tracingLevelUpdate.none.includes=**/*.PROCESS.xml
ipd.migrate.processes.tracingLevelUpdate.none.excludes=

ipd.migrate.processes.tracingLevelUpdate.terse.includes=nothing
ipd.migrate.processes.tracingLevelUpdate.terse.excludes=**/*.xml

ipd.migrate.processes.tracingLevelUpdate.normal.includes=nothing
ipd.migrate.processes.tracingLevelUpdate.normal.excludes=**/*.xml

ipd.migrate.processes.tracingLevelUpdate.verbose.includes=**/*.PROCESS.xml
ipd.migrate.processes.tracingLevelUpdate.verbose.excludes=nothing


# SET Process Suspend On fault
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.tracingLevelUpdate.execute=false

#includes/excludes for processes to enable suspendOnFault
ipd.migrate.processes.suspendOnFault.true.execute=true
ipd.migrate.processes.suspendOnFault.true.includes=**/*.PROCESS.xml
ipd.migrate.processes.suspendOnFault.true.excludes=
 
#includes/excludes for processes to disable suspendOnFault
ipd.migrate.processes.suspendOnFault.false.execute=true
ipd.migrate.processes.suspendOnFault.false.includes=none
ipd.migrate.processes.suspendOnFault.false.excludes=**/*.PROCESS.xml

#remove Specific tags based on pattern
ipd.migrate.removeTags=false
ipd.tags.remove.include=**/*.xml
ipd.tags.remove.exclude=
ipd.tags.remove.tagMatchPattern=(,)?(GIT:\w+)

```

#### Main Ant Script Properties

#### Ant Build Script

This tool uses ant to build/ download and deploy IICS package
Following is a list of available targets which you can retrieve by running `ant -projecthelp` in the root of this repository

```text
ant -projecthelp
Buildfile: /Users/jbrazda/git/icai-fault-alert-service/build.xml

            IICS CAI Component Build Script

Main targets:

 clean.release  Deletes Export/import temporary files in ${basedir}/target/${iics.release.basename}
 download.src   Downloads Designs From Source Environment Org using iics Export utility
 help           help - describes how to use this script
 import         Imports package for a select Environment and Package Configuration
 package.src    Builds Package for specified target environment from ${basedir}/src/ipd
 publish        Publishes Objects Defined in the Configuration Files
 update.src     Updates design sources directory for a Source Environment Org using iics Export/Extract utility
Default target: help
```

### Build Package From Source

#### In Process Developer

Open new empty Eclipse Workspace in `{USER_HOME}/workspace/icai-fault-alert-service`
Switch to Process Developer Perspective

![Eclipse_PD_Perspective](./images/Eclipse_PD_Perspective.png)

Import Cloned repository project as an existing project (assuming you cloned the project to your {USER_HOME}/git folder)

![Eclipse_Import_Existing](./images/Eclipse_Import_Existing.png)

Select Your Exported Git Repo root  folder and finish import

![Eclipse_Import_Project](./images/Eclipse_Import_Project.png)

Open the Ant View using `Window > Show View > Other`

![Open Ant View](./images/IPD_Show_View_Other.png)

Reposition Ant View to a tab below Project Explorer and drag build.xml to Ant runner View

![Eclipse_Ant_Build](./images/Eclipse_Ant_Build.png)

Run The package.src Target, Select the Release configuration from conf directory and Confirm

![Ant_Package_Input_Release_Config](./images/Ant_Package_Input_Release_Config.png)

Select target Environment

![Ant_Package_Input_Environment](./images/Ant_Package_Input_Environment.png)

Select Package Configuration. This step allows to select configuration file that drives what's included/excluded  in the target deployment package.
Use the `all_designs.package.txt` for initial import only (it includes connections and connectors)
Use the `all_exclude_connections.package.txt` for Subsequent builds and updates (it excludes connections and connectors)

![Ant_Package_Input_PackageConf](./images/Ant_Package_Input_PackageConf.png)

Script will generate Package using an iics tool downloaded from GitHub into a folder
defined by following expression `${iics.package.output}_${iics.release.basename}_${iics.target.package.config.basename}.zip`

Import package using an `import` target of ant script

Publish imported resources using a `publish` target of ant script

#### Example package.src Script output

Command

```shell
ant package.src \
-Diics.release=./conf/iclab-dev.release.properties \
-Diics.target.environment=dev \
-Diics.target.package.config=./conf/all_designs.package.txt \
-Dselected.transform.properties=/Users/jbrazda/iics/AlertServices_iclab_dev.transform.properties
```

See [Example Output](example_package.src_output.txt)

## Build Using Command Line

You can run the same as in eclipse from command line using a following commands
(this is personally my preferred method)

Build a full package, DEV Environment Target

```shell
ant package.src \
-Diics.release=./conf/iclab-dev.release.properties \
-Diics.target.environment=dev \
-Diics.target.package.config=./conf/all_designs.package.txt \
-Dselected.transform.properties=/Users/jbrazda/iics/AlertServices_iclab_dev.transform.properties
```

Build a Package without Connections DEV Target

```shell
ant package.src \
-Diics.release=./conf/iclab-dev.release.properties \
-Diics.target.environment=dev \
-Diics.target.package.config=./conf/all_exclude_connections.package.txt
-Dselected.transform.properties=/Users/jbrazda/iics/AlertServices_iclab_dev.transform.properties
```

Import Package to test environment

```shell
ant import \
-Diics.release=./conf/iclab-dev.release.properties \
-Diics.target.environment=test \
-Diics.target.package.config=./conf/all_exclude_connections.package.txt
```

Publish Imported Assets

```shell
ant publish \
-Diics.release=./conf/iclab-dev.release.properties \
-Diics.target.environment=test \
-Diics.target.publish.config=./conf/all_designs.publish.txt
```

[alert_service_help]: https://network.informatica.com/onlinehelp/IICS/prod/CAI/en/index.htm#page/cai-aae-monitor/System_Services.html
[development_setup]: https://github.com/jbrazda/Informatica/blob/master/Guides/InformaticaCloud/set_development_environment.md
[iics_cli]: https://network.informatica.com/docs/DOC-18245
[ipd_install_guide]: https://github.com/jbrazda/Informatica/blob/master/Guides/InformaticaCloud/install_process_developer.md
[iics_urn_mappings]: https://network.informatica.com/onlinehelp/IICS/prod/CAI/en/cai-aae-monitor/URN_Mappings.html