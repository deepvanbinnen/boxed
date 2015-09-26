<cfcomponent extends="cfc.commons.ValueObj" displayname="dbuser" output="false" hint="userobject for dbobject proxy">
	<cfset variables.dbo  = ObjectCreate("cfc.db.core.dbobject") />

	<cffunction name="init" returntype="any" output="false" hint="Initialises dbuser">
		<cfif StructKeyExists(arguments, "username") AND StructKeyExists(arguments, "password")>
			<cfset authenticate( argumentCollection=arguments) >
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="authenticate" returntype="boolean" output="false" hint="handles authentication">
		<cfargument name="username" required="true"  type="string" hint="username for authenticating" />
		<cfargument name="password" required="true"  type="any" hint="password for authenticating" />

		<cfif arguments.username EQ 'e-vision' AND arguments.password EQ 'POI*jkl0'>
			<cfset _setLoggedOn(true) />
		<cfelse>
			<cfset _setLoggedOn(false) />
		</cfif>
		<cfreturn isLoggedOn() />
	</cffunction>

	<cffunction name="isLoggedOn" returntype="boolean" output="false" hint="returns logged on flag">
		<cfif NOT StructKeyExists(variables, "loggedOn")>
			<cfset variables.loggedOn = false />
		</cfif>
		<cfreturn variables.loggedOn />
	</cffunction>

	<cffunction name="logout" returntype="boolean" output="false" hint="resets authenticated flag">
		<cfset _setLoggedOn(false) />
	</cffunction>

	<cffunction name="_setLoggedOn" returntype="any" access="private" output="false" hint="returns logged on flag">
		<cfargument name="flag" required="true"  type="boolean" hint="flag value" />
			<cfset variables.loggedOn = true />
		<cfreturn this />
	</cffunction>
</cfcomponent>