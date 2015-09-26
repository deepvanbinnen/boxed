<!---
DO NOT USE!
- Source for dbobject's implementation of utils.cfc needs cleaning up
--->
<cfcomponent extends="pf">
	<cfset variables.iterators = StructNew()>
	<cfset variables.numiterators = 0>

	<cffunction name="init">
		<cfargument name="utils" required="true"  type="any" hint="Original ebx object" />
		<cfset variables.utils = arguments.utils>
		<cfreturn this>
	</cffunction>

	<cffunction name="iterator">
		<cfargument name="iterable" type="any" required="true">
		<cfset var i = 0>
		<cfloop from="1" to="#variables.numiterators#" index="i">
			<cfif StructKeyExists(variables.iterators, i) AND variables.iterators[i].done>
				<cfreturn variables.iterators[i].init(arguments.iterable)>
			</cfif>
		</cfloop>
		<cfset variables.numiterators = variables.numiterators + 1>
		<cfset StructInsert(variables.iterators, variables.numiterators, variables.utils.iterator(arguments.iterable), true)>
		<cfreturn variables.iterators[variables.numiterators]>
	</cffunction>

	<cffunction name="getCFTypeByDataType" returntype="string" access="public">
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

	<cffunction name="getCFDefaultFormDBDefault" returntype="string" access="public">
		<cfargument name="datatype" type="string" required="true">
		<cfargument name="value"    type="string" required="true">

		<cfswitch expression="#LCASE(arguments.datatype)#">
			<cfcase value="int,int4,int2,int8,integer,bigint,decimal,double,double precision,float,money,mmoney4,numeric,real,tinyint">
				<!---  --->

				<cfreturn Replace(Replace(arguments.value, "(", "", "ALL"), ")", "", "ALL")>

			</cfcase>
			<cfcase value="bit,bool,boolean">
				<!---  --->
			</cfcase>
			<cfcase value="char,text,ntext,uuid,varchar,nvarchar,character varying">
				<!---  --->
			</cfcase>
			<cfcase value="date,datetime,time,timestamp">
				<cfif arguments.value CONTAINS "getDate()">
					<cfreturn CHR(35) & "Now()" & CHR(35)>
				</cfif>
			</cfcase>
			<cfdefaultcase>
				<!---  --->
			</cfdefaultcase>
		</cfswitch>
		<cfreturn value>
	</cffunction>


	<cffunction name="getCFQPByDataType" returntype="string" access="public">
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

	<cffunction name="listundupe" returntype="string" access="public">
		<cfargument name="list" type="string" required="yes">
		<cfargument name="delimiter" type="string" required="no" default=",">

		<cfset var s = StructNew()>
		<cfset var listitem = "">
		<cfloop list="#arguments.list#" delimiters="#arguments.delimiter#" index="listitem">
			<cfset s[listitem] = "">
		</cfloop>
		<cfreturn StructKeyList(s)>
	</cffunction>

	<cffunction name="listify" returntype="string" access="public">
		<cfargument name="list" type="string" required="yes">
		<cfargument name="delimiter" type="string" required="no" default=",">

		<cfset var s = "">
		<cfsavecontent variable="s"><cfoutput><ul><li>#Replace(arguments.list,arguments.delimiter,"</li><li>","ALL")#</li></ul></cfoutput></cfsavecontent>
		<cfreturn s>
	</cffunction>

	<cffunction name="dot" returntype="string" access="public">
		<cfset var s = "">
		<cfloop from="1" to="#ArrayLen(arguments)#" index="i">
			<cfset s = ListAppend(s, arguments[i], ".")>
		</cfloop>
		<cfreturn s>
	</cffunction>

	<cffunction name="_list2Struct" returntype="struct">
		<cfargument name="list" required="true" type="string">
		<cfset var s = StructNew()>
		<cfset var c = "">
		<cfloop list="#arguments.list#" index="c">
			<cfset StructInsert(s,c,"")>
		</cfloop>
		<cfreturn s>
	</cffunction>

	<cffunction name="_queryRow2Struct" returntype="struct">
		<cfargument name="query" required="true" type="query">
		<cfargument name="rownum" required="false" type="numeric" default="1">
		<cfset var s = StructNew()>
		<cfset var c = "">
		<cfloop list="#arguments.query.columnlist#" index="c">
			<cfset StructInsert(s,c,arguments.query[c][rownum])>
		</cfloop>
		<cfreturn s>
	</cffunction>

	<cffunction name="_throwQueryError" returntype="query">
		<cfargument name="catchedError" required="true" type="any">

		<cfset var q   = QueryNew("ERROR")>
		<cfset QueryAddRow(q)>
		<cfset QuerySetCell(q, "ERROR", arguments.catchedError)>

		<cfreturn q>
	</cffunction>

	<cffunction name="namedArguments" returntype="boolean">
		<cfargument name="check" required="true" type="struct">

		<cfif StructKeyList(arguments.check) neq "">
			<cfreturn NOT IsNumeric(ListFirst(StructKeyList(arguments.check)))>
		</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="ListHasList" returntype="boolean">
		<cfargument name="sourcelist" required="true" type="string">
		<cfargument name="checklist" required="true" type="string">
		<cfargument name="srcdelimiter" required="false" type="string" default=",">
		<cfargument name="chkdelimiter" required="false" type="string" default="#arguments.srcdelimiter#">
		<cfargument name="casesensitive" required="false" type="boolean" default="false">

		<cfset var it = iterator(checklist)>
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

	<cffunction name="getType" returntype="string">
		<cfargument name="check" type="any" required="true">
		<cfset var t = "">
		<cfset t = getMetaData(arguments.check).name>
		<cfreturn LCASE(ListLast(t, "."))>
	</cffunction>

	<cffunction name="getCollectionType">
		<cfargument name="collection" type="any" required="true">
		<cfset var obj = arguments.collection>
		<cfset var out = StructNew()>
		<cfset out.name = "">
		<cfset out.type = "">
		<cfset out.name = "">
		<cfif IsStruct(obj)>
			<!--- Structtype found --->
			<cfif IsStruct(getMetaData(obj)) AND StructKeyExists(getMetaData(obj), "extends") AND StructKeyExists(getMetaData(obj), "name")>
				<!--- Component type found --->
				<cfset out.type = "component">
				<cfset out.name = getMetaData(obj).name>
			<cfelse>
				<!--- Struct type --->
				<cfset out.type = "struct">
				<cfset out.name = obj.getClass().getName()>
			</cfif>
		<cfelseif IsArray(obj)>
			<!--- Return array-type --->
			<cfset out.type = "array">
			<cfset out.name = obj.getClass().getName()>
		<cfelseif IsQuery(obj)>
			<!--- Return query-type --->
			<cfset out.type = "query">
			<cfset out.name = obj.getClass().getName()>
		<cfelseif IsSimpleValue(obj)>
			<cfset out.type = "string">
			<cfset out.name = obj.getClass().getName()>
		<cfelse>
			<cftry>
				<cfset out.type = "">
				<cfset out.name = obj.getClass().getName()>
				<cfcatch type="any">
					<cfset out.type = "">
					<cfset out.name = "unknown">
				</cfcatch>
			</cftry>
			<!--- Unable to determine type of java-obj: <cfoutput>#obj.getClass().getName()#</cfoutput> --->
		</cfif>
		<cfreturn out>
	</cffunction>

	<cffunction name="p2sa" hint="pair2structarray">
		<cfargument name="instring" type="string" required="true">
		<cfargument name="extended"  type="boolean" required="false" default="false">
		<cfargument name="delimiter"  type="string" required="false" default="#guessDelimiter(arguments.instring)#">

		<cfset var local = StructNew()>
		<cfset local.instring   = strip(arguments.instring)>
		<cfset local.delimiter  = strip(arguments.delimiter)>
		<cfset local.extended   = arguments.extended>
		<cfset local.result     = ArrayNew(1)>

		<cfif local.instring eq "">
			<cfreturn local.result>
		</cfif>

		<cfif local.delimiter eq "">
			<cfset local.delimiter = CHR(10)>
		</cfif>

		<cfset local.pairs = ListToArray(local.instring, local.delimiter)>
		<cfset local.it    = iterator(local.pairs)>
		<cfloop condition="#local.it.whileHasNext()#">
			<cfset local.pair = ListToArray(local.it.current,"=")>
			<cfset local.temp = StructNew()>
			<cfset StructInsert(local.temp, "key",  TRIM(local.pair[1]))>
			<cfset StructInsert(local.temp, "name", local.temp["key"])>
			<cfset StructInsert(local.temp, "ispair", (Find("=", local.it.current)) GT 0)>
			<cfset StructInsert(local.temp, "value",  "")>
			<cfif (ArrayLen(local.pair) gt 1)>
				<cfset StructUpdate(local.temp, "value",  TRIM(local.pair[2]))>
			</cfif>
			<cfset ArrayAppend(local.result, local.temp)>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="p2s" hint="pair2struct">
		<cfargument name="instring" type="string" required="true">
		<cfargument name="extended"  type="boolean" required="false" default="false">
		<cfargument name="delimiter"  type="string" required="false" default="#guessDelimiter(arguments.instring)#">
		<cfargument name="pairdelimiter"  type="string" required="false" default="=">

		<cfset var local = StructNew()>
		<cfset local.instring   = strip(arguments.instring)>
		<cfset local.delimiter  = strip(arguments.delimiter)>
		<cfset local.pairdelimiter  = strip(arguments.pairdelimiter)>
		<cfset local.extended   = arguments.extended>
		<cfset local.result     = StructNew()>

		<cfif local.instring eq "">
			<cfreturn local.result>
		</cfif>

		<cfif local.delimiter eq "">
			<cfset local.delimiter = CHR(10)>
		</cfif>

		<cfset local.it    = iterator( ListToArray(local.instring, local.delimiter))>
		<cfloop condition="#local.it.whileHasNext()#">
			<cfset local.pair = ListToArray(local.it.current, local.pairdelimiter)>
			<cfset local.key  = TRIM(local.pair[1])>
			<cfset local.val  = "">
			<cfif ArrayLen(local.pair) GT 1>
				<cfset local.val  = TRIM(local.pair[2])>
			</cfif>

			<cfif local.extended>
				<cfset StructInsert(local.result, "name", local.key)>
				<cfset StructInsert(local.result, "ispair", (Find("=", local.it.current)) GT 0)>
				<cfset StructInsert(local.result, "value",  local.val)>
			<cfelse>
				<cfset StructInsert(local.result, local.key, local.val)>
			</cfif>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="d2a" output="yes" returntype="array">
		<cfargument name="instring" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default="#guessDelimiter(arguments.instring)#">

		<cfset var local = StructNew()>
		<cfset local.instring  = TRIM(arguments.instring)>
		<cfset local.delimiter = arguments.delimiter>

		<cfset local.result    = ArrayNew(1)>
		<cfif local.instring neq "">
			<cfif local.delimiter eq "">
				<cfset local.delimiter = CHR(10)>
			</cfif>
			<cfset local.result = ListToArray(local.instring, local.delimiter)>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="a2s" output="No" returntype="struct">
		<cfargument name="inarray"  type="array" required="true">
		<cfargument name="inkeys"   type="string" required="true">
		<cfargument name="instruct" type="struct" required="false" default="#StructNew()#">

		<cfset var local = StructNew()>

		<cfset local.inarray  = arguments.inarray>
		<cfset local.inkeys   = ListToArray(TRIM(arguments.inkeys))>
		<cfset local.instruct = arguments.instruct>

		<cfif ArrayLen(local.inarray) gt ArrayLen(local.inkeys)>
			<cfset local.maxiter = ArrayLen(local.inkeys)>
		<cfelse>
			<cfset local.maxiter = ArrayLen(local.inarray)>
		</cfif>

		<cfset local.it = iterator(local.inkeys)>
		<cfloop condition="#local.it.whileHasNext()#">
			<cfif local.it.index gt local.maxiter>
				<cfbreak>
			</cfif>
			<cfif StructKeyExists(local.instruct, local.it.current)>
				<cfif IsSimpleValue(local.inarray[local.it.index]) AND strip(local.inarray[local.it.index]) neq "">
					<cfset StructUpdate(local.instruct, local.it.current, local.inarray[local.it.index])>
				</cfif>
			<cfelse>
				<cfset StructInsert(local.instruct, local.it.current, local.inarray[local.it.index])>
			</cfif>
		</cfloop>

		<cfreturn local.instruct>
	</cffunction>

	<cffunction name="guessDelimiter">
		<cfargument name="instring" type="string" required="true">

		<cfset var local = StructNew()>
		<cfset local.DELIMITERS = "10,13,32,44,124,43"><!--- CR,SPACE,COMMA,PIPELINE,PLUS, --->
		<cfset local.instring = TRIM(arguments.instring)>

		<cfif local.instring neq "">
			<cfloop from="1" to="#Len(arguments.instring)#" index="local.i">
				<cfset local.value = ASC(MID(arguments.instring,local.i,1))>
				<cfif ListFind(local.DELIMITERS, local.value)>
					<cfreturn CHR(local.value)>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn "">
	</cffunction>

	<cffunction name="copyStruct">
		<cfargument name="source"      type="struct" required="true">
		<cfargument name="destination" type="struct" required="false" default="#StructNew()#">
		<cfargument name="flag"        type="numeric" required="false" default="0">

		<!--- FLAGS: COPY_EMPTY | --->

		<cfset var local = StructNew()>
		<cfset local.source         = arguments.source>
		<cfset local.destination    = arguments.destination>

		<cfset local.it = iterator(local.source)>
		<cfloop condition="#local.it.whileHasNext()#">
			<cfif NOT StructKeyExists(local.destination,local.it.key)>
				<cfset StructInsert(local.destination,local.it.key,local.it.current)>
			<cfelse>
				<cfif IsSimpleValue(local.destination[local.it.key]) AND TRIM(local.destination[local.it.key]) eq "">
					<cfset StructUpdate(local.destination,local.it.key,local.it.current)>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn local.destination>
	</cffunction>


	<cffunction name="emptyMethod" output="no" returntype="struct">
		<cfreturn p2s('name,rettype=any,retval,params,locals')>
	</cffunction>

	<cffunction name="emptyParam" output="no" returntype="struct">
		<cfreturn p2s('name,datatype=any,required=true,default')>
	</cffunction>

	<cffunction name="strip">
		<cfargument name="instring" type="string" required="false" default="">

		<cfif arguments.instring eq "''" OR arguments.instring eq '""'>
			<cfreturn "">
		</cfif>
		<cfreturn arguments.instring>
	</cffunction>

</cfcomponent>