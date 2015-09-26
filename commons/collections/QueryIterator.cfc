<cfcomponent name="QueryIterator" extends="cfc.commons.AbstractIterator">
	<cffunction name="init" output="No" returntype="any">
		<cfargument name="pointer" type="any" required="true" />

			<cfset setIter( arguments.pointer ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getPointer" output="false" access="public" returntype="any">
		<cfreturn getIter() />
	</cffunction>

	<cffunction name="getCollection" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists( variables, "collection")>
			<cfthrow message="Collection is undefined in QueryIterator.cfc" />
		</cfif>
		<cfreturn getPointer().getCollection() />
	</cffunction>

	<cffunction name="whileHasNext" output="false">
		<cfif hasNext()>
			<cfset next()>
			<cfreturn true>
		</cfif>
		<cfset close()>
		<cfreturn false>
	</cffunction>

	<cffunction name="close" output="false">
		<cfreturn getPointer().setNullPointer()>
	</cffunction>

	<cffunction name="reset" output="false">
		<cfset getPointer().setPointer(0)>
	</cffunction>

	<cffunction name="getCurrent" output="false">
		<cfreturn getPointer().getValue(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getLength" output="false">
		<cfreturn getCollection().size()>
	</cffunction>

	<cffunction name="getIterable" output="false">
		<cfreturn getCollection()>
	</cffunction>
</cfcomponent>