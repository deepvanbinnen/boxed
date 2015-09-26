<cfcomponent extends="AbstractWidget" displayname="Validator" output="false" hint="Interface for validator">
	<cffunction name="validate" returntype="any" hint="validates a value">
		<cfargument name="value" type="any" required="true" hint="the value to validate" />
		<cfreturn true />
	</cffunction>
</cfcomponent>