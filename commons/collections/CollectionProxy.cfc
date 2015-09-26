<cfcomponent output="false" extends="cfc.commons.AbstractObject">
	<cfset __constructor(
		    factory    = createObject("component", "CollectionFactory")
		  , collection = ""
	)>
	
	<cffunction name="createCollection" output="false">
		<cfargument name="data" type="any" required="true">
			<cfset  _setCollection( variables.factory.createCollectable(arguments.data) )>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getCollection" output="false">
		<cfreturn _getCollection().getCollection()>
	</cffunction>
	
	<cffunction name="_setCollection" output="false">
		<cfargument name="collection" type="any" required="true">
			<cfset variables.collection = arguments.collection>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="_getCollection" output="false">
		<cfreturn variables.collection>
	</cffunction>
	
	<cffunction name="add" output="false" hint="add element to collection">
		<cfargument name="data" type="any" required="true">
		<cfargument name="key"  type="string" required="false" default="">
		
		<cfreturn _getCollection().add(argumentCollection=arguments)>
	</cffunction>
	
	<cffunction name="addAll" output="false" hint="add element to collection">
		<cfargument name="data" type="any" required="true">
		
		<cfreturn _getCollection().addAll(argumentCollection=arguments)>
	</cffunction>
	
	<cffunction name="isEmpty" output="false" hint="add element to collection">
		<cfargument name="data" type="any" required="true">
		
		<cfreturn _getCollection().isEmpty()>
	</cffunction>
	
	<cffunction name="clear" output="false">
		<cfreturn _getCollection().clear()>
	</cffunction>
	
	<cffunction name="contains" output="false" hint="I return true if the collection contains the element" returntype="boolean">
		<cfargument name="element" type="any" required="true">
		
		<cfreturn _getCollection()._contains(arguments.element)>
	</cffunction>
	
	<cffunction name="containsAll" output="false">
		<cfargument name="elements" type="any" required="true">
		<cfreturn _getCollection().containsAll(arguments.elements)>
	</cffunction>
	
	<cffunction name="remove" output="false">
		<cfargument name="indexkey" type="string" required="true">
		<cfreturn _getCollection().remove(arguments.indexkey)>	
		
	</cffunction>
	
	<cffunction name="retainAll" output="false">
		<cfargument name="keys" type="string" required="true">
		<cfreturn _getCollection().retainAll(arguments.keys)>	
		
	</cffunction>
	
	<cffunction name="removeAll" output="false">
		<cfargument name="keys" type="string" required="true">
		<cfreturn _getCollection().removeAll(arguments.keys)>	
	</cffunction>
	
	<cffunction name="size" output="false">
		<cfreturn _getCollection().size()>
	</cffunction>
	
	<cffunction name="set" output="false">
		<cfargument name="indexkey" type="string" required="true">
		<cfargument name="data"     type="any"    required="true">
		
		<cfreturn _getCollection().set(arguments.indexkey, arguments.data)>
	</cffunction>
</cfcomponent>