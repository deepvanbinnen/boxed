<cfcomponent extends="Application" displayname="ebxApplicationProxy" output="false" hint="Application 'Proxy' object">
	<cffunction name="getEbxParser" returntype="ebxParser" hint="return a new instantiated parser">
		<cfargument name="defaultact"  required="true" type="string"  default="#getProperty('defaultact')#" hint="default act">
		<cfargument name="attributes"  required="false" type="struct"  default="#StructNew()#" hint="attributes to use in the parser">
		<cfargument name="scopecopy"   required="false" type="string"  default="url,form"      hint="list of scopes to copy to attributes">
		<cfargument name="nosettings"  required="false" type="boolean" default="false"         hint="do not parse settingsfile">
		<cfargument name="nolayout"    required="false" type="boolean" default="false"         hint="do not parse layout">
		<cfargument name="useviews"    required="false" type="boolean" default="true"         hint="do not parse inclusion of ebxParser.layoutFile and ebxParser.layoutDir">
		<cfargument name="initvars"    required="false" type="struct" default="#StructNew()#"  hint="'global' variables known to the box">
		<cfargument name="self"        required="false" type="string" default="#CGI.SCRIPT_NAME#"    hint="overridable self-parameter">
		<cfargument name="selfvar"     required="false" type="string" default="parser"    hint="global variablename for ebxParser">
		<cfargument name="flush"       required="false" type="boolean" default="true"    hint="flush request output to the page">
		<cfargument name="showerrors"  required="false" type="boolean" default="false" hint="flush error messages to the page">
		<cfargument name="view"        required="false" type="string"  default="html"         hint="the default view used">
		<cfargument name="attrview"    required="false" type="boolean" default="true" hint="set view from attributes">

		<cfreturn getEbx().getParser(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="getEbx" returntype="any" output="false" hint="Gets the ebx for the appkey">
		<cftry>
			<cfreturn getAppPool().getEbxApp( getAppKey() ) />
			<cfcatch type="any">
				<cfthrow type="Custom" message="No such ebxApp in appPool.">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="hasEbx" returntype="any" output="false" hint="Gets the ebx for the appkey">
		<cftry>
			<cfreturn super.hasEbx( getAppKey() ) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="onApplicationStart" returnType="any" output="false" hint="Registers ebx in application-scope with given key">
		<cftry>
			<cfset registerEbx( getAppKey(), getAppPath() ) />
			<cfset getAppScope().setOrigin( getAppCFC() ) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
		<cfreturn this />
	</cffunction>

	<cffunction name="onApplicationEnd" returnType="void" output="false" hint="Clears the application for the given application key">
		<cftry>
			<cfif hasEbx()>
				<cfset unRegisterEbx( getAppKey() ) />
			</cfif>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="onSessionStart" returnType="any" output="false" hint="Registers the user-session for the given application key">
		<cftry>
			<cfset registerSession( getAppKey() ) />
			<cfset getSesScope().setOrigin( getAppCFC() ) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>

	<cffunction name="onSessionEnd" returnType="void" output="false" hint="Clears the user-session for the given application key">
		<cftry>
			<cfset unregisterSession(  getAppKey() ) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getAppKey" returntype="any" output="false" hint="Gets the application key">
		<cftry>
			<cfreturn this.appKey />
			<cfcatch type="any">
				<cfthrow message="this.appKey must be set in the extending Application.cfc" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getAppPath" returntype="any" output="false" hint="Gets the application path">
		<cftry>
			<cfreturn this.appPath />
			<cfcatch type="any">
				<cfthrow message="this.appPath must be set in the extending Application.cfc" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getAppCFC" returntype="any" output="false" hint="Gets the application cfc">
		<cftry>
			<cfreturn this.appCFC />
			<cfcatch type="any">
				<cfthrow message="this.appPath must be set in the extending Application.cfc" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getAppList" returntype="any" output="false" hint="Gets a list of registered applications in ebx">
		<cftry>
			<cfreturn StructKeyList(getAppPool().getAppPool()) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getAppScope" returntype="any" output="false" hint="Gets the application scope for a given application key">
		<cfargument name="appKey" type="string" required="false" />

		<cfset var local = StructNew() />
		<cftry>
			<cfif StructKeyExists(arguments, "appKey")>
				<cfset local.appKey = arguments.appKey />
			<cfelse>
				<cfset local.appKey = getAppKey() />
			</cfif>
			<cfreturn super.getAppScope( getAppKey() ) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getSesScope" returntype="any" output="false" hint="Gets the session scope for a given application key">
		<cfargument name="appKey" type="string" required="false" />

		<cfset var local = StructNew() />
		<cftry>
			<cfif StructKeyExists(arguments, "appKey")>
				<cfset local.appKey = arguments.appKey />
			<cfelse>
				<cfset local.appKey = getAppKey() />
			</cfif>
			<cfreturn super.getSesScope(local.appKey) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setAppCFC" returntype="any" output="false" hint="Gets the application key">
		<cfargument name="appCFC" required="true"  type="any" hint="Property hint" />
			<cfset this.appCFC = arguments.appCFC />
		<cfreturn this />
	</cffunction>

	<cffunction name="setAppKey" returntype="any" output="false" hint="Gets the application key">
		<cfargument name="appKey" required="true"  type="string" hint="Property hint" />
			<cfset this.appKey = arguments.appKey />
		<cfreturn this />
	</cffunction>

	<cffunction name="setAppPath" returntype="any" output="false" hint="Gets the application key">
		<cfargument name="appPath" required="true"  type="string" hint="Property hint" />
			<cfset this.appPath = arguments.appPath />
		<cfreturn this />
	</cffunction>
</cfcomponent>