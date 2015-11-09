<cfcomponent extends="com.googlecode.dbseries.ebx.ebxPageContext" hint="My custom page context with taconite ajax implementation">
	<cffunction name="setParser" hint="overrides the setParser method in AbstractParser. Custom init goes here">
		<cfargument name="parser" type="any" required="true" />
			<cfset super.setParser(parser = arguments.parser) />
			<cfif NOT StructKeyExists(variables, "content")>
				<cfset variables.content = StructCreate() />
			</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="getXHR" output="false" hint="Returns the xhr cfc and sets the view to xhr">
		<cfset getParser().setView("xhr")>
		<cfif NOT StructKeyExists(variables, "XHR")>
			<cfset variables.XHR = createObject("component", "cfc.xhr.Taconite2").init()>
		</cfif>
		<cfreturn variables.XHR>
	</cffunction>

	<cffunction name="getCSS" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists(variables, "_css")>
			<cfset variables._css = createObject("component", "CSSContext").init( this, ExpandPath("cache/css/") )>
		</cfif>
		<cfreturn variables._css />
	</cffunction>

	<cffunction name="getJS" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists(variables, "_js")>
			<cfset variables._js = createObject("component", "JSContext").init( this, ExpandPath("cache/js/") )>
		</cfif>
		<cfreturn variables._js />
	</cffunction>

	<cffunction name="getCustomCSS" output="false" hint="Returns the array with custom css files">
		<cfreturn getCSS().getCustomCSS()>
	</cffunction>

	<cffunction name="addCustomCSS" hint="Add custom CSS file">
		<cfargument name="cssfile" required="true" type="string" hint="relative path to css file" />
		<cfset getCSS().addCustomCSS( arguments.cssfile ) />
	</cffunction>

	<cffunction name="getDynamicCSS" output="false" hint="Returns the dynamic CSS declarations">
		<cfset getCSS().getDynamicCSS() />
	</cffunction>

	<cffunction name="appendDynamicCSS" output="false" hint="Appends css declaration to dynamic css">
		<cfargument name="css" required="true" type="string" hint="css declaration" />
		<cfset getCSS().appendDynamicCSS( arguments.css )>
	</cffunction>

	<cffunction name="getDynamicCSSCacheID" output="false" hint="Caches content and returns the hash for it ">
		<cfreturn getCSS().getDynamicCSSCacheID() />
	</cffunction>

	<cffunction name="displayCacheCSS" output="true" hint="Displays the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached css" />
		<cfoutput>#getCSS().getCacheCSS(arguments.cacheID)#</cfoutput>
	</cffunction>

	<cffunction name="getCustomJS" output="false" hint="Returns the array with custom JS files">
		<cfreturn getJS().getCustomJS()>
	</cffunction>

	<cffunction name="addCustomJS" hint="Add custom JS file">
		<cfargument name="JSfile" required="true" type="string" hint="relative path to JS file" />
		<cfset getJS().addCustomJS( arguments.JSfile ) />
	</cffunction>

	<cffunction name="getDynamicJS" output="false" hint="Returns the dynamic JS declarations">
		<cfset getJS().getDynamicJS() />
	</cffunction>

	<cffunction name="appendDynamicJS" output="false" hint="Appends JS declaration to dynamic JS">
		<cfargument name="JS" required="true" type="string" hint="JS declaration" />
		<cfset getJS().appendDynamicJS( arguments.JS )>
	</cffunction>

	<cffunction name="getDynamicJSCacheID" output="false" hint="Caches content and returns the hash for it ">
		<cfset var lcl = StructCreate( jqueryOnload = "")>
		<cfsavecontent variable="lcl.jqueryOnload">
		<cfoutput>jQuery( function($) {
				#getJS().getBodyOnloadJS()#
			}
		);</cfoutput>
		</cfsavecontent>
		<cfset appendDynamicJS(lcl.jqueryOnload) />
		<cfreturn getJS().getDynamicCacheID() />
	</cffunction>

	<cffunction name="displayCacheJS" output="true" hint="Displays the content of the file with cache id">
		<cfargument name="cacheID" required="true" type="string" hint="hashkey for the cached JS" />
		<cfoutput>#getJS().getCacheJS(arguments.cacheID)#</cfoutput>
	</cffunction>

	<cffunction name="getBodyOnloadJS" output="false" hint="Gets the body onload JS">
		<cfreturn getJS().getBodyOnloadJS() />
	</cffunction>

	<cffunction name="appendBodyOnloadJS" output="false" hint="Appends the body onload JS">
		<cfargument name="bodyOnloadJS" required="true" type="any" hint="the body onload JS" />
			<cfset getJS().appendBodyOnloadJS(argumentCollection = arguments) />
		<cfreturn this />
	</cffunction>

	<cffunction name="addBodyOnloadJS" output="false" hint="Appends the body onload JS">
		<cfargument name="bodyOnloadJS" required="true" type="any" hint="the body onload JS" />
		<cfreturn appendBodyOnloadJS(argumentCollection = arguments) />
	</cffunction>

</cfcomponent>