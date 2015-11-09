<cfcomponent extends="AbstractObject" displayname="SimpleCache" output="false" hint="Simplified cache for collections">
	<cffunction name="init" returntype="any" output="false" hint="Initialises SimpleCache">
		<cfargument name="creator" type="any" required="true" hint="references a (external) method that returns a new object">
			<cfset variables.knownObjects = StructNew() />
			<cfset variables.createMethod = arguments.creator />
		<cfreturn this />
	</cffunction>

	<cffunction name="getObject" access="public" hint="Gets object for given id">
		<cfargument name="id" type="string" required="true" hint="is the id for the object">

		<cfset var lcl = StructCreate(object = getKnownObject(arguments.id))>
		<cfif IsBoolean(lcl.object)>
			<cfset lcl.object = createKnownObject(argumentCollection = arguments)>
			<cfset ArrayAppend(variables.knownObjects, lcl.object)>
		</cfif>
		<cfreturn lcl.object>
	</cffunction>

	<cffunction name="getKnownObjects" returntype="array" hint="Gets the array of known objects">
		<cfreturn variables.knownObjects>
	</cffunction>

	<cffunction name="getKnownObject" hint="Gets the object with given id from the array of known objects">
		<cfargument name="id" type="string" required="true" hint="is the id for the object">

		<cfset var lcl = StructCreate(iter = iterator(getKnownObjects()))>
		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfif lcl.iter.getCurrent().id eq arguments.id>
				<cfreturn lcl.iter.getCurrent() />
			</cfif>
		</cfloop>

		<cfreturn false>
	</cffunction>

	<cffunction name="createKnownObject" hint="Creates a new known object">
		<cfargument name="id" type="string" required="true" hint="is the id for the object">

		<cfset var lcl = StructCreate(
			  id     = arguments.id
			, object = variables.createMethod(argumentCollection = arguments)
		) />
		<cfreturn local />
	</cffunction>

</cfcomponent>
