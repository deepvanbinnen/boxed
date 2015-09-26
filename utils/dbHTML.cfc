<!---
DO NOT USE!
- Source for dbobject's implementation of HTML.cfc needs cleaning up
--->

<cfcomponent extends="dbutils" output="false">
	<cfset variables.Subst = StructNew()>
	<cfset variables.Subst.regex = "((%([0-9]+)|(%CURRENT%)|(%KEY%))[\\]{0,1})">
	<cfset variables.Subst.pattern = CreateObject("java","java.util.regex.Pattern").Compile(JavaCast("string", variables.Subst.regex))>
	<cfset variables.Subst.matcher = variables.Subst.pattern.Matcher(JavaCast( "string", '' ))>
	<cfset variables.Subst.knownpatterns = StructNew()>

	<cffunction name="init">
		<cfargument name="utils" required="true"  type="any" hint="Original ebx object" />
		<cfset super.init(arguments.utils) />
		<cfset variables.iterators = StructNew()>
		<cfset variables.numiterators = 0>
		<cfreturn this>
	</cffunction>

	<!---
<cffunction name="iterator">
		<cfargument name="obj" required="true">
		<cfreturn variables.utils.iterator(arguments.obj)>
	</cffunction>
 --->

	<cffunction name="parseKeyVal">
		<cfargument name="value"  required="false" type="string" default="">

		<cfset var local = StructNew()>
		<cfset local.key = arguments.value>
		<cfset local.value = arguments.value>

		<cfif ListLen(local.value,"=") gt 1>
			<cfset local.key = ListFirst(local.value,"=")>
			<cfset local.value = ListLast(local.value,"=")>
		</cfif>
		<cfreturn local>
	</cffunction>

	<cffunction name="keysToList">
		<cfargument name="argstruct" required="true" type="struct">
		<cfargument name="attrkeys"  required="false" type="string" default="#StructKeyList(arguments.argstruct)#">
		<cfargument name="qualifier" required="false" type="string" default='"'>

		<cfset var local  = StructNew()>
		<cfset local.it   = iterator(arguments.attrkeys)>
		<cfset local.args = arguments.argstruct>
		<cfset local.val  = "">

		<cfloop condition="#local.it.whileHasNext()#">
			<cfif StructKeyExists(local.args, local.it.current) AND IsSimpleValue(local.it.current)>
				<cfset local.val = ListAppend(local.val, local.it.current & "=" & ListQualify(local.args[local.it.current],arguments.qualifier), " ")>
			</cfif>
		</cfloop>
		<cfreturn local.val>
	</cffunction>

	<cffunction name="substituteValues">
		<cfargument name="value"    required="true" type="string" default="">
		<cfargument name="substitute" required="false" type="struct" default="#StructNew()#">

		<cfset var local  = StructNew()>
		<cfset local.subs = arguments.substitute>
		<cfset local.val  = arguments.value>

		<cfif Find("%", local.val) AND NOT StructIsEmpty(local.subs)>
			<cfset local.val = subsitute(local.val, local.subs)>
		</cfif>
		<cfreturn local.val>
	</cffunction>

	<cffunction name="subsitute">
		<cfargument name="str" type="string">
		<cfargument name="rep">

		<!--- <cfset var myregex = "(%([0-9]+|CURRENT|KEY)%)[\\]{0,1}"> --->
		<cfset var myregex = "(%([0-9a-zA-Z]+)%)[\\]{0,1}">
		<cfset var pattern = CreateObject("java","java.util.regex.Pattern").Compile(JavaCast("string", myregex))>
		<cfset var matcher = pattern.Matcher(JavaCast( "string", '' ))>

		<cfset matcher.reset(arguments.str)>
		<cfloop condition="matcher.Find()">
			<cfif StructKeyExists(rep, matcher.Group('2'))>
				<cftry>
					<cfset str = str.replaceAll(JavaCast("string",matcher.Group('1')), JavaCast("string",rep[matcher.Group('2')]))>
					<cfcatch type="any">
						<cfoutput>Error in replace: (#matcher.Group('1')#,#rep[matcher.Group('2')]#</cfoutput>
						<cfdump var="#str.toString()#">
						<cfdump var="#cfcatch#">
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		<cfreturn str>
	</cffunction>

	<cffunction name="getHTML">
		<cfargument name="tagname"   required="true"  type="string">
		<cfargument name="attribs"   required="false" type="string" default="">
		<cfargument name="tagbody"   required="false" type="string" default="">

		<cfset var html = "">
		<cfset var tag  = LCASE(arguments.tagname)>
		<cfset var body = arguments.tagbody>
		<cfset var attr = arguments.attribs>

		<cfset html = "<" & tag>
		<cfif attr neq "">
			<cfset html = html & " " & attr>
		</cfif>
		<cfif body neq "">
			<cfset html = html & ">" & body & "</" & tag & ">">
		<cfelse>
			<cfset html = html & " />">
		</cfif>
		<cfreturn html>
	</cffunction>

	<cffunction name="substValsFromObj">
		<cfargument name="subst" required="true" type="struct">
		<cfargument name="obj"   required="true" type="struct">

		<cfset var local = StructNew()>
		<cfset local.out = StructNew()>
		<cfset local.obj  = arguments.obj>

		<cfset local.out.list  = "">
		<cfset local.out.subst  = arguments.subst>

		<cfif ArrayLen(arguments) gt 2>
			<cfset local.out.list  = arguments[3]>
			<cfset local.it = iterator(local.out.list)>
			<cfloop condition="#local.it.whileHasNext()#">
				<cfif StructKeyExists(local.obj, local.it.current)>
					<cfset local.out.subst[local.it.key] = local.obj[local.it.current]>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset local.it = iterator(local.out.subst)>
			<cfloop condition="#local.it.whileHasNext()#">
				<cfif StructKeyExists(local.obj, local.it.current)>
					<cfset local.out.list = ListAppend(local.out.list, local.it.current)>
					<cfset local.out.subst[local.it.key] = local.obj[local.it.current]>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn local.out>
	</cffunction>

	<cffunction name="indexNumberedArgs">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="mergelist"  required="false" type="boolean" default="false">

		<cfset var local = StructNew()>
		<cfset local.it  = iterator(arguments.collection)>
		<cfset local.mergelist  = arguments.mergelist>
		<cfset local.tmp = ArrayNew(1)>

		<cfset local.args = StructNew()>
		<cfset local.args.map  = StructNew()>
		<cfset local.args.keylist = "">

		<cfloop condition="#local.it.whileHasNext()#">
			<cfif IsNumeric(local.it.key)>
				<cfset ArraySet(local.tmp, local.it.key, local.it.key, local.it.current)>
			</cfif>
		</cfloop>

		<cfif local.mergelist>
			<cfset local.tmp = ListToArray(ArrayToList(local.tmp))>
		</cfif>
		<cfset local.it = iterator(local.tmp)>
		<cfloop condition="#local.it.whileHasNext()#">
			<cfset StructInsert(local.args.map, local.it.key, local.it.current, true)>
			<cfset local.args.keylist = ListAppend(local.args.keylist, local.it.current)>
		</cfloop>

		<cfreturn local.args>
	</cffunction>

	<cffunction name="indexNamedArgs">
		<cfargument name="namedlist"  required="true" type="string">

		<cfset var local = StructNew()>
		<cfset local.it  = iterator(arguments.namedlist)>
		<cfset local.args = StructNew()>
		<cfset local.args.map  = StructNew()>
		<cfset local.args.keylist = arguments.namedlist>

		<cfloop condition="#local.it.whileHasNext()#">
			<cfset StructInsert(local.args.map, local.it.key, local.it.current, true)>
		</cfloop>

		<cfreturn local.args>
	</cffunction>

	<cffunction name="indexArgs">
		<cfargument name="argmap"   required="true" type="any">
		<cfargument name="idxstart" required="true" type="numeric" default="0">
		<cfargument name="idxfield" required="false" type="string" default="">

		<cfset var out = StructNew()>
		<cfset var local = StructNew()>

		<cfset local.argmap   = arguments.argmap>
		<cfset local.idxstart = arguments.idxstart>
		<cfset local.idxfield = arguments.idxfield>

		<cfset out.map     = StructNew()>
		<cfset out.keylist = "">
		<cfset out.type    = "">

		<cfif numberedArguments(local.argmap, local.idxstart)>
			<cfset out = indexNumberedArgs(local.argmap, true)>
			<cfset out.type = "numbered">
		<cfelseif StructKeyExists(local.argmap, local.idxfield)>
			<cfset out = indexNamedArgs(local.argmap[local.idxfield])>
			<cfset out.type = "named">
		</cfif>
		<cfreturn out>
	</cffunction>

	<cffunction name="numberedArguments">
		<cfargument name="argmap"   required="true" type="any">
		<cfargument name="idxstart" required="true" type="numeric" default="0">

		<cfreturn StructKeyExists(arguments.argmap, arguments.idxstart)>
	</cffunction>

	<cffunction name="structSubtract">
		<cfargument name="struct"  required="true" type="any">
		<cfargument name="keys"    required="true" type="any">

		<cfset var local    = StructNew()>
		<cfset local.struct = arguments.struct>
		<cfset local.out    = StructNew()>

		<cfset local.it = iterator(arguments.keys)>
		<cfloop condition="#local.it.whileHasNext()#">
			<cfset local.temp = parseKeyVal(local.it.current)>
			<cfif StructKeyExists(local.struct, local.temp.key)>
				<cfset StructInsert(local.out, local.temp.value, local.struct[local.temp.key], true)>
			</cfif>
		</cfloop>

		<cfreturn local.out>
	</cffunction>

	<cffunction name="getCollectionHTML">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="render"     required="true" type="any">
		<cfargument name="substmap"   required="true" type="any">
		<cfargument name="colkeys"    required="true" type="any">

		<cfset var local      = StructNew()>
		<cfset local.coll     = arguments.collection>
		<cfset local.render   = arguments.render>
		<cfset local.substmap = arguments.substmap>
		<cfset local.colkeys  = arguments.colkeys>
		<cfset local.html = "">

		<cfswitch expression="#getCollectionType(local.coll).type#">
			<cfcase value="query,component">
				<cfset local.it = iterator(local.coll)>
				<cfloop condition="#local.it.whileHasNext()#">
					<cfset local.temp             = substValsFromObj(local.substmap, local.it.current, local.colkeys)>
					<cfset local.colkeys          = local.temp.list>
					<cfset local.substmap         = local.temp.subst>
					<cfset local.substmap.key     = local.it.index>
					<cfset local.substmap.current = local.it.index>
					<cfset local.html = local.html & substituteValues(local.render, local.substmap)>
				</cfloop>
			</cfcase>

			<cfcase value="string,array">
				<cfset local.it = iterator(local.coll)>
				<cfloop condition="#local.it.whileHasNext()#">
					<cfset local.substmap.current = local.it.index>
					<cfset local.substmap.key     = local.it.key>
					<cfset local.substmap.value   = local.it.current>
					<cfset local.substmap["0"]    = substituteValues(local.it.current, local.substmap)>
					<cfset local.html = local.html & substituteValues(local.render, local.substmap)>
				</cfloop>
			</cfcase>

			<cfcase value="struct">
				<cfset local.temp  = substValsFromObj(local.substmap, local.coll, local.colkeys)>
				<cfset local.colkeys          = local.temp.list>
				<cfset local.substmap         = local.temp.subst>
				<cfset local.html = local.html & substituteValues(local.render, local.substmap)>
				<!--- <cfset local.it = iterator(local.coll)>
				<cfloop condition="#local.it.whileHasNext()#">
					<cfset local.substmap.current = local.it.index>
					<cfset local.substmap.key     = local.it.key>
					<cfset local.substmap.value   = local.it.current>
					<cfset local.substmap["0"]    = substituteValues(local.it.current, local.substmap)>
					<cfset local.html = local.html & substituteValues(local.render, local.substmap)>
				</cfloop> --->
			</cfcase>
		</cfswitch>

		<cfreturn local.html>
	</cffunction>

	<cffunction name="list">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="text" required="false" type="string" default="%0%" hint="the collections 'content-value' will be used (list,array) for the li's tagbody (or an empty string if it can not be determined)">

		<cfset var local     = StructNew()>
		<cfset local.coll    = arguments.collection>
		<cfset local.render  = arguments.text>

		<cfset local.argmap   = indexArgs(arguments, 3, "keyfields")>
		<cfset local.itemattr = structSubtract(arguments, "id,class")>
		<cfset local.linkattr = structSubtract(arguments, "href=href,linkid=id,linkclass=class")>
		<cfset local.listattr = structSubtract(arguments, "listid=id,listclass=class")>

		<cfset local.html      = "">

		<cfif NOT StructIsEmpty(local.linkattr)>
			<cfset local.render = getHTML("a", keysToList(local.linkattr), local.render)>
		</cfif>
		<cfset local.render = getHTML("li", keysToList(local.itemattr), local.render)>

		<cfset local.html = getCollectionHTML(local.coll, local.render, local.argmap.map, local.argmap.keylist)>

		<cfreturn getHTML("ul", keysToList(local.listattr), local.html)>
	</cffunction>

	<cffunction name="link">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="href" required="true" type="string">
		<cfargument name="text" required="false" type="string" default="%0" hint="the collections 'content-value' will be used (list,array) for the li's tagbody (or an empty string if it can not be determined)">

		<cfset var local     = StructNew()>
		<cfset local.coll    = arguments.collection>
		<cfset local.text    = arguments.text>

		<cfset local.argmap   = indexArgs(arguments, 4, "keyfields")>
		<cfset local.linkattr = structSubtract(arguments, "href,rel,class,id")>
		<cfset local.html      = "">

		<cfset local.render = getHTML("a", keysToList(local.linkattr), local.text)>
		<cfset local.html = getCollectionHTML(local.coll, local.render, local.argmap.map, local.argmap.keylist)>

		<cfreturn local.html>
	</cffunction>

	<cffunction name="table">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="colmap"     required="true" type="string">
		<!--- <cfargument name="headers" required="false" type="string" default="%0" hint="the collections 'content-value' will be used (list,array) for the li's tagbody (or an empty string if it can not be determined)"> --->

		<cfset var local     = StructNew()>
		<cfset local.coll    = arguments.collection>
		<cfset local.html      = "">

		<cfset local.tableattr = structSubtract(arguments, "id,class")>

		<cfset local.colmap = arguments.colmap>
		<cfset local.headers = "">
		<cfset local.rowdata = "">

		<cfset local.headers_set = false>
		<cfif StructKeyExists(arguments, "headers") AND arguments.headers neq "">
			<cfset local.headers = arguments.headers>
			<cfset local.headers_set = true>
		</cfif>

		<cfset local.argmap  = StructNew()>
		<cfset local.argmap.map = StructNew()>
		<cfset local.argmap.keylist = "">

		<cfset local.renders = StructNew()>
		<cfset local.renders["th"] = ArrayNew(1)>
		<cfset local.renders["td"] = ArrayNew(1)>

		<!--- Setup substitution map --->
		<cfset local.it = iterator(local.colmap)>
		<cfloop condition="#local.it.whileHasNext()#">
			<cfset local.temp = parseKeyVal(local.it.current)>
			<cfif NOT local.headers_set>
				<cfset local.headers = ListAppend(local.headers, local.temp.value)>
			</cfif>
			<cfset local.rowdata = ListAppend(local.rowdata, local.temp.key)>
			<cfset StructInsert(local.argmap.map, local.it.key, local.temp.key)>

			<cfset ArrayAppend(local.renders["th"], getHTML("th", "", local.temp.value))>
			<cfset ArrayAppend(local.renders["td"], getHTML("td", "", "%#local.it.key#%"))>
		</cfloop>

		<!--- Setup key list to lookup in collection --->
		<cfset local.argmap.keylist = local.rowdata>

		<!--- Parse head --->
		<cfset local.thead = getHTML("tr", "", ArrayToList(local.renders["th"],""))>
		<cfset local.thead = getHTML("thead", "", local.thead )>

		<!--- Parse body template --->
		<cfset local.tbody = getHTML("tr", "", ArrayToList(local.renders["td"],""))>

		<!--- get body data from template and collection --->
		<cfset local.tbody = getCollectionHTML(local.coll, local.tbody, local.argmap.map, local.argmap.keylist)>
		<cfset local.tbody = getHTML("tbody", "", local.tbody )>

		<!--- parse out table --->
		<cfset local.html = getHTML("table", "", local.thead & local.tbody)>

		<cfreturn local.html>
	</cffunction>

	<cffunction name="render">
		<cfargument name="collection"     required="true" type="any">
		<cfargument name="template"       required="true" type="string">
		<cfargument name="collectionkeys" required="false" type="string">

		<cfset var local    = StructNew()>
		<cfset local.coll   = arguments.collection>

		<cfset local.argmap = indexArgs(arguments, 3, "collectionkeys")>
		<cfset local.html   = "">
		<cfset local.render = arguments.template>
		<cfset local.html   = getCollectionHTML(local.coll, local.render, local.argmap.map, local.argmap.keylist)>

		<cfreturn local.html>
	</cffunction>

	<cffunction name="timesnap">
		<cfargument name="msg" required="false">
		<cfif NOT StructKeyExists(variables, "a")>
			<cfset variables.a = getTickCount()>
		</cfif>
		<cfoutput>#getTickCount()-variables.a#ms</cfoutput>
		<cfif StructKeyExists(arguments, "msg")>
			<cfif IsSimpleValue(arguments.msg)>
				<cfoutput><p>#arguments.msg#</p></cfoutput>
			<cfelse>
				<cfdump var="#msg#">
			</cfif>
		</cfif>
		<hr />
	</cffunction>

	<cffunction name="tick">
		<cfset variables.a = getTickCount()>
	</cffunction>
</cfcomponent>

