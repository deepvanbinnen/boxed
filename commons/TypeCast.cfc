<cfcomponent output="false" hint="handle custom casting of datatypes">
	<cffunction name="__constructor" access="private" output="false" returntype="void" hint="maps given arguments to the variablescope. DO NOT USE THIS METHOD in Abstracted Object unless you know how to handle the variables-scope sets">
		<cfif ArrayLen(arguments) AND IsStruct(arguments)>
			<cfset StructAppend(variables, arguments, false)>
		</cfif>
	</cffunction>

	<cffunction name="LocalArgs" output="false" returntype="any" hint="Creates an object that aids in remapping original argumentCollection to named struct based on rules. Usage in cfcdoc:cfc.commons.ArgumentsCollector.">
		<cfargument name="original" type="any" required="true" hint="The original argumentscollection">
		<cfreturn StructCreate(args = CollectArgs(arguments.original))>
	</cffunction>

	<cffunction name="CollectArgs" output="false" returntype="any" hint="Creates an object that aids in remapping original argumentCollection to named struct based on rules. Usage in cfcdoc:cfc.commons.ArgumentsCollector.">
		<cfargument name="original" type="any" required="true" hint="The original argumentscollection">
		<cfreturn createObject("component", "ArgumentsCollector").init(arguments.original)>
	</cffunction>

	<cffunction name="StructCreate" access="public" output="false" returntype="struct" hint="Returns struct from named args">
		<cfreturn _StructCreate(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="QueryCreate" access="public" output="false" returntype="query" hint="Returns query from named args">
		<cfreturn _QueryCreate(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="ArrayCreate" access="public" output="false" returntype="array" hint="Returns array from unnamed args. DO NOT use named args, the order of passed in args is not respected!">
		<cfset var local = StructNew() />

		<cfif ArrayLen(arguments) GT 1 AND _isNumericList(StructKeyList(arguments))>
			<cfset local.a = ArrayNew(1) />
			<cfloop from="1" to="#ArrayLen(arguments)#" index="local.i">
				<cfset ArrayAppend(local.a, arguments["#local.i#"]) />
			</cfloop>
			<cfreturn local.a />
		</cfif>

		<cfreturn _ArrayCreate(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="ObjectCreate" access="public" output="false" returntype="any" hint="Returns a new created object!">
		<cfargument name="targetCFC"   type="any" required="true">
		<cfreturn _ObjectCreate(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="StructArray" access="public" output="false" returntype="array" hint="Returns array from struct and keylist">
		<cfargument name="struct" required="true"  type="struct" hint="in-struct" />
		<cfargument name="keylist" required="true"  type="string" hint="list of keys" />

		<cfset var local = StructNew() />
		<cfset local.arr  = ArrayCreate() />
		<cfset local.keys = ListEnsureList(arguments.keylist, StructKeyList(arguments.struct)) />
		<cfset local.iter = iterator(local.keys) />
		<cfloop condition="#local.iter.whileHasNext()#">
			<cfif StructKeyExists(arguments.struct, local.iter.getCurrent())>
				<cfset ArrayAppend(local.arr, arguments.struct[local.iter.getCurrent()]) />
			</cfif>
		</cfloop>

		<cfreturn local.arr />
	</cffunction>

	<cffunction name="RepeatedArray" access="public" output="false" returntype="array" hint="Returns array with number of 'repeat' items containing value">
		<cfargument name="value" type="any" required="true" />
		<cfargument name="repeat" type="numeric" required="false" default="0" />

		<cfset var local = StructCreate( res = ArrayCreate() ) />
		<cfloop from="1" to="#arguments.repeat#" index="local.i">
			<cfset ArrayAppend(local.res, arguments.value) />
		</cfloop>

		<cfreturn local.res />
	</cffunction>

	<cffunction name="StructValArray" output="false" hint="Returns list of structkey values as an array">
		<cfargument name="struct" type="struct" required="true">
		<cfargument name="list"   type="string" required="false" default="#StructKeyList(arguments.struct)#">

		<cfset var local = StructCreate(keys = iterator(arguments.list), result = ArrayCreate())>
		<cfloop condition="#local.keys.whileHasNext()#">
			<cfif StructKeyExists(arguments.struct, local.keys.getCurrent())>
				<cfset ArrayAppend(local.result, arguments.struct[local.keys.getCurrent()])>
			</cfif>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="IndexedStructCreate" access="public" output="false" returntype="any" hint="Returns struct from named args">
		<cfargument name="keys"     required="false" type="any" default="">
		<cfargument name="valueArr" required="false" type="array" default="#ArrayCreate()#">

		<cfset var local = StructCreate(keylist = arguments.keys, values = arguments.valueArr)>
		<cfswitch expression="#getDataType(local.keylist)#">
			<cfcase value="string">
				<cfif getDataType(local.values) eq "array" AND NOT ArrayLen(local.values) eq ListLen(local.keylist)>
					<cfthrow message="Unable to create indexed struct!">
				</cfif>
			</cfcase>
			<cfcase value="struct">
				<cfif local.values neq "">
					<cfset local.keylist = local.values>
				<cfelse>
					<cfset local.keylist = StructKeyList(arguments.keys)>
				</cfif>
				<cfset local.values = StructValArray(arguments.keys, local.keylist)>
			</cfcase>
		</cfswitch>

		<cfreturn createObject("component", "collections.OrderedStruct").init(argumentCollection = local)>
	</cffunction>

	<cffunction name="ise" returntype="boolean" output="false" hint="checks if given value is empty">
		<cfargument name="value" required="true"  type="any" hint="value to check" />
		<cfargument name="trim" required="false"  type="boolean" default="true" hint="whether to trim strings" />

		<cfswitch expression="#getDatatype(arguments.value)#">
			<cfcase value="string">
				<cfif arguments.trim>
					<cfreturn NOT Len(Trim(arguments.value)) />
				<cfelse>
					<cfreturn NOT Len(arguments.value) />
				</cfif>
			</cfcase>
			<cfcase value="struct">
				<cfreturn StructIsEmpty(arguments.value) />
			</cfcase>
			<cfcase value="array">
				<cfreturn ArrayLen(arguments.value) />
			</cfcase>
			<cfdefaultcase>
				<cfreturn false />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="nise" returntype="boolean" output="false" hint="checks if given value not is empty">
		<cfargument name="value" required="true"  type="any" hint="value to check" />
		<cfreturn NOT ise(arguments.value) />
	</cffunction>

	<cffunction name="ltoa" output="false" hint="ListToArray shorthand">
		<cfargument name="list"      type="string" required="true">
		<cfargument name="delimiter" type="any" required="false" default="">

		<cfif arguments.delimiter eq "">
			<cfset arguments.delimiter = ",">
		<cfelseif IsNumeric(arguments.delimiter)>
			<cfset arguments.delimiter = CHR(arguments.delimiter)>
		</cfif>

		<cfreturn ListToArray(arguments.list, arguments.delimiter)>
	</cffunction>

	<cffunction name="ListReplaceLast" access="public" output="false" returntype="string" hint="Returns list with last element replaced!">
		<cfargument name="list" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">
		<cfif ListLen(arguments.list, arguments.delimiter)>
			<cfreturn ListAppend(ListDeleteLast(arguments.list, arguments.delimiter), arguments.value, arguments.delimiter)>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="ListEnsureLast" access="public" output="false" returntype="string" hint="Returns list with last element ensured to be value">
		<cfargument name="list" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">

		<cfif ListLast(arguments.list, arguments.delimiter) NEQ arguments.value>
			<cfset arguments.list = ListAppend(arguments.list, arguments.value, arguments.delimiter) />
		</cfif>
		<cfreturn arguments.list />
	</cffunction>

	<cffunction name="ListMergeKeys" access="public" output="false" returntype="string" hint="Adds targetlist items to sourcelist if targetlist item does not exist in sourcelist">
		<cfargument name="sourcelist" type="string" required="true">
		<cfargument name="targetlist" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">
		<cfargument name="trgdelimiter" type="string" required="false" default="#arguments.delimiter#">

		<cfset var local = StructCreate(list = iterator(ListToArray(arguments.targetlist, arguments.trgdelimiter)))>
		<cfloop condition="#local.list.whileHasNext()#">
			<cfset local.index = ListFindNoCase(arguments.sourcelist, local.list.getCurrent(), arguments.delimiter)>
			<cfif local.index eq 0>
				<cfset arguments.sourcelist = ListAppend(arguments.sourcelist, local.list.getCurrent(), arguments.delimiter)>
			</cfif>
		</cfloop>
		<cfreturn arguments.sourcelist>
	</cffunction>

	<cffunction name="ListDeleteList" access="public" output="false" returntype="string" hint="Returns sourcelist with targetlist elements removed">
		<cfargument name="sourcelist" type="string" required="true">
		<cfargument name="targetlist" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">
		<cfargument name="trgdelimiter" type="string" required="false" default="#arguments.delimiter#">

		<cfset var local = StructCreate(list = iterator(ListToArray(arguments.targetlist, arguments.trgdelimiter)))>
		<cfloop condition="#local.list.whileHasNext()#">
			<cfset local.index = ListFindNoCase(arguments.sourcelist, local.list.getCurrent(), arguments.delimiter)>
			<cfif local.index neq 0>
				<cfset arguments.sourcelist = ListDeleteAt(arguments.sourcelist, local.index, arguments.delimiter)>
			</cfif>
		</cfloop>
		<cfreturn arguments.sourcelist>
	</cffunction>

	<cffunction name="ListEnsureList" access="public" output="false" returntype="string" hint="Returns sourcelist with undefined targetlist elements removed">
		<cfargument name="sourcelist" type="string" required="true">
		<cfargument name="targetlist" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">
		<cfargument name="trgdelimiter" type="string" required="false" default="#arguments.delimiter#">

		<cfset var local = StructCreate(list = iterator(ListToArray(arguments.targetlist, arguments.trgdelimiter)))>
		<cfloop condition="#local.list.whileHasNext()#">
			<cfset local.index = ListFindNoCase(arguments.sourcelist, local.list.getCurrent(), arguments.delimiter)>
			<cfif local.index eq -1>
				<cfset arguments.sourcelist = ListDeleteAt(arguments.sourcelist, local.index, arguments.delimiter)>
			</cfif>
		</cfloop>
		<cfreturn arguments.sourcelist>
	</cffunction>

	<cffunction name="ListDeleteLast" access="public" output="false" returntype="string" hint="Returns list with last element removed!">
		<cfargument name="list" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">
		<cfif ListLen(arguments.list, arguments.delimiter)>
			<cfreturn ListDeleteAt(arguments.list, ListLen(arguments.list, arguments.delimiter), arguments.delimiter)>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="ListRemoveLast" access="public" output="false" returntype="string" hint="Alias for ListDeleteLast">
		<cfreturn ListDeleteLast(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="ListRemoveLastDelimiters" access="public" output="false" returntype="string" hint="Returns a list without final delimiter (used for xpath/file path expressions)">
		<cfargument name="list" type="string" required="yes">
		<cfargument name="delimiter" type="string" required="no" default=",">
		<cfreturn REReplace(arguments.list, "([#arguments.delimiter#]{0,})$", "") />
	</cffunction>

	<cffunction name="ListHasList" output="false" returntype="boolean" hint="Checks if every list element in checklist is available in sourcelist">
		<cfargument name="sourcelist" required="true" type="string">
		<cfargument name="checklist" required="true" type="string">
		<cfargument name="srcdelimiter" required="false" type="string" default=",">
		<cfargument name="chkdelimiter" required="false" type="string" default="#arguments.srcdelimiter#">
		<cfargument name="casesensitive" required="false" type="boolean" default="false">

		<cfset var it = iterator(arguments.checklist)>
		<cfloop condition="#it.whileHasNext()#">
			<cfif arguments.casesensitive>
				<cfif NOT ListFind(arguments.sourcelist, it.current)>
					<cfreturn false>
				</cfif>
			<cfelse>
				<cfif NOT ListFindNoCase(arguments.sourcelist, it.current)>
					<cfreturn false>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn true>
	</cffunction>

	<cffunction name="ListUndupe" output="false" returntype="string" access="public" hint="Removes duplicates from list. This method is NOT case-sensitive and does NOT keep list order">
		<cfargument name="list" type="string" required="yes">
		<cfargument name="delimiter" type="string" required="no" default=",">

		<cfset var s = StructNew()>
		<cfset var listitem = "">
		<cfloop list="#arguments.list#" delimiters="#arguments.delimiter#" index="listitem">
			<cfset s[listitem] = "">
		</cfloop>
		<cfreturn StructKeyList(s,arguments.delimiter)>
	</cffunction>

	<cffunction name="ListUndupe2" output="false" returntype="string" access="public" hint="Removes duplicates from list. This method is NOT case-sensitive and does NOT keep list order">
		<cfargument name="list" type="string" required="yes">
		<cfargument name="delimiter" type="string" required="no" default=",">

		<cfset var s = StructNew()>
		<cfset var o = ArrayCreate()>
		<cfset var listitem = "">
		<cfloop list="#arguments.list#" delimiters="#arguments.delimiter#" index="listitem">
			<cfif NOT StructKeyExists(s, listitem)>
				<cfset s[listitem] = "">
				<cfset ArrayAppend(o, listitem)>
			</cfif>
		</cfloop>
		<cfreturn ltoa(o, arguments.delimiter)>
	</cffunction>

	<cffunction name="MapQueryStruct" hint="maps a query to a struct with keys and values from given columns">
		<cfargument name="query"       type="query" required="true">
		<cfargument name="keycolumn"   type="string" required="true">
		<cfargument name="valuecolumn" type="string" required="true">

		<cfset var local = _StructCreate(
				result = StructNew()
		)>
		<cfloop query="arguments.query">
			<cfset StructInsert(local.result, arguments.query[keycolumn][currentrow], arguments.query[valuecolumn][currentrow], true)>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="RowStruct" access="public" output="false" returntype="struct" hint="return struct from named args else array">
		<cfif ArrayLen(arguments) AND StructKeyExists(arguments, "1") AND IsQuery(arguments[1])>
			<cfreturn _q2s(arguments[1])>
		</cfif>
		<cfreturn StructNew()>
	</cffunction>

	<cffunction name="structDeleteList" hint="Deletes a list of keys from struct">
		<cfargument name="struct" required="true" type="struct" hint="struct to get keylist from" />
		<cfargument name="list" required="false" type="string" default="text" hint="sorttype for keys" />
		<cfargument name="delimiter" required="false" type="string" default="," hint="list delimiter to use" />

		<cfset var local = StructNew() />
		<cfset local.iter = iterator(ltoa(arguments.list, arguments.delimiter)) />
		<cfloop condition="#local.iter.whileHasNext()#">
			<cfset local.curr = local.iter.getCurrent() />
			<cfif StructKeyExists(arguments.struct, local.curr)>
				<cfset StructDelete(arguments.struct, local.curr) />
			</cfif>
		</cfloop>
		<cfreturn arguments.struct />
	</cffunction>

	<cffunction name="structSortedKeyList" hint="Returns a sorted keylist from struct">
		<cfargument name="struct" required="true" type="struct" hint="struct to get keylist from" />
		<cfargument name="sorttype" required="false" type="string" default="text" hint="sorttype for keys" />
		<cfargument name="sortorder" required="false" type="string" default="ASC" hint="sortorder for keys" />
		<cfargument name="delimiter" required="false" type="string" default="," hint="list delimiter to use" />

		<cfreturn ListSort(StructKeyList(arguments.struct), arguments.sorttype, arguments.sortorder, arguments.delimiter)>
	</cffunction>

	<cffunction name="structToQueryString" hint="Convert a struct to escaped querystring">
		<cfargument name="struct" required="true" type="struct" hint="struct to convert" />
		<cfargument name="qsdelim" required="false" type="string" default="&" hint="qs delimiter to use" />

		<cfset var local = StructCreate( iter = iterator(arguments.struct), qVars = "")>
		<cfloop condition="#local.iter.whileHasNext()#">
			<cfif local.iter.getIndex() neq 1>
				<cfset local.qVars = local.qVars & arguments.qsdelim>
			</cfif>
			<cfset local.qVars = local.qVars & local.iter.getKey() & "=" & URLEncodedFormat(local.iter.getValue())>
		</cfloop>

		<cfreturn local.qVars />
	</cffunction>

	<cffunction name="mergeStruct" returntype="struct" output="false" hint="merges given struct into a struct's subkey">
		<cfargument name="struct" required="true"  type="struct" hint="The original struct" />
		<cfargument name="key" required="false"  type="string" default="" hint="The key containing the struct to merge other keys in to" />

		<cfset var local = StructNew() />
		<cfif StructKeyExists(arguments.struct, arguments.key) AND IsStruct(arguments.struct[arguments.key])>
			<cfset local.struct = StructCopy(arguments.struct[arguments.key]) />
			<cfset StructDelete(arguments.struct, arguments.key) />
			<cfset StructAppend(local.struct, arguments.struct, false) />
		<cfelse>
			<cfset local.struct = StructCopy(arguments.struct) />
		</cfif>
		<cfreturn local.struct />
	</cffunction>

	<cffunction name="XmlNodesToArray" output="false">
		<cfargument name="xmlNodes" type="array" required="true">

		<cfset var local = _StructCreate(result = ArrayNew(1))>

		<cfloop from="1" to="#ArrayLen(arguments.xmlNodes)#" index="local.i">
			<cfswitch expression="#arguments.xmlNodes[local.i].getNodeType()#">
				<cfdefaultcase>
					<cfset ArrayAppend(local.result, arguments.xmlNodes[local.i].getTextContent())>
				</cfdefaultcase>
			</cfswitch>
		</cfloop>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="XPathAttribsToQuery" output="false">
		<cfargument name="xml"     type="xml"    required="true">
		<cfargument name="xmlRoot" type="string" required="true">
		<cfargument name="attribs" type="string" required="true">
		<cfargument name="collist" type="string" required="false" default="#arguments.attribs#">
		<cfargument name="query"   type="query"  required="false" default="#QueryNew("")#">

		<cfset var local = StructCreate(result = arguments.query)>

		<cfset local.a = ListToArray(arguments.attribs)>
		<cfset local.c = ListToArray(arguments.collist)>

		<cfloop from="1" to="#ArrayLen(local.a)#" index="local.i">
			<cfset QueryAddColumn(
					local.result
				  , local.c[local.i]
				  , XmlNodesToArray(XmlSearch(arguments.xml, arguments.xmlRoot & "/@" & local.a[local.i]))
			)>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="XPathChildrenToQuery" output="false">
		<cfargument name="xml"      type="xml"    required="true">
		<cfargument name="xmlRoot"  type="string" required="true">
		<cfargument name="children" type="string" required="true">
		<cfargument name="collist"  type="string" required="false" default="#arguments.children#">
		<cfargument name="query"    type="query"  required="false" default="#QueryNew("")#">

		<cfset var local = StructCreate(result = arguments.query)>

		<cfset local.a = ListToArray(arguments.children)>
		<cfset local.c = ListToArray(arguments.collist)>

		<cfloop from="1" to="#ArrayLen(local.a)#" index="local.i">
			<cfset QueryAddColumn(
					local.result
				  , local.c[local.i]
				  , XmlNodesToArray(XmlSearch(arguments.xml, arguments.xmlRoot & "/" & local.a[local.i] & "/"))
			)>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="XPathMapToQuery" hint="converts an xml object into a query according to given mapping.">
		<cfargument name="xmlObj"    type="xml"    required="true" hint="the xml data" />
		<cfargument name="xPathMap"  type="struct" required="true" hint="where key corresponds to columnname and value to XPath-expression" />
		<cfargument name="xPathCols" type="string" required="false" hint="the ordered list in which columns appear in out query, defaults to StructKeyList of XPathMap" />
		<cfargument name="xPathFrmt" type="struct" required="false" hint="struct in which keys correspond to columnname and where value is a reference to a cf-method." />

		<cfset var lcl = StructCreate(
			  qry = QueryCreate()
			, xml = arguments.xmlObj
			, map = arguments.xPathMap
		) />
		<cfif NOT StructKeyExists(arguments, "xPathCols")>
			<cfset lcl.cols = StructKeyList( lcl.map ) />
		<cfelse>
			<cfset lcl.cols = arguments.xPathCols />
		</cfif>
		<cfif NOT StructKeyExists(arguments, "xPathFrmt")>
			<!---
			Specifies a struct with functions used for postprocessing columnvalues,
			where key is columnname and value is the function reference.
			The function is given the xpath-expression-array used for columnvalues
			and must return an array with new/processed columnvalues.
			 --->
			<cfset lcl.frmt = StructNew() />
		<cfelse>
			<cfset lcl.frmt = arguments.xPathFrmt />
		</cfif>

		<cfset lcl.iter = iterator(lcl.cols) />
		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfset lcl.cname = lcl.iter.getCurrent()>
			<cfif StructKeyExists(lcl.map, lcl.cname)>
				<cfset lcl.expr = lcl.map[lcl.cname] />
				<cfset lcl.cval = XmlNodesToArray( XmlSearch(lcl.xml, lcl.expr) ) />
				<cfif StructKeyExists(lcl.frmt, lcl.cname)>
					<cfset lcl.fn = lcl.frmt[lcl.cname] />
					<cfset lcl.cval = lcl.fn(lcl.cval) />
				</cfif>
				<cfset QueryAddColumn(
						lcl.qry
					  , lcl.cname
					  , lcl.cval
				)>
			</cfif>
		</cfloop>

		<cfreturn lcl.qry />
	</cffunction>

	<cffunction name="rmxml" output="false" hint="removes xmlnamespace from string">
		<cfargument name="xml" required="Yes" type="any">
		<cfreturn REReplaceNoCase(ToString(arguments.xml) ,"<.xml.*?>","","ALL") />
	</cffunction>

	<cffunction name="addQS" hint="Appends querystring to a given link" output="false">
		<cfargument name="href" type="string" required="false" hint="on which the arguments will be appended" default="#CGI.SCRIPT_NAME#" />
		<cfargument name="qsdelimiter" type="string" required="false" default="&amp;" hint="is the delimiter used for querystring variables (for XHTML compliancy)">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#" hint="query params to add passed as struct">
		<cfargument name="listorder" type="string" required="false" default="" hint="defines the order in which the keys appear in the querystring">

		<cfset var lcl = StructCreate( result = arguments.href, excludelist = "href,qsdelimiter,params,listorder") />
		<cfset lcl.argkeys = ListDeleteList(StructKeyList(arguments), lcl.excludelist)>
		<cfset lcl.iter = iterator(lcl.argkeys) />
		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfset StructInsert(arguments.params, lcl.iter.getKey(), arguments[lcl.iter.getKey()], true) />
		</cfloop>
		<cfset lcl.listorder = ListMergeKeys(arguments.listorder, ListSort(StructKeyList(arguments.params), "TEXT")) />

		<cfset lcl.iter = iterator(lcl.listorder) />
		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfif StructKeyExists(arguments, lcl.iter.getCurrent())>
				<cfif NOT Find("?", lcl.result)>
					<cfset lcl.result = lcl.result & "?">
				<cfelse>
					<cfset lcl.result = lcl.result & arguments.qsdelimiter />
				</cfif>
				<cfset lcl.result = lcl.result & LCASE(lcl.iter.getCurrent()) & "=" & URLEncodedFormat(arguments[lcl.iter.getCurrent()]) />
			</cfif>
		</cfloop>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="getCFTypeByDataType" output="false" returntype="string" access="public" hint="get cfdatatype from database columntype">
		<cfargument name="datatype" type="string" required="true">

		<cfswitch expression="#LCASE(arguments.datatype)#">
			<cfcase value="int,int4,int2,int8,integer,bigint,decimal,double,double precision,float,money,mmoney4,numeric,real,tinyint">
				<cfreturn "numeric">
			</cfcase>
			<cfcase value="bit,bool,boolean">
				<cfreturn "boolean">
			</cfcase>
			<cfcase value="char,text,ntext,uuid,varchar,nvarchar,character varying">
				<cfreturn "string">
			</cfcase>
			<cfcase value="date,datetime,time,timestamp">
				<cfreturn "date">
			</cfcase>
			<cfdefaultcase>
				<cfreturn "any">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="getCFQPByDataType" output="false" returntype="string" access="public" hint="get cfqueryparamtype from database columntype">
		<cfargument name="datatype" type="string" required="true">

		<cfswitch expression="#LCASE(arguments.datatype)#">
			<cfcase value="int8,bigint">
				<cfreturn "CF_SQL_BIGINT">
			</cfcase>
			<cfcase value="bit,bool,boolean">
				<cfreturn "CF_SQL_BIT">
			</cfcase>
			<cfcase value="char">
				<cfreturn "CF_SQL_CHAR">
			</cfcase>
			<cfcase value="binary">
				<cfreturn "CF_SQL_BLOB">
			</cfcase>
			<cfcase value="binary character">
				<cfreturn "CF_SQL_CLOB">
			</cfcase>
			<cfcase value="date">
				<cfreturn "CF_SQL_DATE">
			</cfcase>
			<cfcase value="datetime">
				<cfreturn "CF_SQL_DATETIME">
			</cfcase>
			<cfcase value="decimal">
				<cfreturn "CF_SQL_DECIMAL">
			</cfcase>
			<cfcase value="double,double precision">
				<cfreturn "CF_SQL_DOUBLE">
			</cfcase>
			<cfcase value="float">
				<cfreturn "CF_SQL_FLOAT">
			</cfcase>
			<cfcase value="uuid">
				<cfreturn "CF_SQL_IDSTAMP">
			</cfcase>
			<cfcase value="int,int4,integer">
				<cfreturn "CF_SQL_INTEGER">
			</cfcase>
			<cfcase value="text,ntext">
				<cfreturn "CF_SQL_LONGVARCHAR">
			</cfcase>
			<cfcase value="money">
				<cfreturn "CF_SQL_MONEY">
			</cfcase>
			<cfcase value="money4">
				<cfreturn "CF_SQL_MONEY4">
			</cfcase>
			<cfcase value="numeric">
				<cfreturn "CF_SQL_NUMERIC">
			</cfcase>
			<cfcase value="real">
				<cfreturn "CF_SQL_REAL">
			</cfcase>
			<cfcase value="refcursor">
				<cfreturn "CF_SQL_REFCURSOR">
			</cfcase>
			<cfcase value="timestamp">
				<cfreturn "CF_SQL_TIMESTAMP">
			</cfcase>
			<cfcase value="tinyint,int2">
				<cfreturn "CF_SQL_TINYINT">
			</cfcase>
			<cfcase value="varchar,nvarchar,character varying">
				<cfreturn "CF_SQL_VARCHAR">
			</cfcase>
			<cfdefaultcase>
				<cfreturn "UNKNOWN_CFQP_TYPE: #LCASE(arguments.datatype)#">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="iterator" output="false" hint="creates an iterator for a given object">
		<cfargument name="iterable" required="yes" type="any" hint="iterable object, can be a list, query, array, struct">
		<cfreturn createObject("component", "iterators.Iterator").init(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getDataType" output="no" hint="get string representation for datatype">
		<cfargument name="data"    type="any" required="true">

		<cfif IsSimpleValue(arguments.data)>
			<cfreturn "string" />
		<cfelseif IsQuery(arguments.data)>
			<cfreturn "query">
		<cfelseif IsArray(arguments.data)>
			<cfreturn "array">
		<cfelseif IsObject(arguments.data)>
			<cfif _isCFC(arguments.data)>
				<cfreturn "cfc:" & _getName(arguments.data)>
			<cfelse>
				<cfif REFind("(.*)Exception$", _getName(arguments.data))>
					<cfreturn "exception">
				</cfif>
				<cfreturn "object">
			</cfif>
		<cfelseif IsStruct(arguments.data)>
			<cfreturn "struct">
		<cfelse>
			<cfif REFind("(.*)Exception$", _getName(arguments.data))>
				<cfreturn "exception">
			</cfif>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="_isArgumentCollection" output="false" hint="checks if data is an argumentcollection">
		<cfargument name="data" type="any" required="true">
		<cfreturn _getName(arguments.data) eq 'coldfusion.runtime.ArgumentCollection'>
	</cffunction>

	<cffunction name="_isNumericList" output="false" hint="checks if list is numeric">
		<cfargument name="list" type="string" required="true">
		<cfargument name="delimiter" type="string" default=",">

		<cfset var lcl = StructCreate(
			  vals   = iterator(ListToArray(arguments.list, arguments.delimiter))
			, result = false
		) />

		<cfif lcl.vals.getLength()>
			<cfset lcl.result = true />
			<cfloop condition="#lcl.vals.whileHasNext()#">
				<cfif NOT IsNumeric(lcl.vals.getCurrent())>
					<cfset lcl.result = false />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="_getName" access="public" output="false" returntype="string" hint="get java classname for CF-type or cfc-name if object is a cfc">
		<cfargument name="data" type="any" required="true">
		<cfif _isCFC(arguments.data)>
			<cfreturn getMetadata(arguments.data).name>
		<cfelse>
			<cfreturn getMetadata(arguments.data).getSimpleName()>
		</cfif>
	</cffunction>

	<cffunction name="_isCFC" access="public" output="false" returntype="boolean" hint="validates is given argument is a cfc">
		<cfreturn NOT ArrayLen(arguments) eq 0 AND isObject(arguments[1]) AND StructKeyExists(getMetaData(arguments[1]), "extends")>
	</cffunction>

	<cffunction name="_isClass" access="public" output="false" returntype="boolean" hint="checks if argument is a javaclass">
		<cfargument name="cls" type="any">
		<cftry>
			<cfreturn arguments.cls.getName() eq "java.lang.Class">
			<cfcatch type="any">
				<cfreturn false>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="_isMethod" access="public" output="false" returntype="boolean" hint="validates is given argument is a method by inspecting metadata">
		<cfargument name="func" type="any" hint="function reference">

		<cfset var local = StructNew()>
		<cfset local.fn  = arguments.func>

		<cfif NOT IsStruct(local.fn) AND NOT IsArray(local.fn) AND NOT IsObject(local.fn) AND NOT IsSimpleValue(local.fn)>
			<cfset local.metadata = getMetaData(local.fn)>
			<cfreturn StructKeyExists(local.metadata, "name") AND StructKeyExists(local.metadata, "parameters")>
		</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="_methodExists" access="public" output="false" returntype="boolean" hint="checks if method exists in cfc">
		<cfargument name="cfc" type="any">
		<cfargument name="func" type="any">

		<cfset var local = StructNew()>
		<cfset local.cfc  = arguments.cfc>
		<cfset local.result = false>

		<cfif _isCFC(local.cfc)>
			<cfset local.fns = getMetaData(local.cfc).functions>
			<cfloop from="1" to="#ArrayLen(local.fns)#" index="local.i">
				<cfif local.fns[local.i].name eq arguments.func>
					<cfset local.result = true>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_as2q" access="public" output="false" returntype="query" hint="array of structs to query">
		<cfargument name="data" type="array" required="true">
		<cfargument name="keys" type="string" required="false" default="">

		<cfset var local = StructNew()>
		<cfset local.result = QueryNew("")><!--- result query --->

		<!--- struct that holds columns with an array of their (row)-values --->
		<cfset local.temp   = StructNew()>

		<!--- setup columns --->
		<cfif arguments.keys neq "">
			<!--- columns are given only process these keys (make the list immutable) and initialise result struct --->
			<cfset local.immutable_keys = true>
			<cfset local.keys = arguments.keys>
			<!--- initialise result struct --->
			<cfloop list="#local.keys#" index="local.key">
				<cfif NOT StructKeyExists(local.temp, local.key)>
					<cfset StructInsert(local.temp, local.key, ArrayNew(1))>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset local.immutable_keys = false>
			<cfset local.keys = "">
		</cfif>

		<!--- loop the data --->
		<cfloop from="1" to="#ArrayLen(arguments.data)#" index="local.i">
			<cfset local.item = arguments.data[local.i]>
			<!--- reset columnlist if applicable--->
			<cfif NOT local.immutable_keys>
				<cfset local.keys = StructKeyList(local.item)>
			</cfif>
			<cfloop list="#local.keys#" index="local.key">
				<!--- Only process keys that exist --->
				<cfif StructKeyExists(local.item,local.key)>
					<!--- If applicable check and add struct key --->
					<cfif NOT local.immutable_keys AND NOT StructKeyExists(local.temp, local.key)>
						<cfset StructInsert(local.temp, local.key, ArrayNew(1))>
					</cfif>
					<!--- Set value --->
					<cfset ArraySet(local.temp[local.key], local.i, local.i, local.item[local.key])>
				</cfif>
			</cfloop>
		</cfloop>

		<cfset local.keys = StructKeyList(local.temp)>
		<cfloop list="#local.keys#" index="local.key">
			<cfset QueryAddColumn(local.result, local.key, local.temp[local.key])>
		</cfloop>


		<cfreturn local.result>
	</cffunction>

	<cffunction name="_aa2s" output="true" hint="array, array to struct">
		<cfargument name="keyarr" type="array" required="true" hint="Array of keys" />
		<cfargument name="valarr" type="array" required="true" hint="Array of corresponding values" />

		<cfset var lcal = StructCreate(
			  sameLength = (ArrayLen(arguments.keyarr) EQ ArrayLen(arguments.valarr))
			, data = StructCreate()
		) />

		<cfif lcal.sameLength>
			<cfloop from="1" to="#ArrayLen(arguments[1])#" index="lcal.i">
				<cfset StructInsert(lcal.data, arguments.keyarr[lcal.i], arguments.valarr[lcal.i], true)>
			</cfloop>
			<cfreturn lcal.data />
		<cfelse>
			<cfthrow message="_aa2s: Arguments not of same length (keyArr:#ArrayLen(arguments.keyarr)#, valarr:#ArrayLen(arguments.valarr)# )">
		</cfif>

	</cffunction>

	<cffunction name="_csv2q">
		<cfargument name="data"    type="string" required="true" hint="CSV data" />
		<cfargument name="cols"    type="string" required="true" hint="Columnlist" />
		<cfargument name="coldel"  type="string" required="false" default="," hint="Column delimiter" />
		<cfargument name="linedel" type="string" required="false" default="#CHR(10)#" hint="Line delimiter" />

		<cfset var local = StructCreate(
			  rows   = iterator(ListToArray(arguments.data, arguments.linedel))
			, result = QueryCreate(arguments.cols)
		) />

		<cfloop condition="#local.rows.whileHasNext()#">
			<cfset local.cols = request.ebx.iterator(ListToArray(TRIM(local.rows.getCurrent()), arguments.coldel)) />
			<cfif local.cols.getLength() eq ListLen(local.result.columnlist)>
				<!--- Still a bit dirty since the collections feature isn't actie yet --->
				<cfset QueryAddRow(local.result) />
				<cfloop condition="#local.cols.whileHasNext()#">
					<cfset QuerySetCell(local.result, ListGetAt(arguments.cols, local.cols.getIndex()), local.cols.getCurrent()) />
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn local.result />
	</cffunction>

	<cffunction name="_q2s" access="public" output="false" returntype="any" hint="return struct from query's current row">
		<cfargument name="query" type="query" required="true" hint="the query to obtain data from">
		<cfargument name="list"  type="string" required="false" default="#arguments.query.columnlist#" hint="the keys for the outstruct">

		<cfset var local = StructNew()>

		<cfset local.result = StructNew()>
		<cfloop list="#arguments.list#" index="local.column">
			<cfset StructInsert(local.result, local.column, arguments.query[local.column])>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_q2as" access="public" output="false" returntype="any" hint="return array of structs from query's current row">
		<cfargument name="query" type="query" required="true" hint="the query to obtain data from">
		<cfargument name="list"  type="string" required="false" default="#arguments.query.columnlist#" hint="the columns from the inquery">
		<cfargument name="keys"  type="string" required="false" default="#arguments.list#" hint="the keys for the outstruct">

		<cfset var local = StructNew()>
		<cfset local.result = ArrayNew(1)>

		<cfset local.list = ListToArray(arguments.list)>
		<cfif ListLen(arguments.keys) eq ListLen(arguments.list)>
			<cfset local.keys = ListToArray(arguments.keys)>
		<cfelse>
			<cfset local.keys = local.list>
		</cfif>

		<cfloop query="arguments.query">
			<cfset local.temp = StructNew()>
			<cfloop from="1" to="#ArrayLen(local.list)#" index="local.i">
				<cfset StructInsert(local.temp, local.keys[local.i], arguments.query[local.list[local.i]][currentrow], true)>
			</cfloop>
			<cfset ArrayAppend(local.result, local.temp)>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_toArray" access="public" output="false" returntype="array" hint="return array from any data">
		<cfargument name="data"   type="any" required="true" hint="the data to convert to array">
		<cfargument name="filter" type="any" required="false" hint="the filter for the data">

		<cfset var local = StructNew()>

		<cfif IsArray(arguments.data) AND NOT StructKeyExists(arguments, "filter")>
			<cfreturn arguments.data>
		</cfif>

		<cfset local.result = ArrayNew(1)>
		<cfif IsStruct(arguments.data)>
			<cfset local.keylist = StructKeyList(arguments.data)>
			<cfif StructKeyExists(arguments, "filter") AND IsSimpleValue(arguments.filter)>
				<cfset local.keylist = arguments.filter>
			</cfif>
			<cfloop list="#local.keylist#" index="local.key">
				<cfif StructKeyExists(arguments.data, local.key)>
					<!--- Must quote local.key because of unreliable behaviour when getting numeric keys from struct --->
					<cfset ArrayAppend(local.result, arguments.data["#local.key#"])>
				</cfif>
			</cfloop>
		<cfelseif IsSimpleValue(arguments.data)>
			<cfset local.delim = ",">
			<cfif StructKeyExists(arguments, "filter") AND IsSimpleValue(arguments.filter)>
				<cfset local.delim = arguments.filter>
				<cfif IsNumeric(arguments.filter)>
					<cfset local.delim = CHR(local.delim)>
				</cfif>
			</cfif>
			<cfset local.result = ListToArray(arguments.data, local.delim)>
		<cfelseif IsQuery(arguments.data)>
			<cfset local.collist = arguments.data.columnlist>
			<cfif StructKeyExists(arguments, "filter")>
				<cfif IsSimpleValue(arguments.filter)>
					<cfset local.collist = arguments.filter>
				<cfelseif IsArray(arguments.filter)>
					<cfset local.collist = ArrayToList(arguments.filter)>
				</cfif>
			</cfif>
			<cfset local.result = _q2as(arguments.data, local.collist)>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_toStruct" access="public" output="false" returntype="struct" hint="return struct from any data">
		<cfargument name="data"   type="any" required="true" hint="the data to convert to struct">
		<cfargument name="filter" type="any" required="false" hint="the filter for the data">

		<cfset var local = StructNew()>

		<cfif IsStruct(arguments.data) AND NOT StructKeyExists(arguments, "filter")>
			<cfreturn arguments.data>
		</cfif>

		<cfset local.result = StructNew()>
		<cfif IsQuery(arguments.data)>
			<cfset local.collist = arguments.data.columnlist>
			<cfif StructKeyExists(arguments, "filter")>
				<cfif IsSimpleValue(arguments.filter)>
					<cfset local.collist = arguments.filter>
				<cfelseif IsArray(arguments.filter)>
					<cfset local.collist = ArrayToList(arguments.filter)>
				</cfif>
			</cfif>
			<cfset local.result = _q2s(arguments.data, local.collist)>
		<cfelseif IsArray(arguments.data) OR IsSimpleValue(arguments.data)>
			<cfset local.array = _toArray(argumentCollection=arguments)>
			<cfloop from="1" to="#ArrayLen(local.array)#" index="local.i">
				<!--- Must quote local.i because of unreliable behaviour when getting numeric keys from struct --->
				<cfset StructInsert(local.result, local.i, local.array["#local.i#"], true)>
			</cfloop>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_StructCreate" access="public" output="true" returntype="struct" hint="return struct from named args else array">
		<cfset var local = StructNew()>

		<cfset local.data = arguments>

		<cfif ArrayLen(arguments) GT 1 AND StructKeyExists(arguments, "1")>
			<cfif IsStruct(arguments[1])>
				<cfset local.data = arguments[1]>
			<cfelseif IsQuery(arguments[1])>
				<cfset local.data = StructNew()>
				<cfloop list="#arguments[1].columnlist#" index="local.column">
					<cfset StructInsert(local.data, local.column, arguments[1][local.column])>
				</cfloop>
			<cfelseif IsArray(arguments[1]) AND IsArray(arguments[2]) AND ArrayLen(arguments[1]) EQ ArrayLen(arguments[2])>
				<cfset local.data = StructNew()>
				<cfloop from="1" to="#ArrayLen(arguments[1])#" index="local.i">
					<cfset StructInsert(local.data, arguments[1][local.i], arguments[2][local.i], true)>
				</cfloop>
			<cfelseif IsSimpleValue(arguments[1])>
				<cfset local.data = StructNew()>
				<cfloop list="#arguments[1]#" index="local.column">
					<cfset StructInsert(local.data, local.column, arguments[2])>
				</cfloop>
			</cfif>
		<cfelseif ArrayLen(arguments) EQ 1 AND StructKeyExists(arguments, "1")>
			<cfif _isArgumentCollection(arguments[1])>
				<cfset local.data = StructNew()>
				<cfset StructAppend(local.data, arguments[1])>
			<cfelseif IsSimpleValue(arguments[1])>
				<cfset local.data = StructNew()>
				<cfloop list="#arguments[1]#" index="local.column">
					<cfset StructInsert(local.data, local.column, "")>
				</cfloop>
			</cfif>
		</cfif>

		<cfreturn local.data>
	</cffunction>

	<cffunction name="_QueryCreate" access="private" output="false" returntype="query" hint="Creates query with default row from named args (values may be arrays), or empty columns if given argument is a list">
		<cfset var local = _StructCreate( query = QueryNew(""), data = arguments )>

		<cfif ArrayLen(arguments) eq 1 AND (IsStruct(arguments[1]) OR IsSimpleValue(arguments[1]))>
			<cfset local.data = arguments[1]>
		</cfif>

		<cfset local.iter = iterator(local.data)>
		<cfloop condition="#local.iter.whileHasNext()#">
			<cfif IsNumeric(local.iter.getKey())>
				<cfset local.columnname = "AUTO_COLUMN_NAME_#local.column#">
			<cfelse>
				<cfset local.columnname = local.iter.getKey()>
			</cfif>

			<cfif IsSimpleValue(local.data)>
				<cfset local.columnvalue = "">
			<cfelse>
				<cfset local.columnvalue = local.iter.getCurrent()>
			</cfif>

			<cfset QueryAddColumn(local.query, local.columnname, _ArrayCreate(local.columnvalue))>
		</cfloop>

		<cfreturn local.query>
	</cffunction>

	<cffunction name="_ArrayCreate" access="private" output="false" returntype="array" hint="By default returns array from unnamed args. This method does not create a new array, if number of equals 1 and is an array but returns that array. If number of arguments equals 1 and is an empty string returns a new empty array.">
		<cfset var local = StructNew()>

		<cfif ArrayLen(arguments) eq 1>
			<cfif IsArray(arguments[1])>
				<cfreturn arguments[1] />
			<cfelseif IsSimpleValue(arguments[1])>
				<cfif arguments[1] eq "">
					<cfreturn ArrayNew(1) />
				<cfelse>
					<cfreturn ListToArray(arguments[1])>
				</cfif>
			</cfif>
		</cfif>

		<cfset local.result = ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(arguments)#" index="local.i">
			<cfset ArrayAppend(local.result, arguments["#local.i#"]) />
		</cfloop>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="_ObjectCreate" access="private" output="false" returntype="any" hint="By default returns array from unnamed args. This method does not create a new array, if number of equals 1 and is an array but returns that array. If number of arguments equals 1 and is an empty string returns a new empty array.">
		<cfargument name="targetCFC"   type="any" required="true">

		<cfset var local = StructNew()>
		<cfif NOT _isCFC(arguments.targetCFC)>
			<cftry>
				<cfreturn createObject("component", arguments.targetCFC)>
				<cfcatch type="any">
					<cfthrow message="Unable to create object for: #arguments.targetCFC#"
						detail="#cfcatch.message# #cfcatch.detail# #cfcatch.extendedInfo#">
				</cfcatch>
			</cftry>
		<cfelseif _isCFC(arguments.targetCFC)>
			<cfreturn arguments.targetCFC />
		<cfelse>
			<cfthrow message="Unable to create object for: #arguments.targetCFC#">
		</cfif>

		<cfreturn arguments.targetCFC>
	</cffunction>

	<cffunction name="_listAsArray" output="false" hint="row as array">
		<cfargument name="list"      type="string" required="true">
		<cfargument name="delimiter" type="any" required="false" default="">

		<cfif arguments.delimiter eq "">
			<cfset arguments.delimiter = ",">
		<cfelseif IsNumeric(arguments.delimiter)>
			<cfset arguments.delimiter = CHR(arguments.delimiter)>
		</cfif>

		<cfreturn ListToArray(arguments.list, arguments.delimiter)>
	</cffunction>

	<cffunction name="_structValueArray" output="false" returntype="array">
		<cfargument name="data" type="struct" required="true">
		<cfreturn StructValArray(arguments.data)>
	</cffunction>

</cfcomponent>