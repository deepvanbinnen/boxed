<cfcomponent extends="AbstractStructCollection" hint="Abstract struct object">
	<cffunction name="init" output="false">
		<cfargument name="data" type="struct" required="false">
		<cfargument name="cfc" type="any" required="false" hint="the collection object">
		<cfif NOT StructKeyExists(arguments, "data")>
			<cfset arguments.data = StructNew() />
		</cfif>
		<cfif NOT StructKeyExists(arguments, "cfc")>
			<cfset arguments.cfc = this />
		</cfif>
		<cfset super.init(arguments.data, arguments.cfc)>
		<cfreturn this />
	</cffunction>

	<cffunction name="createPointer" returntype="any">
		<cfreturn ObjectCreate("cfc.commons.collections.AbstractKeyPointer").init( this, createKeysPointer() )>
	</cffunction>

	<cffunction name="createIterator" output="false" hint="create the iterator for this collection">
		<cfreturn ObjectCreate("cfc.commons.collections.AbstractKeyIterator").init( createPointer() )>
	</cffunction>

	<cffunction name="createKeysPointer" returntype="any">
		<cfargument name="keys" type="string" required="false" default="#getKeys()#">
		<cfreturn ObjectCreate("cfc.commons.collections.ListCollection").init( getValidKeys(arguments.keys) ).createIterator()>
	</cffunction>

	<cffunction name="getValidKeys" output="true">
		<cfargument name="keys" type="string" required="true">
		<cfset var lcl = StructCreate( keys = ListToArray( getKeys() ))>
			<cfset lcl.keys.retainAll( ListToArray(arguments.keys) )>
		<cfreturn ArrayToList(lcl.keys)>
	</cffunction>

	<cffunction name="addAll" hint="Appends any object with filter applied as a struct. See the _toStruct() method for details on the conversion">
		<cfargument name="data" type="any" required="true">
		<cfargument name="filter" type="any" required="false">

		<cfset getCollection().putAll( _toStruct(argumentCollection = arguments) )>
		<!--- <cfset StructAppend(getCollection(),  _toStruct( argumentCollection = arguments ), true)> --->
		<cfreturn this>
	</cffunction>

	<cffunction name="get" output="false" hint="Returns the value for the given key.">
		<cfargument name="key" type="any" required="true">
		<cftry>
			<cfreturn getData().get( JavaCast('string', arguments.key) )>
			<cfcatch type="any">
				<cfthrow message="Error trying to get key">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getKeys">
		<cfif NOT StructKeyExists(variables, "keys")>
			<cfset variables.keys = getSortedKeys()>
		</cfif>
		<cfreturn variables.keys>
	</cffunction>

	<cffunction name="getSortedKeys">
		<cfreturn ListSort(_getKeys(), "text")>
	</cffunction>

	<cffunction name="setKeys">
		<cfargument name="keys" type="string" default="#getSortedKeys()#">
			<cfset variables.keys = arguments.keys>
		<cfreturn this>
	</cffunction>

	<cffunction name="size">
		<cfreturn ListLen(_getKeys())>
	</cffunction>

	<cffunction name="_getKeys">
		<cfreturn StructKeyList(getData())>
	</cffunction>
</cfcomponent>