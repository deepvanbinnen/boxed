<cfcomponent displayname="Application" output="false" hint="Main Ebx Application">
	<cfset this.name = "EBX">
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(0,0,20,0)>

	<!--- Events --->
	<cffunction name="onApplicationStart" returntype="Boolean" output="false" hint="Initialise application pool">
		<cfif NOT StructKeyExists(application, "ebxAppPool")>
			<cfset _resetAppPool() />
		</cfif>
		<cfreturn true />
	</cffunction>

	<cffunction name="onApplicationEnd" returnType="void" output="false" hint="Cleanup application pool">
		<cfset _resetAppPool() />
	</cffunction>

	<!--- Runs when your session starts --->
	<cffunction name="onSessionStart" returnType="void" output="false" hint="Initialise session pool">
		<!---  --->
	</cffunction>

	<!--- Runs when session ends --->
	<cffunction name="onSessionEnd" returnType="void" output="false" hint="Cleanup session pool">
		<!--- <cfset _resetSesPool() /> --->
	</cffunction>

	<cffunction name="hasAppPool" returntype="any" output="false" hint="Gets application pool">
		<cfreturn StructKeyExists(application, "ebxAppPool") />
	</cffunction>

	<!--- Getters --->
	<cffunction name="getAppPool" returntype="any" output="false" hint="Gets application pool">
		<cftry>
			<cfif NOT hasAppPool()>
				<cfset _resetAppPool() />
			</cfif>
			<cfreturn application.ebxAppPool />
			<cfcatch type="any">
				<cfthrow type="Custom" message="ebxAppPool is undefined in Application" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getEbx" returntype="any" output="false" hint="Gets the ebx for the appkey">
		<cfargument name="appKey" type="string" required="true" />

		<cftry>
			<cfreturn getAppPool().getEbxApp(arguments.appKey) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="hasEbx" returntype="any" output="false" hint="Gets the ebx for the appkey">
		<cfargument name="appKey" type="string" required="true" />

		<cftry>
			<cfreturn getAppPool().containsEbxApp(arguments.appKey) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getAppScope" returntype="any" output="false" hint="Gets application scope for ebx-application key">
		<cfargument name="appKey" type="string" required="true" />

		<cfif StructKeyExists(application, arguments.appKey)>
			<cfreturn application[arguments.appKey] />
		<cfelse>
			<cfreturn StructNew() />
		</cfif>
	</cffunction>

	<cffunction name="getSesScope" returntype="any" output="false" hint="Gets session scope for ebx-application key">
		<cfargument name="appKey" type="string" required="true" />

		<cfif StructKeyExists(session, arguments.appKey)>
			<cfreturn session[arguments.appKey] />
		<cfelse>
			<cfreturn StructNew() />
		</cfif>
	</cffunction>

	<cffunction name="setAppVar" returntype="any" output="false" hint="sets the application scope for a given application key">
		<cfargument name="appKey" type="string" required="true" />
		<cfargument name="appVarKey" type="string" required="true" />
		<cfargument name="appVarValue" type="any" required="true" />

		<cfset var local = StructNew() />
		<cfset StructInsert( getAppScope(arguments.appKey), arguments.appVarKey, arguments.appVarValue, TRUE) />
		<cfreturn />
	</cffunction>

	<cffunction name="setSesVar" returntype="any" output="false" hint="sets the session scope for a given application key">
		<cfargument name="appKey" type="string" required="true" />
		<cfargument name="sesVarKey" type="string" required="true" />
		<cfargument name="sesVarValue" type="any" required="true" />
		<cfset var local = StructNew() />
		<cfset StructInsert( getSesScope(arguments.appKey), arguments.sesVarKey, arguments.sesVarValue, TRUE) />
		<cfreturn />
	</cffunction>

	<cffunction name="getAppVar" returntype="any" output="false" hint="Gets the application scope for a given application key">
		<cfargument name="appKey" type="string" required="true" />
		<cfargument name="appVarKey" type="string" required="true" />

		<cfset var local = StructNew() />
		<cfset local.app = getAppScope(arguments.appKey)>
		<cfif StructKeyExists(local.app, arguments.appVarKey)>
			<cfreturn local.app[arguments.appVarKey] />
		</cfif>
		<cfreturn />
	</cffunction>

	<cffunction name="getSesVar" returntype="any" output="false" hint="Gets the session scope for a given application key">
		<cfargument name="appKey" type="string" required="true" />
		<cfargument name="sesVarKey" type="string" required="true" />
		<cfset var local = StructNew() />
		<cfset local.ses = getSesScope(arguments.appKey)>
		<cfif StructKeyExists(local.ses, arguments.sesVarKey)>
			<cfreturn local.ses[arguments.sesVarKey] />
		</cfif>
		<cfreturn />
	</cffunction>

	<!--- Registration --->
	<cffunction name="registerEbx" returntype="any" output="false" hint="Registers an ebx application">
		<cfargument name="appKey" type="string" required="true" />
		<cfargument name="appPath" type="any" required="true" />

			<cfset _registerEbx( arguments.appKey, _createEbx(arguments.appPath) ) />
			<cfset _resetEbxAppScope( arguments.appKey ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="registerSession" returntype="any" output="false" hint="Registers an ebx application session">
		<cfargument name="appKey" type="string" required="true" />

			<cfset _resetEbxSesScope( arguments.appKey ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="unregisterSession" returntype="any" output="false" hint="Unregisters an ebx application session">
		<cfargument name="appKey" type="string" required="true" />

			<cfset _unsetEbxSesScope( arguments.appKey ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="unregisterEbx" returntype="any" output="false" hint="Unregisters an ebx application">
		<cfargument name="appKey" type="string" required="true" />

			<cfset getAppPool().unregisterEbxApp( arguments.appKey ) />
			<cfset _unsetEbxAppScope( arguments.appKey ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="_registerEbx" returntype="any" output="false" hint="Registers an ebx application in the pool">
		<cfargument name="appKey" type="string" required="true" />
		<cfargument name="ebxApp" type="any" required="true" />
			<cfset getAppPool().registerEbxApp(arguments.appKey, arguments.ebxApp) />
		<cfreturn this />
	</cffunction>

	<cffunction name="_resetEbxAppScope" returntype="any" output="false" hint="Resets the ebx-application scope">
		<cfargument name="appKey" type="string" required="true" />

		<cfif getAppPool().containsEbxApp(arguments.appKey)>
			<cfset application[arguments.appKey] = createObject("component", "ebxAppPoolEntry") />
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="_unsetEbxAppScope" returntype="any" output="false" hint="Entirely removes ebx-application (key)reference from main application scope">
		<cfargument name="appKey" type="string" required="true" />

		<cfif StructKeyExists(application, arguments.appKey)>
			<cfset StructDelete(application, arguments.appKey) />
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="_resetEbxSesScope" returntype="any" output="false" hint="Resets ebx-application session">
		<cfargument name="appKey" type="string" required="true" />

		<cfset session[arguments.appKey] = createObject("component", "ebxSesEntry") /> />

		<cfreturn this />
	</cffunction>

	<cffunction name="_unsetEbxSesScope" returntype="any" output="false" hint="Entirely removes ebx-application-session from session scope">
		<cfargument name="appKey" type="string" required="true" />

		<cfif StructKeyExists(session, arguments.appKey)>
			<cfset StructDelete(session, arguments.appKey) />
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="_resetAppPool" returntype="any" output="false" hint="(Re)creates the ebxApplicationPool instance">
		<cfset application.ebxAppPool = createObject("component", "ebxApplicationPool").init() />
		<cfreturn this />
	</cffunction>

	<cffunction name="_createEbx" returntype="any" output="false" hint="Creates a new ebx application">
		<cfargument name="appPath" type="string" required="true" />
		<cfreturn createObject("component", "ebx").init(arguments.appPath) />
	</cffunction>
</cfcomponent>
