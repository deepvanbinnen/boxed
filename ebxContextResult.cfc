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
<!---
Filename: ebxContextResult.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->
<cfcomponent hint="I am a value object representing a context-result message">
	<cfset variables.output = "">
	<cfset variables.caught = StructNew()>
	<cfset variables.errors = false>

	<cffunction name="getResult" returntype="struct" hint="get result struct">
		<cfset var local = StructNew()>

		<cfset StructInsert(local, "output", getOutput())>
		<cfset StructInsert(local, "errors", getErrors())>
		<cfset StructInsert(local, "caught", getCaught())>

		<cfreturn local>
	</cffunction>

	<cffunction name="setResult" returntype="ebxContextResult" hint="update instance from result struct, return instance">
		<cfargument name="result" type="struct"  required="true" hint="result message">

		<cfif StructKeyExists(arguments.result, "output")>
			<cfset setOutput(arguments.result.output)>
		</cfif>

		<cfif StructKeyExists(arguments.result, "errors")>
			<cfset setErrors(arguments.result.errors)>
		</cfif>

		<cfif StructKeyExists(arguments.result, "caught")>
			<cfset setCaught(arguments.result.caught)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="getOutput" returntype="string" hint="get result output">
		<cfreturn variables.output>
	</cffunction>

	<cffunction name="getCaught" returntype="any" hint="get cfcatch from result">
		<cfreturn variables.caught>
	</cffunction>

	<cffunction name="getErrors" returntype="string" hint="get result's errorflag">
		<cfreturn variables.errors>
	</cffunction>

	<cffunction name="hasErrors" returntype="string" hint="check for errors">
		<cfreturn getErrors()>
	</cffunction>

	<cffunction name="setOutput" returntype="any" hint="set instance output, return instance">
		<cfargument name="output" type="string" required="true" hint="result output">
			<cfset variables.output = arguments.output>
		<cfreturn this>
	</cffunction>

	<cffunction name="setCaught" returntype="any" hint="set instance cfcatch, return instance">
		<cfargument name="caught" type="any" required="true" hint="result cfcatch">
			<cfset variables.caught = arguments.caught>
		<cfreturn this>
	</cffunction>

	<cffunction name="setErrors" returntype="any" hint="set instance errorflag, return instance">
		<cfargument name="errors" type="boolean" required="true" hint="result error flag">
			<cfset variables.errors = arguments.errors>
		<cfreturn this>
	</cffunction>

</cfcomponent>