xquery version "3.0" ;
declare namespace saxon = "http://saxon.sf.net/";

import module namespace util = "urn:activevos:spi:functions:utilities" at "iics-util-mockup.xq";


declare option saxon:output "indent=yes";
declare option saxon:output "saxon:indent-spaces=4";
declare option saxon:output "omit-xml-declaration=yes";

(:Proccess Variables:)
let $input := doc('../../sample-data/email-alerts/input.xml')/*/.
let $temp := doc('../../sample-data/email-alerts/temp.xml')/*/.
let $output := doc('../../sample-data/email-alerts/output.xml')/*/.

(:Input Fields:)
let $input.in_parameters       := $temp/*:params[@name="in_parameters"]/*
(:Temp fields:)
let $temp.tmp_base_uri         := $temp/*:field[@name="tmp_base_uri"]/text()
let $temp.tmp_org_id           := $temp/*:field[@name="tmp_org_id"]/text()
let $temp.tmp_environment_name := $temp/*:field[@name="tmp_environment_name"]/text()
let $temp.tmp_process_name     := $temp/*:field[@name="tmp_process_name"]/text()
let $temp.tmp_context          := $temp/*:field[@name="tmp_context"]/*

(:Output Fields:)
let $output.faultInfo          := $output/*:field[@name="faultInfo"]/*


(:Expression Starts here:)

let $context      := $temp.tmp_context 
let $current-time := current-date()
let $date_format  := "[Y0001]-[M01]-[D01] [H01]:[m01]:[s01]"

let $org_id       := $context/orgId/text()
let $environment  := $context/environmentName/text() 
let $base_uri     := $context/baseURI/text() 
let $processId    := $context/parentProcessId/text()
let $processName  := $temp.tmp_process_name
let $recipients   := distinct-values(tokenize($input.in_parameters/alertEmailRecipents/text(), ','))

(:trying to parse fault details if XML and pretty print:)
let $serialization-params := <xsl:output 
                                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                xmlns:saxon="http://saxon.sf.net/"
                                method="xml"
                                omit-xml-declaration="yes"
                                indent="yes"
                                saxon:indent-spaces="4"/>
                                
let $view_url :=  if (contains($environment, "Cloud"))
    then concat($base_uri,"/activevos-central/projres/apps/app-integration/integrationConsole/index.html#/main/processinstance/",$processId,"/",$processName,"-",$processId,"%7B%7D")
    else concat($base_uri,"/activevos-central/projres/apps/app-integration/integrationConsole/index.html#/main/processinstance/",$processId,"/",$processName,"-",$processId,"%7B",$environment,"%7D")
    
let $faultInfo := $output.faultInfo 

let $detail := $faultInfo/detail/*
let $reason := $faultInfo/reason/*

let $faultDetail := switch (true())
                       case ($detail instance of element()) return 
                            try { saxon:serialize($detail,$serialization-params )
                            } catch * {
                              string($detail)
                            } 
                       case (not(empty($faultInfo/detail/text()))) return 
                            try { saxon:serialize(fn:parse-xml(string($faultInfo/detail/text())),$serialization-params )
                            } catch * {
                              $faultInfo/detail/text()
                            }
                       default return ()

let $faultReason := switch (true())
                       case ($reason instance of element()) return 
                            try { saxon:serialize($reason,$serialization-params )
                            } catch * {
                              string($reason)
                            } 
                       case (not(empty($faultInfo/reason/text()))) return 
                            try { saxon:serialize(fn:parse-xml(string($faultInfo/reason/text())),$serialization-params )
                            } catch * {
                              $faultInfo/reason/text()
                            }
                       default return $faultInfo/reason/text()   

let $email_body :=
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="Generator" content="Informatica Cloud" />
        <title>Integration Job Notification</title>
        <style type="text/css" media="screen">

            body {{
                font-size: 12px;
                font-family: arial, sans-serif;
                width: 100% !important;
                -webkit-text-size-adjust: 100%;
                -ms-text-size-adjust: 100%;
                margin: 0;
                padding: 0;
            }}
            
            /* Prevent Webkit and Windows Mobile platforms from changing default font sizes, while not breaking desktop design. */
            .ExternalClass {{
                width: 100%;
            }}
            
            /* Force Hotmail to display emails at full width */
            .ExternalClass,.ExternalClass p,.ExternalClass span,.ExternalClass font,.ExternalClass td,.ExternalClass div
                {{
                line-height: 100%;
            }}
            /* Force Hotmail to display normal line spacing.  More on that: http://www.emailonacid.com/forum/viewthread/43/ */
            #backgroundTable {{
                margin: 0;
                padding: 0;
                width: 100% !important;
                line-height: 100% !important;
            }}
            
            p {{
                font-size: 12px;
                font-family: inherit;
            }}
            
            ul {{
                list-style-type: disc;
            }}
            
            li {{
                font-size: 12px;
                font-family: arial, sans-serif;
            }}
            
            table{{
               table-layout: fixed;
               width: 100%;
            }}
            
            table td {{
                border-collapse: collapse;
                font-size: 12px;
                background-color: inherit;
                color: inherit;
                padding: 5px !important;
            }}
            
            td.center {{
                text-align: center;
                white-space: nowrap;
            }}
            

            
            table th {{
                font-size: 12px;
                font-weight: bold;
                background-color: #ddd;
                text-align: left;
            }}
        
            .content table, .content th, .content td {{
              border: 1px solid black;
              border-collapse: collapse;
            }}
    </style>
       
    </head>
    <body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background: #E4E4E4;" >
    <table id="backgroundTable" align="center"  role="presentation" cellspacing="0" cellpadding="0" border="0"
        style="width: 100%; background: #FFFFFF; border: 12px solid #FFFFFF; width: 90%; border-collapse: collapse; padding: 10px; font-size: 10pt; font-family: Arial, sans-serif;">
        <tr style="background: #00558c; color: #FFFFFF;">
            <td style="padding: 8px; padding-left: 12px; color: #FFFFFF;"><b>IICS - Fault Alert Notification</b></td>
            <td style="padding: 8px; padding-right: 12px; text-align: right; color: #FFFFFF;"><b><i>Org:{$org_id} Env:{$environment}</i></b></td>
        </tr>
        <tr>
            <td colspan="2"
                style="padding: 0px; padding-top: 10px; background: #FFFFFF; font-size: 10pt;">
                <table id="messageTable"
                    align="center"
                    style="padding: 0px; border: 0px; width: 100%; background: #F4F4F4; color: #2F2F2F; font-size: 10pt; font-family: Arial, sans-serif;">
                    <tr>
                        <td style="padding: 2em">

                            <h2>Unexpected Process Error</h2>                            
                            <p style="padding-bottom: 5px; font-size: 12pt; font-family: Arial, sans-serif;">Error in {$temp.tmp_process_name} Process ID [<a href="{$view_url}">{$processId}</a>] Job ID: {$context/jobId/text()}</p>
                            
                            
                            <h2>Error Information</h2>
                            <table id="AlertTable" class="content" style="border-collapse: collapse; width: unset;" align="left">
                                <tr >
                                    <td style="width: 150px">Process Id</td>
                                    <td><a href="{$view_url}">{$processId}</a></td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Process Name</td>
                                    <td>{$processName}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Error Time</td>
                                    <td>{fn:format-dateTime(current-dateTime(),$date_format)}</td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Error Code</td>
                                    <td><pre style="margin: 0px">{$faultInfo/code/text()}</pre></td>
                                </tr>
                                <tr>
                                    <td style="width: 150px">Error Reason</td>
                                    <td><pre style="margin: 0px">{$faultReason}</pre></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    {
                    if (empty($faultDetail)) then () else
                    <tr style="padding: 2em" >
                        <td>
                            <h2>Fault Detail</h2>
                            <pre style="border: 1px; padding: 1em; border-color: black; border-style: solid;">
                            {$faultDetail}
                            </pre>
                        </td>
                    </tr>
                    } 
                </table>
            </td>
        </tr>
    </table>
    </body>
</html>

return
$email_body
(:
<EmailTaskInput>
   {
   for $recipient in $recipients
   return
   <to>{$recipient}</to>
   }
   <subject>Error in {util:getAssetName()} on {$environment}</subject>
   <contentType>text/html</contentType>
   <body>{util:toXML($email_body)}</body>
</EmailTaskInput>
:)
