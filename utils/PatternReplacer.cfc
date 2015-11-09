<cfcomponent hint="Replace string with encapsulated key occurances from a struct or array with corresponding values via regex">
	<!--- Start/End characters that need escaping in the regex --->
	<cfset variables.ESCAPES     = "[]{}|$?">
	<!--- Global flag --->
	<cfset variables.initialised = false>
	<!--- String to perform replacement on --->
	<cfset variables.template    = "">
	<!--- Struct containing keys and corresponding values for replacement --->
	<cfset variables.replacement = StructNew()>
	<!--- The variables that build up the regex --->
	<cfset variables.keyregex    = "">
	<cfset variables.keystart    = "%">
	<cfset variables.keyend      = "%">
	<!--- <cfset variables.patternObj  = CreateObject("java","java.util.regex.Pattern")> --->
	<!--- The matcher object --->
	<cfset variables.matcher     = "">
	<cfset variables.customRX    = "">
	<cfset variables.rxKeyIndex  = 2>
	<cfset variables.substIndex  = 1>

 	<cffunction name="init" hint="initialise">
		<cfargument name="template"    required="false" type="string" default="#getTemplate()#" hint="the string to perform object replacements on">
		<cfargument name="keystart"    required="false" type="string" default="#getKeyStart()#">
		<cfargument name="keyend"      required="false" type="string" default="#getKeyEnd()#">
		<cfargument name="customRX"    required="false" type="string" default="#getCustomRX()#">
		<cfargument name="rxKeyIndex"    required="false" type="string" default="#variables.rxKeyIndex#">
		<cfargument name="substIndex"    required="false" type="string" default="#variables.substIndex#">
		<cfargument name="replacement" required="false" type="struct" default="#StructNew()#" hint="the struct with replacement keys and value">

			<cfset setTemplate(arguments.template)>
			<cfset setKeyStart(arguments.keystart)>
			<cfset setKeyEnd(arguments.keyend)>
			<cfif arguments.customRX neq "">
				<cfset setCustomRX(arguments.customRX)>
				<cfset setRxKeyIndex(arguments.rxKeyIndex)>
				<cfset setSubstIndex(arguments.substIndex)>
			</cfif>
			<cfset setMatcher()>
			<cfset setReplacement(arguments.replacement)>

		<cfreturn this>
	</cffunction>

	<cffunction name="isInitialised" hint="has the component been initialised?">
		<cfreturn variables.initialised>
	</cffunction>

	<cffunction name="setInitialised" hint="set initialised flag">
		<cfset variables.initialised = true>
		<cfreturn this>
	</cffunction>

	<cffunction name="createMatcher" hint="create or reinitialise java matcher">
		<cfargument name="regex" required="true" type="string">
		<cfargument name="string" required="false" type="string" default="">

		<cfset setTemplate(arguments.string)>
		<cfreturn initMatcher(arguments.regex, arguments.string) />
	</cffunction>

	<cffunction name="initMatcher" hint="create or reinitialise java matcher">
		<cfargument name="regex" required="true" type="string">
		<cfargument name="string" required="false" type="string" default="">

		<cfset variables.matcher = CreateObject("java","java.util.regex.Pattern").Compile(JavaCast("string", arguments.regex)).Matcher(JavaCast( "string", arguments.string ))>

		<cfreturn this>
	</cffunction>

	<cffunction name="getMatcher" hint="get the matcher">
		<cfreturn variables.matcher>
	</cffunction>

	<cffunction name="getGroupCount" hint="get the matcher">
		<cfreturn getMatcher().groupCount() />
	</cffunction>

	<cffunction name="getMatches" hint="get the matcher">
		<cfreturn variables.matcher>
	</cffunction>

	<cffunction name="getKeyRegex" hint="get the regex used to match keys">
		<!--- Default regex: "(%([0-9a-zA-Z_]+)%)[\\]{0,1}" --->
		<cfreturn "(#getKeyStart()#([0-9a-zA-Z_]+)#getKeyEnd()#)[\\]{0,1}">
	</cffunction>

	<cffunction name="getKeyStart" hint="get the key's encapsulating start character">
		<cfreturn variables.keystart>
	</cffunction>

	<cffunction name="getKeyEnd" hint="get the key's encapsulating end character">
		<cfreturn variables.keyend>
	</cffunction>

	<cffunction name="getMatchKeys" hint="get the matched keylist">
		<cfargument name="groupIndex" required="false" default="1" type="numeric" hint="the group index for the key's match in the regex">
		<cfset var lcl = StructNew()>
		<cfset lcl.result = ArrayNew(1)>

		<cfset variables.matcher.reset(getTemplate())>
		<cfloop condition="variables.matcher.Find()">
			<cfset ArrayAppend(lcl.result, TRIM(variables.matcher.Group(JavaCast("string", arguments.groupIndex))))>
		</cfloop>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="getCustomRX" hint="get the replacement struct">
		<cfreturn variables.customRX>
	</cffunction>

	<cffunction name="getReplacement" hint="get the replacement struct">
		<cfreturn variables.replacement>
	</cffunction>

	<cffunction name="getTemplate" hint="get the string in which substitutions are made">
		<cfreturn variables.template>
	</cffunction>

	<cffunction name="substitute" hint="check if replace is actually needed before calling replace function">
		<cfargument name="replacement" required="true"  type="struct" default="#getReplacement()#" hint="Struct that contains the keys with it's replacement values">

		<cfset var lcl = StructNew()>
		<cfreturn _substitute(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="_substitute" hint="check if replace is actually needed before calling replace function">
		<cfargument name="replacement" required="true"  type="struct" default="#StructNew()#" hint="Struct that contains the keys with it's replacement values">
		<cfargument name="template"    required="false" type="string" default="#getTemplate()#" hint="String to perform replacement on, defaults to initialisation parameter">
		<cfargument name="keystart"    required="false" type="string" default="#getKeyStart()#">
		<cfargument name="keyend"      required="false" type="string" default="#getKeyEnd()#">
		<cfargument name="customRX"    required="false" type="string" default="#getCustomRX()#">
		<cfargument name="rxKeyIndex"    required="false" type="string" default="#variables.rxKeyIndex#">
		<cfargument name="substIndex"    required="false" type="string" default="#variables.substIndex#">

		<cfset var lcl = StructNew()>
		<!--- Used when called directly for instance by cfinvoke --->
		<cfif NOT isInitialised()>
			<cfset init(arguments.template, arguments.keystart, arguments.keyend, arguments.customRX, arguments.rxKeyIndex, arguments.substIndex)>
		</cfif>
		<cfset setReplacement(arguments.replacement)>
		<cfreturn substituteValues()>
	</cffunction>

	<cffunction name="needReplacement" hint="checks if replacement isn't empty and templatestring contains startkey and endkey">
		<cfargument name="replacement" required="false" type="struct" default="#StructNew()#">
		<cfreturn variables.customRX neq "" OR NOT StructIsEmpty(arguments.replacement) AND NOT getTemplate() eq "" AND Find(getKeyStart(), getTemplate()) AND Find(getKeyEnd(), getTemplate())>
	</cffunction>

	<cffunction name="setReplacement" hint="set the struct with keys and their replacements">
		<cfargument name="replacement" required="true" type="struct">
			<cfset variables.replacement = arguments.replacement>
		<cfreturn this>
	</cffunction>

	<cffunction name="setTemplate" hint="set the string in which substitutions are made">
		<cfargument name="template" required="true" type="string">
			<cfset variables.template = arguments.template>
		<cfreturn this>
	</cffunction>

	<cffunction name="setKeyRegex" hint="the regex to use when matching keys">
		<cfargument name="regex" required="false" type="string" default="#getKeyRegex()#">
			<cfset variables.keyregex = arguments.regex>
		<cfreturn this>
	</cffunction>

	<cffunction name="setKeyStart" hint="set the key's encapsulating start character, defaults to percentage sign">
		<cfargument name="keystart" required="true" type="string">
			<cfset variables.keystart = arguments.keystart>
			<cfif Find(arguments.keystart, variables.ESCAPES)>
				<cfset variables.keystart = "\" & variables.keystart>
			</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setKeyEnd" hint="set the key's encapsulating end character, defaults to percentage sign">
		<cfargument name="keyend" required="true" type="string">
			<cfset variables.keyend = arguments.keyend>
			<cfif Find(arguments.keyend, variables.ESCAPES)>
				<cfset variables.keyend = "\" & variables.keyend>
			</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setCustomRX" hint="set the replacement rx">
		<cfargument name="customRX" required="true" type="string">
		<cfargument name="rxKeyIndex" required="false" type="numeric" default="#variables.rxKeyIndex#">
		<cfargument name="substIndex" required="false" type="numeric" default="#variables.substIndex#">
			<cfset variables.customRX = arguments.customRX>
			<cfset setRXKeyIndex(arguments.rxKeyIndex)>
			<cfset setSubstIndex(arguments.substIndex)>
			<cfset setMatcher()>
		<cfreturn this>
	</cffunction>

	<cffunction name="setRXKeyIndex" hint="set the key's encapsulating end character, defaults to percentage sign">
		<cfargument name="rxKeyIndex" required="true" type="string">
			<cfset variables.rxKeyIndex = arguments.rxKeyIndex>
		<cfreturn this>
	</cffunction>

	<cffunction name="setSubstIndex" hint="set the key's encapsulating end character, defaults to percentage sign">
		<cfargument name="substIndex" required="true" type="string">
			<cfset variables.substIndex = arguments.substIndex>
		<cfreturn this>
	</cffunction>

	<cffunction name="setMatcher" hint="create compiled regex pattern and corresponding matcher object">
		<cfset var lcl = StructNew()>
		<cfset lcl.compileRX = variables.customRX>
		<cfif lcl.compileRX eq "">
			<cfset lcl.compileRX = getKeyRegex()>
		</cfif>
		<cfset initMatcher(lcl.compileRX)>
		<cfset setInitialised()>
		<cfreturn this>
	</cffunction>

	<cffunction name="substituteValue" hint="create compiled regex pattern and corresponding matcher object">
		<cfargument name="string" type="string" required="true">
		<cfargument name="oldval" type="string" required="true">
		<cfargument name="newval" type="string" required="true">

		<cfset var lcl = StructNew()>

		<cfset lcl.str   = arguments.string>
		<cfset lcl.subst = Replace(arguments.oldval, "$", "\$", "ALL")>
		<cfset lcl.subst = Replace(lcl.subst, "{", "\{", "ALL")>
		<cfset lcl.subst = Replace(lcl.subst, "}", "\}", "ALL")>
		<cfset lcl.subst = Replace(lcl.subst, "|", "\|", "ALL")>
		<cfset lcl.subst = Replace(lcl.subst, "[", "\[", "ALL")>
		<cfset lcl.subst = Replace(lcl.subst, "]", "\]", "ALL")>

		<cftry>
			<cfset lcl.str = lcl.str.replaceAll("("&lcl.subst&")", arguments.newval)>
			<cfcatch type="any">
			</cfcatch>
		</cftry>

		<cfreturn lcl.str>
	</cffunction>

	<cffunction name="substituteValues" hint="performs the regex replacement">
		<cfset var lcl = StructNew()>
		<cfset lcl.rep = getReplacement()>
		<cfset lcl.str = getTemplate()>

		<cfset variables.matcher.reset(lcl.str)>
		<cfloop condition="variables.matcher.Find()">
			<cftry>
				<cfset lcl.rxKeyFound = TRIM(variables.matcher.Group(JavaCast("string", variables.rxKeyIndex)))>
				<cfif StructKeyExists(lcl.rep, lcl.rxKeyFound)>
					<cfset lcl.subst = variables.matcher.Group(JavaCast("string", variables.substIndex))>
					<cfset lcl.value = JavaCast("string", lcl.rep[lcl.rxKeyFound])>
					<cftry>
						<cfset lcl.str = substituteValue(lcl.str, lcl.subst, lcl.value)>
						<cfcatch type="any">
							<cfoutput>
								<cfdump var="#cfcatch#">
								<p>Error in replace: #variables.matcher.Group(JavaCast("string", variables.substIndex))#,#lcl.rep[variables.matcher.Group(JavaCast("string", variables.rxKeyIndex))]#</p>
								<cfloop from="1" to="#matcher.groupCount()#" index="lcl.i">
									Group #lcl.i#: #matcher.Group(JavaCast("string", lcl.i))#<br />
								</cfloop>
								#lcl.rep[variables.matcher.Group(JavaCast("string", variables.rxKeyIndex))]#<br />
								<pre>#HTMLEditFormat(lcl.str)#</pre>
								<hr />
							</cfoutput>
						</cfcatch>
					</cftry>
				</cfif>
				<cfcatch type="any">
				<!--- 	<cfdump var="#cfcatch#"> --->
					<!--- <cfdump var="#variables.matcher.Group('1')#"> --->
					<!-- No group 2 found! -->
				</cfcatch>
			</cftry>
		</cfloop>

		<cfreturn lcl.str>
	</cffunction>

</cfcomponent>