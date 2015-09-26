<cfcomponent name="ListPointer" extends="ArrayPointer">
	<cffunction name="init" output="true" returntype="any">
		<cfargument name="collection" type="any"   required="true" hint="an object of (extended) type commons.collections.ArrayCollection" />
		<cfargument name="index"      type="numeric" required="false" default="1" />
			<cfset super.init(arguments.collection, arguments.index, this)>
		<cfreturn this />
	</cffunction>

	<cffunction name="setPointer" output="true" returntype="any" hint="Sets the pointer properties">
		<cfargument name="index" type="numeric" required="true" />

		<cfif hasIndex(arguments.index)>
			<cfset super.setPointer( arguments.index, super.get(arguments.index) )>
		<cfelse>
			<cfset super.setPointer(0)>
		</cfif>
		<cfreturn this />
	</cffunction>
</cfcomponent>