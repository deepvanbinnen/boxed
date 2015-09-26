<cfcomponent name="AbstractKeyIterator" extends="cfc.commons.AbstractIterator">
	<cffunction name="init" output="No" returntype="any">
		<cfargument name="pointer" type="any" required="true" />
			<cfset setIter( arguments.pointer ) />
			<cfset reset()>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getPointer" output="false" access="public" returntype="any">
		<cfreturn getIter() />
	</cffunction>
	
	<cffunction name="getCollection" output="false" access="public" returntype="any">
		<cfreturn getPointer().getCollection() />
	</cffunction>
	
	<cffunction name="whileHasNext" output="false">
		<cfif getPointer().hasNext()>
			<cfset getPointer().next()>
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
		<cfreturn getValue()>
	</cffunction>
	
	<cffunction name="getIndex" output="false">
		<cfreturn getPointer().getIndex()>
	</cffunction>
	
	<cffunction name="getKey" output="false">
		<cfreturn getPointer().getKey()>
	</cffunction>
	
	<cffunction name="getValue" output="false">
		<cfreturn getPointer().getKey()>
	</cffunction>
	
	<cffunction name="getLength" output="false">
		<cfreturn getPointer().getCollectionSize()>
	</cffunction>
	
	<cffunction name="getIterable" output="false">
		<cfreturn getCollection().getData()>
	</cffunction>
</cfcomponent>