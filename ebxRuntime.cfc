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
Filename: ebxParserInterface.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->
<cfcomponent>
	<cfparam name="session" default="#StructNew()#">

	<cfset variables.ebx          = "">
	<cfset variables.Parser       = "">
	<cfset variables.thisContext  = "">
	<cfset variables.errors       = ArrayNew(1)>

	<cffunction name="init" returntype="ebxRuntime" hint="initialise controller">
		<cfargument name="ebxParser"  type="ebxParser" required="true" hint="parser instance">
		<cfargument name="attributes" type="struct"    required="false" default="#StructNew()#" hint="parser initial attributes">
		<cfargument name="pagecontext" type="ebxPageContext"    required="false" default="#StructNew()#" hint="parser initial attributes">

		<cfset variables.Parser = arguments.ebxParser>
		<cfset variables.ebx    = variables.Parser.getEbx()>

		<cfset variables.pc    = arguments.pagecontext>
		<cfset variables.cf    = createObject("component", "ebxContextFactory").init(this)>
		<cfset variables.stack = createObject("component", "ebxExecutionStack").init(variables.cf.getEmptyContext())>
		<cfset setAttributes(arguments.attributes)>
		<cfset variables.pc.ebx_put("session", session)>

		<cfreturn this>
	</cffunction>

	<cffunction name="getErrors" returntype="array" hint="return error stack">
		<cfreturn variables.errors>
	</cffunction>

	<cffunction name="createErrorContext" returntype="any" hint="add error to stack">
		<cfargument name="message" type="string" required="true" />
		<cfargument name="detail" type="string" required="false" default="" />
			<cfset ArrayAppend(variables.errors, variables.cf.getErrorContext( argumentCollection = arguments ))>
		<cfreturn this>
	</cffunction>

	<!--- Pagecontext --->
	<cffunction name="include" returntype="struct" hint="include template in the page en return result">
		<cfargument name="template"      type="string" required="true" hint="full mapping path to include template">

		<cfset var result = "" />
		<cftry>
			<cfset result = getEbxPageContext().ebx_include(arguments.template) />
			<cfcatch type="any">
				<cfdump var="#arguments.template#">
				<cfdump var="#result#"><cfabort>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfreturn result />
	</cffunction>

	<cffunction name="flushOutput" returntype="boolean" hint="write output to the page. Always return true">
		<cfargument name="output" type="string" required="true" hint="string to write">
		<cfset getEbxPageContext().ebx_write(arguments.output)>
		<cfreturn true>
	</cffunction>

	<cffunction name="assignVariable" returntype="boolean" hint="handles append and assigns value to content var">
		<cfargument name="contentvar" required="true" type="string" hint="pagevariable to set">
		<cfargument name="value"      required="true" type="any"  hint="value to use">
		<cfargument name="append"     required="false" type="boolean" default="false" hint="append contentvar value or overwrite">

		<cfset var lcl = StructNew()>
		<cfif arguments.append>
			<cfset lcl.currval = appendVariable(getVar(arguments.contentvar, ""), arguments.value)>
		<cfelse>
			<cfset lcl.currval = arguments.value>
		</cfif>

		<cfset getEbxPageContext().ebx_put(arguments.contentvar, lcl.currval)>

		<cfreturn true>
	</cffunction>

	<cffunction name="setParser" returntype="any" hint="sets the parser">
		<cfset getEbxPageContext().setParser(getParser()) />
		<cfreturn true>
	</cffunction>

	<cffunction name="getVar" returntype="any" hint="get variable value from pagecontext">
		<cfargument name="name"  type="string" required="true" hint="variable name">
		<cfargument name="value" type="any"    required="false" default="" hint="default value to return if variable does not exist">
		<cfreturn getEbxPageContext().ebx_get(arguments.name, arguments.value)>
	</cffunction>

	<cffunction name="maxRequestsReached" returntype="boolean" hint="check if maximum requests in the stack is reached.">
		<cfreturn getStackInterface().maxReached()>
	</cffunction>

	 <cffunction name="setThisContext" returntype="boolean" hint="set active context">
		<cfargument name="context" type="any" required="true" hint="context instance to set active context to">
		<cfset variables.thisContext = arguments.context>
		<cfreturn true>
	</cffunction>

	<cffunction name="getCurrentEbxContext" returntype="ebxContext" hint="get active context">
		<cfreturn variables.thisContext>
	</cffunction>

	<cffunction name="createContext" returntype="boolean" hint="create context from arguments and update stack and parser on success. Return true on successfull context creation">
		<cfargument name="type"       required="true"  type="string" hint="context type">
		<cfargument name="action"     required="true"  type="string" hint="action to be parsed">
		<cfargument name="template"   required="true"  type="string" hint="context-template">
		<cfargument name="params"     required="false" type="struct"  default="#StructNew()#" hint="custom attributes">
		<cfargument name="contentvar" required="false" type="string"  default="" hint="contentvariable to store result output">
		<cfargument name="append"     required="false" type="boolean" default="false" hint="append contentvar or overwrite">

		<cfset var lcl = StructNew()>
		<cfset lcl.req = getParsedAction(arguments.action)>
		<cfif NOT StructIsEmpty(lcl.req)>
			<cfset StructDelete(arguments, "action")>
			<cfset StructAppend(lcl.req, arguments)>
			<cfset variables.cf.createContext(argumentCollection=lcl.req)>
			<cfset setContextFromFactory(arguments.type)>
			<cfset addContextToStack()>
			<cfset updateParserFromContext()>
			<cfset setAttributesFromContext()>
			<cfreturn true>
		<cfelse>
			<cfset createErrorContext( message = "No such circuit/action: #arguments.action#", originalArguments = arguments )>
		</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="getParsedAction" returntype="struct" hint="return parsed fuseaction as struct with action and circuitdir">
		<cfargument name="action"  required="true"  type="string" hint="action to be parsed">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = StructNew()>

		<cfif ListLen(arguments.action, ".") eq 3 AND hasInternal(arguments.action)>
			<cfset lcl.result.action  = arguments.action>
			<cfset lcl.result.circuitdir = getInternalExecDir(arguments.action)>
		<cfelseif ListLen(arguments.action, ".") eq 2 AND hasCircuit(ListFirst(arguments.action, "."))>
			<cfset lcl.result.action  = arguments.action>
			<cfset lcl.result.circuitdir = getCircuitExecDir(ListFirst(arguments.action, "."))>
		<cfelseif ListLen(arguments.action, ".") eq 1 AND getProperty("thisCircuit") neq "">
			<cfset lcl.result.action    = getProperty("thisCircuit") & "." & arguments.action>
			<cfset lcl.result.circuitdir = getProperty("circuitdir")>
		</cfif>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="setContextFromFactory" returntype="any" hint="set active context based on type??">
		<cfargument name="type" required="true"  type="string" hint="type to create">
		<cfswitch expression="#arguments.type#">
			<cfcase value="include">
				<cfset setThisContext(variables.cf.getIncludeContext())>
			</cfcase>
			<cfcase value="request">
				<cfset setThisContext(variables.cf.getRequestContext())>
			</cfcase>
			<cfcase value="layout">
				<cfset setThisContext(variables.cf.getLayoutContext())>
			</cfcase>
			<cfcase value="plugin">
				<cfset setThisContext(variables.cf.getPluginContext())>
			</cfcase>
			<cfcase value="mainrequest">
				<cfset setThisContext(variables.cf.getMainRequestContext())>
			</cfcase>
		</cfswitch>
		<cfreturn this>
	</cffunction>

	<cffunction name="addContextToStack" hint="add active context to stack">
		<cfif variables.stack.add(variables.thisContext)>
			<!--- <cfset updateParser()> --->
			<!--- yes --->
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setAttributesFromContext" returntype="any" hint="update page attributes with active context">
		<cfif NOT StructIsEmpty(variables.thisContext.getAttributes())>
			<cfset updateAttributes(variables.thisContext.getAttributes())>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="executeContext" returntype="boolean" hint="include context-template and set result in context. Return true if result does not contain errors">
		<cfset var lcl = StructNew()>
		<cfset lcl.template = variables.thisContext.getExecDir() & variables.thisContext.getTemplate()>
		<cfset lcl.result   = include(lcl.template)>
		<!--- <cfdump var="#variables.thisContext._dump()#"> --->
		<cfset variables.thisContext.setResult(lcl.result)>

		<cfif variables.thisContext.hasErrors()>
			<cfset ArrayAppend(variables.errors, variables.thisContext)>
		</cfif>
		<cfreturn NOT variables.thisContext.hasErrors()>
	</cffunction>

	<cffunction name="handleContextOutput" returntype="any" hint="process result: assign content-variable or parser-layout otherwise write result output">
		<cfset var lcl = StructNew( )>
		<cfset lcl.cc = getCurrentEbxContext()>
		<cfif lcl.cc.getContentVar() neq "">
			<cfset assignVariable(lcl.cc.getContentVar(), lcl.cc.getOutput(), lcl.cc.getAppend())>
		<cfelse>
			<!--- Always fill layout variable if requesttype for action is the main action or a layout action --->
			<cfif isMainRequest() OR isLayoutRequest()>
				<cfset setLayout( lcl.cc.getOutput() )>
			<cfelse>
				<cfset flushOutput( lcl.cc.getOutput() )>
			</cfif>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="isLayoutRequest" returntype="boolean" hint="check if active context is layout context">
		<cfreturn getContextFactory().isLayoutRequest( getCurrentEbxContext() )>
	</cffunction>

	<cffunction name="isMainRequest" returntype="boolean" hint="check if active context is main context">
		<cfreturn getContextFactory().isMainRequest( getCurrentEbxContext() )>
	</cffunction>

	<cffunction name="getContextOutput" returntype="any" hint="get context output">
		<cfreturn variables.thisContext.getOutput()>
	</cffunction>

	<cffunction name="restoreContextAttributes" returntype="any" hint="restore page-attributes from active-context">
		<cfif NOT StructIsEmpty(variables.thisContext.getOriginals())>
			<cfset updateAttributes(variables.thisContext.getOriginals())>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeContextFromStack" returntype="any" hint="remove context from stack and update active context">
		<cfset variables.stack.remove()>
		<cfset updateContext()>
		<cfreturn true>
	</cffunction>

	<cffunction name="updateParserFromContext" returntype="any" hint="update parser settings from active context">
		<cfargument name="types"   required="false" type="string" default="current,target" hint="parser context scopes can be current target or original">

		<cfset var lcl = StructNew()>
		<cfset lcl.keylist  = ListToArray("action,circuitdir,circuit,rootpath,execdir,act")>
		<cfset lcl.thislist = ListToArray("thisAction,circuitdir,thisCircuit,rootpath,execdir,act")>

		<!--- Do not update parser on calls to include which uses an internal circuit --->
		<cfif variables.thisContext.getType() neq "include">
			<cfloop list="#arguments.types#" index="lcl.type">
				<cfswitch expression="#lcl.type#">
					<cfcase value="current">
						<cfloop from="1" to="#ArrayLen(lcl.keylist)#" index="lcl.i">
							<cfset setProperty(lcl.thislist[lcl.i], variables.thisContext.get(lcl.keylist[lcl.i]))>
						</cfloop>
					</cfcase>
					<cfcase value="original,target">
						<cfloop from="1" to="#ArrayLen(lcl.keylist)#" index="lcl.i">
							<cfset setProperty(lcl.type & lcl.keylist[lcl.i], variables.thisContext.get(lcl.keylist[lcl.i]))>
						</cfloop>
					</cfcase>
					<!--- <cfcase value="target">
						<cfif variables.thisContext.getType() neq "include">
							<cfloop from="1" to="#ArrayLen(lcl.keylist)#" index="lcl.i">
								<cfset setProperty(lcl.type & lcl.keylist[lcl.i], variables.thisContext.get(lcl.keylist[lcl.i]))>
							</cfloop>
						</cfif>
					</cfcase> --->

				</cfswitch>
			</cfloop>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="getExecutedStack" returntype="array" hint="return array with executed contexts from stack">
		<cfreturn variables.stack.getExecutedStack()>
	</cffunction>

	<cffunction name="getContextFromFactory" returntype="ebxContext" hint="return current-context from factory">
		<cfreturn variables.cf.getContext()>
	</cffunction>

	<cffunction name="updateAttributes" returntype="any" hint="merge page-attributes with given attributes, always overwrites existing attributes">
		<cfargument name="attributes" type="struct" required="true" default="#StructNew()#" hint="struct with new attributes values">
		<cfargument name="overwrite"  type="boolean" required="false" default="true" hint="overwrite existing keys">
		<cfset var local  = StructNew()>
		<cfset lcl.attr = getAttributes()>
		<cfset StructAppend(lcl.attr, arguments.attributes, arguments.overwrite)>
		<cfreturn setAttributes(lcl.attr)>
		<!--- --->
	</cffunction>

	<cffunction name="getInternal" returntype="string" hint="return internal circuit from ebx">
		<cfargument name="action" required="false"  type="string"  default="" hint="internal action">
		<cfreturn variables.ebx.getInternal(arguments.action)>
	</cffunction>

	<cffunction name="hasInternal" returntype="boolean" hint="return check for internal circuit from ebx">
		<cfargument name="action"  required="false"  type="string"  default="" hint="action">
		<cfreturn variables.ebx.hasInternal(ListLast(arguments.action, '.'))>
	</cffunction>

	<cffunction name="getMainAction" returntype="string" hint="if page-attribute action exists return it, otherwise return default act">
		<cfreturn getAttribute(getParameter("actionvar"), getParameter("defaultact"))>
	</cffunction>

	<cffunction name="setMainAction" returntype="any" hint="sets the main action for the parser">
		<cfargument name="action" required="true" type="string" hint="main action">
			<cfset setAttribute(getParameter("actionvar"), arguments.action)>
		<cfreturn this>
	</cffunction>

	<cffunction name="updateContext" returntype="boolean" hint="set active-context from stack">
		<cfset variables.thisContext = variables.stack.getCurrent()>
		<cfreturn true>
	</cffunction>

	<!--- Interfaces --->
	<cffunction name="getParser" returntype="ebxParser" hint="return the parser">
		<cfreturn variables.Parser>
	</cffunction>

	<cffunction name="getEbxPageContext" returntype="ebxPageContext" hint="return the pagecontext">
		<cfreturn variables.pc>
	</cffunction>

	<cffunction name="getStackInterface" returntype="ebxExecutionStack" hint="return the stack">
		<cfreturn variables.stack>
	</cffunction>

	<cffunction name="getContextFactory" returntype="any" hint="return the factory">
		<cfreturn variables.cf>
	</cffunction>

	<!--- Path related --->
	<cffunction name="getInternalExecDir" returntype="string" hint="get (path)value from parser-property for a property read from the internal circuit definition">
		<cfargument name="action" type="string" required="true" hint="full qualified internal action">
		<cfset var lcl = StructNew()>

		<cfset lcl.pathvar = getInternal(ListLast(arguments.action, "."))>
		<cfif lcl.pathvar neq "">
			<cfreturn getProperty(lcl.pathvar)>
		</cfif>
		<cfreturn "">
	</cffunction>

	<cffunction name="getCircuitExecDir" returntype="string" hint="return circuitpath for circuit from ebx">
		<cfargument name="circuit" type="string" required="true" hint="circuit name">
		<cfreturn variables.ebx.getCircuit(arguments.circuit)>
	</cffunction>

	<cffunction name="getAppPath" returntype="string" hint="return application path from ebx">
		<cfreturn variables.ebx.getAppPath()>
	</cffunction>

	<cffunction name="getFilePath" returntype="string" hint="return mapping path for template based on application and current circuit, which can be disbled">
		<cfargument name="name" type="string" required="true" hint="template name">
		<cfargument name="parseAppPath"  type="boolean" required="false" default="true" hint="prepend template with application path">
		<cfargument name="parseCircPath" type="boolean" required="false" default="true" hint="prepend template with current circuit path">

		<cfif arguments.parseCircPath>
			<cfset arguments.name = variables.Parser.getProperty("circuitdir") & arguments.name>
		</cfif>
		<cfif arguments.parseAppPath>
			<cfset arguments.name = getAppPath() & arguments.name>
		</cfif>
		<cfreturn arguments.name>
	</cffunction>

	<cffunction name="hasCircuit" returntype="boolean" hint="validate circuit in ebx">
		<cfargument name="name" type="string" required="true" hint="circuit name">
		<cfreturn variables.ebx.hasCircuit(arguments.name)>
	</cffunction>

	<cffunction name="setLayout" returntype="boolean" hint="set parser's layout property">
		<cfargument name="layout" type="string" required="true" hint="main context result output">
		<cfreturn variables.Parser.setLayout(arguments.layout)>
	</cffunction>

	<cffunction name="getParameter" returntype="any" hint="get ebx parameter from parser">
		<cfargument name="name"  type="string" required="true" hint="parameter name">
		<cfreturn variables.Parser.getParameter(arguments.name)>
	</cffunction>

	<cffunction name="getProperty" returntype="any" hint="get parser property">
		<cfargument name="key"     type="string" required="true" hint="property name">
		<cfargument name="default" type="any"    required="false" default="" hint="value if unexistant">
		<cfreturn variables.Parser.getProperty(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="setProperty" returntype="boolean" access="public" hint="set parser property. Return true on success.">
		<cfargument name="key"       required="true"  type="string"  hint="key to update">
		<cfargument name="value"     required="false" type="any"     default="" hint="value for the key">
		<cfreturn variables.Parser.setProperty(arguments.key, arguments.value)>
	</cffunction>

	<!---
	******************************************************************************
	Attributes
	******************************************************************************
	--->
	<cffunction name="getAttribute" returntype="any" hint="get page-attribute">
		<cfargument name="name"  type="string" required="true" hint="attribute name">
		<cfargument name="value" type="any"    required="false" default="" hint="value if unexistant">

		<cfset var lcl = StructNew()>
		<cfset lcl.attr = getAttributes()>
		<cfif hasAttribute(arguments.name, lcl.attr)>
			<cfreturn lcl.attr[arguments.name]>
		</cfif>

		<cfreturn arguments.value>
	</cffunction>

	<cffunction name="setAttribute" returntype="any" hint="set page-attribute">
		<cfargument name="name"  type="string" required="true" hint="attribute name">
		<cfargument name="value" type="any"    required="true" hint="value for attribute">

		<cfreturn getEbxPageContext().ebx_put("attributes.#name#", arguments.value)>
	</cffunction>

	<cffunction name="unsetAttribute" returntype="any" hint="set page-attribute">
		<cfargument name="name"  type="string" required="true" hint="attribute name">

		<cfreturn getEbxPageContext().ebx_unset("attributes.#name#")>
	</cffunction>

	<cffunction name="paramAttribute" returntype="any" hint="set page-attribute">
		<cfargument name="name"  type="string" required="true" hint="attribute name">
		<cfargument name="value" type="any"    required="true" hint="value for attribute">

		<cfset var lcl = StructNew()>
		<cfset lcl.attr = getAttributes()>
		<cfif NOT hasAttribute(arguments.name, lcl.attr)>
			<cfset setAttribute(arguments.name, arguments.value)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="getAttributes" returntype="struct" hint="get page-attributes">
		<cfreturn getVar("attributes", StructNew())>
	</cffunction>

	<cffunction name="setAttributes" returntype="any" hint="set page-attributes">
		<cfargument name="attribs" type="struct" required="true" hint="attribute struct">
		<cfreturn getEbxPageContext().ebx_put("attributes", arguments.attribs)>
	</cffunction>

	<cffunction name="hasAttribute" returntype="boolean" hint="check if key exists in attributes.">
		<cfargument name="name"       type="string" required="true" hint="attributes name">
		<cfargument name="attributes" type="struct" required="false" default="#getAttributes()#" hint="scope to search in defaults to page-attributes">

		<cfreturn StructKeyExists(arguments.attributes, arguments.name)>
	</cffunction>

	<cffunction name="appendVariable" returntype="any" hint="appends value to a variable, append-behaviour differences are based on original's datatype!">
		<cfargument name="orginal" required="true" type="any" hint="pagevariable to set">
		<cfargument name="value"   required="true" type="any"  hint="value to use">

		<cfset var local     = StructNew()>
		<cfset lcl.currval = arguments.orginal>

		<cfif IsSimpleValue(lcl.currval) AND lcl.currval eq "">
			<!--- bail out immediately if append isn't needed --->
			<cfset lcl.currval = arguments.value>
		<cfelseif IsSimpleValue(lcl.currval) AND IsSimpleValue(arguments.value)>
			<!--- string concatenation if both are string --->
			<cfset lcl.currval = lcl.currval & 	arguments.value>
		<cfelseif IsArray(lcl.currval)>
			<!--- ArrayAppend on array --->
			<!--- TODO:
					Add [[AND NOT IsArray(arguments.value)]] so that we can concat both arrays;
					But is this actually nice behaviour?
			--->
			<cfset ArrayAppend(lcl.currval, arguments.value)>
		<cfelseif IsStruct(lcl.currval) AND IsStruct(arguments.value)>
			<!--- Merge structs if both are structs --->
			<cfset StructAppend(lcl.currval, arguments.value, true)>
		<cfelseif IsQuery(lcl.currval) AND IsStruct(arguments.value)>
			<!--- Add query row based on struct; this is a bit experimental --->
			<cfset lcl.cols  = lcl.currval.columnlist>
			<cfset lcl.recs  = lcl.currval.recordcount>
			<cfset lcl.valid = false>
			<cfset QueryAddRow(lcl.currval)>
			<cfloop list="#StructKeyList(arguments.value)#" index="lcl.item">
				<cfset lcl.testval = arguments.value[lcl.item]>
				<cfif ListFind(lcl.cols, lcl.item)>
					<cfset QuerySetCell(lcl.currval, lcl.item, lcl.testval)>
					<cfset lcl.valid = true>
				<cfelseif IsArray(lcl.testval) AND ArrayLen(lcl.testval) eq lcl.recs>
					<cfset QueryAddColumn(lcl.currval, lcl.item, lcl.testval)>
					<cfset lcl.valid = true>
				</cfif>
			</cfloop>
			<cfif NOT lcl.valid>
				<cfset lcl.currval.removeRows(JavaCast( "int", lcl.recs ),JavaCast( "int", 1 ))>
			</cfif>
		</cfif>
		<cfreturn lcl.currval>
	</cffunction>

</cfcomponent>