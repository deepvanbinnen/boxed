<cfcomponent hint="Abstract extension for snipex">
	<!--- Regex used to get snippet variables --->
	<cfset variables.snipRX = "(\$\$\{(([a-zA-Z0-9_ ]+)(.*?))\})" />
	<!--- Compiled regex object --->
	<cfset variables.rxPat  = createObject(
		  "java"
		, "java.util.regex.Pattern"
	).Compile(
		  JavaCast("string", variables.snipRX)
	) />

	<cffunction name="getPlaceHolderForm" type="string" hint="Gets HTML-form for matched variables" output="false" access="remote">
		<cfargument name="sniptext"  type="string" required="true" hint="the snippet string to parse" />
		<cfargument name="form_action" type="string" required="false" default="" hint="the action for the form" />

		<cfset var lcl = StructNew()>
		<cfset lcl.q = getMatches(arguments.sniptext) />
		<cfif lcl.q.recordcount>
			<cfsavecontent variable="lcl.string">
				<cfoutput>
					<form method="post" action="#arguments.form_action#">
						<input type="hidden" name="sniptext" value="#URLEncodedFormat(arguments.sniptext)#">
						<cfloop query="lcl.q">
							<label for="#name#">#label#</label>
							<cfif ListLen(value,'|') GT 1>
								<select id="#name#" name="#name#">
									<cfloop list="#value#" index="lcl.opt" delimiters="|">
										<option value="#opt#">#lcl.opt#</option>
									</cfloop>
								</select>
							<cfelse>
								<input name="#name#" id="#name#" type="text" value="#value#" />
							</cfif>
						</cfloop>
						<input type="submit" value="get" />
					</form>
				</cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfset lcl.string = arguments.sniptext />
		</cfif>

		<cfreturn lcl.string />
	</cffunction>

	<cffunction name="getReplacedSnippet" type="string" output="false" access="remote" hint="Gets the snippet with replaced values from a struct (most likely the form)">
		<cfargument name="sniptext" type="string" required="true"  hint="the snippet string to parse" />
		<cfargument name="struct"   type="struct" required="false" default="#StructNew()#" hint="the replacement values" />

		<cfset var lcl = StructNew()>
		<cfset lcl.str = URLDecode(arguments.sniptext) />
		<cfset lcl.q   = getMatches(URLDecode(arguments.sniptext)) />
		<cfif lcl.q.recordcount>
			<cfloop query="lcl.q">
				<cfif StructKeyExists(arguments.struct, name)>
					<cfset lcl.str = lcl.str.replaceAll("(" & escapeRegexPattern(orgmatch) & ")", arguments.struct[name]) />
				<cfelse>
					<cfset lcl.str = lcl.str.replaceAll("(" & escapeRegexPattern(orgmatch) & ")", value) />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn lcl.str />
	</cffunction>

	<cffunction name="getMatches" returntype="query" access="remote" output="false" hint="Gets query containing match info">
		<cfargument name="sniptext" type="string" required="false" hint="the snippet string to parse" />
		<cfif NOT StructKeyExists(variables, "matchResults")>
			<cfset variables.matchResults = QueryNew("name,value,label,orgmatch") />
			<cfif StructKeyExists(arguments, "sniptext")>
				<cfset _processMatches(arguments.sniptext) />
			</cfif>
		</cfif>
		<cfreturn variables.matchResults />
	</cffunction>

	<cffunction name="_getMatcher" returntype="any" access="private" hint="Gets a new matcher for sniptext from compiled java regex pattern object">
		<cfargument name="sniptext" type="string" required="true" hint="the snippet string to parse" />
		<cfreturn variables.rxPat.Matcher( JavaCast("string", arguments.sniptext) ) />
	</cffunction>

	<cffunction name="_processMatches" returntype="any" access="private" output="false" hint="Processes the regex matches for snipstring">
		<cfargument name="sniptext" type="string" required="true" hint="the snippet string to parse" />

		<cfset var local     = StructNew() />
		<cfset lcl.result  = StructNew() />
		<cfset lcl.matcher = _getMatcher(arguments.sniptext) />

		<cfloop condition="lcl.matcher.Find()">
			<cfif lcl.matcher.groupCount() eq 4>
				<cfset lcl.orgmatch = lcl.matcher.Group(JavaCast("string", 1)) />
				<cfset lcl.label    = lcl.matcher.Group(JavaCast("string", 3)) />
				<cfset lcl.name     = REReplace("[\t\s\n\r]+", lcl.label, "_", "ALL") />

				<cfset _addMatch(
					  name     = lcl.name
					, value    = REReplace(lcl.orgmatch, "^(.*?)\:(.*?)\}", "\2")
					, label    = lcl.label
					, orgmatch = lcl.orgmatch
				) />
			</cfif>
		</cfloop>

		<cfreturn this />
	</cffunction>

	<cffunction name="_addMatch" returntype="any" access="private" hint="Adds match info to the match query">
		<cfargument name="name" required="true" type="string" hint="the name for the var" />
		<cfargument name="value" required="false" type="string" default="" hint="the default value" />
		<cfargument name="label" required="false" type="string" default="" hint="the default value" />
		<cfargument name="orgmatch" required="false" type="string" default="" hint="the original match" />

		<cfset var lcl = StructNew() />

		<cfset QueryAddRow(getMatches()) />
		<cfloop list="#StructKeyList(arguments)#" index="lcl.key">
			<cfset QuerySetCell(getMatches(), lcl.key, arguments[lcl.key]) />
		</cfloop>

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
</cfcomponent>