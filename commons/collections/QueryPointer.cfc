<cfcomponent name="QueryPointer" extends="Pointer">
	<cffunction name="init" output="true" reurntype="any">
		<cfargument name="collection" type="any" required="true" />
		<cfargument name="columns"    type="any" required="true" />
		<cfargument name="index"      type="numeric" required="false" default="0" />

			<cfset super.init( arguments.collection, this )>
			<cfset setColumns( arguments.columns )>
			<cfset setPointer( arguments.index )>

		<cfreturn this />
	</cffunction>

	<cffunction name="get" output="true">
		<cfargument name="column" type="string" required="true" default="#getColumns()#">
		<cfargument name="row" type="numeric"   required="false" default="#_getIndex()#">

		<cfreturn super.get(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getColumn" output="false">
		<cfreturn ListFirst(getColumns())>
	</cffunction>

	<cffunction name="getColumns" output="false">
		<cfreturn variables.columns>
	</cffunction>

	<cffunction name="setColumns" output="false">
		<cfargument name="columns" type="any" required="true">
			<cfset variables.columns = arguments.columns>
		<cfreturn this>
	</cffunction>

	<cffunction name="setPointer" output="true" returntype="any" hint="Sets the pointer properties">
		<cfargument name="index" type="numeric" required="true" />
		<cfargument name="key"   type="string"  required="false" default="naam" />

		<cfif _getCollection()._hasIndex(arguments.index)>
			<cfset super.setPointer(arguments.index, getColumns() )>
		<cfelse>
			<cfset super.setPointer(0, "")>
		</cfif>
		<cfreturn this />
	</cffunction>

</cfcomponent>