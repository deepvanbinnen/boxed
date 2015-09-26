<cfcomponent name="Pointer" extends="AbstractPointer" hint="Default pointer implementation. Determines operations based on the original collection's size and a stepvalue of 1 ">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="collection" type="any" required="true" />
		<cfargument name="pointerCFC" type="any" required="false" hint="concrete implementation cfc providing methods to maintain the data, defaults to this" />
			<cfset _setCollection(arguments.collection) />
			<cfif StructKeyExists( arguments, "pointerCFC" )>
				<cfset super._setPointer( arguments.pointerCFC ) />
			<cfelse>
				<cfset super._setPointer( this ) />
			</cfif>
		<cfreturn this />
	</cffunction>
</cfcomponent>
