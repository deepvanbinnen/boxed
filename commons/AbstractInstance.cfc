<cfcomponent extends="AbstractObject" hint="This actually is an instance proxy">
	<cfset __constructor(instance = emptyInstance(), locked = false, public = "", publishAll = false)>
	<cfset __initInstance()>

	<cffunction name="get" hint="get property from instance">
		<cfargument name="key" type="string" required="true">
		<cfif StructKeyExists(variables.instance, arguments.key)>
			<cfreturn variables.instance[arguments.key]>
		</cfif>
		<cfreturn "">
	</cffunction>

	<cffunction name="set" hint="get property from the current instance">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="any" required="true" default="">
			<cfif mayUpdate(arguments.key)>
				<cfset StructInsert(variables.instance, arguments.key, arguments.value, true)>
				<cfset setPublicKey(arguments.key)>
			</cfif>
		<cfreturn this>
	</cffunction>


	<cffunction name="__initInstance__" hint="this method must be called by the extending instance to initialise instance properties">
		<cfargument name="cfc" type="any"      required="false" default="#this#">
		<cfargument name="lock" type="boolean" required="false" default="#isLocked()#">
		<cfargument name="public" type="string" required="false" default="#getPublic()#">
		<cfargument name="publishAll" type="boolean" required="false" default="#getPublishAll()#">

		<cfif arguments.publishAll>
			<cfset setPublic(StructKeyList(emptyInstance()))>
		<cfelse>
			<cfset setPublic(arguments.public)>
		</cfif>
		<cfset setInstance(arguments.cfc.emptyInstance())>
		<cfset setLocked(arguments.lock)>

		<cfreturn this>
	</cffunction>

	<cffunction name="__initInstance" hint="initialise instance properties">
		<cfargument name="cfc"        type="any"     required="false" default="#this#">
		<cfargument name="lock"       type="boolean" required="false" default="#isLocked()#">
		<cfargument name="public"     type="string"  required="false" default="#getPublic()#">
		<cfargument name="publishAll" type="boolean" required="false" default="false">

		<cfreturn __initInstance__(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="emptyInstance" hint="get a default empty instance, this function should be overriden in the extending CFC">
		<cfreturn StructCreate()>
	</cffunction>

	<cffunction name="setPublic" hint="get a default empty instance, this function should be overriden in the extending CFC">
		<cfargument name="public" type="string" required="true">
			<cfset variables.public = arguments.public	>
		<cfreturn this>
	</cffunction>

	<cffunction name="getPublic" hint="get a default empty instance, this function should be overriden in the extending CFC">
		<cfreturn variables.public>
	</cffunction>

	<cffunction name="setPublishAll" hint="get a default empty instance, this function should be overriden in the extending CFC">
		<cfargument name="publishall" type="boolean" required="true">
			<cfset variables.publishall = arguments.publishall	>
		<cfreturn this>
	</cffunction>

	<cffunction name="getPublishAll" hint="get a default empty instance, this function should be overriden in the extending CFC">
		<cfreturn variables.publishall>
	</cffunction>

	<cffunction name="init" hint="initialise instance properties">
		<cfargument name="data" type="struct" required="false" default="#StructNew()#">
		<cfset setInstance(arguments.data)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getInstance" hint="get the current instance">
		<cfreturn variables.instance>
	</cffunction>


	<cffunction name="setInstance" hint="set the current instance">
		<cfargument name="data" type="struct" required="false" default="#StructNew()#">

		<cfset var lcl = StructNew()>
		<cfset lcl.properties = _args(argumentCollection = arguments)>
		<cfset lcl.properties = arguments.data>
		<cfloop collection="#lcl.properties#" item="lcl.key">
			<cfif NOT isLocked() OR hasKey(lcl.key)>
				<cfset StructInsert(variables.instance, lcl.key, lcl.properties[lcl.key], true)>
				<cfset setPublicKey(lcl.key)>
			</cfif>
		</cfloop>
		<!--- <cfset updateInstance()> --->

		<cfreturn this>
	</cffunction>

	<cffunction name="hasKey" hint="update public property">
		<cfargument name="key" type="string" required="true">
		<cfreturn StructKeyExists(variables.instance, arguments.key)>
	</cffunction>

	<cffunction name="mayUpdate" hint="update public property">
		<cfargument name="key" type="string" required="true">
		<cfreturn getPublishAll() OR ListFindNoCase(getPublic(), arguments.key)>
	</cffunction>

	<cffunction name="setPublicKey" hint="update public property">
		<cfargument name="key" type="string" required="true">

		<cfif hasKey(arguments.key) AND mayUpdate(arguments.key)>
			<cfset this[arguments.key] = variables.instance[arguments.key]>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="newInstance" hint="create a new instance">
		<cfreturn createObject("component", _getName()).setInstance(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="dumpInstance" hint="initialise object for actueel table">
		<cfdump var="#getInstance()#">
		<cfreturn ''>
	</cffunction>

	<cffunction name="isLocked" hint="is instance locked">
		<cfreturn variables.locked>
	</cffunction>

	<cffunction name="setLocked" hint="'lock' instance keys (no keys can be added)">
		<cfargument name="lock" type="boolean" required="false" default="true">
			<cfset variables.locked = arguments.lock>
		<cfreturn this>
	</cffunction>

</cfcomponent>