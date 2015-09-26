<cfcomponent extends="CacheContext" name="CSSCache">
	<cffunction name="init" output="false" hint="Returns the array with custom css files">
		<cfargument name="orgcontext"     required="true"  type="any" hint="original pagecontext" />
		<cfargument name="cachepath"      required="true"  type="string" hint="path to cache" />
		<cfargument name="customcssfiles" required="false" type="string" default="customCSS"  hint="parser property in which custom css filepaths are stored as an array" />
		<cfargument name="dynCSScontent"  required="false" type="string" default="dynamicCSS" hint="parser property in which dynamic css is stored" />

			<cfset super.init(
				  orgcontext = arguments.orgcontext
				, cachepath = arguments.cachepath
				, customfilesprop = arguments.customcssfiles
				, dyncontentprop = arguments.dynCSScontent
			) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getCustomCSS" output="false" hint="Returns the array with custom css files">
		<cfreturn getCustomFiles()>
	</cffunction>

	<cffunction name="addCustomCSS" hint="Add custom CSS file">
		<cfargument name="cssfile" required="true" type="string" hint="mapping path to css file" />
			<cfset addCustomFile(arguments.cssfile) />
		<cfreturn this />
	</cffunction>

	<cffunction name="getDynamicCSS" output="false" hint="Returns the dynamic CSS declarations">
		<cfreturn getDynamicContent()>
	</cffunction>

	<cffunction name="appendDynamicCSS" output="false" hint="Appends css declaration string to dynamic css">
		<cfargument name="css" required="true" type="string" hint="css declaration" />
		<cfreturn appendDynamicContent(arguments.css)>
	</cffunction>

	<cffunction name="getDynamicCSSCacheID" output="false" hint="Caches content and returns the hash for it ">
		<cfreturn getDynamicCacheID() />
	</cffunction>

	<cffunction name="getCacheCSS" output="false" hint="Returns the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached css" />

		<cfreturn getCacheContent(arguments.cacheID) />
	</cffunction>

	<cffunction name="getCustomCSSContent" output="false" hint="Returns the content of the file with cache id">
		<cfreturn super.getFileArrayContent() & super.getDynamicContent() />
	</cffunction>
</cfcomponent>