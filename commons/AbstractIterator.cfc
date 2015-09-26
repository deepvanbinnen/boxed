<cfcomponent output="false" extends="AbstractObject">
	<cffunction name="getIter" output="false">
		<cfif NOT StructKeyExists(variables, "iter")>
			<cfthrow message="No iterator in AbstractIterator">
		</cfif>
		<cfreturn variables.iter>
	</cffunction>

	<cffunction name="setIter" output="false">
		<cfargument name="iter" required="true" type="any">
			<cfset variables.iter = arguments.iter>
		<cfreturn this>
	</cffunction>

	<cffunction name="hasNext" output="false">
		<cfreturn getIter().hasNext(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="whileHasNext" output="false">
		<cfreturn getIter().whileHasNext(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="next" output="false">
		<cfreturn getIter().next(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="get" output="false">
		<cfreturn getIter().get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="close" output="false">
		<cfreturn getIter().close(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getCurrent" output="false">
		<cfreturn getIter().getCurrent(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getIndex" output="false">
		<cfreturn getIter().getIndex(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getKey" output="false">
		<cfreturn getIter().getKey(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getValue" output="false">
		<cfreturn getIter().getValue(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getLength" output="false">
		<cfreturn getIter().getLength(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getIterable" output="false">
		<cfreturn getIter().getIterable(argumentCollection=arguments)>
	</cffunction>
</cfcomponent>