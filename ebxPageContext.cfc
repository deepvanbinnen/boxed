<!---
Copyright 2009 Bharat Deepak Bhikharie

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->

<!--- Added extends cfc.commons.AbstractObject --->
<!---
Filename: ebxPageContext.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->
<cfcomponent extends="AbstractEBXParser" displayname="ebxPageContext" hint="I handle inclusion of templates and retrieve or assign variables">

	<!--- <cffunction name="StructCreate" returnType="struct" output="false">
		<cfreturn arguments>
	</cffunction> --->

	<cffunction name="ebx_include" returntype="struct" hint="include template in the page">
		<cfargument name="template" required="true" type="string" hint="full mapping path to the include file">

		<cfset var lcl = StructNew()>
		<cfset lcl.template = arguments.template>
		<cfset lcl.output   = "">
		<cfset lcl.errors   = false>
		<cfset lcl.caught   = "">

		<cfif NOT ListFind( "cfm,js,css", ListLast(arguments.template, ".") )>
			<cfset lcl.template = lcl.template & ".cfm">
		</cfif>
		<cftry>
			<cfsavecontent variable="lcl.output">
				<cftry>
					<cfinclude template="#lcl.template#">
					<!--- <cfoutput><!-- DEBUG: #arguments.template# --></cfoutput> --->
					<cfcatch type="any">
						<cfset lcl.output = cfcatch.message & CHR(10) & cfcatch.detail>
						<cfset lcl.errors = true>
						<cfset lcl.caught = cfcatch>
					</cfcatch>
				</cftry>
			</cfsavecontent>
			<cfset lcl.output = TRIM(lcl.output)>
			<cfcatch type="any">
				<cfif NOT lcl.errors>
					<cfset lcl.output = cfcatch.message & CHR(10) & cfcatch.detail>
					<cfset lcl.errors = true>
					<cfset lcl.caught = cfcatch>
				</cfif>
			</cfcatch>
		</cftry>

		<cfreturn lcl />
	</cffunction>

	<cffunction name="ebx_write" returntype="ebxPageContext" hint="write output to the page">
		<cfargument name="output" required="true" type="string" hint="the output to write">

			<cfset writeOutput(arguments.output)>

		<cfreturn this>
	</cffunction>

	<cffunction name="ebx_unset" returntype="any" hint="unset variable in the page">
		<cfargument name="name"      type="string"  required="true" hint="variable name">

		<cfset var lcal = StructCreate(
			  scopedNames = iterator( ListToArray(arguments.name, ".") )
			, curscope    = variables
			, found       = StructCreate()
		) />

		<cfloop condition="#lcal.scopedNames.whileHasNext()#">
			<cfif StructKeyExists(lcal.curscope, lcal.scopedNames.getCurrent())>
				<cfif lcal.scopedNames.getIndex() eq lcal.scopedNames.getLength()>
					<cfset StructDelete(lcal.curscope, lcal.scopedNames.getCurrent())>
				<cfelse>
					<cfset lcal.curscope = lcal.curscope[lcal.scopedNames.getCurrent()]>
					<cfif NOT IsStruct(lcal.curscope)>
						<cfbreak />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn this />
	</cffunction>


	<cffunction name="ebx_put" returntype="ebxPageContext" hint="set variable in the page">
		<cfargument name="name"      type="string"  required="true" hint="variable name">
		<cfargument name="value"     type="any"     required="true" hint="variable value">

			<cfset SetVariable(arguments.name, arguments.value)>

		<cfreturn this>
	</cffunction>

	<cffunction name="ebx_get" returntype="any" hint="get variable in the page">
		<cfargument name="name"      type="string"  required="true"  hint="variable name">
		<cfargument name="value"     type="any"     required="false" default="" hint="value if variable isn't defined. Does not actually set the variable!">

		<cfif IsDefined(arguments.name)>
			<cfif IsDefined("GetVariable")>
				<!--- OpenBD 1.1 --->
				<cfreturn GetVariable(arguments.name)>
			<cfelse>
				<cfreturn Evaluate(arguments.name)>
			</cfif>
		</cfif>

		<cfreturn arguments.value>
	</cffunction>
</cfcomponent>