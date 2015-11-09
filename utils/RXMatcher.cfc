<cfcomponent hint="Snippets Regex Matcher">
	<cffunction name="init" returntype="any" output="false" hint="">
		<cfset resetPatterns() />
		<cfreturn this />
	</cffunction>

	<cffunction name="getMatches" returntype="any" output="false" hint="adds pattern to known patterns">
		<cfargument name="pattern"   type="string" required="true" hint="the pattern to match" />
		<cfargument name="text"      type="string" required="true" hint="the text to match the pattern on" />

		<cfreturn _processMatches(arguments.pattern, arguments.text) />
	</cffunction>

	<cffunction name="getPattern" returntype="any" output="false" hint="adds pattern to known patterns">
		<cfargument name="pattern" required="true"  type="string" hint="the pattern to get a compiled pattern for" />
		<cfset var lcl = StructNew() />
		<cfif NOT hasPattern(arguments.pattern)>
			<cfset addPattern(arguments.pattern) />
		</cfif>
		<cfset lcl.patterns = getPatterns() />
		<cfreturn lcl.patterns[hash(arguments.pattern)] />
	</cffunction>

	<cffunction name="hasPattern" returntype="any" output="false" hint="adds pattern to known patterns">
		<cfargument name="pattern" required="true"  type="string" hint="the pattern to get a compiled pattern for" />
		<cfreturn StructKeyExists(getPatterns(), Hash(arguments.pattern)) />
	</cffunction>

	<cffunction name="getPatterns" returntype="any" output="false" hint="adds pattern to known patterns">
		<cfreturn variables._patterns />
	</cffunction>

	<cffunction name="resetPatterns" returntype="any" output="false" hint="resets known patterns">
		<cfset variables._patterns = StructNew() />
		<cfreturn this />
	</cffunction>

	<cffunction name="createPattern" returntype="any" output="false" hint="adds pattern to known patterns">
		<cfargument name="pattern" required="true"  type="string" hint="the pattern to add" />
		<cfreturn createObject(
			  "java"
			, "java.util.regex.Pattern"
		).Compile(
			  JavaCast("string", arguments.pattern)
		) />
	</cffunction>

	<cffunction name="addPattern" returntype="any" output="false" hint="adds pattern to known patterns">
		<cfargument name="pattern" required="true"  type="string" hint="the pattern to add" />

		<cfset StructInsert(getPatterns(), Hash(arguments.pattern), createPattern(arguments.pattern), true) />
		<cfreturn this />
	</cffunction>

	<cffunction name="escapeRegexPattern" type="string" hint="Gets string with values escaped for regexp pattern">
		<cfargument name="rx_string" type="string" required="true" hint="the regexp string to escape" />

		<cfset var lcl = StructNew()>
		<cfset lcl.str   = arguments.rx_string>
		<cfset lcl.str = Replace(lcl.str, "$", "\$", "ALL")>
		<cfset lcl.str = Replace(lcl.str, "{", "\{", "ALL")>
		<cfset lcl.str = Replace(lcl.str, "}", "\}", "ALL")>
		<cfset lcl.str = Replace(lcl.str, "|", "\|", "ALL")>
		<cfset lcl.str = Replace(lcl.str, "[", "\[", "ALL")>
		<cfset lcl.str = Replace(lcl.str, "]", "\]", "ALL")>

		<cfreturn lcl.str />
	</cffunction>

	<cffunction name="getMatcher" returntype="any" access="public" hint="Gets a new matcher for sniptext from compiled java regex pattern object">
		<cfargument name="pattern" type="string" required="true" hint="the pattern to match" />
		<cfargument name="text" type="string" required="true" hint="the text to match the pattern on" />
		<cfreturn getPattern(arguments.pattern).Matcher( JavaCast("string", arguments.text) ) />
	</cffunction>

	<cffunction name="_processMatches" returntype="any" access="private" output="true" hint="Processes the regex matches for snipstring">
		<cfargument name="pattern"   type="string" required="true" hint="the pattern to match" />
		<cfargument name="text"      type="string" required="true" hint="the text to match the pattern on" />

		<cfset var local     = StructNew() />
		<cfset lcl.matcher = getMatcher(arguments.pattern, arguments.text) />
		<cfset lcl.result  = QueryNew("") />

		<cfloop condition="lcl.matcher.Find()">
			<cfset lcl.matchArgs = StructNew() />
			<cfdump var="#lcl.matcher.groupCount()#">
			<cfloop from="1" to="#lcl.matcher.groupCount()#" index="lcl.i">
				<cfset StructInsert(lcl.matchArgs, "M#lcl.i#", lcl.matcher.Group(JavaCast("string", lcl.i)), true) />
			</cfloop>
			<cfset lcl.result = _addMatch(argumentCollection=lcl.matchArgs, query=lcl.result) />
		</cfloop>

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="_addMatch" returntype="any" access="private" hint="Adds match info to the match query">
		<cfargument name="query" required="true" type="query" hint="the query to add the matches to" />

		<cfset var lcl = StructNew() />

		<cfset QueryAddRow(arguments.query) />
		<cfloop list="#StructKeyList(arguments)#" index="lcl.key">
			<cfif lcl.key NEQ "query">
				<cfif NOT ListFindNoCase(arguments.query.columnlist, lcl.key)>
					<cfset QueryAddColumn(arguments.query, lcl.key, ArrayNew(1)) />
				</cfif>
				<cfset QuerySetCell(arguments.query, lcl.key, arguments[lcl.key]) />
			</cfif>
		</cfloop>

		<cfreturn arguments.query />
	</cffunction>
</cfcomponent>