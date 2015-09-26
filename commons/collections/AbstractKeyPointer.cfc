<cfcomponent name="AbstractKeyPointer" extends="Pointer" hint="Implementation for a pointer of a list of keys over a collection that implements get(string)">
	<cffunction name="init" output="No" returntype="any">
		<cfargument name="collection"  type="any"  required="true" />
		<cfargument name="keyspointer" type="any"  required="true" />
		
			<cfset super.init(arguments.keyspointer.getCollection(), arguments.keyspointer)>
			<cfset variables.collection = arguments.collection>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="get" output="true" hint="Overwrites the get method for the ListPointer and returns the value for the key from the collection">
		<cfargument name="key" type="string" required="true" default="#getKey()#">
		<cfreturn getCollection().get(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getCollection" output="No" returntype="any">
		<cfreturn variables.collection  />
	</cffunction>
	
</cfcomponent>
