<cfcomponent displayname="ebxReference" output="false" hint="A Composite object">
	<cffunction name="getOrigin" returntype="any" output="false" hint="Getter for origin">
		<cftry>
			<cfreturn variables.origin />
			<cfcatch type="any">
				<cfthrow message="No such variable: origin" />
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="setOrigin" returntype="any" output="false" hint="Setter for origin">
		<cfargument name="origin" required="true"  type="any" hint="origin : any">
			<cfset variables.origin = arguments.origin/>
		<cfreturn this />
	</cffunction>

</cfcomponent>