<cfcomponent displayname="Singleton" hint="Singleton CFC with self instantiation">
	<!--- Make sure we are always constructed. See @init $hint --->
	<cfset variables.init() />

	<cffunction name="init" access="private" hint="Initialises instance struct. Access is private therefore this method cannot be accessed by the outside world.">
		<cfif NOT StructKeyExists(variables, "instance")>
			<cfset variables.instance = StructNew() />
		</cfif>
	</cffunction>

	<cffunction name="getInstance" access="public" hint="Get instance struct">
		<cfreturn variables.instance />
	</cffunction>
</cfcomponent>