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

		<cfset var local = StructNew()>
		<cfset local.q = getMatches(arguments.sniptext) />
		<cfif local.q.recordcount>
			<cfsavecontent variable="local.string">
				<cfoutput>
					<form method="post" action="#arguments.form_action#">
						<input type="hidden" name="sniptext" value="#URLEncodedFormat(arguments.sniptext)#">
						<cfloop query="local.q">
							<label for="#name#">#label#</label>
							<cfif ListLen(value,'|') GT 1>
								<select id="#name#" name="#name#">
									<cfloop list="#value#" index="local.opt" delimiters="|">
										<option value="#opt#">#local.opt#</option>
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
			<cfset local.string = arguments.sniptext />
		</cfif>

		<cfreturn local.string />
	</cffunction>

	<cffunction name="getReplacedSnippet" type="string" output="false" access="remote" hint="Gets the snippet with replaced values from a struct (most likely the form)">
		<cfargument name="sniptext" type="string" required="true"  hint="the snippet string to parse" />
		<cfargument name="struct"   type="struct" required="false" default="#StructNew()#" hint="the replacement values" />

		<cfset var local = StructNew()>
		<cfset local.str = URLDecode(arguments.sniptext) />
		<cfset local.q   = getMatches(URLDecode(arguments.sniptext)) />
		<cfif local.q.recordcount>
			<cfloop query="local.q">
				<cfif StructKeyExists(arguments.struct, name)>
					<cfset local.str = local.str.replaceAll("(" & escapeRegexPattern(orgmatch) & ")", arguments.struct[name]) />
				<cfelse>
					<cfset local.str = local.str.replaceAll("(" & escapeRegexPattern(orgmatch) & ")", value) />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn local.str />
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
		<cfset local.result  = StructNew() />
		<cfset local.matcher = _getMatcher(arguments.sniptext) />

		<cfloop condition="local.matcher.Find()">
			<cfif local.matcher.groupCount() eq 4>
				<cfset local.orgmatch = local.matcher.Group(JavaCast("string", 1)) />
				<cfset local.label    = local.matcher.Group(JavaCast("string", 3)) />
				<cfset local.name     = REReplace("[\t\s\n\r]+", local.label, "_", "ALL") />

				<cfset _addMatch(
					  name     = local.name
					, value    = REReplace(local.orgmatch, "^(.*?)\:(.*?)\}", "\2")
					, label    = local.label
					, orgmatch = local.orgmatch
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

		<cfset var local = StructNew() />

		<cfset QueryAddRow(getMatches()) />
		<cfloop list="#StructKeyList(arguments)#" index="local.key">
			<cfset QuerySetCell(getMatches(), local.key, arguments[local.key]) />
		</cfloop>

		<cfreturn this />
	</cffunction>

	<cffunction name="escapeRegexPattern" type="string" hint="Gets string with values escaped for regexp pattern">
		<cfargument name="rx_string" type="string" required="true" hint="the regexp string to escape" />

		<cfset var local = StructNew()>
		<cfset local.str   = arguments.rx_string>
		<cfset local.str = Replace(local.str, "$", "\$", "ALL")>
		<cfset local.str = Replace(local.str, "{", "\{", "ALL")>
		<cfset local.str = Replace(local.str, "}", "\}", "ALL")>
		<cfset local.str = Replace(local.str, "|", "\|", "ALL")>
		<cfset local.str = Replace(local.str, "[", "\[", "ALL")>
		<cfset local.str = Replace(local.str, "]", "\]", "ALL")>

		<cfreturn local.str />
	</cffunction>
</cfcomponent>