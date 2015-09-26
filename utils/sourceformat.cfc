<cfcomponent name="SourceFormatter" output="false">
    
    <cffunction name="init" access="remote" returntype="sourceformat">
        <cfreturn this>
    </cffunction>
    
    <cffunction name="freeTheSource" output="No">
    	<cfargument name="instring" type="string" default="">
            <cfset var outString = arguments.instring>
            <cfset re = '[\s]+[\r\n]'>
            <cfset outString  = REReplace(outString,re,chr(10),'ALL')>
            <cfset re = '[\s]+[\n]'>
            <cfset outString  = REReplace(outString,re,chr(10),'ALL')>
            <cfset re = '[\t]+[\r\n]'>
            <cfset outString  = REReplace(outString,re,chr(10),'ALL')>
            <cfset re ='[\t]+[\n]'>
            <cfset outString  = REReplace(outString,re,chr(10),'ALL')>
        	<cfset re='[\r\n]+'>
            <cfset outString  = REReplace(outString,re,chr(10),'ALL')>
            <cfset re='[\n]+'>
            <cfset outString  = REReplace(outString,re,chr(10),'ALL')>
    	<cfreturn TRIM(outString)>
    </cffunction>
    
    <cffunction name="squeezeTheSource" output="No">
        <cfargument name="instring" type="string" default="">
            <cfset var outString = freeTheSource(arguments.instring)>
            <cfset re='[\t]+'>
            <cfset outString = REReplace(outString,re,'','ALL')>
            <cfset re='[\n]'>
            <cfset outString = REReplace(outString,re,'','ALL')>
        <cfreturn TRIM(outString)>
    </cffunction>
    
    <cffunction name="replaceBR" access="remote" returntype="string" output="no" hint="Functie voor het vervangen van line-breaks door '<br />' in textarea's">
    	<cfargument name="instring">
    	    <cfset var outString = arguments.instring>
            <cfset outString = replace(outString,chr(10),"<br />","ALL")>
    	<cfreturn TRIM(outString)>
    </cffunction>
</cfcomponent>