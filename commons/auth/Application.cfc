<cfcomponent displayname="Application.cfc" output="false" hint="">
	<cfset this.name = "AUTHSERVICE">
	<cfset this.applicationTimeout = createTimeSpan(0,2,0,0)>
	<cfset this.sessionManagement  = true>
	<cfset this.sessionTimeout     = createTimeSpan(0,0,20,0)>
	<cfset this.userSessionKey     = "user"><!--- the session key name in which authService stores the user object --->
	<cfset this.userSessionObject  = "User"><!--- the session key name in which authService stores the user object --->

	<cffunction name="authenticate" access="public" returntype="boolean" output="false" hint="handles authentication">
		<cfargument name="j_username" required="true"  type="string" hint="username for authenticating" />
		<cfargument name="j_password" required="true"  type="any" hint="password for authenticating" />
		<cfreturn getUserSession().authenticate( arguments.j_username, arguments.j_password ) />
	</cffunction>

	<cffunction name="getUserSession" returntype="any" output="true" hint="creates an object for the user session">
		<cfif NOT StructKeyExists(session, this.userSessionKey)>
			<cfset _createUserSession() />
		</cfif>
		<cfreturn session[this.userSessionKey] />
	</cffunction>

	<cffunction name="onApplicationStart" returnType="boolean" output="false" hint="Initialise session pool">
		<cfreturn true>
	</cffunction>

	<cffunction name="onApplicationEnd" returnType="void" output="false" hint="Initialise session pool">
		<cfargument name="applicationScope" required="true"  type="any" hint="the session scope" />
	</cffunction>

	<cffunction name="onSessionStart" returnType="boolean" output="false" hint="Initialise session pool">
		<cfset _createUserSession() />
		<cfreturn true />
	</cffunction>

	<cffunction name="onSessionEnd" returnType="void" output="false" hint="Initialise session pool">
		<cfargument name="sessionScope" required="true"  type="any" hint="the session scope" />
		<cfargument name="applicationScope" required="true"  type="any" hint="the session scope" />
		<cfset StructDelete(arguments.sessionScope, this.userSessionKey) />
	</cffunction>

	<cffunction name="isAuthenticated" returntype="boolean" output="false" hint="checks authentication">
		<cfif NOT StructKeyExists(session, this.userSessionKey)>
			<cfset _createUserSession() />
		</cfif>
		<cfreturn session.user.isLoggedOn() />
	</cffunction>

	<cffunction name="resetUserSession" access="remote" returnType="void" output="false" hint="Initialise session pool">
		<cflock type="exclusive" timeout="5">
			<cfset _createUserSession() />
		</cflock>
	</cffunction>

	<cffunction name="_createUserSession" returntype="void" access="private" output="true" hint="creates an object for the user session">
		<cfset session[this.userSessionKey] = createObject("component", this.userSessionObject).init() />
	</cffunction>
</cfcomponent>