<cfcomponent name="pf" output="false" extends="sourceformat">
	<!--- Property declarations --->
	<cfset this.string = "">
	<cfset this.trim   = TRUE>
	<cfset this.flval  = 160>

	<!--- Constructor --->
	<cffunction name="init" output="false">
		<cfargument name="str" required="no"  type="string" default="">
		<cfargument name="trim" required="no" type="boolean" default="#this.trim#">
		<cfargument name="flval" required="no" type="numeric" default="#this.flval#">
		<cfset this.trim  = arguments.trim>
		<cfset this.flval = arguments.flval>
		<cfset set(arguments.str)>
		<cfreturn this>
	</cffunction>

	<!--- Private function(s) --->
	<cffunction name="set" output="false" access="private">
		<cfargument name="str" required="no" type="string" default="">
		<cfset this.string = arguments.str>
		<cfif this.trim><cfset this.string = TRIM(this.string)></cfif>
		<cfreturn this>
	</cffunction>

	<!--- Public getter function --->
	<cffunction name="get" output="false">
		<cfreturn PreserveSingleQuotes(this.string)>
	</cffunction>

	<!--- Public functions --->
	<cffunction name="firstcap" output="false" hint="returns string with first character capitalised">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = UCASE(LEFT(arguments.str,1))>
		<cfif LEN(arguments.str) gt 1>
			<cfset nstr = nstr & LCASE(RIGHT(arguments.str,LEN(arguments.str)-1))>
		</cfif>
		<cfreturn set(nstr)>
	</cffunction>

	<cffunction name="uspace" output="false" hint="returns string with underscores replaced with spaces">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = Replace(arguments.str,"_"," ","ALL")>
		<cfreturn set(nstr)>
	</cffunction>

	<cffunction name="rmpfix" output="false" hint="returns string with given prefix removed">
		<cfargument name="prefix" required="yes" type="string">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = arguments.str>
		<cfset var plen = Len(arguments.prefix)>
		<cfif Left(nstr,plen) eq arguments.prefix>
			<cfset nstr = Right(nstr,Len(nstr)-plen)>
		</cfif>
		<cfreturn set(nstr)>
	</cffunction>

	<cffunction name="rmsfix" output="false" hint="returns string with given suffix removed">
		<cfargument name="suffix" required="yes" type="string">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = arguments.str>
		<cfset var slen = Len(arguments.suffix)>
		<cfif Right(nstr,slen) eq arguments.suffix>
			<cfset nstr = Right(nstr,Len(nstr)-slen)>
		</cfif>
		<cfreturn set(nstr)>
	</cffunction>

	<cffunction name="normalise" output="false" hint="removes mulitple spaces from string">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = REReplaceNoCase(arguments.str,"\s+"," ","ALL")>
		<cfreturn set(nstr)>
	</cffunction>

	<cffunction name="rmtags" output="false" hint="returns string with html tags removed">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = REReplaceNoCase(arguments.str,"</?[A-Za-z0-9].*?>","","ALL")>
		<cfreturn set(HTMLEditFormat(nstr))>
	</cffunction>

	<cffunction name="fleft" output="false" hint="returns full left string with html tags removed, the count defaults to 300">
		<cfargument name="count" required="no" type="numeric" default="#this.flval#">
		<cfargument name="str" required="no" type="string" default="#this.string#">

		<cfset var nstr = arguments.str>
		<cfset var cnt  = arguments.count>

		<cfif NOT REFind("[[:space:]]", nstr) OR cnt GTE LEN(nstr)>
			<cfreturn set(Left(nstr,cnt))>
		<cfelseif REFind("[[:space:]]",MID(nstr,arguments.count+1,1))>
			<cfreturn set(Left(nstr,cnt))>
		<cfelse>
			<cfset cnt = cnt - REFind("[[:space:]]", Reverse(MID(nstr,1,cnt)))>
			<cfif cnt>
				<cfreturn set(Left(nstr,cnt))>
			<cfelse>
				<cfreturn set(Left(nstr,1))>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="untab" output="false" hint="returns string with tabs removed">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfargument name="num" required="no" type="numeric" default="0">
		<cfset var nstr = ReplaceNoCase(arguments.str,CHR(9),"","ALL")>
		<cfset var line = "">
		<cfset var tmp = "">
		<cfif arguments.num neq 0>
			<cfloop list="#nstr#" index="line" delimiters="#CHR(10)#">
				<cfset tmp = ListAppend(tmp, RepeatString(CHR(9),arguments.num) & line, CHR(10))>
			</cfloop>
			<cfset nstr = tmp>
		</cfif>
		<cfreturn set(nstr)>
	</cffunction>

	<!--- INDENTATION --->
	<cffunction name="indent" output="false" hint="returns string with tabs added">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfargument name="num" required="no" type="numeric" default="0">
		<cfset var nstr = ListToArray(arguments.str,chr(10))>
		<cfset var narr = ArrayNew(1)>
		<cfset var i    = 0>

		<cfif arguments.num neq 0>
			<cfloop from="1" to="#ArrayLen(nstr)#" index="i">
				<cfset ArrayAppend(narr, RepeatString(chr(9),arguments.num) & nstr[i])>
			</cfloop>
			<cfset nstr = narr>
		</cfif>
		<cfreturn set(ArrayToList(nstr,chr(10)))>
	</cffunction>

	<cffunction name="unindent" output="false" hint="returns string with relative number of tabs removed">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfargument name="num" required="no" type="numeric" default="0">
		<cfset var nstr = ListToArray(arguments.str,chr(10))>
		<cfset var narr = ArrayNew(1)>
		<cfset var i    = 0>

		<cfif arguments.num neq 0>
			<cfloop from="1" to="#ArrayLen(nstr)#" index="i">
				<cfset ArrayAppend(narr, REREplace(nstr[i], "^(\t){#arguments.num#}", "", "ALL"))>
			</cfloop>
			<cfset nstr = narr>
		</cfif>
		<cfreturn set(ArrayToList(nstr,chr(10)))>
	</cffunction>

	<!--- QUOTING --->
	<cffunction name="unquote" output="false" hint="returns string with enquotation removed">
		<cfargument name="instring" type="string" required="false" default="">

		<cfif (LEFT(arguments.instring,1) eq "'" AND RIGHT(arguments.instring,1) eq "'")
			OR (LEFT(arguments.instring,1) eq '"' AND RIGHT(arguments.instring,1) eq '"')>
			<cfif Len(arguments.instring) eq 2>
				<cfreturn "">
			<cfelse>
				<cfreturn Mid(arguments.instring, 2, Len(arguments.instring)-2)>
			</cfif>
		</cfif>
		<cfreturn arguments.instring>
	</cffunction>

	<cffunction name="encaps" output="false" hint="returns string encapsulated in start quote and endquote">
		<cfargument name="instring" type="string" required="false" default="">
		<cfargument name="quoter" required="false" default="34" type="numeric">

		<cfif ASC(LEFT(instring,1)) eq arguments.quoter AND ASC(RIGHT(instring,1)) eq arguments.quoter>
			<cfreturn arguments.instring>
		<cfelse>
			<cfreturn CHR(arguments.quoter) & arguments.instring & CHR(arguments.quoter)>
		</cfif>
	</cffunction>

	<cffunction name="encode" output="false" hint="returns string encodes in given format">
		<cfargument name="instring" type="string" required="false" default="">
		<cfargument name="type" required="false" default="url" type="string">

		<cfswitch expression="#arguments.type#">
			<cfdefaultcase>
				<cfreturn URLEncodedFormat(decode(arguments.instring, arguments.type)) />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="decode" output="false" hint="returns string encodes in given format">
		<cfargument name="instring" type="string" required="false" default="">
		<cfargument name="type" required="false" default="url" type="string">

		<cfset var local = StructNew() />
		<cfswitch expression="#arguments.type#">
			<cfdefaultcase>
				<cfset local.guard = 0 />
				<cfset local.decoded = arguments.instring />
				<cfloop condition="local.guard LT 1000">
					<cfset local.guard = local.guard+1 />
					<cfif URLDecode(local.decoded) NEQ local.decoded>
						<cfset local.decoded = URLDecode(local.decoded) />
					<cfelse>
						<cfbreak />
					</cfif>
				</cfloop>
				<cfreturn local.decoded />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="free" output="false" hint="removes mulitple spaces from string">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfreturn freeTheSource(arguments.str)>
	</cffunction>

	<cffunction name="squeeze" output="false" hint="removes mulitple spaces from string">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfreturn freeTheSource(arguments.str)>
	</cffunction>

	<cffunction name="freeTheSource" output="false" hint="returns freethesourced string">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = super.freeTheSource(arguments.str)>
		<cfreturn set(nstr)>
	</cffunction>

	<cffunction name="squeezeTheSource" output="false" hint="returns squeezethesourced string">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = super.squeezeTheSource(arguments.str)>
		<cfreturn set(nstr)>
	</cffunction>

	<cffunction name="stripTag" access="remote" returntype="string" output="No" hint="Gets the inner content of a xmlnode">
		<cfargument name="inString" required="Yes" type="any">
		<cfargument name="tagToRemove" required="Yes" type="string">

		<cfreturn REReplaceNoCase(arguments.inString,"<(#arguments.tagToRemove#|/#arguments.tagToRemove#)[^>]*>","","ALL")>
	</cffunction>

	<cffunction name="stripXMLNamespace" access="remote" returntype="string" output="No" hint="XMLNamespace strip functie">
		<cfargument name="inString" required="Yes" type="string">

		<cfreturn REReplaceNoCase(arguments.inString,"<.xml.*?>","","ALL")>
	</cffunction>

	<cffunction name="escapeAmp" access="public" output="false" returntype="any" hint="Escapes the & character in XHTML string">
		<cfargument name="str" required="no" type="string" default="#this.string#">
		<cfset var nstr = REReplace(arguments.str, "&(?!(?:[a-zA-Z][a-zA-Z0-9]*|##\d+);)", "&amp;", "ALL") />
		<cfreturn set(nstr)>
	</cffunction>

	<cffunction name="prettyPrint" output="true" hint="returns pretty printed XML string">
		<cfargument name="str"      required="no" type="string"  default="#this.string#">
		<cfargument name="omitdecl" required="no" type="boolean" default="true" hint="omits xml declaration">
		<cfargument name="dumpCaught" required="no" type="boolean" default="false" hint="dump cfcatch if error occurs (for debugging only)">

		<!---
		/**
		 * @source http://www.firemoss.com/post.cfm/Prettyprinting-formatted-XML-in-ColdFusion-via-JDOM#comment-46E42F89-FF1D-C52F-5ED2972F2BAED722
		 * @feature-soltion
		 *
		 * FIXED:
		 *  - handle strings containing DOCTYPE declaration
		 *    added Feature solution from:
		 *        http://stackoverflow.com/questions/2157449/problem-loading-remote-html-source-code-using-jdom
		 */
		 --->
		<cfset var local = StructNew()>
		<cftry>
			<cfset local.builder = createObject("java", "org.jdom.input.SAXBuilder").init(JavaCast('boolean', 0)) />
			<cfset local.format = createObject("java", "org.jdom.output.Format").getPrettyFormat() />
			<cfset local.format.setOmitDeclaration(arguments.omitdecl) />
			<!--- Feature solution --->
			<cfset local.builder.setFeature("http://xml.org/sax/features/validation", JavaCast('boolean', 0)) />
		    <cfset local.builder.setFeature("http://apache.org/xml/features/nonvalidating/load-dtd-grammar", JavaCast('boolean', 0)) />
		    <cfset local.builder.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", JavaCast('boolean', 0)) />
		    <cfset local.builder.setValidation(JavaCast('boolean', 0)) />
		    <!--- / Feature solution --->
			<cfset local.out = createObject("java", "org.jdom.output.XMLOutputter").init(local.format) />

			<cfset local.reader = CreateObject( "java", "java.io.StringReader" ).init( JavaCast( "string", arguments.str ) ) />
			<cfset local.document = local.builder.build( local.reader ) />

			<cfreturn REReplace(local.out.outputString( local.document ), "<script(.*?)(/>)", "<script\1></script>", "ALL") />

			<cfcatch type="any">
				<cfdump var="#cfcatch#"><cfabort>
				<cfreturn arguments.str>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="replaceTab" returntype="string" output="false">
		<cfargument name="code" type="string" required="true">
		<cfreturn arguments.code.replaceAll('((<span class="tab">)+|)\t(.*)', '$1<span class="tab">$3</span>')>
	</cffunction>

	<cffunction name="formatSourceCode" returntype="any" output="false">
		<cfargument name="str"      required="no" type="string"  default="#this.string#">
		<cfargument name="maxtabs" type="numeric" required="false" default="100">

		<cfset var local  = StructNew()>
		<cfset local.code = HTMLEditFormat(arguments.str)>
		<cfset local.i    = 0>

		<cfloop condition="local.code neq replaceTab(local.code)">
			<cfset local.code = replaceTab(local.code)>
			<cfset local.i = local.i + 1>
			<cfif local.i GTE arguments.maxtabs>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfreturn set(local.code.replaceAll('(.*)','<span class="line">$1</span>'))>
	</cffunction>

	<cffunction name="unHTMLEditFormat" returntype="any" output="false">
		<cfargument name="str" required="no" type="string"  default="#this.string#">
		<cfset var local = StructNew() />
		<cfset local.str = Replace(arguments.str, "&gt;", ">", "ALL") />
		<cfset local.str = Replace(local.str, "&lt;", "<", "ALL") />
		<cfset local.str = Replace(local.str, "&quot;", '"', "ALL") />

		<cfreturn set(local.str)>
	</cffunction>

</cfcomponent>