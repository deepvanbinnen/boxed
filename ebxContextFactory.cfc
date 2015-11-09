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
Filename: ebxContextFactory.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->
<cfcomponent hint="I am responsable for creating contexts and holding them until requested back by the ebxRuntime">
	<cfset variables.INCLUDE     = "include">
	<cfset variables.NEW         = "newrequest">
	<cfset variables.EMPTY       = "empty">
	<cfset variables.REQUEST     = "request">
	<cfset variables.MAINREQUEST = "mainrequest">
	<cfset variables.LAYOUT      = "layout">
	<cfset variables.PLUGIN      = "plugin">
	<cfset variables.ERROR       = "error">


	<cfset variables.empty_context   = createObject("component", "ebxContext").init(variables.EMPTY)>
	<cfset variables.current         = variables.empty_context>
	<cfset variables.context_flushed = FALSE>

	<cffunction name="init" returntype="ebxContextFactory" hint="initialise factory">
		<cfargument name="runtime" required="true" type="ebxRuntime" hint="instance of runtime">
			<cfset variables.pi = arguments.runtime>
		<cfreturn this>
	</cffunction>

	<cffunction name="getEmptyContext"  returntype="ebxContext" hint="return empty context">
		<cfreturn variables.empty_context>
	</cffunction>

	<cffunction name="getContext"  returntype="ebxContext" hint="get active context, allows resetting active context to empty context">
		<cfargument name="reset" required="false" type="boolean" default="false" hint="reset active context to empty context">
		<cfset var lcl = StructNew()>
		<cfif arguments.reset>
			<cfset lcl.current = variables.current>
			<cfset emptyCurrentContext()>
			<cfreturn lcl.current>
		</cfif>
		<cfreturn variables.current>
	</cffunction>

	<cffunction name="createContext" returntype="ebxContext" hint="set active-context to new context and initialise and return it">
		<cfargument name="action"     required="true"  type="string"  hint="full qualified action">
		<cfargument name="template"   required="false" type="string"  default="" hint="templatename">
		<cfargument name="circuitdir" required="false" type="string"  default="" hint="circuit directory">
		<cfargument name="params"     required="false" type="struct"  default="#StructNew()#" hint="custom attributes">
		<cfargument name="contentvar" required="false" type="string"  default="" hint="content-variable to store output in">
		<cfargument name="append"     required="false" type="boolean" default="false" hint="append content-variable value">

		<cfset variables.current = createObject("component", "ebxContext").init(variables.NEW)>

		<cfset variables.current.setAction(arguments.action)>
		<cfset variables.current.setCircuit(ListDeleteAt(arguments.action, ListLen(arguments.action, "."), "."))>
		<cfset variables.current.setAct(ListLast(arguments.action, "."))>

		<cfset variables.current.setCircuitDir(arguments.circuitdir)>
		<cfset variables.current.setAppPath(variables.pi.getAppPath())>
		<cfset variables.current.setExecDir()>

		<cfset variables.current.setTemplate(arguments.template)>

		<cfif NOT StructIsEmpty(arguments.params)>
			<cfset variables.current.setAttributes(arguments.params)>
			<cfset lcl.attr = variables.pi.getAttributes()>
			<cfset lcl.copy = StructNew()>
			<cfloop collection="#arguments.params#" item="lcl.item">
				<cfif StructKeyExists(lcl.attr, lcl.item)>
					<cfset StructInsert(lcl.copy, lcl.item, lcl.attr[lcl.item])>
				</cfif>
			</cfloop>
			<cfset variables.current.setOriginals(lcl.copy)>
		</cfif>

		<cfif arguments.contentvar neq "">
			<cfset variables.current.setContentVar(arguments.contentvar)>
			<cfset variables.current.setAppend(arguments.append)>
		</cfif>

		<cfreturn getContext()>
	</cffunction>

	<cffunction name="getMainRequestContext" hint="set active-context type to main-context and return it, while resetting active-context">
		<cfset variables.current.setType(variables.MAINREQUEST)>
		<cfset variables.context_flushed = TRUE>
		<cfreturn getContext(true)>
	</cffunction>

	<cffunction name="getPluginContext" hint="set active-context type to plugin-context and return it, while resetting active-context">
		<cfset variables.current.setType(variables.PLUGIN)>
		<cfset variables.context_flushed = TRUE>
		<cfreturn getContext(true)>
	</cffunction>

	<cffunction name="getErrorContext" hint="set active-context type to error-context and return it, while resetting active-context">
		<cfargument name="message" type="string" default="Unspecified error" required="false">
		<cfargument name="detail" type="string" default="" required="false">

		<cfset variables.current.setType(variables.ERROR)>
		<cfset variables.current.setErrors(TRUE)>
		<cfset variables.current.setCaught(arguments)>
		<cfset variables.context_flushed = TRUE>
		<cfreturn getContext(true)>
	</cffunction>

	<cffunction name="getRequestContext" hint="set active-context type to request-context and return it, while resetting active-context">
		<cfset variables.current.setType(variables.REQUEST)>
		<cfset variables.context_flushed = TRUE>
		<cfreturn getContext(true)>
	</cffunction>

	<cffunction name="getIncludeContext" hint="set active-context type to include-context and return it, while resetting active-context">
		<cfset variables.current.setType(variables.INCLUDE)>
		<cfset variables.context_flushed = TRUE>
		<cfreturn getContext(true)>
	</cffunction>

	<cffunction name="getLayoutContext" hint="set active-context type to layout-context and return it, while resetting active-context">
		<cfset variables.current.setType(variables.LAYOUT)>
		<cfset variables.context_flushed = TRUE>
		<cfreturn getContext(true)>
	</cffunction>

	<cffunction name="emptyCurrentContext" returntype="boolean" hint="set active context to empty context, always return true">
		<cfset variables.current = variables.empty_context>
		<cfreturn true>
	</cffunction>

	<cffunction name="isEmptyContext" returntype="boolean" hint="check if active context is empty context">
		<cfargument name="context" required="true"  type="ebxContext" hint="context instance">
		<cfreturn NOT arguments.context.hasType("") OR arguments.context.checkType(variables.EMPTY)>
	</cffunction>

	<cffunction name="isInclude" returntype="boolean" hint="check if active context is include context">
		<cfargument name="context" required="true"  type="ebxContext" hint="context instance">
		<cfreturn arguments.context.checkType(variables.INCLUDE)>
	</cffunction>

	<cffunction name="isLayoutRequest" returntype="boolean" hint="check if active context is layout context">
		<cfargument name="context" required="true"  type="ebxContext" hint="context instance">
		<cfreturn arguments.context.checkType(variables.LAYOUT)>
	</cffunction>

	<cffunction name="isMainRequest" returntype="boolean" hint="check if active context is main context">
		<cfargument name="context" required="true"  type="ebxContext" hint="context instance">
		<cfreturn arguments.context.checkType(variables.MAINREQUEST)>
	</cffunction>

	<cffunction name="isRequest" returntype="boolean" hint="check if active context is request context">
		<cfargument name="context" required="true"  type="ebxContext" hint="context instance">
		<cfreturn arguments.context.checkType(variables.REQUEST) OR isMainRequest(arguments.context)>
	</cffunction>

	<cffunction name="isNewRequest" returntype="boolean" hint="check if active context is new context">
		<cfargument name="context" required="true"  type="ebxContext" hint="context instance">
		<cfreturn arguments.context.checkType(variables.NEW)>
	</cffunction>

</cfcomponent>