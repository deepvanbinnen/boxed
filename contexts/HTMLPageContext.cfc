<cfcomponent extends="com.googlecode.dbseries.ebx.ebxPageContext"
	hint="Pagecontext for easy creation of a htmlpage. Contains CSS/JS/Taconite methods and a caching mechanism.">

	<cffunction name="init" output="true" hint="Returns the xhr cfc and sets the view to xhr">
		<cfargument name="csscache" required="false" type="string" default="#ExpandPath('cache/css/')#" hint="path to css cache dir" />
		<cfargument name="jscache" required="false" type="string" default="#ExpandPath('cache/js/')#" hint="path to js cache dir" />
		<cfargument name="cssfiles" required="false" type="array" default="#ArrayCreate()#" hint="array of default cssfiles" />
		<cfargument name="jsfiles" required="false" type="array" default="#ArrayCreate()#" hint="array of default jsfiles" />
		<cfargument name="loadlibs" required="false" type="string" default="taconite_client,taconite_parser,jquery,jquery_taconite,ebx_defaults" hint="libraries to load by default loads all available libraries" />

		<cfif NOT StructKeyExists(variables, "EBX_INIT")>
			<cfset variables.EBX_INIT  = 1 />
			<cfset variables.CSS_CACHE = arguments.csscache />
			<cfset variables.JS_CACHE  = arguments.jscache />

			<cfset variables.JS_LIBS   = StructCreate(
				  taconite_client = "/cfc/ebx/utils/scripts/taconite-client-min.js"
				, taconite_parser = "/cfc/ebx/utils/scripts/taconite-parser-min.js"
				, jquery          = "/cfc/ebx/utils/scripts/jquery.min.js"
				, jquery_taconite = "/cfc/ebx/utils/scripts/jquery.taconite.min.js"
				, ebx_defaults    = "/cfc/ebx/utils/scripts/jquery.ebx.defaults.js"
			) />
			<cfset variables.JS_LOAD = StructArray(variables.JS_LIBS, arguments.loadlibs) />
			<cfset variables.JS_FILES = arguments.jsfiles />
			<cfset variables.CSS_FILES = arguments.cssfiles />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="setParser" hint="overrides the setParser method in AbstractParser. Custom init goes here">
		<cfargument name="parser" type="any" required="true" />
			<cfset super.setParser(parser = arguments.parser) />
			<cfset addJSFiles(variables.JS_LOAD) />
			<cfset addJSFiles(variables.JS_FILES) />
			<cfset addCSSFiles(variables.CSS_FILES) />

			<cfif NOT StructKeyExists(variables, "content")>
				<cfset variables.content = StructCreate() />
			</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="getXHR" output="false" hint="Returns the xhr cfc and sets the view to xhr">
		<cfargument name="version" required="false" default="2"  type="numeric" hint="taconite version" />
		<cfargument name="reset"   required="false" default="false"  type="boolean" hint="reset xhr flag" />

		<cfset getParser().setView("xhr")>
		<cfif NOT StructKeyExists(variables, "XHR") OR arguments.reset>
			<cfset variables.XHR = createObject("component", "cfc.xhr.Taconite#arguments.version#").init()>
		</cfif>
		<cfreturn variables.XHR>
	</cffunction>

	<cffunction name="getTaconite" output="false" hint="Returns the taconite cfc and sets the view to xhr">
		<cfreturn this.getXHR(3) />
	</cffunction>

	<cffunction name="getCSSFiles" output="false" hint="Returns the array of css files">
		<cfreturn _getCSS().getCustomCSS()>
	</cffunction>

	<cffunction name="getCSSFilesContent" output="false" hint="Returns the content from the array of css files">
		<cfreturn _getCSS().getCustomCSSContent()>
	</cffunction>

	<cffunction name="displayCSSContent" output="true" hint="Outputs the content from the array of css files">
		<cfoutput>#getCSSFilesContent()#</cfoutput>
	</cffunction>

	<cffunction name="addCSSFile" hint="Add CSS file">
		<cfargument name="cssfile" required="true" type="string" hint="relative path to css file" />
		<cfset _getCSS().addCustomCSS( arguments.cssfile ) />
	</cffunction>

	<cffunction name="addCSSFiles" hint="Add list of CSS files">
		<cfargument name="cssfiles" required="true" type="array" hint="array with relative paths to css file" />

		<cfset var local = StructNew()>
		<cfset local.iter = iterator(arguments.cssfiles) />
		<cfloop condition="#local.iter.whileHasNext()#">
			<cfset addCSSFile(local.iter.getCurrent()) />
		</cfloop>
	</cffunction>

	<cffunction name="getCSS" output="false" hint="Returns the dynamic CSS declarations">
		<cfreturn _getCSS().getDynamicCSS() />
	</cffunction>

	<cffunction name="addCSS" output="false" hint="Appends css declaration to dynamic css">
		<cfargument name="css" required="true" type="string" hint="css declaration" />
		<cfset _getCSS().appendDynamicCSS( arguments.css )>
	</cffunction>

	<cffunction name="getCSSCacheID" output="false" hint="Caches content and returns the hash for it ">
		<cfreturn _getCSS().getDynamicCSSCacheID() />
	</cffunction>

	<cffunction name="displayCacheCSS" output="true" hint="Displays the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached css" />
		<cfoutput>#getCacheCSS(arguments.cacheID)#</cfoutput>
	</cffunction>

	<cffunction name="getCacheCSS" output="true" hint="Displays the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached css" />
		<cfreturn _getCSS().getCacheCSS(arguments.cacheID) />
	</cffunction>

	<cffunction name="getCustomJS" output="false" hint="Returns the array with custom JS files">
		<cfreturn _getJS().getCustomJS()>
	</cffunction>

	<cffunction name="addJSFile" hint="Add custom JS file">
		<cfargument name="JSfile" required="true" type="string" hint="relative path to JS file" />
		<cfset _getJS().addCustomJS( arguments.JSfile ) />
	</cffunction>

	<cffunction name="addJSFiles" hint="Add list of custom JS files">
		<cfargument name="jsfiles" required="true" type="array" hint="array with relative paths to js file" />
		<cfset var local = StructNew()>

		<cfset local.iter = iterator(arguments.jsfiles) />
		<cfloop condition="#local.iter.whileHasNext()#">
			<cfset addJSFile(local.iter.getCurrent()) />
		</cfloop>
	</cffunction>

	<cffunction name="getJS" output="false" hint="Returns the dynamic JS declarations">
		<cfreturn _getJS().getDynamicJS() />
	</cffunction>

	<cffunction name="addJS" output="false" hint="Appends JS declaration to dynamic JS">
		<cfargument name="JS" required="true" type="string" hint="JS declaration" />
		<cfset _getJS().appendDynamicJS( arguments.JS )>
	</cffunction>

	<cffunction name="getJSCacheID" output="false" hint="Caches content and returns the hash for it ">
		<cfset var local = StructCreate( jqueryOnload="", js=_getJS().getBodyOnloadJS() ) />
		<cfif NOT ise(local.js)>
			<cfsavecontent variable="local.jqueryOnload"><cfoutput>
			jQuery(function($){
				#local.js#
			});
			</cfoutput></cfsavecontent>
			<cfset addJS(local.jqueryOnload) />
		</cfif>
		<cfreturn _getJS().getDynamicCacheID() />
	</cffunction>

	<cffunction name="displayCacheJS" output="true" hint="Displays the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached JS" />
		<cfoutput>#getCacheJS(arguments.cacheID)#</cfoutput>
	</cffunction>

	<cffunction name="getCacheJS" output="true" hint="Displays the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached JS" />
		<cfreturn _getJS().getCacheJS(arguments.cacheID) />
	</cffunction>

	<cffunction name="getBodyOnloadJS" output="false" hint="Gets the body onload JS">
		<cfreturn _getJS().getBodyOnloadJS() />
	</cffunction>

	<cffunction name="appendBodyOnloadJS" output="false" hint="Appends the body onload JS">
		<cfargument name="bodyOnloadJS" required="true" type="any" hint="the body onload JS" />
			<cfset _getJS().appendBodyOnloadJS(argumentCollection = arguments) />
		<cfreturn this />
	</cffunction>

	<cffunction name="addBodyOnloadJS" output="false" hint="Appends the body onload JS">
		<cfargument name="bodyOnloadJS" required="true" type="any" hint="the body onload JS" />
		<cfreturn appendBodyOnloadJS(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="addOnloadJS" output="false" hint="Appends the body onload JS">
		<cfargument name="bodyOnloadJS" required="true" type="any" hint="the body onload JS" />
		<cfreturn appendBodyOnloadJS(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="_getCSS" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists(variables, "_css")>
			<cfset variables._css = createObject("component", "CSSContext").init( this, variables.CSS_CACHE )>
		</cfif>
		<cfreturn variables._css />
	</cffunction>

	<cffunction name="_getJS" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists(variables, "_js")>
			<cfset variables._js = createObject("component", "JSContext").init( this, variables.JS_CACHE )>
		</cfif>
		<cfreturn variables._js />
	</cffunction>

</cfcomponent>