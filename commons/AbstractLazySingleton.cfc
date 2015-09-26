<cfcomponent displayname="AbstractLazySingleton" hint="Laze Singleton CFC. The singleton is created on the first call to getInstance, not before.">
	<cfset variables.mynameis = getMetaData(this).name />
	<!---
	@URL http://en.wikipedia.org/wiki/Singleton_pattern#Java
	Java implementation
	 --->
	<cffunction name="getInstance" access="public" hint="Get instance struct">
		<cfif NOT StructKeyExists(variables, "instanceHolder")>
			<cfset variables.instanceHolder = createObject("component", "Singleton") />
		</cfif>
		<cfreturn variables.instanceHolder.getInstance() />
	</cffunction>

	<cffunction name="dump" access="public" hint="Dumps the instance holders Singleton">
		<cfset getInstance().dump() />
	</cffunction>

	<cffunction name="_dump" access="public" hint="Dump the lazy singleton's variables-scope to see if it is truely lazy.">
		<cfdump var="#variables#">
	</cffunction>
</cfcomponent>

