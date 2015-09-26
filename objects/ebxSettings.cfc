<cfcomponent displayname="ebxSettings" output="false" hint="Settings object">
	<cffunction name="init" returntype="ebxSettings" output="false" hint="Initialises ebxSettings">
		<cfargument name="appPath"      required="true"  type="string"  default="" hint="coldfusion mapping to the root of the box">
		<cfargument name="defaultact"   required="false" type="string"  default="" hint="default action to excute if non is specified">
		<cfargument name="actionvar"    required="false" type="string"  default="act" hint="variable name that has the main action to execute">
		<cfargument name="circuitsfile" required="false" type="string"  default="ebx_circuits.cfm" hint="maps to the file that contains circuit settings">
		<cfargument name="pluginsfile"  required="false" type="string"  default="ebx_plugins.cfm" hint="maps to the file that contains plugin settings">
		<cfargument name="layoutsfile"  required="false" type="string"  default="ebx_layouts.cfm" hint="maps to the file that contains layout settings">
		<cfargument name="settingsfile" required="false" type="string"  default="ebx_settings.cfm" hint="maps to the file that contains global settings">
		<cfargument name="switchfile"   required="false" type="string"  default="ebx_switch.cfm" hint="maps to the file that contains global settings">
		<cfargument name="circuits"     required="false" type="struct"  default="#StructNew()#"    hint="ebox circuits">
		<cfargument name="plugins"      required="false" type="struct"  default="#StructNew()#"    hint="ebox circuits">
		<cfargument name="layouts"      required="false" type="struct"  default="#StructNew()#"    hint="ebox circuits">
		<cfargument name="forms2attrib" required="false" type="boolean" default="true" hint="convert formvariables to attributes">
		<cfargument name="url2attrib"   required="false" type="boolean" default="true" hint="convert urlvariables to attributes">
		<cfargument name="precedence"   required="false" type="string"  default="form" hint="if form and url variables are converted to attributes, which takes precedence?">
		<cfargument name="debuglevel"   required="false" type="numeric" default="0" hint="error level for debugmessages">
		<cfargument name="self"         required="false" type="string" default="#CGI.SCRIPT_NAME#"    hint="overridable self-parameter">

			<cfset setAppPath( arguments.appPath ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="getAppPath" returntype="string" output="false" hint="Getter for appPath">
		<cfreturn getInstance("appPath") />
	</cffunction>

	<cffunction name="setAppPath" returntype="ebxSettings" output="false" hint="Setter for appPath">
		<cfargument name="appPath" required="true"  type="string" hint="coldfusion mapping to the root of the box">
			<cfset setInstance("appPath", arguments.appPath) />
		<cfreturn this />
	</cffunction>

</cfcomponent>