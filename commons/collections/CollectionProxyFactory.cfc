<cfcomponent extends="cfc.commons.AbstractObject">
	<cffunction name="createCollection">
		<cfargument name="data" type="any" required="true">
		
		<cfreturn createObject("component", "CollectionProxy").createCollection(arguments.data)>
	</cffunction>
	
	<cffunction name="ArrayCreate">
		<cfreturn createCollection( super._ArrayCreate(argumentCollection = arguments) )>
	</cffunction>
	
	<cffunction name="QueryCreate">
		<cfreturn createCollection( super._QueryCreate(argumentCollection = arguments) )>
	</cffunction>
	
	<cffunction name="StructCreate">
		<cfreturn createCollection( super._StructCreate(argumentCollection = arguments) )>
	</cffunction>
</cfcomponent>