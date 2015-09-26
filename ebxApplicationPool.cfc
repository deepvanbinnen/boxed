<cfcomponent displayname="ebxApplicationPool" output="false" hint="Shared ebxApplications container">
	<cffunction name="init" returntype="any" output="false" hint="Initialises ebxApplicationPool">
		<cfreturn this />
	</cffunction>

	<cffunction name="getAppPool" returntype="struct" output="false" hint="Getter for appPool">
		<cftry>
			<cfif NOT StructKeyExists(variables, "appPool")>
				<cfset resetAppPool() />
			</cfif>
			<cfreturn variables.appPool />
			<cfcatch type="any">
				<cfthrow message="No such variable: appPool" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getEbxApp" returntype="any" output="false" hint="Get ebx from applications key">
		<cfargument name="appKey" type="string" required="true" />
		<cftry>
			<cfif containsEbxApp(arguments.appKey)>
				<cfreturn variables.appPool[arguments.appKey] />
			<cfelse>
				<cfthrow type="Custom" message="No such key (#arguments.appKey#) in appPool. Unable to get EBX" />
			</cfif>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="containsEbxApp" returntype="any" output="false" hint="Checks ebxApp key">
		<cfargument name="appKey" type="string" required="true" />
		<cfreturn StructKeyExists(getAppPool(), arguments.appKey) />
	</cffunction>

	<cffunction name="registerEbxApp" returntype="any" output="false" hint="Registers an ebx application">
		<cfargument name="appKey" type="string" required="true" />
		<cfargument name="ebxApp" type="any" required="true" />
			<cfset StructInsert(getAppPool(), arguments.appKey, arguments.ebxApp, true) />
		<cfreturn this />
	</cffunction>

	<cffunction name="unregisterEbxApp" returntype="any" output="false" hint="Registers an ebx application">
		<cfargument name="appKey" type="string" required="true" />
		<cfif containsEbxApp(arguments.appKey)>
			<cfset StructDelete(getAppPool(), arguments.appKey) />
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="resetAppPool" returntype="any" output="false" hint="Setter for appPool">
		<cfset variables.appPool = StructNew() />
		<cfreturn this />
	</cffunction>

</cfcomponent>