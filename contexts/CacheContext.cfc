<cfcomponent extends="com.googlecode.dbseries.ebx.AbstractEBXParser" name="CacheContext">
	<cffunction name="init" output="false" hint="Initialises custom context with original context and cachepath">
		<cfargument name="orgcontext"      required="true" type="any" hint="original pagecontext" />
		<cfargument name="cachepath"       required="true" type="string" hint="path to cache" />
		<cfargument name="customfilesprop" required="true" type="string" hint="the parser property in which custom files are stored" />
		<cfargument name="dyncontentprop"  required="true" type="string" hint="the parser property in which the dynamic content stored" />

			<cfset setOrgContext(arguments.orgcontext) />
			<cfset setParser( getOrgContext().getParser() ) />
			<cfset setCachePath(arguments.cachepath) />
			<cfset setCustomFilesProp(arguments.customfilesprop) />
			<cfset setDynContentProp(arguments.dyncontentprop) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getOrgContext" output="false" hint="Get original context">
		<cfreturn variables.orgcontext />
	</cffunction>

	<cffunction name="setOrgContext" output="false" hint="Sets original context">
		<cfargument name="orgcontext" required="true" type="any" hint="original pagecontext" />
			<cfset variables.orgcontext = arguments.orgcontext />
		<cfreturn this />
	</cffunction>

	<cffunction name="getCachePath" output="false" hint="Gets root path for cache">
		<cfreturn variables.cachepath />
	</cffunction>

	<cffunction name="setCachePath" output="false" hint="Sets root path for cache">
		<cfargument name="cachepath" required="true" type="string" hint="path to cache" />
			<cfset variables.cachepath = arguments.cachepath />
		<cfreturn this />
	</cffunction>

	<cffunction name="getCustomFilesProp" output="false" hint="Gets the customfiles property">
		<cfreturn variables.customfilesprop />
	</cffunction>

	<cffunction name="setCustomFilesProp" output="false" hint="Sets the customfiles property">
		<cfargument name="customfilesprop" required="true" type="string" hint="property used for customfiles" />
			<cfset variables.customfilesprop = arguments.customfilesprop />
		<cfreturn this />
	</cffunction>

	<cffunction name="getDynContentProp" output="false" hint="Gets the dyncontent property">
		<cfreturn variables.dyncontentprop />
	</cffunction>

	<cffunction name="setDynContentProp" output="false" hint="Sets the dyncontent property">
		<cfargument name="dyncontentprop" required="true" type="string" hint="property used for dyncontentprop" />
			<cfset variables.dyncontentprop = arguments.dyncontentprop />
		<cfreturn this />
	</cffunction>

	<cffunction name="getCustomFiles" output="false" hint="Returns the array with custom  files">
		<cfreturn getProp(getCustomFilesProp(), ArrayCreate())>
	</cffunction>

	<cffunction name="addCustomFile" hint="Add custom CSS file">
		<cfargument name="file" required="true" type="string" hint="mapping path to file" />

		<cfset var lcl = StructCreate( files = getCustomFiles() )>
		<cfset ArrayAppend(lcl.files, arguments.file)>
		<cfset setProp(getCustomFilesProp(), lcl.files)>
	</cffunction>

	<cffunction name="getDynamicContent" output="false" hint="Returns the dynamic content">
		<cfreturn getProp(getDynContentProp(), "")>
	</cffunction>

	<cffunction name="appendDynamicContent" output="false" hint="Appends css declaration to dynamic css">
		<cfargument name="css" required="true" type="string" hint="css declaration" />
		<cfreturn setProp(getDynContentProp(), getDynamicContent() & arguments.css)>
	</cffunction>

	<cffunction name="getDynamicCacheID" output="false" hint="Caches content and returns the hash for it ">
		<cfset var lcl = StructCreate( content = getFileArrayContent() & getDynamicContent() ) />
		<cfif lcl.content neq "">
			<cfreturn getCacheID( lcl.content ) />
		</cfif>
		<cfreturn "" />
	</cffunction>

	<cffunction name="getCacheID" output="false" hint="Caches content and returns the hash for it ">
		<cfargument name="content" required="true" type="string" hint="hashkey for the cached css" />

		<cfset var lcl = StructCreate( cacheID = Hash(arguments.content) ) />
		<cfif NOT FileExists(getCachePath() & lcl.cacheID)>
			<cfset sys().writeFile(getCachePath() & lcl.cacheID, arguments.content) />
		</cfif>

		<cfreturn lcl.cacheID />
	</cffunction>

	<cffunction name="getCacheContent" output="false" hint="Returns the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached css" />

		<cfif FileExists(getCachePath() & arguments.cacheID)>
			<cfreturn sys().readFile(getCachePath() & arguments.cacheID) />
		</cfif>
		<cfreturn "" />
	</cffunction>

	<cffunction name="getFileArrayContent" output="false" hint="Returns the content from inclusion of the items in file-array">
		<cfset var lcl = StructCreate( iter = iterator(getCustomFiles()), result = "") />

		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfsavecontent variable="lcl.inc">
				<cftry>
					<cfoutput><cfinclude template="#lcl.iter.getCurrent()#" /></cfoutput>
					<cfcatch type="any">
						<cfoutput>/* #cfcatch.message#: #lcl.iter.getCurrent()# */</cfoutput>
						<!--- <cfdump var="#cfcatch#"> --->
					</cfcatch>
				</cftry>
			</cfsavecontent>
			<cfset lcl.result = ListAppend(lcl.result, lcl.inc, CHR(10)) />
		</cfloop>

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="purgeCache" output="false" hint="Purge the cache">
		<cfset var lcl = StructCreate( iter = iterator( sys().listdir( getCachePath() ) ) ) />
		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfset lcl.file = getCachePath() & lcl.iter.getCurrent("name")>
			<cfif FileExists(lcl.file)>
				<cffile action="delete" file="#lcl.file#" />
			</cfif>
		</cfloop>
		<cfreturn true>
	</cffunction>
</cfcomponent>