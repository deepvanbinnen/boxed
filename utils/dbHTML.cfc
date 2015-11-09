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

		<cfset var lcl = StructNew()>
		<cfset lcl.key = arguments.value>
		<cfset lcl.value = arguments.value>

		<cfif ListLen(lcl.value,"=") gt 1>
			<cfset lcl.key = ListFirst(lcl.value,"=")>
			<cfset lcl.value = ListLast(lcl.value,"=")>
		</cfif>
		<cfreturn local>
	</cffunction>

	<cffunction name="keysToList">
		<cfargument name="argstruct" required="true" type="struct">
		<cfargument name="attrkeys"  required="false" type="string" default="#StructKeyList(arguments.argstruct)#">
		<cfargument name="qualifier" required="false" type="string" default='"'>

		<cfset var local  = StructNew()>
		<cfset lcl.it   = iterator(arguments.attrkeys)>
		<cfset lcl.args = arguments.argstruct>
		<cfset lcl.val  = "">

		<cfloop condition="#lcl.it.whileHasNext()#">
			<cfif StructKeyExists(lcl.args, lcl.it.current) AND IsSimpleValue(lcl.it.current)>
				<cfset lcl.val = ListAppend(lcl.val, lcl.it.current & "=" & ListQualify(lcl.args[lcl.it.current],arguments.qualifier), " ")>
			</cfif>
		</cfloop>
		<cfreturn lcl.val>
	</cffunction>

	<cffunction name="substituteValues">
		<cfargument name="value"    required="true" type="string" default="">
		<cfargument name="substitute" required="false" type="struct" default="#StructNew()#">

		<cfset var local  = StructNew()>
		<cfset lcl.subs = arguments.substitute>
		<cfset lcl.val  = arguments.value>

		<cfif Find("%", lcl.val) AND NOT StructIsEmpty(lcl.subs)>
			<cfset lcl.val = subsitute(lcl.val, lcl.subs)>
		</cfif>
		<cfreturn lcl.val>
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

		<cfset var lcl = StructNew()>
		<cfset lcl.out = StructNew()>
		<cfset lcl.obj  = arguments.obj>

		<cfset lcl.out.list  = "">
		<cfset lcl.out.subst  = arguments.subst>

		<cfif ArrayLen(arguments) gt 2>
			<cfset lcl.out.list  = arguments[3]>
			<cfset lcl.it = iterator(lcl.out.list)>
			<cfloop condition="#lcl.it.whileHasNext()#">
				<cfif StructKeyExists(lcl.obj, lcl.it.current)>
					<cfset lcl.out.subst[lcl.it.key] = lcl.obj[lcl.it.current]>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset lcl.it = iterator(lcl.out.subst)>
			<cfloop condition="#lcl.it.whileHasNext()#">
				<cfif StructKeyExists(lcl.obj, lcl.it.current)>
					<cfset lcl.out.list = ListAppend(lcl.out.list, lcl.it.current)>
					<cfset lcl.out.subst[lcl.it.key] = lcl.obj[lcl.it.current]>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn lcl.out>
	</cffunction>

	<cffunction name="indexNumberedArgs">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="mergelist"  required="false" type="boolean" default="false">

		<cfset var lcl = StructNew()>
		<cfset lcl.it  = iterator(arguments.collection)>
		<cfset lcl.mergelist  = arguments.mergelist>
		<cfset lcl.tmp = ArrayNew(1)>

		<cfset lcl.args = StructNew()>
		<cfset lcl.args.map  = StructNew()>
		<cfset lcl.args.keylist = "">

		<cfloop condition="#lcl.it.whileHasNext()#">
			<cfif IsNumeric(lcl.it.key)>
				<cfset ArraySet(lcl.tmp, lcl.it.key, lcl.it.key, lcl.it.current)>
			</cfif>
		</cfloop>

		<cfif lcl.mergelist>
			<cfset lcl.tmp = ListToArray(ArrayToList(lcl.tmp))>
		</cfif>
		<cfset lcl.it = iterator(lcl.tmp)>
		<cfloop condition="#lcl.it.whileHasNext()#">
			<cfset StructInsert(lcl.args.map, lcl.it.key, lcl.it.current, true)>
			<cfset lcl.args.keylist = ListAppend(lcl.args.keylist, lcl.it.current)>
		</cfloop>

		<cfreturn lcl.args>
	</cffunction>

	<cffunction name="indexNamedArgs">
		<cfargument name="namedlist"  required="true" type="string">

		<cfset var lcl = StructNew()>
		<cfset lcl.it  = iterator(arguments.namedlist)>
		<cfset lcl.args = StructNew()>
		<cfset lcl.args.map  = StructNew()>
		<cfset lcl.args.keylist = arguments.namedlist>

		<cfloop condition="#lcl.it.whileHasNext()#">
			<cfset StructInsert(lcl.args.map, lcl.it.key, lcl.it.current, true)>
		</cfloop>

		<cfreturn lcl.args>
	</cffunction>

	<cffunction name="indexArgs">
		<cfargument name="argmap"   required="true" type="any">
		<cfargument name="idxstart" required="true" type="numeric" default="0">
		<cfargument name="idxfield" required="false" type="string" default="">

		<cfset var out = StructNew()>
		<cfset var lcl = StructNew()>

		<cfset lcl.argmap   = arguments.argmap>
		<cfset lcl.idxstart = arguments.idxstart>
		<cfset lcl.idxfield = arguments.idxfield>

		<cfset out.map     = StructNew()>
		<cfset out.keylist = "">
		<cfset out.type    = "">

		<cfif numberedArguments(lcl.argmap, lcl.idxstart)>
			<cfset out = indexNumberedArgs(lcl.argmap, true)>
			<cfset out.type = "numbered">
		<cfelseif StructKeyExists(lcl.argmap, lcl.idxfield)>
			<cfset out = indexNamedArgs(lcl.argmap[lcl.idxfield])>
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
		<cfset lcl.struct = arguments.struct>
		<cfset lcl.out    = StructNew()>

		<cfset lcl.it = iterator(arguments.keys)>
		<cfloop condition="#lcl.it.whileHasNext()#">
			<cfset lcl.temp = parseKeyVal(lcl.it.current)>
			<cfif StructKeyExists(lcl.struct, lcl.temp.key)>
				<cfset StructInsert(lcl.out, lcl.temp.value, lcl.struct[lcl.temp.key], true)>
			</cfif>
		</cfloop>

		<cfreturn lcl.out>
	</cffunction>

	<cffunction name="getCollectionHTML">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="render"     required="true" type="any">
		<cfargument name="substmap"   required="true" type="any">
		<cfargument name="colkeys"    required="true" type="any">

		<cfset var local      = StructNew()>
		<cfset lcl.coll     = arguments.collection>
		<cfset lcl.render   = arguments.render>
		<cfset lcl.substmap = arguments.substmap>
		<cfset lcl.colkeys  = arguments.colkeys>
		<cfset lcl.html = "">

		<cfswitch expression="#getCollectionType(lcl.coll).type#">
			<cfcase value="query,component">
				<cfset lcl.it = iterator(lcl.coll)>
				<cfloop condition="#lcl.it.whileHasNext()#">
					<cfset lcl.temp             = substValsFromObj(lcl.substmap, lcl.it.current, lcl.colkeys)>
					<cfset lcl.colkeys          = lcl.temp.list>
					<cfset lcl.substmap         = lcl.temp.subst>
					<cfset lcl.substmap.key     = lcl.it.index>
					<cfset lcl.substmap.current = lcl.it.index>
					<cfset lcl.html = lcl.html & substituteValues(lcl.render, lcl.substmap)>
				</cfloop>
			</cfcase>

			<cfcase value="string,array">
				<cfset lcl.it = iterator(lcl.coll)>
				<cfloop condition="#lcl.it.whileHasNext()#">
					<cfset lcl.substmap.current = lcl.it.index>
					<cfset lcl.substmap.key     = lcl.it.key>
					<cfset lcl.substmap.value   = lcl.it.current>
					<cfset lcl.substmap["0"]    = substituteValues(lcl.it.current, lcl.substmap)>
					<cfset lcl.html = lcl.html & substituteValues(lcl.render, lcl.substmap)>
				</cfloop>
			</cfcase>

			<cfcase value="struct">
				<cfset lcl.temp  = substValsFromObj(lcl.substmap, lcl.coll, lcl.colkeys)>
				<cfset lcl.colkeys          = lcl.temp.list>
				<cfset lcl.substmap         = lcl.temp.subst>
				<cfset lcl.html = lcl.html & substituteValues(lcl.render, lcl.substmap)>
				<!--- <cfset lcl.it = iterator(lcl.coll)>
				<cfloop condition="#lcl.it.whileHasNext()#">
					<cfset lcl.substmap.current = lcl.it.index>
					<cfset lcl.substmap.key     = lcl.it.key>
					<cfset lcl.substmap.value   = lcl.it.current>
					<cfset lcl.substmap["0"]    = substituteValues(lcl.it.current, lcl.substmap)>
					<cfset lcl.html = lcl.html & substituteValues(lcl.render, lcl.substmap)>
				</cfloop> --->
			</cfcase>
		</cfswitch>

		<cfreturn lcl.html>
	</cffunction>

	<cffunction name="list">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="text" required="false" type="string" default="%0%" hint="the collections 'content-value' will be used (list,array) for the li's tagbody (or an empty string if it can not be determined)">

		<cfset var local     = StructNew()>
		<cfset lcl.coll    = arguments.collection>
		<cfset lcl.render  = arguments.text>

		<cfset lcl.argmap   = indexArgs(arguments, 3, "keyfields")>
		<cfset lcl.itemattr = structSubtract(arguments, "id,class")>
		<cfset lcl.linkattr = structSubtract(arguments, "href=href,linkid=id,linkclass=class")>
		<cfset lcl.listattr = structSubtract(arguments, "listid=id,listclass=class")>

		<cfset lcl.html      = "">

		<cfif NOT StructIsEmpty(lcl.linkattr)>
			<cfset lcl.render = getHTML("a", keysToList(lcl.linkattr), lcl.render)>
		</cfif>
		<cfset lcl.render = getHTML("li", keysToList(lcl.itemattr), lcl.render)>

		<cfset lcl.html = getCollectionHTML(lcl.coll, lcl.render, lcl.argmap.map, lcl.argmap.keylist)>

		<cfreturn getHTML("ul", keysToList(lcl.listattr), lcl.html)>
	</cffunction>

	<cffunction name="link">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="href" required="true" type="string">
		<cfargument name="text" required="false" type="string" default="%0" hint="the collections 'content-value' will be used (list,array) for the li's tagbody (or an empty string if it can not be determined)">

		<cfset var local     = StructNew()>
		<cfset lcl.coll    = arguments.collection>
		<cfset lcl.text    = arguments.text>

		<cfset lcl.argmap   = indexArgs(arguments, 4, "keyfields")>
		<cfset lcl.linkattr = structSubtract(arguments, "href,rel,class,id")>
		<cfset lcl.html      = "">

		<cfset lcl.render = getHTML("a", keysToList(lcl.linkattr), lcl.text)>
		<cfset lcl.html = getCollectionHTML(lcl.coll, lcl.render, lcl.argmap.map, lcl.argmap.keylist)>

		<cfreturn lcl.html>
	</cffunction>

	<cffunction name="table">
		<cfargument name="collection" required="true" type="any">
		<cfargument name="colmap"     required="true" type="string">
		<!--- <cfargument name="headers" required="false" type="string" default="%0" hint="the collections 'content-value' will be used (list,array) for the li's tagbody (or an empty string if it can not be determined)"> --->

		<cfset var local     = StructNew()>
		<cfset lcl.coll    = arguments.collection>
		<cfset lcl.html      = "">

		<cfset lcl.tableattr = structSubtract(arguments, "id,class")>

		<cfset lcl.colmap = arguments.colmap>
		<cfset lcl.headers = "">
		<cfset lcl.rowdata = "">

		<cfset lcl.headers_set = false>
		<cfif StructKeyExists(arguments, "headers") AND arguments.headers neq "">
			<cfset lcl.headers = arguments.headers>
			<cfset lcl.headers_set = true>
		</cfif>

		<cfset lcl.argmap  = StructNew()>
		<cfset lcl.argmap.map = StructNew()>
		<cfset lcl.argmap.keylist = "">

		<cfset lcl.renders = StructNew()>
		<cfset lcl.renders["th"] = ArrayNew(1)>
		<cfset lcl.renders["td"] = ArrayNew(1)>

		<!--- Setup substitution map --->
		<cfset lcl.it = iterator(lcl.colmap)>
		<cfloop condition="#lcl.it.whileHasNext()#">
			<cfset lcl.temp = parseKeyVal(lcl.it.current)>
			<cfif NOT lcl.headers_set>
				<cfset lcl.headers = ListAppend(lcl.headers, lcl.temp.value)>
			</cfif>
			<cfset lcl.rowdata = ListAppend(lcl.rowdata, lcl.temp.key)>
			<cfset StructInsert(lcl.argmap.map, lcl.it.key, lcl.temp.key)>

			<cfset ArrayAppend(lcl.renders["th"], getHTML("th", "", lcl.temp.value))>
			<cfset ArrayAppend(lcl.renders["td"], getHTML("td", "", "%#lcl.it.key#%"))>
		</cfloop>

		<!--- Setup key list to lookup in collection --->
		<cfset lcl.argmap.keylist = lcl.rowdata>

		<!--- Parse head --->
		<cfset lcl.thead = getHTML("tr", "", ArrayToList(lcl.renders["th"],""))>
		<cfset lcl.thead = getHTML("thead", "", lcl.thead )>

		<!--- Parse body template --->
		<cfset lcl.tbody = getHTML("tr", "", ArrayToList(lcl.renders["td"],""))>

		<!--- get body data from template and collection --->
		<cfset lcl.tbody = getCollectionHTML(lcl.coll, lcl.tbody, lcl.argmap.map, lcl.argmap.keylist)>
		<cfset lcl.tbody = getHTML("tbody", "", lcl.tbody )>

		<!--- parse out table --->
		<cfset lcl.html = getHTML("table", "", lcl.thead & lcl.tbody)>

		<cfreturn lcl.html>
	</cffunction>

	<cffunction name="render">
		<cfargument name="collection"     required="true" type="any">
		<cfargument name="template"       required="true" type="string">
		<cfargument name="collectionkeys" required="false" type="string">

		<cfset var local    = StructNew()>
		<cfset lcl.coll   = arguments.collection>

		<cfset lcl.argmap = indexArgs(arguments, 3, "collectionkeys")>
		<cfset lcl.html   = "">
		<cfset lcl.render = arguments.template>
		<cfset lcl.html   = getCollectionHTML(lcl.coll, lcl.render, lcl.argmap.map, lcl.argmap.keylist)>

		<cfreturn lcl.html>
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

