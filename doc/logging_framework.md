# IICS Logging Framework

<!-- TOC -->

- [IICS Logging Framework](#iics-logging-framework)
  - [Overview](#overview)
    - [Decision Matrix](#decision-matrix)
    - [Job Tracking/Logging Bundle DB Setup](#job-trackinglogging-bundle-db-setup)
  - [Use of the Framework](#use-of-the-framework)

<!-- /TOC -->

## Overview

Common use case while implement event-driven Integrations in IICS is a need to track Integration failures, milestones or other events that happen during Integration process execution.
ICAI does not keep persistent execution log logs for extended period of time so the need to store tracking integration Externally outside of Process engine database.
ICAI typically purges persisted process log information 1 day after completion or after fault.

> Note: We recommend to increase faulted process retention to 7 days with this pattern which allows more time to Support and administrators to diagnose the root cause of potential errors in the execution of integration processes

This project provides a set of pre-built Components allows to Design Integration processes leveraging Informatica Cloud best practices and design patterns.

Integration processes often share same characteristics:

- Processes can be batch or event-driven, near real time integrations.
- Processes can be both Stateful/Stateless (Business Process, Job, Composite Service)
- There might be need for unified external logging (Job Tracking) and error handling
- Integration Process may be composed from multiple steps/suppresses to simplify maintenance and enable re-use, in such case we might need to build layers to provide an end to end transactional tracking system.

The typical CAI integration often composed of several Layers as depicted on the following Image

![IICS Logging Design](https://www.lucidchart.com/publicSegments/view/459d21e0-5054-4cc1-a496-6b877cfbe108/image.png)

Following this Design patter allows process execution to be easily tracked and monitored outside of runtime environment and improves error handling and speed of development as the components provided with this framework also significantly improve efficiency and ability to test and support implementation. This pattern also allows to build a robust unit and regression testing.

- Trigger - Inbound SOAP or REST message, Scheduled Process, JMS or other events such as File Listener events
- Job process - records Job tracking Information, handles subprocess reports, aggregates subprocess results in case of batch list processing, records job final status, records error events in case of unexpected job failure
- Integration Process - Runs actual Integration tasks, This process can be composed of many chained processes, sub-processes and records events such as
    - INFO - Start/Finish or milestones
    - WARNING – Non Critical, non interrupting errors
    - ERROR – Critical, interrupting errors

Integration process and its children propagate critical errors upstream and all unexpected interrupting errors are handled by the main Job process
This framework is designed with different options to store the logging and tracking data. It uses simple data model composed of two related objects/entities

- Job Tracking Table - IC_JOB_LOG
- Event Tracking table – IC_JOB_EVENTS

Framework can be  used with any relational Database and Salesforce as backend store for log entries. It currently provides a support for following back-ends

- MySQL
- MS SQL Server
- Oracle
- PostgreSQL
- Salesforce

### Decision Matrix

| Use SFDC when                                        | Use RDBMS When                                                                       |
|------------------------------------------------------|--------------------------------------------------------------------------------------|
| Salesforce is one of the Integrated Systems          | Salesforce is not an option or used by the organization                              |
| Relatively low volumes of jobs or transactions       | High Volume of logging data would be prohibitively expensive on SFDC                 |
| Want to keep all log information in the Cloud        | Risk of exceeding API limits on SFDC APIs                                            |
| Salesforce would be a primary UI to inspect log data | Prefer to store data on premise or Cloud DB hosted at same location as secure agents |
|                                                      | Already have existing Staging DB used by Secure agents or other integrations         |

### Job Tracking/Logging Bundle DB Setup

Framework provides ICAI Guide and Process which can automate DB Configuration

You Can Can also setup DB Manually or you need request DBA to create manage DB schema for yo, use Following links to retrieve DDL/SQL examples to create/manage DB Schema for corresponding DB
Following Table also provides links to pre-defined Informatica Data Access Service Request example to manage database Schema via DAS Service

| Database                 | MSSQL                    | MySQL                    | PostgreSQL                 | Oracle                    |
| ------------------------ | ------------------------ | ------------------------ | -------------------------- | ------------------------- |
| DDL                      | [View][ddl_MSSQL]        | [View][ddl_Mysql]        | [View][ddl_Postgre]        | [View][ddl_Oracle]        |
| Create Schema DAS Script | [View][das_create_MSSQL] | [View][das_create_Mysql] | [View][das_create_Postgre] | [View][das_create_Oracle] |
| Reset Schema DAS Script  | [View][das_reset_MSSQL]  | [View][das_reset_Mysql]  | [View][das_reset_Postgre]  | [View][das_reset_Oracle]  |

## Use of the Framework

TBD

[ddl_MSSQL]: https://gist.githubusercontent.com/jbrazda/8e0be794bebf57965b4b810ee4ee1c67/raw/IICS_Logging_MSSQL.sql
[ddl_Mysql]: https://gist.githubusercontent.com/jbrazda/8e0be794bebf57965b4b810ee4ee1c67/raw/IICS_Logging_MySQL.sql
[ddl_Postgre]: https://gist.githubusercontent.com/jbrazda/8e0be794bebf57965b4b810ee4ee1c67/raw/IICS_Logging_PostgreSQL.sql
[ddl_Oracle]: https://gist.githubusercontent.com/jbrazda/8e0be794bebf57965b4b810ee4ee1c67/raw/IICS_Logging_Oracle.sql
[das_create_MSSQL]: https://gist.githubusercontent.com/jbrazda/a50b178232eb3d43ec3ca1e117e09cdf/raw/IICS_Logging_MDAS_CreateSchema_MSSQL.xml
[das_create_Mysql]: https://gist.githubusercontent.com/jbrazda/a50b178232eb3d43ec3ca1e117e09cdf/raw/IICS_Logging_MDAS_CreateSchema_MySQL.xml
[das_create_Postgre]: https://gist.githubusercontent.com/jbrazda/a50b178232eb3d43ec3ca1e117e09cdf/raw/IICS_Logging_MDAS_CreateSchema_PostgreSQL.xml
[das_create_Oracle]: https://gist.githubusercontent.com/jbrazda/a50b178232eb3d43ec3ca1e117e09cdf/raw/IICS_Logging_MDAS_CreateSchema_Oracle.xml
[das_reset_MSSQL]: https://gist.githubusercontent.com/jbrazda/a50b178232eb3d43ec3ca1e117e09cdf/raw/IICS_Logging_MDAS_ResetSchema_MSSQL.xml
[das_reset_Mysql]: https://gist.githubusercontent.com/jbrazda/a50b178232eb3d43ec3ca1e117e09cdf/raw/IICS_Logging_MDAS_ResetSchema_MySQL.xml
[das_reset_Postgre]: https://gist.githubusercontent.com/jbrazda/a50b178232eb3d43ec3ca1e117e09cdf/raw/IICS_Logging_MDAS_ResetSchema_PostgreSQL.xml
[das_reset_Oracle]: https://gist.githubusercontent.com/jbrazda/a50b178232eb3d43ec3ca1e117e09cdf/raw/IICS_Logging_MDAS_ResetSchema_Oracle.xml
