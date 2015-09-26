<cfcomponent output="false" extends="ArrayCollection" hint="Abstract list object">
	<cffunction name="init" output="false">
		<cfargument name="list"      type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">

			<cfif StructKeyExists(arguments, "data")>
				<cfset arguments.list = arguments.data />
			</cfif>
			<cfset _setDelimiter(arguments.delimiter)>
			<cfset super.init(_getAsArray(arguments.list), this)>
		<cfreturn this>
	</cffunction>

	<cffunction name="get" output="true">
		<cfargument name="index" type="any" required="false" default="#getIndex()#" />

		<cfset var local = StructCreate(index = arguments.index)>
		<cfif NOT isNumeric(arguments.index)>
			<cfset local.index = getCollection().indexOf(arguments.index)-1>
			<cfif local.index GTE 0>
				<cfset local.index = local.index + 1>
			<cfelse>
				<cfset local.index = 0>
			</cfif>
		</cfif>
		<cfreturn super.get(local.index)>
	</cffunction>

	<cffunction name="createPointer" returntype="any">
		<cfreturn ObjectCreate("cfc.commons.collections.ListPointer").init( this )>
	</cffunction>

	<cffunction name="createIterator" output="false" hint="create the iterator for this collection">
		<cfreturn ObjectCreate("cfc.commons.collections.ListIterator").init( createPointer() )>
	</cffunction>

	<cffunction name="getCollection" output="false">
		<cfreturn ArrayToList(getArray(), getDelimiter())>
	</cffunction>

	<cffunction name="getDelimiter" output="false" hint="get delimiter">
		<cfif NOT StructKeyExists(variables, "delimiter")>
			<cfthrow message="No delimiter in ListCollection">
		</cfif>
		<cfreturn variables.delimiter>
	</cffunction>

	<cffunction name="_getAsArray" output="false" hint="Returns array from list with set delimiter">
		<cfargument name="list"      type="string" required="true">
		<cfreturn ListToArray(arguments.list, getDelimiter())>
	</cffunction>

	<cffunction name="_setDelimiter" access="private" output="false" hint="Sets the delimiter for the list. This method must not be called directly">
		<cfargument name="delimiter" type="string" required="true">
			<cfset variables.delimiter = arguments.delimiter>
		<cfreturn this>
	</cffunction>

</cfcomponent>