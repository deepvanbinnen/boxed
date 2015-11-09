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
Filename: ebxParser.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->
<cfcomponent extends="PropertyInterface" hint="I am the fuseaction parser and responsible for execution of the fuseaction. You can instruct me to 'include' files  or 'do' 'sub'-fuseactions customise the attributes for the call and store the output for this in a 'contentvar' variable. I provide mechanisms to read/write variable-scopes such as paramters and attributes and xfa's">
	<cfset variables.ebx = "">
	<cfset variables.ParserInterface  = "">
	<cfset variables.initialised  = false>
	<cfset variables.settings_parsed  = false>

	<cfset variables.xfa = StructNew()>

	<cfset this.state = "UNINITIALISED">
	<cfset this.phase = "UNINITIALISED">

	<cfset this.originalAction      = "">
	<cfset this.originalCircuit     = "">
	<cfset this.originalAct         = "">
	<cfset this.originalCircuitdir  = "">
	<cfset this.originalRootpath    = "">
	<cfset this.originalExecdir     = "">

	<cfset this.targetAction        = "">
	<cfset this.targetCircuit       = "">
	<cfset this.targetAct           = "">
	<cfset this.targetCircuitdir    = "">
	<cfset this.targetRootpath      = "">
	<cfset this.targetExecdir       = "">

	<cfset this.thisAction          = "">
	<cfset this.thisCircuit         = "">
	<cfset this.act                 = "">
	<cfset this.circuitdir          = "">
	<cfset this.rootpath            = "">
	<cfset this.execdir             = "">

	<cfset this.prePlugins          = ArrayNew(1)>
	<cfset this.postPlugins         = ArrayNew(1)>

	<cfset this.layout     = "">
	<cfset this.layoutdir  = "">
	<cfset this.layoutfile = "">
	<cfset this.layoutpath = "">

	<cfset this.configdir  = "">
	<cfset this.self       = CGI.SCRIPT_NAME>
	<cfset this.abspath    = getDirectoryFromPath(CGI.CF_TEMPLATE_PATH)>

	<cfset this.stream     = false>
	<cfset this.mime       = "text/html">
	<cfset this.etag       = false>
	<cfset this.gzip       = false>
	<cfset this.gmime      = "text/html">
	<cfset this.debug      = false>

	<cffunction name="init" output="false" returntype="ebxParser" hint="initialise parser">
		<cfargument name="ebx"         required="true"  type="any" hint="ebox settings instance">
		<cfargument name="attributes"  required="false" type="struct"  default="#StructNew()#" hint="attributes to use in the parser">
		<cfargument name="scopecopy"   required="false" type="string"  default="url,form"      hint="list of scopes to copy to attributes">
		<cfargument name="nosettings"  required="false" type="boolean" default="false"         hint="do not parse settingsfile">
		<cfargument name="nolayout"    required="false" type="boolean" default="false"         hint="do not parse layout at all">
		<cfargument name="useviews"    required="false" type="boolean" default="false"         hint="do not parse inclusion of ebxParser.layoutFile and ebxParser.layoutDir">
		<cfargument name="initvars"    required="false" type="struct"  default="#StructNew()#" hint="known variables">
		<cfargument name="self"        required="false" type="string"  default="#this.self#"   hint="overridable self-parameter">
		<cfargument name="action"      required="false" type="string"  hint="force the parser to use this as action">
		<cfargument name="selfvar"     required="false" type="string"  default="request.ebx"   hint="the variable used to identify this parser instance">
		<cfargument name="flush"       required="false" type="boolean" default="true"          hint="if false manually call displayOutput() or getOutput() to retrieve the executions output">
		<cfargument name="showerrors"  required="false" type="boolean" default="false"         hint="actually ment for debugging">
		<cfargument name="view"        required="false" type="string"  default="html"          hint="set view ">
		<cfargument name="pc"          required="false" type="ebxPageContext" hint="overridable pageContext ">
		<cfargument name="stream"      required="false" type="boolean" default="#this.stream#" hint="set stream flag">
		<cfargument name="gzip"        required="false" type="boolean" default="#this.gzip#"   hint="set gzip flag">
		<cfargument name="etag"        required="false" type="boolean" default="#this.etag#"   hint="set etag flag">
		<cfargument name="mime"        required="false" type="string"  default="#this.mime#"   hint="set mime ">
		<cfargument name="gmime"       required="false" type="string"  default="#this.gmime#"  hint="set gzipmime ">
		<cfargument name="debug"       required="false" type="boolean" default="#this.debug#"  hint="set debug flag">

			<cfset var lcl = StructNew()>
			<cfif StructKeyExists(arguments, "pc")>
				<cfset lcl.pc = arguments.pc>
			<cfelse>
				<cfset lcl.pc = createObject("component", "ebxPageContext")>
			</cfif>

			<cfset this.stream  = arguments.stream />
			<cfset this.mime    = arguments.mime />
			<cfset this.etag    = arguments.etag />
			<cfset this.gzip    = arguments.gzip />
			<cfset this.gmime   = arguments.gmime />
			<cfset this.debug   = arguments.debug />


			<cfset setExecParameters(arguments.scopecopy, arguments.nosettings, arguments.nolayout, arguments.flush, arguments.showerrors, arguments.view, arguments.useviews)>

			<cfset variables.ebx = arguments.ebx>
			<cfset variables.internalParser  = createObject("component", "ebxRuntime").init(this, arguments.attributes, lcl.pc)>
			<!---  --->
			<cfset variables.internalParser.assignVariable(arguments.selfvar, this)>
			<cfloop collection="#arguments.initvars#" item="lcl.varname">
				<cfset variables.internalParser.assignVariable(lcl.varname, arguments.initvars[lcl.varname])>
			</cfloop>
			<cfset setSelf(arguments.self)>

			<cfif getProperty("scopecopy") neq "">
				<cfloop list="#getProperty("scopecopy")#" index="lcl.scope">
					<cfset variables.internalParser.updateAttributes(variables.internalParser.getVar(lcl.scope, StructNew()))>
				</cfloop>
			</cfif>

			<cfif StructKeyExists(arguments, "action")>
				<cfset variables.internalParser.setMainAction(arguments.action)>
			</cfif>

			<cfset variables.internalParser.setParser() />
			<!--- <cfif ip().testOwner("deepak")>
				<cfdump var="#arguments.self#">
			</cfif> --->
			<!--- <cfset variables.evt = variables.internalParser.getEventInterface()> --->

		<cfreturn this>
	</cffunction>

	<!--- EXECUTION METHODS --->
	<cffunction name="execute" returntype="any" hint="Executes the main-context from the setMainAction. Return true on successfull execution">
		 <!--- Executes several stages in order:
		- preprocess - parse settings file (happens only for maincontext)
		- preplugin - get preplugins and execute them (happens only for maincontext)
		- prefuse - customise attributes (happens for all contexts) and execute prefuse-context (happens only for maincontext)
		- context - include switch-template and set result (happens for all contexts)
		- postfuse - reset attributes (happens for all contexts) and execute postfuse-context (happens only for maincontext)
		- postplugin - get postplugins and execute them (happens only for maincontext)
		- postprocess - if applicable parse layouts file and set final output
		 --->
		<cfset var lcl = StructNew()>

		<cfif NOT getProperty("nosettings") AND NOT variables.settings_parsed>
			<cfset parseSettings()>
		</cfif>

		<!--- Execute main request --->
		<cfif executeMain()>
			<!--- Parse ebx_layouts --->
			<cfif NOT getProperty("nolayout")>
				<cfif parseLayouts() AND NOT getProperty("useviews")>
					<!--- Execute layout file --->
					<cfif NOT executeLayout()>
						<cfset createErrorContext( message = "Error in layout-context" )>
					</cfif>
				</cfif>
			</cfif>
			<cfif getProperty("flush")>
				<cfset displayOutput()>
			</cfif>
		</cfif>

		<cfif hasErrors() AND getProperty("showErrors")>
			<cfset dumpErrors()>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="do" returntype="boolean" hint="Includes context-template and sets the context-result. Returns true on successfull execution">
		<cfargument name="action"     required="true"  type="string" hint="the full qualified action">
		<cfargument name="contentvar" required="false" type="string"  default="" hint="variable that catches output">
		<cfargument name="append"     required="false" type="boolean" default="false" hint="append contentvar value or overwrite">
		<cfargument name="params"     required="false" type="struct"  default="#StructNew()#" hint="local params">
		<cfargument name="template"   required="false" type="string"  default="#getParameter('switchfile')#" hint="context template">
		<cfargument name="type"       required="false" type="string"  default="request" hint="context type">

		<cfset var lcl = StructNew()>
		<!--- Check for max requests --->
		<cfif NOT variables.internalParser.maxRequestsReached()>
			<!--- convert named arguments to params --->
			<cfset _setParamsFromArgs(arguments, "action,contentvar,append,template,type")>
			<cfif getContext(argumentCollection=arguments)>
				<cfset executeContext()>
				<cfset postContext()>
				<cfreturn true>
			<cfelse>
				<cfset createErrorContext( message = "Error executing do for action #arguments.action# with template #arguments.template#" )>
			</cfif>
		<cfelse>
			<!--- Throw max reached error --->
			<cfthrow message="MAX REQUESTS REACHED!">
		</cfif>

		<cfreturn false>
	</cffunction>

	<cffunction name="include" returntype="boolean" hint="Creates include-context and execute do. Return true on successfull execution">
		<cfargument name="template"   required="true" type="string" hint="context template">
		<cfargument name="contentvar" required="false" type="string"  default="" hint="variable that catches output">
		<cfargument name="append"     required="false" type="boolean" default="false" hint="append contentvar value or overwrite">
		<cfargument name="params"     required="false" type="struct"  default="#StructNew()#" hint="local params">

		<cfset _setParamsFromArgs(arguments, "contentvar,append,template")>
		<cfset arguments.action = "internal.circuit.include">
		<cfset arguments.type   = "include">
		<!--- <cfreturn testRequest(argumentCollection=arguments)> --->
		<cfreturn do(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="obtain" output="true" returntype="any" hint="executes do and returns the content as a string instead of outputting or contentvar">
		<cfargument name="action"     required="false" type="string"  hint="the full qualified action">
		<cfargument name="template"   required="false" type="string"  hint="context template">
		<cfargument name="append"     required="false" type="boolean" default="false" hint="append contentvar value or overwrite">
		<cfargument name="params"     required="false" type="struct"  default="#StructNew()#" hint="local params">
		<cfargument name="type"       required="false" type="string"  default="request" hint="context type">

		<cfset var lcl = StructNew() />
		<cfset lcl.out   = "" />
		<cfset lcl.clean = false />
		<cfif StructKeyExists(arguments, "action")>
			<cfset do(argumentCollection = arguments, contentvar="_tmpebx") />
			<cfset lcl.clean = true />
		<cfelseif StructKeyExists(arguments, "template")>
			<cfset include(argumentCollection = arguments, contentvar="_tmpebx") />
			<cfset lcl.clean = true />
		</cfif>

		<cfif lcl.clean>
			<cfset lcl.out = getEbxPageContext().ebx_get("_tmpebx") />
			<cfset getEbxPageContext().ebx_unset("_tmpebx") />
		</cfif>

		<cfreturn lcl.out />
	</cffunction>

	<cffunction name="setVars" returntype="any" hint="get variable value from pagecontext">
		<cfargument name="varStruct"  type="struct" required="true" hint="variable name">

		<cfset var lcl = StructNew() />
		<cfset lcl.iter = iterator(arguments.varStruct) />
		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfset variables.internalParser.assignVariable( lcl.iter.getKey(), lcl.iter.getCurrent() ) />
		</cfloop>
		<cfreturn this />
	</cffunction>

	<cffunction name="createErrorContext" returntype="any" output="false">
		<cfargument name="message" type="string" required="true" />

		<cfset variables.internalParser.createErrorContext(
			  message = arguments.message
			, detail = dumpErrors()
			, caught = variables.internalParser.getCurrentEbxContext().getCaught()
		)>

		<cfreturn this>
	</cffunction>

	<cffunction name="getOutput" returntype="string" output="false" hint="returns the layout as a free the sourced string">
		<cfargument name="raw" type="boolean" default="false">
		<cfif NOT arguments.raw>
			<cfreturn pf(this.layout).freeTheSource().get()>
		<cfelse>
			<cfreturn this.layout />
		</cfif>
	</cffunction>

	<cffunction name="displayOutput" returntype="any" output="true" hint="cfoutputs getOutput">
		<cfargument name="raw" type="boolean" default="false">
		<cfoutput>#getOutput( arguments.raw )#</cfoutput>
	</cffunction>

	<cffunction name="resetOutput" returntype="any" output="true" hint="resets the output buffer">
		<cfset this.layout = "">
		<cfreturn this />
	</cffunction>

	<!---
	Disabled because of heavy load and needs investigation.
	I suspect this is caused streaming content from within a cfc to the client

	<cffunction name="streamOutput" returntype="any" output="true" hint="streams getOutput using mimetype">
		<cfargument name="mime" type="string" default="text/html">
		<cfargument name="gzip" type="boolean" default="true">
		<cfargument name="etag" type="boolean" default="true">
		<cfargument name="raw" type="boolean" default="false">
		<cfargument name="reset" type="boolean" default="true">


		<cfset var lcl = StructCreate(
			  out   = getOutput(arguments.raw)
		)>

		<cfif arguments.etag AND sys().etag( lcl.out )>
			<!---
			*** Checkpoint Charlie! ***
			We have just sent a 304 response back to the client.
			Page execution halts here.
			 --->
		</cfif>

		<cfif arguments.gzip>
			<cfset sys().gzStreamMimeContent(sys().getGZMime(arguments.mime), lcl.out, arguments.mime, arguments.reset) />
		<cfelse>
			<cfset sys().streamMimeContent(arguments.mime, lcl.out, arguments.reset) />
		</cfif>
	</cffunction>
	 --->
	<cffunction name="dumpErrors" returntype="any" output="true" hint="outputs all encountered errors">
		<cfset var err =  getErrors()>

		<cfoutput>
			<cfloop from="1" to="#ArrayLen(err)#" index="i">
				<cftry>
					#__Dump().dumpCatch( err[i].getCaught() )#
					<cfcatch type="any">
						#__Dump().dumpCatch( cfcatch )#
					</cfcatch>
				</cftry>
			</cfloop>
		</cfoutput>
	</cffunction>

	<cffunction name="dumpExecutionStack" returntype="any" output="true" hint="outputs all encountered errors">

		<cfset var debugStack =  iterator( getInterface().getStackInterface().getExecutedStack()  )>
		<cfset var attr = "">
		<cfoutput>
			<style type="text/css">
			div.ebxerror {font-size: 80%; border: 0.2em solid silver; background: whitesmoke; padding: 0.25em;}
			div.ebxerror div {border: 0.3em solid gainsboro;}
			div.ebxerror div strong.function, div.ebxerror div strong em {font-size: 90%;}
			div.ebxerror div strong em {font-style: normal; font-size: 80%;}
			</style>
			<div class="ebxerror">
				<p>Debugging (#debugStack.getLength()# executed contexts)</p>
				<cfif debugStack.getLength()>
					<ul>
						<cfloop condition="#debugStack.whileHasNext()#">
							<li><strong>#debugStack.getCurrent().getTemplate()#</strong>:
								#debugStack.getCurrent().getType()# - #debugStack.getCurrent().getAction()#

								<cfset attr = iterator(debugStack.getCurrent().getAttributes()) />
								<cfif attr.getLength()>
									<ul>
										<cfloop condition="#attr.whileHasNext()#">
											<li>#LCASE(attr.getKey())# - #getDataType(attr.getCurrent())#</li>
										</cfloop>
									</ul>
								</cfif>
							</li>
						</cfloop>
					</ul>
				</cfif>
			</div>
		</cfoutput>
	</cffunction>

	<cffunction name="getExecutionStack" returntype="any" output="true" hint="outputs all encountered errors">

		<cfset var outstring = "">
		<cfsavecontent variable="outstring">
			<cfset dumpExecutionStack() />
		</cfsavecontent>
		<cfreturn outstring />
	</cffunction>

	<cffunction name="executeMain" output="true" returntype="boolean" hint="create main context and execute it. Return true on successfull execution. Setting layout is handled in executeContext??">
		<cfset var lcl = StructNew()>
		<cfset lcl.req.action   = variables.internalParser.getMainAction()>
		<cfset lcl.req.template = getParameter("switchfile")>
		<cfset lcl.req.type     = "mainrequest">

		<cfif getContext(argumentCollection=lcl.req)>
			<cfset variables.internalParser.updateParserFromContext("original")>
			<cfset executeContext()>
			<cfset executePostPlugins()>
			<cfset postContext()>
			<cfreturn true>
		</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="executeLayout" returntype="boolean" hint="create layout context and execute it. Return true on successfull execution">
		<cfargument name="layoutfile" type="string" default="#getProperty('layoutfile')#">

		<cfset var lcl = StructNew()>
		<cfset lcl.req.action   = "internal.pathto.layout">
		<cfset lcl.req.template = arguments.layoutfile>
		<cfset lcl.req.type     = "layout">

		<cfreturn do(argumentCollection=lcl.req)>
	</cffunction>

	<cffunction name="executePlugin" returntype="boolean" hint="create plugin context and execute it. Return true on successfull execution">
		<cfargument name="template"   required="true" type="string">
		<cfset var lcl = StructNew()>
		<cfset lcl.req.action   = "internal.pathto.plugins">
		<cfset lcl.req.template = arguments.template>
		<cfset lcl.req.type     = "plugin">

		<cfreturn do(argumentCollection=lcl.req)>
	</cffunction>

	<cffunction name="preContext" returntype="boolean" hint="prepend the stack with context, update the parser and customise attributes. Always return true.">
		<!--- <cfset variables.internalParser.addContextToStack()>
		<cfset variables.internalParser.updateParserFromContext()>
		<cfset variables.internalParser.setAttributesFromContext()> --->
		<cfreturn true>
	</cffunction>

	<cffunction name="postContext" returntype="boolean" hint="remove context from stack, update the parser and restore attributes. Always return true.">
		<cftry>
			<cfset variables.internalParser.restoreContextAttributes()>
			<cfset variables.internalParser.removeContextFromStack()>
			<cfset variables.internalParser.updateParserFromContext()>
			<cfreturn true>
			<cfcatch type="any">
				<!--- <cfdump var="#cfcatch#" /> --->
				<cfreturn false>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="executeContext" returntype="boolean" hint="include context-template and process context-result. Return true on successfull include.">
		<cfif variables.internalParser.executeContext()>
			<cfset variables.internalParser.handleContextOutput()>
			<cfreturn true>
		<cfelse>
			<!--- <cfset createErrorContext(message = "An ebx-context-error occurred")> --->
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="getContextOutput" returntype="any" hint="get context output">
		<cfreturn variables.internalParser.getContextOutput()>
	</cffunction>

	<cffunction name="executePostPlugins" output="true" returntype="boolean" hint="loop parsers current postplugin property, validate against defined plugins and execute plugin. Return true on successfull execution.">
		<cfset var lcl = StructNew()>

		<cftry>
			<!--- <cfset lcl.known_plugins = variables.ebx.getProperty('plugins')>
			<cfset lcl.plugins = getProperty('postPlugins')>

			<cfloop from="1" to="#ArrayLen(lcl.plugins)#" index="lcl.i">
				<cfif StructKeyExists(lcl.known_plugins, lcl.plugins[lcl.i])>
					<cfset executePlugin(lcl.known_plugins[lcl.plugins[lcl.i]])>
				</cfif>
			</cfloop> --->

			<cfcatch type="any">
				<cfreturn false>
			</cfcatch>
		</cftry>
		<cfreturn true>
	</cffunction>

	<cffunction name="parseSettings" returntype="boolean" hint="create settings context and execute it. Return true on successfull execution">
		<cfset var lcl = StructNew()>
		<cfset lcl.req.action   = "internal.pathto.settings">
		<cfset lcl.req.template = getParameter("settingsfile")>
		<cfset lcl.req.type     = "include">

		<cfset variables.settings_parsed = true>
		<cfreturn do(argumentCollection=lcl.req)>
	</cffunction>

	<cffunction name="parseLayouts" returntype="boolean" hint="create layouts context and execute it. Return true on successfull execution">
		<cfset var lcl = StructNew()>
		<cfif NOT getProperty("useviews")>
			<cfset lcl.req.action   = "internal.pathto.layouts">
			<cfset lcl.req.template = getParameter("layoutsfile")>
			<cfset lcl.req.type     = "include">
			<cfreturn do(argumentCollection=lcl.req)>
		<cfelse>
			<cftry>
				<cfset lcl.v = getView()>
				<cfif getEbx().hasLayout(lcl.v)>
					<cfreturn executeLayout(getLayoutView(lcl.v)) />
				<cfelse>
					<cfset createErrorContext("Error executing layout, does the view '#lcl.v#' exist?") />
					<cfreturn false />
				</cfif>
				<cfcatch type="any">
					<cfset createErrorContext("Error executing layout include, does your view exist? #cfcatch.Message# - #cfcatch.Detail#") />
					<cfreturn false />
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<!--- GETTERS / SETTERS --->
	<cffunction name="getVar" returntype="any" hint="get variable value from pagecontext">
		<cfargument name="name"  type="string" required="true" hint="variable name">
		<cfargument name="value" type="any"    required="false" default="" hint="default value to return if variable does not exist">
		<cfreturn variables.internalParser.getVar(arguments.name, arguments.value)>
	</cffunction>

	<cffunction name="getEbx" returntype="ebx" hint="return ebx-settings instance">
		<cfreturn variables.ebx>
	</cffunction>

	<cffunction name="getLayout" returntype="string" hint="return ebx-settings instance">
		<cfreturn this.layout>
	</cffunction>

	<cffunction name="getLayoutView" returntype="string" hint="return ebx-settings instance">
		<cfargument name="name" required="true" type="string" default="#getView()#" hint="name of the parameter">
		<cfreturn getEbx().getLayout( arguments.name ) />
	</cffunction>

	<cffunction name="setParameter"  returntype="ebx" hint="set a parameter and its public scope variant">
		<cfargument name="name"      required="true" type="string"  hint="name of the parameter">
		<cfargument name="value"     required="true" type="any"     default="" hint="value for the parameter">
		<cfargument name="overwrite" required="true" type="boolean" default="true" hint="by default does not overwrite existing parameters">
		<cfreturn variables.ebx.setParameter(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="setParameters" returntype="ebx" hint="set all parameters, but does not overwrite existing parameters">
		<cfargument name="parameters" required="true" type="struct"  hint="new parameter values">
		<cfargument name="overwrite"  required="true" type="boolean" default="false" hint="by default does not overwrite existing parameters">

		<cfreturn variables.ebx.setParameters(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getParameter" returntype="any" hint="get ebx parameter">
		<cfargument name="name"    type="string" required="true"  hint="parameter name">
		<cfargument name="default" type="any"    required="false" default="" hint="the default value to return if the parameter does not exist">
		<cfreturn variables.ebx.getParameter(arguments.name, arguments.default)>
	</cffunction>

	<cffunction name="getParameters" returntype="struct" hint="get all ebx parameters">
		<cfreturn variables.ebx.getParameters()>
	</cffunction>

	<cffunction name="getAttribute" returntype="any" hint="get page-attribute" output="false">
		<cfargument name="name"  type="string" required="true" hint="attribute name">
		<cfargument name="value" type="any"    required="false" default="" hint="value if unexistant">

		<cfreturn variables.internalParser.getAttribute(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getAttributes" returntype="any" hint="get page-attribute" output="false">
		<cfreturn variables.internalParser.getAttributes()>
	</cffunction>

	<cffunction name="hasAttribute" returntype="any" hint="get page-attribute">
		<cfargument name="name"  type="string" required="true" hint="attribute name">

		<cfreturn variables.internalParser.hasAttribute(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="paramAttribute" returntype="any" hint="set page-attribute">
		<cfargument name="name"  type="string" required="true" hint="attribute name">
		<cfargument name="value" type="any"    required="true" hint="value for attribute">

		<cfreturn variables.internalParser.paramAttribute(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="setAttribute" returntype="any" hint="set page-attribute">
		<cfargument name="name"  type="string" required="true" hint="attribute name">
		<cfargument name="value" type="any"    required="true" hint="value for attribute">

		<cfreturn variables.internalParser.setAttribute(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="unsetAttribute" returntype="any" hint="set page-attribute">
		<cfargument name="name"  type="string" required="true" hint="attribute name">

		<cfreturn variables.internalParser.unsetAttribute(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getInterface" returntype="any" hint="return internal parser">
		<cfreturn variables.internalParser>
	</cffunction>

	<cffunction name="hasErrors" returntype="boolean" hint="return if internal parser contains errors">
		<cfreturn ArrayLen(getErrors()) GT 0>
	</cffunction>

	<cffunction name="getErrors" returntype="array" hint="return internal parser errors">
		<cfreturn variables.internalParser.getErrors()>
	</cffunction>

	<cffunction name="getContext" returntype="boolean" hint="return true on succesfull creation from arguments">
		<cfargument name="type"       required="true" type="string" hint="context-type">
		<cfargument name="template"   required="true" type="string" hint="context-template">
		<cfargument name="action"     required="true" type="string" hint="context-action">
		<cfargument name="params"     required="false" type="struct"  default="#StructNew()#" hint="local params for the context">
		<cfargument name="contentvar" required="false" type="string"  default="" hint="content-variable to use for catching output">
		<cfargument name="append"     required="false" type="boolean" default="false" hint="append content-variable instead of overwrite">

		<cfreturn variables.internalParser.createContext(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="isOriginalAction" returntype="boolean" hint="return true if current action is original">
		<cfreturn this.originalAction neq "" AND this.originalAction eq this.thisAction>
	</cffunction>

	<cffunction name="setExecParameters" returntype="boolean" hint="initialise parser settings always return true">
		<cfargument name="scopecopy"  required="false" type="string"  default="url,form" hint="list of scopes to copy to attributes">
		<cfargument name="nosettings" required="false" type="boolean" default="false"    hint="do not parse settingsfile">
		<cfargument name="nolayout"   required="false" type="boolean" default="false"    hint="do not parse layout">
		<cfargument name="flush"   required="false" type="boolean" default="true"    hint="flush output to the page">
		<cfargument name="showerrors" required="false" type="boolean" default="false" hint="actually ment for debugging">
		<cfargument name="view" required="false" type="string"  default="html"         hint="set view from attributes">
		<cfargument name="useviews"   required="false" type="boolean" default="false"    hint="use views">

			<cfset setProperty("scopecopy", arguments.scopecopy, true)>
			<cfset setProperty("nosettings", arguments.nosettings, true)>
			<cfset setProperty("nolayout", arguments.nolayout, true)>
			<cfset setProperty("showerrors", arguments.showerrors, true)>
			<cfset setProperty("useviews", arguments.useviews, true)>

			<cfset setFlush(arguments.flush)>
			<cfset setView(arguments.view)>

		<cfreturn true>
	</cffunction>

	<cffunction name="getView" returntype="string" hint="">
		<cfreturn getProperty( "view", getProperty("defaultView", "") )>
	</cffunction>

	<cffunction name="setView" returntype="any" hint="Set the ">
		<cfargument name="view" type="string" required="true" hint="name for the view property">
			<cfset setProperty("view", arguments.view, true)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getFlush" returntype="string" hint="">
		<cfreturn getProperty( "flush", "true" )>
	</cffunction>

	<cffunction name="setFlush" returntype="any" hint="Set the ">
		<cfargument name="flush" type="boolean" required="true" hint="value for the flush property">
			<cfset setProperty("flush", arguments.flush, true)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setLayout" returntype="boolean" hint="update parser's layout property. always return true">
		<cfargument name="output" type="string" required="true" hint="output to assign">
		<cfset setProperty("layout", arguments.output)>
		<cfreturn true>
	</cffunction>

	<cffunction name="addCircuits"  returntype="any" hint="return true if adding circuit succeeds">
		<cfargument name="circuits" required="false" type="struct" default="#StructCreate()#" hint="circuit to add">

		<cfset var lcl = StructCreate(circuits = arguments.circuits)>
		<cfset StructDelete(arguments, "circuits") />
		<cfset StructAppend(lcl.circuits, arguments, true) />

		<cfset variables.ebx.addCircuits(circuits = lcl.circuits) />

		<cfreturn this />
	</cffunction>

	<cffunction name="hasCircuit"  returntype="boolean" hint="return true if circuit is available">
		<cfargument name="name" required="true" type="string" hint="circuit to check">

		<cfreturn variables.ebx.hasCircuit(argumentCollection = arguments) />
	</cffunction>

	<!--- <cffunction name="setPhase">
		<cfargument name="phase">
		<cfset setProperty("phase", arguments.phase)>
		<cfreturn true>
	</cffunction>

	<cffunction name="setState">
		<cfargument name="state">
		<cfset setProperty("state", arguments.state)>
		<cfreturn true>
	</cffunction>

	<cffunction name="hasLayoutPath">
		<cfreturn getProperty("layoutpath") neq "">
	</cffunction>

	<cffunction name="setLayoutPath">
		<cfset setProperty("layoutpath", getProperty("layoutdir") & getProperty("layoutfile"), true, true)>
		<cfreturn hasLayoutPath()>
	</cffunction>

	<cffunction name="getTicks">
		<cfreturn variables.internalParser.getTicks()>
	</cffunction>
	 --->

	<cffunction name="_setParamsFromArgs" returntype="ebxParser" hint="only used internally for passing arguments to context; modifies the given argumentcollection setting all named and not excluded arguments in the key params">
		<cfargument name="argcollection" type="struct" required="true" hint="original argumentcollection">
		<cfargument name="excludekeys"   type="string" required="false" hint="keys to exclude" default="">

		<cfset var local  = StructNew()>

		<cfif NOT StructKeyExists(arguments.argcollection, "params")>
			<cfset arguments.argcollection.params = StructNew()>
		</cfif>

		<cfloop collection="#arguments.argcollection#" item="lcl.key">
			<cfif lcl.key neq "params" AND NOT ListFindNoCase(arguments.excludekeys, lcl.key)>
				<!--- Insert named argument to parameter --->
				<cfset StructInsert(arguments.argcollection.params, lcl.key, arguments.argcollection[lcl.key], true)>
				<cfset StructDelete(arguments.argcollection, lcl.key)>
			</cfif>
		</cfloop>

		<cfreturn this>
	</cffunction>

	<cffunction name="updateAttributes" returntype="any" hint="merge page-attributes with given attributes, always overwrites existing attributes">
		<cfargument name="params" type="struct" required="true" default="#StructNew()#" hint="struct with new attributes values, named arguments are transformed">
		<cfset _setParamsFromArgs(arguments)>
		<cfreturn variables.internalParser.updateAttributes(arguments.params)>
		<!--- --->
	</cffunction>

	<cffunction name="paramAttributes" returntype="any" hint="parameterise attributes">
		<cfargument name="params" type="struct" required="true" default="#StructNew()#" hint="attribute parameters as struct, named arguments are transformed">

		<cfset _setParamsFromArgs(arguments)>
		<cfreturn variables.internalParser.updateAttributes(arguments.params, false)>
		<!--- --->
	</cffunction>

	<cffunction name="setSelf" returntype="any" hint="set self-parameter">
		<cfargument name="self" required="false" type="string" default="#CGI.SCRIPT_NAME#" hint="value used for self">
			<cfset this.self = arguments.self>
		<cfreturn this>
	</cffunction>

	<cffunction name="getSelf" returntype="string" hint="return CGI.SCRIPT_NAME">
		<cfreturn this.self>
		<!--- --->
	</cffunction>

	<cffunction name="getMySelf" returntype="string" hint="return scriptname + ?act=">
		<cfreturn getSelf() & "?" & getParameter("actionvar") & "=">
		<!--- --->
	</cffunction>

	<cffunction name="createXFA" returntype="struct" hint="create xfa struct and store it with given name for reuse">
		<cfargument name="name"   type="string" required="true" hint="name for xfa, will be used for action if it isn't specified">
		<cfargument name="action" type="string" required="false" default="#arguments.name#" hint="action for xfa defaults to name">
		<cfargument name="self"   type="string" required="false" hint="value for self defaults to getSelf()" default="#getSelf()#">

		<cfset var lcl = StructNew()>
		<cfset lcl.req = _createXFA(argumentCollection = arguments)>
		<cfif NOT StructIsEmpty(lcl.req)>
			<cfset StructInsert(variables.xfa, arguments.name, lcl.req, true)>
			<cfset StructInsert(lcl.req, "href", getXFA(arguments.name), true)>
			<cfset variables.internalParser.assignVariable(contentvar="xfa.#arguments.name#", value=lcl.req.href) />
			<!--- <cfset getEbxPageContext().assignVariable(name="xfa.#arguments.name#", value=lcl.req.href) /> --->
		</cfif>

		<cfreturn lcl.req>
		<!--- --->
	</cffunction>

	<cffunction name="_createXFA" returntype="struct" hint="create xfa struct">
		<cfargument name="action" type="string" required="true" hint="action for xfa">
		<cfargument name="name"   type="string" required="false" default="#arguments.action#" hint="name for xfa default to action name">
		<cfargument name="self"   type="string" required="false" hint="value for self defaults to getSelf()" default="#getSelf()#">


		<cfset var lcl = StructNew()>
		<cfset lcl.result = StructNew()>
		<cfset lcl.req = getParsedAction(arguments.action)>
		<cfif NOT StructIsEmpty(lcl.req)>
			<cfset lcl.result.action = lcl.req.action>
		<cfelse>
			<cfset lcl.result.action = arguments.action>
		</cfif>
		<cfset StructDelete(arguments, "action")>
		<cfset StructDelete(arguments, "name")>
		<cfset StructAppend(lcl.result, arguments, false)>

		<cfreturn lcl.result>
		<!--- --->
	</cffunction>

	<cffunction name="getParsedAction" output="false" returntype="struct" hint="create xfa struct">
		<cfargument name="action" type="string" required="true" hint="action for xfa">
		<cfreturn variables.internalParser.getParsedAction(arguments.action)>
	</cffunction>

	<cffunction name="getXFA" output="false" returntype="string" hint="get scriptname (use for href) link from xfa struct or given action">
		<cfargument name="name"   type="string" required="true" hint="name for xfa">
		<cfargument name="action" type="string" required="false" default="#arguments.name#" hint="action for xfa default to name">
		<cfargument name="self"   type="string" required="false" hint="the self-parameter used" default="#getSelf()#">

		<cfset var lcl = StructNew()>
		<cfif StructKeyExists(variables.xfa, arguments.name)>
			<cfset lcl.xfa = variables.xfa[arguments.name]>
			<cfset StructDelete(arguments, "name")>
			<cfset StructDelete(arguments, "action")>
			<cfset StructDelete(arguments, "self")>
			<cfset StructAppend(lcl.xfa, arguments, true)>
		<cfelse>
			<cfset lcl.xfa = _createXFA(argumentCollection = arguments)>
		</cfif>

		<cfreturn parseXFA(lcl.xfa)>
		<!--- --->
	</cffunction>

	<cffunction name="getCFXFA" output="false" returntype="string" hint="get scriptname (use for href) link from xfa struct or given action">
		<cfargument name="name"   type="string" required="true" hint="name for xfa">
		<cfargument name="action" type="string" required="false" default="#arguments.name#" hint="action for xfa default to name">
		<cfargument name="self"   type="string" required="false" hint="the self-parameter used" default="#getSelf()#">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = "">
		<cfif StructKeyExists(variables.xfa, arguments.name)>
			<cfset lcl.xfa = variables.xfa[arguments.name]>
			<cfset StructDelete(arguments, "name")>
			<cfset StructDelete(arguments, "action")>
			<cfset StructDelete(arguments, "self")>
			<cfset StructAppend(lcl.xfa, arguments, true)>
		<cfelse>
			<cfset lcl.xfa = _createXFA(argumentCollection = arguments)>
		</cfif>

		<cfreturn parseXFA(lcl.xfa, "&")>
		<!--- --->
	</cffunction>

	<cffunction name="parseXFA" output="false" returntype="string" hint="parse xfa-link from xfa struct">
		<cfargument name="xfa"         type="struct" required="true" hint="xfa struct">
		<cfargument name="qsdelimiter" type="string" required="false" default="&amp;" hint="delimiter used for querystring variables (for XHTML compliancy)">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = "">
		<cfset lcl.xfa = arguments.xfa>

		<cfset lcl.result = lcl.xfa.self & "?" & getParameter("actionvar") & "=" & lcl.xfa.action>
		<cfloop list="#StructKeyList(lcl.xfa)#" index="lcl.key">
			<cfif NOT ListFindNoCase("self,action,href", lcl.key)>
				<!--- Convert to wddx if value is complex?? --->
				<cfif IsSimpleValue(lcl.xfa[lcl.key])>
					<cfset lcl.result = lcl.result & arguments.qsdelimiter & LCASE(lcl.key) & "=" & URLEncodedFormat(lcl.xfa[lcl.key])>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn TRIM(lcl.result)>
		<!--- --->
	</cffunction>

	<cffunction name="newXFA" output="false" returntype="any" hint="creates a xfa object">
		<cfargument name="action" type="string" required="false"  hint="action for xfa" default="#getProperty('originalact')#">
		<cfargument name="self"   type="string" required="false" hint="the self-parameter used" default="#getSelf()#">
		<cfargument name="attrlist"   type="string" required="false" hint="attributes order" default="">

		<cfset var lcl = StructCreate(
			 keys = ListDeleteList(StructKeyList(arguments), "action,self,attrlist")
		)>
		<cfset lcl.keys = ListDeleteList(lcl.keys, arguments.attrlist)>
		<cfset lcl.keys = ListPrepend(lcl.keys, arguments.attrlist)>
		<cftry>
			<cfset lcl.attr = IndexedStructCreate(arguments, lcl.keys)>
			<cfcatch type="any">
				<cfdump var="#arguments#">
				<cfdump var="#local#">
				<cfdump var="#cfcatch#">
				<cfabort>
			</cfcatch>
		</cftry>

		<cfreturn createObject("component", "ebxXFA").init(this, arguments.action, arguments.self, lcl.attr)>
	</cffunction>

	<cffunction name="each" output="true" returntype="any" hint="execute action or template for each item in collection">
		<cfargument name="collection" type="any"     required="true"  hint="the collection to execute every action for">
		<cfargument name="action"     type="string"  required="true"  hint="action to execute">
		<cfargument name="itervar"    type="string"  required="false" default="_iter" hint="parametername in which the current iteration is passed">
		<cfargument name="contentvar" type="string"  required="false" default="" hint="content variable for do">
		<cfargument name="params"     type="struct"  required="false" default="#StructNew()#" hint="parameters for do">
		<cfargument name="append"     type="boolean" required="false" default="true" hint="append flag for do">

		<cfset var lcl = StructNew()>
		<cfset lcl.result     = "">
		<cfset lcl.req        = variables.internalParser.getParsedAction(arguments.action)>

		<cfif NOT StructIsEmpty(lcl.req)>
			<cfset lcl.itervar    = arguments.itervar>
			<cfset lcl.contentvar = arguments.contentvar>
			<cfset lcl.append     = arguments.append>

			<cfset _setParamsFromArgs(arguments, "collection,action,contentvar,append,itervar")>
			<cfset lcl.params = arguments.params>

			<cfset lcl.iter = iterator(arguments.collection)>
			<cfloop condition="#lcl.iter.whileHasNext()#">
				<cfset StructInsert(lcl.params, lcl.itervar, lcl.iter, true) />
				<cfif IsStruct(lcl.iter.getCurrent())>
					<cfset StructAppend(lcl.params, lcl.iter.getCurrent(), true) />
				</cfif>
				<cfset do(
					  action     = lcl.req.action
					, params     = lcl.params
					, contentvar = lcl.contentvar
					, append     = lcl.append
				)>
			</cfloop>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="setAction" returntype="any" hint="set main action circuitpath for circuit from ebx">
		<cfargument name="action" type="string" required="true" hint="action name">
			<cfset variables.internalParser.setMainAction(arguments.action)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getEbxPageContext" returntype="any" hint="return the pagecontext">
		<cfreturn variables.internalParser.getEbxPageContext()>
	</cffunction>

	<cffunction name="getCircuit" returntype="string" hint="return circuitpath for circuit from ebx">
		<cfargument name="circuit" type="string" required="true" hint="circuit name">
		<cfreturn variables.ebx.getCircuit(arguments.circuit)>
	</cffunction>

	<cffunction name="getAppPath" returntype="string" hint="return circuitpath for circuit from ebx">
		<cfargument name="trailingPath" type="string" required="false" default="" hint="trailing string for the path" />
		<cfreturn variables.ebx.getAppPath() & arguments.trailingPath />
	</cffunction>

	<cffunction name="getOriginalAction" returntype="string" hint="return originalaction from parser properties">
		<cfreturn getProperty("originalact")>
	</cffunction>


	<cffunction name="isLayoutRequest" returntype="boolean" hint="check if active context is layout context">
		<cfreturn getInterface().isLayoutRequest()>
	</cffunction>

	<cffunction name="isMainRequest" returntype="boolean" hint="check if active context is main context">
		<cfreturn getInterface().isMainRequest()>
	</cffunction>

</cfcomponent>