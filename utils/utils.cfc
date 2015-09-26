<cfcomponent extends="com.googlecode.dbseries.ebx.commons.AbstractObject" output="false">
	<cffunction name="init" hint="'constructor'">
		<cfreturn this>
	</cffunction>

	<cffunction name="pf" output="false" hint="get an instance of the 'PrettyFormat' component, used for strings, contains functions like FirstCap, SpaceToUnderScore etc..">
		<cfargument name="str" required="no"  type="string" default="" hint="String to initialise with">
		<cfargument name="trim" required="no" type="boolean" default="TRUE" hint="global flag 'trim' will be called on every 'set'">
		<cfargument name="flval" required="no" type="numeric" default="160" hint="when using full-left and no value is specified this number will be user for maximum characters">
		<cfreturn createObject("component", "pf").init(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="prep" output="false" hint="object that performs regex replacement for structkeys with values in a 'template'-like-string; by default searches for keys encapsulated in percentage-signs (e.g. %mykey%)">
		<cfargument name="template"    required="false" type="string" default="" hint="the string that contains values to be replaces">
		<cfargument name="keystart"    required="false" type="string" default="%" hint="the start character for identifying a replacement-key">
		<cfargument name="keyend"      required="false" type="string" default="%" hint="the end character for identifying a replacement-key ">
		<cfargument name="replacement" required="false" type="struct" default="#StructNew()#" hint="the struct with replacement keys and value">
		<cfreturn createObject("component", "PatternReplacer").init(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="matcher" output="false" hint="object that performs regex replacement for structkeys with values in a 'template'-like-string; by default searches for keys encapsulated in percentage-signs (e.g. %mykey%)">
		<cfargument name="regex"  required="true" type="string" hint="the regex string for">
		<cfargument name="string" required="false" type="string" default="" hint="the check string">
		<cfreturn createObject("component", "PatternReplacer").createMatcher(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getRXMatcher" output="false" hint="object that performs regex replacement for structkeys with values in a 'template'-like-string; by default searches for keys encapsulated in percentage-signs (e.g. %mykey%)">
		<cfif NOT StructKeyExists(variables, "rxMatcher")>
			<cfset variables.rxMatcher = createObject("component", "RXMatcher").init()>
		</cfif>
		<cfreturn variables.rxMatcher />
	</cffunction>

	<cffunction name="getMatchQuery" output="false" hint="object that performs regex replacement for structkeys with values in a 'template'-like-string; by default searches for keys encapsulated in percentage-signs (e.g. %mykey%)">
		<cfargument name="regex"  required="true" type="string" hint="the regex string for">
		<cfargument name="string" required="false" type="string" default="" hint="the check string">
		<cfargument name="groupCols" required="false" type="string" default="" hint="groupindexes as column names given as listpairs: 1=first_column,2=second_column">

		<cfreturn getRXMatcher().getMatches(arguments.regex, arguments.string, arguments.groupCols)>
	</cffunction>

	<cffunction name="widget" output="false" hint="object that performs regex replacement for structkeys with values in a 'template'-like-string; by default searches for keys encapsulated in percentage-signs (e.g. %mykey%)">
		<cfargument name="value"    required="true" type="string" hint="the regex string for">
		<cfargument name="datatype" required="false" type="string" default="" hint="the check string">


		<cfreturn createObject("component", "PatternReplacer").createMatcher(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="ip" output="false" hint="maps ip-addresses to owners used for debugging; returns booleans based on given CGI.REMOTE_ADDR">
		<cfparam name="variables.ipdebug" default="#StructNew()#">
		<cfif StructIsEmpty(variables.ipdebug)>
			<cfset variables.ipdebug = createObject("component", "IPDebug").init()>
		</cfif>
		<cfreturn variables.ipdebug>
	</cffunction>

	<cffunction name="testIP" output="false" hint="a quick call for debugging on IP">
		<cfreturn ip().testIP()>
	</cffunction>

	<cffunction name="html" output="false" hint="contains several functions to quickly generate HTML-tags">
		<cfargument name="attr_qualifier"  required="false" type="numeric" default="34" hint="ascii value of the character used to enquote attributes">
		<cfreturn createObject("component", "HTMLInterface").init(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="dbhtml" output="false" hint="Needed in order to make cfc-generator work!">
		<cfreturn createObject("component", "dbHTML").init(this)>
	</cffunction>

	<cffunction name="htmlc" output="false" hint="control HTML output; still in development">
		<cfargument name="attr_qualifier"  required="false" type="numeric" default="34" hint="ascii value of the character used to enquote attributes">
		<cfreturn createObject("component", "HTMLController").init(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="pair" output="false" hint="create a pair">
		<cfargument name="pair" required="true" type="string">
		<cfreturn createObject("component", "Pair").setPair(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="sys" output="false" hint="create a pair">
		<cfreturn createObject("component", "com.googlecode.dbseries.ebx.commons.SysProxy")>
	</cffunction>

	<cffunction name="prettyPrint" output="false" hint="pretty print HTML/XML string">
		<cfargument name="string"  required="true" type="string">
		<cfargument name="xmldecl" required="false" type="boolean" default="false" hint="add XML declaration?">

		<cfreturn pf().prettyPrint(string, (NOT xmldecl))>
	</cffunction>

	<cffunction name="freeTheSource" output="false" hint="...and the source will be free. Free!">
		<cfargument name="source"  required="true" type="string">

		<cfreturn pf().free(arguments.source).get()>
	</cffunction>

	<cffunction name="slice" output="false" hint="Take a slice out of a list. This method uses the underlying java 'subList' method.">
		<cfargument name="list"  required="true" type="string">
		<cfargument name="start" required="false" type="numeric" default="0">
		<cfargument name="end"   required="false" type="numeric" default="#ListLen(arguments.list)#">

		<cfset var local = StructNew()>
		<cfset local.arr = ListToArray(arguments.list)>
		<cfif arguments.end GT ListLen(arguments.list)>
			<cfset arguments.end = ArrayLen(local.arr)>
		</cfif>
		<cfreturn ArrayToList(local.arr.subList(arguments.start, arguments.end))>
	</cffunction>

	<cffunction name="dot" returntype="string" access="public">
		<cfset var s = "">
		<cfloop from="1" to="#ArrayLen(arguments)#" index="i">
			<cfset s = ListAppend(s, arguments[i], ".")>
		</cfloop>
		<cfreturn s>
	</cffunction>

	<cffunction name="formatSource" output="false" hint="Wraps given sourcecode in a pre-tag with all \n replaced by spans and the content HTML-escaped. ie: <pre class='source'><span class='line'>[LINECONTENT]</span></pre>">
		<cfargument name="source"  required="true" type="string">
		<cfargument name="wraptag"   required="false" type="string" default="pre">
		<cfargument name="wrapclass" required="false" type="string" default="source">
		<cfargument name="escapeHTML" required="false" type="boolean" default="true">

		<cfset var local = StructNew() />
		<cfset local.source = arguments.source />
		<cfif arguments.escapeHTML>
			<cfset local.source = pf(local.source).formatSourceCode().free().get()>
		</cfif>

		<cfif arguments.wraptag neq "">
			<cfset local.source = html().get(tag = arguments.wraptag, text=local.source, class=arguments.wrapclass)>
		</cfif>

		<cfreturn local.source>
	</cffunction>

	<cffunction name="fileSource" output="false" hint="Gets the content of a file wrapped in a pre-tag with all \n replaced by spans and the content HTML-escaped. ie: <pre class='source'><span class='line'>[LINECONTENT]</span></pre>">
		<cfargument name="filename"  required="true" type="string">
		<cfargument name="wraptag"   required="false" type="string" default="pre">
		<cfargument name="wrapclass" required="false" type="string" default="source">
		<cfargument name="escapeHTML" required="false" type="boolean" default="true">

		<cfset var local = StructNew() />
		<cftry>
			<cfset local.source = sys().readFile(arguments.filename) />
			<cfreturn formatSource( argumentCollection = arguments, source = local.source ) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="_fileSource" output="false" hint="Gets the content of a file wrapped in a pre-tag with all \n replaced by spans and the content HTML-escaped. ie: <pre class='source'><span class='line'>[LINECONTENT]</span></pre>">
		<cfargument name="filename"  required="true" type="string">

		<cfset var local = StructNew()>
		<cftry>
			<cffile action="read" file="#arguments.filename#" variable="local.source">
			<cfcatch type="any">
				<cfset local.source = "Unable to read file: #arguments.filename#">
			</cfcatch>
		</cftry>
		<cfreturn local.source>
	</cffunction>

	<cffunction name="_getDoc" output="false" hint="Gets documentation from given CFC. The maxdepth of following extensions can be controlled and default to -1.">
		<cfargument name="cfc"  required="true" type="any" default="#this#">
		<cfargument name="maxdepth" required="false" type="numeric" default="-1">
		<cfargument name="pdfname" type="string" required="false" default="">
		<cfargument name="format" type="string" required="false" default="html">

		<cfswitch expression="#arguments.format#">
			<cfcase value="pdf">
				<cfreturn createObject("component", "cfcdoc").getPDF(argumentCollection = arguments) />
			</cfcase>
			<cfcase value="story">
				<cfreturn createObject("component", "cfcdoc").getStory(argumentCollection = arguments) />
			</cfcase>
			<cfdefaultcase>
				<cfreturn createObject("component", "cfcdoc").getHTML(cfc=arguments.cfc, maxdepth=arguments.maxdepth) />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="getProtocol" output="false">
		<cfreturn __getProtocol()>
	</cffunction>

	<cffunction name="getCurrentURL" output="false">
		<cfreturn __getCurrentURL()>
	</cffunction>
</cfcomponent>