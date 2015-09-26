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
Filename: ebxContext.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->
<cfcomponent extends="ebxContextResult" hint="I am a value object that represents a execution context. I am created by the contextFactory and returned to the ebxRuntime">
	<cfset variables.type       = "">
	<cfset variables.template   = "">
	<cfset variables.attributes = StructNew()>
	<cfset variables.originals  = StructNew()>
	<cfset variables.contentvar = "">
	<cfset variables.append     = FALSE>
	<cfset variables.executed   = FALSE>
	<cfset variables.act        = "">
	<cfset variables.action    = "">
	<cfset variables.circuit    = "">
	<cfset variables.circuitdir = "">
	<cfset variables.rootPath   = "">
	<cfset variables.execDir    = "">
	<cfset variables.appPath    = "">

	<cffunction name="init" returntype="ebxContext" hint="initialise context from arguments">
		<cfargument name="type"       type="string"  required="true"  hint="contexttype">
		<cfargument name="action"     type="string"  required="false" default=""              hint="full qualified action">
		<cfargument name="attributes" type="struct"  required="false" default="#StructNew()#" hint="custom attribute values">
		<cfargument name="originals"  type="struct"  required="false" default="#StructNew()#" hint="original attribute values">
		<cfargument name="contentvar" type="string"  required="false" default=""              hint="name of variable in which to store result output">
		<cfargument name="append"     type="boolean" required="false" default="false"         hint="flag that indicates appending the output of contentvar">
		<cfargument name="template"   type="string"  required="false" default=""              hint="full mapping path to include template for the context">
		<cfargument name="appPath"    type="string"  required="false" default=""              hint="full mapping path to include template for the context">

			<cfset StructAppend(variables, arguments, true)>
		<cfreturn this>
	</cffunction>

	<!--- Getters --->
	<cffunction name="get" returntype="any" hint="get private variable value by name">
		<cfargument name="key" type="string" required="true" hint="private variable name">
		<cfif StructKeyExists(variables, arguments.key)>
			<cfreturn variables[arguments.key]>
		</cfif>
		<cfreturn "">
	</cffunction>

	<cffunction name="getType" returntype="string" hint="return instance type">
		<cfreturn variables.type>
	</cffunction>

	<cffunction name="getTemplate" returntype="string" hint="return instance template">
		<cfreturn variables.template>
	</cffunction>

	<cffunction name="getAppPath" returntype="string" hint="return instance application path">
		<cfreturn variables.appPath>
	</cffunction>

	<cffunction name="getAttributes" returntype="struct" hint="return instance custom attributes">
		<cfreturn variables.attributes>
	</cffunction>

	<cffunction name="getOriginals" returntype="struct" hint="return original attributevalues from instance">
		<cfreturn variables.originals>
	</cffunction>

	<cffunction name="getContentVar" returntype="string" hint="return name of instance contentvar">
		<cfreturn variables.contentvar>
	</cffunction>

	<cffunction name="getAppend" returntype="boolean" hint="return appendflag for instance contentvar">
		<cfreturn variables.append>
	</cffunction>

	<cffunction name="getCircuit" returntype="string" hint="return instance circuit">
		<cfreturn variables.circuit>
	</cffunction>

	<cffunction name="getAction" returntype="string" hint="return instance full qualified action">
		<cfreturn variables.action>
	</cffunction>

	<cffunction name="getAct" returntype="string" hint="return instance act">
		<cfreturn variables.act>
	</cffunction>

	<cffunction name="getCircuitDir" returntype="string" hint="return instance circuit">
		<cfreturn variables.circuitdir>
	</cffunction>

	<cffunction name="getRootPath" returntype="string" hint="return relative path prefix for include from instance circuit">
		<cfreturn variables.rootPath>
	</cffunction>

	<cffunction name="getExecDir" returntype="string" hint="return instance full mapping path">
		<cfreturn variables.execdir>
	</cffunction>

	<cffunction name="isExecuted" returntype="boolean" hint="return executed flag">
		<cfreturn variables.executed>
	</cffunction>

	<!--- Setters --->
	<cffunction name="setExecuted" returntype="boolean" hint="set executed flag, always return true">
		<cfargument name="executed" type="boolean" required="false" default="true" hint="executed flag, can be unset manually">
			<cfset variables.executed = arguments.executed>
		<cfreturn true>
	</cffunction>

	<cffunction name="setTemplate" returntype="any" hint="set template, return instance">
		<cfargument name="template" type="string" required="true" hint="templatename for context">
		<cfset variables.template = arguments.template>
		<cfreturn this>
	</cffunction>

	<cffunction name="setType" returntype="any" hint="set type, return instance">
		<cfargument name="type" type="string" required="true" hint="typename of context">
		<cfset variables.type = arguments.type>
		<cfreturn this>
	</cffunction>

	<cffunction name="setContentVar" returntype="any" hint="set contentvar, return instance">
		<cfargument name="contentvar" type="string" required="true" hint="content variable to store context output in">
		<cfset variables.contentvar = arguments.contentvar>
		<cfreturn this>
	</cffunction>

	<cffunction name="setAttributes" returntype="any" hint="set attributes struct, return instance">
		<cfargument name="attributes" type="struct" required="true" hint="custom attributes for context">
		<cfset variables.attributes = arguments.attributes>
		<cfreturn this>
	</cffunction>

	<cffunction name="setOriginals" returntype="any" hint="set originals struct, return instance">
		<cfargument name="originals" type="struct" required="true" hint="struct containing original attribute values for context attributes">
		<cfset variables.originals = arguments.originals>
		<cfreturn this>
	</cffunction>

	<cffunction name="setAppend" returntype="any" hint="set append flag, return instance">
		<cfargument name="append" type="boolean" required="true" hint="flags if contentvar should be appended in stead of overwritten">
		<cfset variables.append = arguments.append>
		<cfreturn this>
	</cffunction>

	<cffunction name="setCircuit" returntype="any" hint="set circuit, return instance">
		<cfargument name="circuit" type="string" required="true" hint="circuit name">
		<cfset variables.circuit = arguments.circuit>
		<cfreturn this>
	</cffunction>

	<cffunction name="setAction" returntype="any" hint="set action, return instance">
		<cfargument name="action" type="string" required="true" hint="the full qualified fuseaction">
		<cfset variables.action = arguments.action>
		<cfreturn this>
	</cffunction>

	<cffunction name="setAct" returntype="any" hint="set act, return instance">
		<cfargument name="act" type="string" required="true" hint="the action-part of the fuseaction">
		<cfset variables.act = arguments.act>
		<cfreturn this>
	</cffunction>

	<cffunction name="setCircuitDir" returntype="any" hint="set circuitdir and calculate and set rootpath, return instance">
		<cfargument name="circuitdir" type="string" required="true" hint="path associated with circuit">
		<cfset variables.circuitdir = arguments.circuitdir>
		<cfset setRootPath(RepeatString("../", ListLen(variables.circuitdir, "/")))>
		<!--- <cfset setExecDir()> --->
		<cfreturn this>
	</cffunction>

	<cffunction name="setAppPath" returntype="any" hint="set application path, return instance">
		<cfargument name="appPath" type="string" required="true" hint="full mapping path">
		<cfset variables.appPath = arguments.appPath>
		<!--- <cfset setExecDir()> --->
		<cfreturn this>
	</cffunction>

	<cffunction name="setRootPath" returntype="any" hint="set rootpath, return instance">
		<cfargument name="rootPath" type="string" required="true" hint="relative path prefix for includes">
		<cfset variables.rootPath = arguments.rootPath>
		<cfreturn this>
	</cffunction>

	<cffunction name="setExecDir" returntype="any" hint="set execdir from application path and circuitdir, return instance">
		<cfset variables.execdir = getAppPath() & getCircuitDir()>
		<cfreturn this>
	</cffunction>

	<!--- Type info --->
	<cffunction name="checkType" returntype="any" hint="check if instance is of given type">
		<cfargument name="type" required="true" type="string" hint="type to check">
		<cfreturn getType() eq arguments.type>
	</cffunction>

	<cffunction name="hasType" returntype="boolean" hint="check if type is not empty">
		<cfreturn NOT checkType("")>
	</cffunction>

	<cffunction name="_dump" hint="dump instance info">
		<cfloop collection="#variables#" item="local.i">
			<cfif IsSimpleValue(variables[local.i])>
				<cfoutput>#local.i#: #variables[local.i]#<br /></cfoutput>
			<cfelseif local.i eq "attributes" OR local.i eq "originals">
				<cfoutput>#local.i#:<br /></cfoutput>
				<cfloop collection="#variables[local.i]#" item="local.j">
					<cfif IsSimpleValue(variables[local.i][local.j])>
						<cfoutput>#local.j#: #variables[local.i][local.j]#<br /></cfoutput>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	</cffunction>
</cfcomponent>
