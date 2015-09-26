<cfcomponent extends="cfc.commons.Introspect">
	<cffunction name="createCollectable" hint="Alias for creating collection">
		<cfreturn createCollection(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="createCollection" hint="Creates a collection object for data, handles creation collection equivalents for cfdatatypes">
		<cfargument name="data" type="any" required="true" hint="The collection data">

		<cfset var lcl = StructCreate( type = getDatatype(arguments.data) )>
		<cfif hasCollectable(lcl.type)>
			<cfreturn ObjectCreate( getCollectable(lcl.type) ).init( arguments.data )>
		<cfelseif isCollectable(arguments.data)>
			<cfreturn arguments.data>
		<cfelse>
			<cfthrow message="No handle for data">
		</cfif>
	</cffunction>

	<cffunction name="createPointer" returntype="any" hint="Returns pointer instance from collectable">
		<cfreturn createCollectable(argumentCollection = arguments).getPointer()>
	</cffunction>

	<cffunction name="createIterator" output="false" hint="Returns iterator instance from collectable">
		<cfreturn createCollectable(argumentCollection = arguments).getIterator()>
	</cffunction>

	<cffunction name="getCollectable" hint="Gets collection object from the factory">
		<cfargument name="name" type="string" required="true">
		<cfif hasCollectable(arguments.name)>
			<cfreturn getCollectables().get(arguments.name)>
		</cfif>
		<cfthrow message="Unable to get collectable for: #arguments.name#">
	</cffunction>

	<cffunction name="getCollectables" hint="Gets all collection objects known to the factory">
		<cfif NOT StructKeyExists( variables, "collectables")>
			<cfset setCollectables()>
		</cfif>
		<cfreturn variables.collectables>
	</cffunction>

	<cffunction name="hasCollectable" hint="Checks if given cfc name is a known factory object">
		<cfargument name="name" type="string" required="true">
		<cfreturn StructKeyExists(getCollectables(), arguments.name)>
	</cffunction>

	<cffunction name="isCollectable" hint="Checks if cfc is created by the collection factory">
		<cfargument name="data" type="any" required="true">
		<cfreturn (
				getDatatype( arguments.data ) eq "cfc"
			AND isCollectableType( _getName( arguments.data ) )
		)>
	</cffunction>

	<cffunction name="isCollectableType" hint="Checks if given cfdatatype is known to the factory">
		<cfargument name="name" type="string" required="true" hint="a cfdatatype">
		<cfreturn StructValueArray( getCollectables() ).indexOf( arguments.name )>
	</cffunction>

	<cffunction name="setCollectables" hint="Setter for known collection objects mapped to cfdatatype">
		<cfset variables.collectables = StructCreate(
			  array  = "cfc.commons.collections.ArrayCollection"
			, struct = "cfc.commons.collections.StructCollection"
			, query  = "cfc.commons.collections.QueryCollection"
			, string = "cfc.commons.collections.ListCollection"
			, xml    = "cfc.commons.collections.AbstractXMLCollection"
			, object = "cfc.commons.collections.CollectionProxy"
		)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setIterators" hint="Setter for known iterator objects mapped to cfdatatype">
		<cfset variables.iterators = StructCreate(
			  array  = "cfc.commons.collections.ArrayIterator"
			, struct = "cfc.commons.collections.StructIterator"
			, query  = "cfc.commons.collections.QueryIterator"
			, string = "cfc.commons.collections.ListIterator"
			, xml    = "cfc.commons.collections.AbstractXMLIterator"
			, object = "cfc.commons.collections.CollectionProxy"
		)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setPointers" hint="Setter for known pointer objects mapped to cfdatatype">
		<cfset variables.pointers = StructCreate(
			  array  = "cfc.commons.collections.ArrayPointer"
			, struct = "cfc.commons.collections.AbstractKeyPointer"
			, query  = "cfc.commons.collections.QueryPointer"
			, string = "cfc.commons.collections.ListPointer"
			, xml    = "cfc.commons.collections.AbstractXMLPointer"
			, object = "cfc.commons.collections.CollectionProxy"
		)>
		<cfreturn this>
	</cffunction>
</cfcomponent>