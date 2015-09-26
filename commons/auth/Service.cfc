<cfcomponent extends="Application" displayname="dbproxy" output="false" hint="service object for authentication">
	<!--- ******************************************************************************************************
	* PSEUDO CONSTRUCTOR
	******************************************************************************************************* --->

	<!---
	* Declare variables
	--->
	<cfset variables.instance = StructNew() />
	<cfset variables.post     = false />

	<!---
	* Append URL and FORM submit vars to instance struct
	--->
	<cfset StructAppend(variables.instance, url, true) />
	<cfif StructKeyExists(form, "fieldnames")>
		<cfset StructAppend(variables.instance, form, true) />
		<cfset variables.post = true />
	</cfif>

	<!---
	* Validate the wanted method
	--->
	<cfif NOT StructKeyExists(variables.instance, "method")>
		<!---
		** Set to login if no method is given
		--->
		<cfset variables.instance.method = "isAuthenticated" />
	<cfelse>
		<cfswitch expression="#variables.instance.method#">
			<cfcase value="login,authenticate,logout,isAuthenticated">
				<!---
				** methods for which authentication is not needed;
					don't do anything
				 --->
			</cfcase>
			<cfdefaultcase>
				<!---
				** check if we are authenticated
				 --->
				<cfif NOT isAuthenticated()>
					<!---
					*** Set to false if not authenticated
					--->
					<cfset variables.instance.method = "isAuthenticated" />
				</cfif>
			</cfdefaultcase>
		</cfswitch>
	</cfif>

	<!---
	** Reset original called method to validated method
	--->
	<cfset setMethod(variables.instance.method) />
	<!--- ************************************************************************************************* --->

	<cffunction name="authenticate" access="remote" returntype="boolean" output="true" hint="handles authentication">
		<cfargument name="j_username" required="true"  type="string" hint="username for authenticating" />
		<cfargument name="j_password" required="true"  type="any" hint="password for authenticating" />

		<cfreturn getUserSession().authenticate( arguments.j_username, arguments.j_password ) />
	</cffunction>

	<cffunction name="getInstance" access="remote" returntype="struct" output="true" hint="gets the instance vars">
		<cfreturn variables.instance />
	</cffunction>

	<cffunction name="isAuthenticated" access="remote" returntype="boolean" output="false" hint="returns authenticated state">
		<cfreturn getUserSession().isAuthenticated() />
	</cffunction>

	<cffunction name="logout" access="remote" returntype="void" output="true" hint="resets the user session">
		<cfset resetUserSession() />
	</cffunction>

	<cffunction name="setMethod" access="remote" returntype="any" output="true" hint="resets the user session">
		<cfargument name="method" required="true"  type="string" hint="method to call" />

		<cfset variables.instance.orgmethod = variables.instance.method>
		<cfset variables.instance.method = arguments.method>
		<cfif variables.post>
			<cfset form.method = arguments.method />
		<cfelse>
			<cfset url.method = arguments.method />
		</cfif>
	</cffunction>

	<cffunction name="dumpSession" access="remote" returntype="any" output="true" hint="get session info">
		<cfdump var="#session#">
	</cffunction>
</cfcomponent>