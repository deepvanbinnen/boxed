<cfcomponent extends="com.googlecode.dbseries.ebx.utils.utils" name="AbstractEBXParser">
	<cffunction name="obtain" output="true" returntype="any" hint="executes do and returns the content as a string instead of outputting or contentvar">
		<cfreturn getParser().obtain(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="do" output="true" returntype="any">
		<cfreturn getParser().do(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="include" output="true" returntype="any">
		<cfreturn getParser().include(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="each" output="true" returntype="any">
		<cfreturn getParser().each(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="relocate" output="true" returntype="any" hint="relocates the request on the serverside">
		<cfif StructKeyExists(arguments, "action")>
			<cflocation addtoken="false" url="#getCFXFA(argumentCollection = arguments)#" />
		<cfelseif StructKeyExists(arguments, "href")>
			<cflocation addtoken="false" url="#arguments.href#" />
		</cfif>
	</cffunction>

	<cffunction name="attr" output="false" returntype="any" hint="Shorthand for getAttribute">
		<cfargument name="name" required="false"  type="string" hint="Property hint" />
		<cfargument name="value" required="false"  type="any" hint="Property hint" />
		<cfreturn getAttr(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="attrv" output="false" returntype="any" hint="Shorthand for setAttribute">
		<cfreturn setAttr(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getAttrArgs" output="false" returntype="any" hint="create an argumentCollection for get/set/paramAttribute">
		<cfreturn setAttr(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getAttr" returntype="any" hint="Shorthand for getAttribute" output="false">
		<cfset var a = StructCreate(name="", default="") />
		<cfif ArrayLen(arguments) eq 1>
			<cfset a.name    = StructKeyList(arguments) />
			<cfif IsNumeric(Val(a.name))>
				<cfset a.name = arguments[1] />
			<cfelse>
				<cfset a.value = arguments[1] />
			</cfif>
		<cfelseif ArrayLen(arguments) eq 2>
			<cfset a.name  = arguments[1] />
			<cfset a.value = arguments[2] />
		</cfif>
		<cftry>
			<cfreturn getParser().getAttribute(argumentCollection = a)>
			<cfcatch type="any">
				<cfdump var="#arguments#">
				<cfdump var="#a#">
				<cfdump var="#cfcatch#"><cfabort>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setAttr" returntype="any" hint="Shorthand for setAttribute">
		<cfset var a = StructCreate(name="", value="") />
		<cfif ArrayLen(arguments) eq 1>
			<cfset a.name    = StructKeyList(arguments) />
			<cfset a.value = arguments[1] />
		<cfelseif ArrayLen(arguments) eq 2>
			<cfset a.name  = arguments[1] />
			<cfset a.value = arguments[2] />
		</cfif>
		<cfreturn getParser().setAttribute(argumentCollection = a)>
	</cffunction>

	<cffunction name="hasAttr" returntype="any" hint="Shorthand for hasAttribute">
		<cfargument name="name" required="false"  type="string" hint="Property hint" />
		<cfreturn getParser().hasAttribute(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="unsetAttr" returntype="any" hint="Shorthand for unsetAttribute">
		<cfreturn getParser().unsetAttribute(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getProp" returntype="any" access="public" hint="return property value or if the property does not exist default value which defaults to empty string">
		<cfargument name="key"     required="true"  type="string" hint="key to get">
		<cfargument name="default" required="false" type="any"    default="" hint="default value to return if key doesn't exist">

		<cfreturn getParser().getProperty(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="setProp" returntype="boolean" access="public" hint="returns true on success otherwise false">
		<cfargument name="key"       required="true"  type="string"  hint="key to update">
		<cfargument name="value"     required="false" type="any"     default="" hint="value for the key">

		<cfreturn getParser().setProperty(arguments.key, arguments.value, true) />
	</cffunction>

	<cffunction name="getView" returntype="any" access="public" hint="return property value or if the property does not exist default value which defaults to empty string">
		<cfreturn getParser().getView( argumentCollection = arguments ) />
	</cffunction>

	<cffunction name="setView" returntype="any" access="public" hint="returns true on success otherwise false">
		<cfargument name="view"       required="true"  type="string"  hint="view to use">
			<cfset getParser().setView( argumentCollection = arguments ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="param" returntype="any" hint="Shorthand for paramAttributes">
		<cfset var a = StructCreate(name="", value="") />
		<cfif ArrayLen(arguments) eq 1>
			<cfset a.name    = StructKeyList(arguments) />
			<cfset a.value = arguments[1] />
		<cfelseif ArrayLen(arguments) eq 2>
			<cfset a.name    = arguments[1] />
			<cfset a.value = arguments[2] />
		</cfif>
		<cfreturn getParser().paramAttribute(argumentCollection = a)>
	</cffunction>

	<cffunction name="params" returntype="any" hint="Shorthand for paramAttributes">
		<cfreturn getParser().paramAttributes(arguments)>
	</cffunction>

	<cffunction name="getAbsCircPath" returntype="any" access="public" hint="returns absolute path to current circuit dir">
		<cfargument name="filename" required="false" type="string" default="" hint="filename to append at the end">
		<cfreturn REReplace(ListAppend(ListAppend(getParser().abspath, getParser().circuitdir, "/"), arguments.filename, "/"), "(\/){1,}", "/", "ALL") />
	</cffunction>

	<cffunction name="getMapCircPath" returntype="any" access="public" hint="returns absolute path to current circuit dir">
		<cfargument name="cfcname" required="false" type="string" default="" hint="cfcname to append at the end">
		<cfreturn REReplace(ListAppend(getParser().mappath, ListAppend(ListChangeDelims(getParser().circuitdir, ".", "/"), REReplace(arguments.cfcname, "\.cfc$", ""), "."), "."), "(\.){1,}", ".", "ALL") />
	</cffunction>

	<cffunction name="getXFA" output="No" returntype="any">
		<cfif StructKeyExists(arguments, "action") AND NOT StructKeyExists(arguments, "name")>
			<cfset arguments.name = arguments.action>
		</cfif>
		<cfreturn getParser().getXFA(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getCFXFA" output="No" returntype="any">
		<cfif StructKeyExists(arguments, "action") AND NOT StructKeyExists(arguments, "name")>
			<cfset arguments.name = arguments.action>
		</cfif>
		<cfreturn getParser().getCFXFA(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="createXFA" output="No" returntype="any">
		<cfset var lcl = LocalArgs(arguments)>
		<cfif lcl.args.getOriginalCount() eq 1 AND NOT lcl.args.parseRule(keylist="name", typelist="string")>
			<cfset lcl.args.remapSingleNamedArg("name,action")>
		</cfif>
		<cfreturn getParser().createXFA(argumentCollection = lcl.args.getArguments())>
	</cffunction>

	<cffunction name="createCFXFA" output="No" returntype="any">
		<cfset var lcl = LocalArgs(arguments)>
		<cfif lcl.args.getOriginalCount() eq 1 AND NOT lcl.args.parseRule(keylist="name", typelist="string")>
			<cfset lcl.args.remapSingleNamedArg("name,action")>
		</cfif>
		<cfreturn getParser().createCFXFA(argumentCollection = lcl.args.getArguments())>
	</cffunction>

	<cffunction name="getParser" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists( variables, "parser")>
			<cfthrow message="parser is undefined in scope this." />
		</cfif>
		<cfreturn variables.parser />
	</cffunction>

	<cffunction name="setParser" output="false" access="public" returntype="any">
		<cfargument name="parser" type="any" required="true" />
			<cfset variables.parser = arguments.parser />
		<cfreturn this />
	</cffunction>
</cfcomponent>