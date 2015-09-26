<cfcomponent extends="AbstractWidget" displayname="Retriever" output="false" hint="Interface for retriever">
	<cffunction name="getValue" returntype="any" hint="returns the value">
		<cfargument name="keyname" required="true"  type="string" hint="to find a value for" />
		<cfargument name="scope"   required="false" type="struct" hint="in which to lookup the key's value, defaults to cf's form-scope" />

		<cfif NOT StructKeyExists(arguments, scope)>
			<cfset arguments.scope = form />
		</cfif>

		<cfif StructKeyExists(arguments.scope, arguments.key)>
			<cfreturn arguments.scope[arguments.key] />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>
</cfcomponent>