module namespace util = 'urn:activevos:spi:functions:utilities';



declare function util:getAssetName () as item() {
    'Asset_Name'
};

declare function util:toXML($xml) as item()? {
    let $serialization-params := <xsl:output 
                                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                xmlns:saxon="http://saxon.sf.net/"
                                method="xml"
                                omit-xml-declaration="yes"
                                indent="yes"
                                saxon:indent-spaces="4"/>
   return
   saxon:serialize($xml,$serialization-params)
};
