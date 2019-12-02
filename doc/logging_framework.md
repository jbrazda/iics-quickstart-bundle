# IICS Logging Framework

<!-- TOC -->

- [IICS Logging Framework](#iics-logging-framework)
  - [Overview](#overview)
    - [IICS Logging Diagram](#iics-logging-diagram)
    - [Decision Matrix](#decision-matrix)
    - [Data Model](#data-model)
      - [Job Tracking Table - IC_JOB_LOG](#job-tracking-table---ic_job_log)
      - [Event Tracking table – IC_JOB_EVENTS](#event-tracking-table--ic_job_events)
    - [Job Tracking/Logging Bundle DB Setup](#job-trackinglogging-bundle-db-setup)
  - [Use of the Framework](#use-of-the-framework)
    - [Job Input Fields](#job-input-fields)
    - [Execution Context](#execution-context)
    - [Job Temp Fields](#job-temp-fields)
    - [Job Output Fields](#job-output-fields)
    - [Job Process Initialization](#job-process-initialization)

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

### IICS Logging Diagram

![IICS Logging Design](https://www.lucidchart.com/publicSegments/view/459d21e0-5054-4cc1-a496-6b877cfbe108/image.png)

Following this Design patter allows process execution to be easily tracked and monitored outside of runtime environment and improves error handling and speed of development as the components provided with this framework also significantly improve efficiency and ability to test and support implementation. This pattern also allows to build a robust unit and regression testing.

- Trigger - Inbound SOAP or REST message, Scheduled Process, JMS or other events such as a File Listener events
- Job process - records a Job tracking Information, handles subprocess reports, aggregates subprocess results in case of batch list processing, records job final status, records error events in case of unexpected job failure
- Integration Process - Performs actual integration tasks. This process can be composed of many chained processes, sub-processes and records events such as
  - INFO - Start/Finish or milestones
  - WARNING – Non Critical, non interrupting errors
  - ERROR – Critical, interrupting errors

Integration process and its children propagate critical errors upstream and all unexpected interrupting errors are handled by the main Job process
This framework is designed with different options to store the logging and tracking data. It uses simple data model composed of two related objects/entities

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

### Data Model

![SFDC Schema Logging](images/Salesforce_Schema_Builder_Logging.png)

#### Job Tracking Table - IC_JOB_LOG

| Field          | Type                 | Description                                                                                                                             |
| -------------- | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| JOB_ID         | VARCHAR(36) NOT NULL | PK - uuid                                                                                                                               |
| JOB_PROCESS_ID | BIGINT               | Matching main job process ID (this process id is passed down to all sub processes as a parameter to allow tracking and event reporting) |
| JOB_NAME       | VARCHAR(255)         | Job Name, Usually Matches the JOB Process Name                                                                                          |
| START_DATE     | TIMESTAMP(6)         | Start Date                                                                                                                              |
| END_DATE       | TIMESTAMP(6)         | End Date                                                                                                                                |
| STATUS         | SMALLINT             | 1-Running, 2-Failed, 3-Completed                                                                                                        |
| INITIATOR      | VARCHAR(255)         | User Login Id (system user or actual user who started a job)                                                                            |
| ORG_ID         | VARCHAR(32)          | IICS Org ID                                                                                                                             |
| ENVIRONMENT    | VARCHAR(256)         | ICCS Environment (Resolved from URN Mapping )                                                                                           |

#### Event Tracking table – IC_JOB_EVENTS

| Field         | Type                 | Description                                                  |
| ------------- | -------------------- | ------------------------------------------------------------ |
| EVENT_ID      | VARCHAR(36) NOT NULL | PK GUID                                                      |
| JOB_ID        | VARCHAR(36)          | FK Job ID (main Job tracking ID)                             |
| PROCESS_ID    | BIGINT               | Process ID that Generated Event                              |
| PROCESS_NAME  | VARCHAR(256)         | Process Name                                                 |
| PROCESS_TITLE | VARCHAR(256)         | Process Title                                                |
| LOGGING_LEVEL | SMALLINT             | 1=INFO, 2=WARNING, 3=ERROR                                   |
| EVENT_TIME    | TIMESTAMP(6)         | Event Timestamp                                              |
| EVENT_MESSAGE | VARCHAR(1024)        | Event Message                                                |
| EVENT_DETAIL  | TEXT                 | Event Detail                                                 |
| ORG_ID        | VARCHAR(32)          | Org ID                                                       |
| ENVIRONMENT   | VARCHAR(256)         | ICCS Environment (Resolved from URN Mapping )                |
| INITIATOR     | VARCHAR(255)         | User Login Id (system user or actual user who started a job) |

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

The Logging Framework Bundle Provides examples end Templates of the processes.
Most of integration processes will start with some Event as Depicted on [IICS Logging Diagram](#iics-logging-diagram)

Process Can Be started by

- IICS Scheduler
- Inbound Message on Cloud
- Inbound Message on Secure Agent
- JMS Message Listener
- Any of the File based Listeners (File Connector, FTP, AWS S3 Connector)
- Salesforce Eventing

Trigger Process is responsible to capture and react to specified events and start corresponding Job Process.
This process often runs job in asynchronous fashion but in some cases it runs Integration synchronously. 
Synchronous invocation more common for interactive composite services where caller service needs to receive result of event processing in rea-time synchronous pattern.
You should prefer asynchronous behaviors whenever overall response times

Example Event Handler With Asynchronous processing

![Inbound Message Handler](images/Application_Integration_Inbound_Handler.png)

Main job process is responsible to create Job Entry in the Logging DB It also often defines Integration Specific
Inbound Parameters which are typically passed down to Integration (ETL) Sub process. See below image of such Job process.

![Job Process](images/Application_Integration_Job_Process.png)

All processes participation in this execution chain `Trigger > Job > Integration SubProcess` share a set of common input, temporary and output fields

### Job Input Fields

| Field               | Type                        | Description                               |
| ------------------- | --------------------------- | ----------------------------------------- |
| in_context          | $po:ProcessExecutionContext | Execution context Based on Process object |
| in_wait_to_complete | boolean                     | Defines whether the Job should wait for ETL process completion or run asynchronously                                          |

> Note that the Execution Context is used to pass following data to all downstream processes and is dynamically updated and passed down to all child processes in execution chain, 
> Note that there are typically tow context objects (in_context and tmp_context or out_context) tmp/out contexts are passed to child processes.

### Execution Context

This is a process Object Structure containing following fields, which allow us to track all Integration events within execution chain composed of one or many sub-processes against common Job ID

| Field           | Type    | Description                                              |
| --------------- | ------- | -------------------------------------------------------- |
| jobId           | string  | Job ID (GUID)                                            |
| mainProcessId   | integer | Main Process ID (typically Job ID or Trigger process ID) |
| parentProcessId | integer | Parent Process ID                                        |

### Job Temp Fields

| Field                        | Type                         | Description                                                                                                                 |
| ---------------------------- | ---------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| tmp_process_name             | string                       | Must match the actual process Name (it is used to generate process title and must be updated when using a Template process) |
| tmp_process_title            | string                       | Stores generated process Title                                                                                                                            |
| tmp_script_out               | string                       | Temporary output used when updating process Title or other temp outputs                                                                                                                            |
| tmp_CreateJobLogEventRequest | $po:CreateJobLogEventRequest | Used to create Log Events                                                                                                                            |
|                              |                              |                                                                                                                             |

### Job Output Fields

Job always returns out_context (its own execution context which contains process ID, And Job id)

| Field       | Type   | Description                                        |
| ----------- | ------ | -------------------------------------------------- |
| out_context | string |                                                    |
| Other       | Any    | Output parameters are specific to each integration |

### Job Process Initialization

All Job Processes follow the same pattern so minimal changes are required when you use provided Process Tenplate.

TODO -ADD Details

Example Sub-process Fault Event Handling

```xquery
let $detail := $output.faultInfo[1]/detail
let $error_detail := switch (true())
        case ($detail/text()) return $detail/text()
        case ($detail/* instance of element()) return util:toXML($detail)
        default return string($detail)

let $pb_request := $input.in_StatusUpdate
return
<CreateJobLogEventRequest>
   <event_message>Job Fault</event_message>
   <event_time>{current-dateTime()}</event_time>
   <event_detail>Error Code: {$output.faultInfo[1]/code}
Error Reason: {$output.faultInfo[1]/reason}
Error Detail:
{$error_detail}
Request Data:
{ (: it might be useful to print out the input parameters of the process to log details :)
 for $field in $pb_request/*
 return
 concat(local-name($field),':',$field/text(),' ')
}

</event_detail>
   <process_id>{$output.out_context[1]/parentProcessId}</process_id>
   <logging_level>3</logging_level>
   <process_name>{$temp.tmp_process_name }</process_name>
   {$output.out_context }
   <process_title>{$temp.tmp_process_title}</process_title>
</CreateJobLogEventRequest>
```

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
