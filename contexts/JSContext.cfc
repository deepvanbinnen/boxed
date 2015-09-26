<cfcomponent extends="CacheContext" name="JSCache">
	<cffunction name="init" output="false" hint="Returns the array with custom JS files">
		<cfargument name="orgcontext" required="true" type="any" hint="original pagecontext" />
		<cfargument name="cachepath" required="true" type="string" hint="path to cache" />
		<cfargument name="customJSfiles" required="false" type="string" default="customJS"  hint="parser property in which custom js filepaths are stored as an array" />
		<cfargument name="dynJScontent"  required="false" type="string" default="dynamicJS" hint="parser property in which dynamic js is stored" />
		<cfargument name="bodyOnloadJS"  required="false" type="string" default=""          hint="JS executed in body onload" />
		
			<cfset super.init(
				  orgcontext = arguments.orgcontext
				, cachepath = arguments.cachepath
				, customfilesprop = arguments.customJSfiles
				, dyncontentprop = arguments.dynJScontent
			) />
			<cfset setBodyOnloadJS(arguments.bodyOnloadJS)>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getBodyOnloadJS" output="false" hint="Gets the body onload JS">
		<cfreturn variables.bodyOnloadJS />
	</cffunction>
	
	<cffunction name="setBodyOnloadJS" output="false" hint="Sets the body onload JS">
		<cfargument name="bodyOnloadJS" required="true" type="string" hint="the body onload JS" />
			<cfset variables.bodyOnloadJS = arguments.bodyOnloadJS />
		<cfreturn this />
	</cffunction>

	<cffunction name="appendBodyOnloadJS" output="false" hint="Appends the body onload JS">
		<cfargument name="bodyOnloadJS" required="true" type="any" hint="the body onload JS" />
			<cfset setBodyOnloadJS(getBodyOnloadJS() & arguments.bodyOnloadJS) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="addBodyOnloadJS" output="false" hint="Appends the body onload JS">
		<cfargument name="bodyOnloadJS" required="true" type="any" hint="the body onload JS" />
		<cfreturn appendBodyOnloadJS(argumentCollection = arguments) />
	</cffunction>
	
	<cffunction name="getCustomJS" output="false" hint="Returns the array with custom JS files">
		<cfreturn getCustomFiles()>
	</cffunction>
	
	<cffunction name="addCustomJS" hint="Add custom JS file">
		<cfargument name="JSfile" required="true" type="string" hint="relative path to JS file" />
			<cfset addCustomFile(arguments.JSfile) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getDynamicJS" output="false" hint="Returns the dynamic JS declarations">
		<cfreturn getDynamicContent()>
	</cffunction>
	
	<cffunction name="appendDynamicJS" output="false" hint="Appends JS declaration to dynamic JS">
		<cfargument name="JS" required="true" type="string" hint="JS declaration" />
		<cfreturn appendDynamicContent(arguments.JS)>
	</cffunction>
	
	<cffunction name="addDynamicJS" output="false" hint="Appends JS declaration to dynamic JS">
		<cfargument name="JS" required="true" type="string" hint="JS declaration" />
		<cfreturn appendDynamicJS(argumentCollection = arguments)>
	</cffunction>
	
	<cffunction name="getDynamicJSCacheID" output="false" hint="Caches content and returns the hash for it ">
		<cfreturn getDynamicCacheID() />
	</cffunction>
	
	<cffunction name="getCacheJS" output="false" hint="Returns the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached JS" />
		
		<cfreturn getCacheContent(arguments.cacheID) />
	</cffunction>
</cfcomponent>