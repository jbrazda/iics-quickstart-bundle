# Informatica Cloud IPS Baseline Bundle

This project contains set of re-usable IICS Designs SDLC utilities, examples and documentations

<!-- TOC -->

- [Informatica Cloud IPS Baseline Bundle](#informatica-cloud-ips-baseline-bundle)
  - [Provided Assets](#provided-assets)
  - [Before You Start](#before-you-start)
  - [Install The Bundle](#install-the-bundle)
    - [Build from Source](#build-from-source)
    - [Use pre-built binaries](#use-pre-built-binaries)
  - [Configure Individual Components](#configure-individual-components)
  - [Connectors](#connectors)
  - [Processes](#processes)
  - [Glossary of Terms used in this Documents](#glossary-of-terms-used-in-this-documents)

<!-- /TOC -->

## Provided Assets

- [Logging Framework](doc/logging_framework.md)
- [Administration and Development Support Guides](doc/guides.md)
- [Process Templates and Examples](doc/templates.md)
- [Asset Management Scripts](doc/build.md) to export, import, publish and Version Control IPD Designs Implemented as Apache Ant Scripts
- Integration with other SDLC Assisting Tools ([Migration/Transformation Tool](https://github.com/jbrazda/icai-migration-tools), [IICS Reporting Tool](https://github.com/jbrazda/iics-reporting-tools))
- Best practices and Other Integration use case Examples

## Before You Start

- **Read the provided documentation**
- This bundle is continuously developed and improved, feel free to subscribe and monitor updates that might be useful for you in the future
- This bundle is not officially supported by Informatica, please report any issues you find via Github issues report
- Do not or move imported assets Project/ Folder Locations after import, this would make updates much more difficult
- You can update or change imported resources to adjust them for your needs but keep in mind that it would be your responsibility to merge or maintain any changes you have made to provided designs
- Any of the provided assets can significantly re-designed or removed in the future releases

## Install The Bundle

### Build from Source

This should be the preferred method to build this package from source and deploy following a generic guide to use provided [Asset Management Scripts](doc/build.md)

### Use pre-built binaries

Using pre-build packages is easy but has some down-sides such as need to adjust a lot environment specific parameters after import i.e. Deployment targets for Connections and Processes
Use build from source method which allows you to automate these adjustments in bulk using a declarative configuration and set of provided scripts

1. Download pre built Distribution from [Releases]
   1. Use [ICAI-IPS-Bundle_InitialInstall_All_Designs.zip](releases/latest/download/ICAI-IPS-Bundle_InitialInstall_All_Designs.zip) to initial install
   2. Use [ICAI-IPS-Bundle_Update_Excluding_Connections.zip](releases/latest/download/ICAI-IPS-Bundle_Update_Excluding_Connections.zip) to update your Bundle in environments whet it was already installed before
2. Import Distribution Package Bundle
3. Configure, adjust and publish provided designs

## Configure Individual Components

## Connectors

## Processes

## Glossary of Terms used in this Documents

| Term                            | Description                                                                                                                                                        |
|---------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| IICS                            | Informatica Intelligent Cloud Services, Informatica Cloud Integration platform                                                                                     |
| ICAI                            | (formerly ICRT) Informatica Cloud Application Integration, see ICRT                                                                                                |
| ICDI                            | (formerly ICS) Informatica Cloud Data Integration is an ETL batch integration component of IICS platform                                                           |
| BPEL                            | Business Process Execution Language                                                                                                                                |
| BPMN                            | Business Process Modeling Notation                                                                                                                                 |
| WSDL                            | Web Service Definition Language                                                                                                                                    |
| API                             | Application Programming Interface                                                                                                                                  |
| REST                            | REpresentational State Transfer                                                                                                                                    |
| IPD                             | Informatica Process Designer                                                                                                                                       |
| Application Integration Console | ICAI Cloud and Secure Agent Runtime Administration Tool                                                                                                            |
| Informatica Secure Agent        | Informatica Data Integration Execution Agent that Provides ability to integrate data on premise and in the Cloud, hybrid data integration both batch and real time |
| DAS                             | Data Access Service                                                                                                                                                |
| SDLC                            | Software Development Lifecycle                                                                                                                                     |

[alert_service_help]: https://network.informatica.com/onlinehelp/IICS/prod/CAI/en/index.htm#page/cai-aae-monitor/System_Services.html
[development_setup]: https://github.com/jbrazda/Informatica/blob/master/Guides/InformaticaCloud/set_development_environment.md
[iics_cli]: https://network.informatica.com/docs/DOC-18245
[ipd_install_guide]: https://github.com/jbrazda/Informatica/blob/master/Guides/InformaticaCloud/install_process_developer.md
[iics_urn_mappings]: https://network.informatica.com/onlinehelp/IICS/prod/CAI/en/cai-aae-monitor/URN_Mappings.html
