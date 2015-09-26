<cfcomponent output="false" extends="AbstractQueryCollection" hint="Abstract array object">
	<cffunction name="init" output="false">
		<cfargument name="data" type="query" required="false">
		<cfargument name="cfc" type="any" required="false" hint="the collection object">
		<cfif NOT StructKeyExists(arguments, "data")>
			<cfset arguments.data = QueryNew("") />
		</cfif>
		<cfif NOT StructKeyExists(arguments, "cfc")>
			<cfset arguments.cfc = this />
		</cfif>
		<cfset super.init(arguments.data, arguments.cfc)>
		<cfreturn this>
	</cffunction>
</cfcomponent>