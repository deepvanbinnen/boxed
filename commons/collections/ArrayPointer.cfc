<cfcomponent name="ArrayPointer" extends="Pointer">
	<cffunction name="init" output="true" returntype="any">
		<cfargument name="collection" type="any"   required="true" hint="an object of (extended) type commons.collections.ArrayCollection" />
		<cfargument name="index"      type="numeric" required="false" default="1" />
		<cfargument name="cfc"  type="any" required="false" hint="concrete implementation cfc providing methods to maintain the data, defaults to this" />
			<cfif StructKeyExists( arguments, "cfc" )>
				<cfset super.init( arguments.collection, arguments.cfc ) />
			<cfelse>
				<cfset super.init(arguments.collection, this)>
			</cfif>
			<cfset setPointer( arguments.index )>
		<cfreturn this />
	</cffunction>

	<cffunction name="get" output="false" returntype="any">
		<cfargument name="index" type="numeric" required="false" hint="index" />
		<cfif NOT StructKeyExists(arguments, "index")>
			<cfset arguments.index = _getIndex() />
		</cfif>
		<cfreturn super.get(index = arguments.index)>
	</cffunction>

	<cffunction name="setPointer" output="true" returntype="any" hint="Sets the pointer properties">
		<cfargument name="index" type="numeric" required="true" />
		<cfif hasIndex(arguments.index)>
			<cfset super.setPointer(arguments.index, arguments.index)>
		<cfelse>
			<cfset super.setPointer( 0, 0)>
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="hasIndex" output="false" returntype="any">
		<cfargument name="index" type="numeric" required="false" default="#_getIndex()#" />
		<cfreturn arguments.index GT 0 AND arguments.index LTE size()>
	</cffunction>
</cfcomponent>