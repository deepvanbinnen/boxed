<cfcomponent name="ListIterator" extends="cfc.commons.collections.ArrayIterator">
	<cffunction name="init" output="No" returntype="any">
		<cfargument name="pointer" type="any" required="true" />
			<cfset setIter( arguments.pointer ) />
		<cfreturn this />
	</cffunction>
</cfcomponent>