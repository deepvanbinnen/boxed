<cfcomponent extends="TypeCast" output="false">
	<cffunction name="getFormVar" returntype="string" hint="">
		<cfargument name="name" required="true"  type="string" hint="name of formvar" />
		<cfargument name="default" required="false"  type="string" default="" hint="default if unexistant" />
		<cfif hasFormVar(arguments.name)>
			<cfreturn form[arguments.name] />
		</cfif>
		<cfreturn arguments.default />
	</cffunction>

	<cffunction name="getUrlVar" returntype="string" hint="gets the urlvar if exists or default">
		<cfargument name="name" required="true"  type="string" hint="name of Urlvar" />
		<cfargument name="default" required="false"  type="string" default="" hint="default if unexistant" />
		<cfif hasURLVar(arguments.name)>
			<cfreturn url[arguments.name] />
		</cfif>
		<cfreturn arguments.default />
	</cffunction>

	<cffunction name="getAllMethods" output="false" access="public" hint="gets all methods from given cfc">
		<cfargument name="cfc"   type="any" required="true">

		<cfreturn _as2q(_getAllMethods(getMetaData(arguments.cfc)))>
	</cffunction>

	<cffunction name="getMethodArgs" access="public" output="false" returntype="any" hint="checks if method exists in cfc">
		<cfargument name="cfc" type="any">
		<cfargument name="func" type="any">

		<cfset var local = StructNew()>
		<cfset local.cfc  = arguments.cfc>
		<cfset local.result = false>

		<cfif _isCFC(local.cfc)>
			<cfset local.fns = getMetaData(local.cfc).functions>
			<cfloop from="1" to="#ArrayLen(local.fns)#" index="local.i">
				<cfset local.fn = local.fns[local.i]>
				<cfif local.fn.name eq arguments.func>
					<cfset local.result = _getMethodArgs(local.fn.parameters)>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="hasFormVar" returntype="boolean" hint="checks if formvar exists">
		<cfargument name="name" required="true"  type="string" hint="name of formvar" />
		<cfreturn StructKeyExists( form, arguments.name ) AND ListFindNoCase( form.fieldnames, arguments.name ) />
	</cffunction>

	<cffunction name="hasUrlVar" returntype="boolean" hint="checks if urlvar exists">
		<cfargument name="name" required="true"  type="string" hint="name of Urlvar" />
		<cfreturn StructKeyExists( Url, arguments.name ) />
	</cffunction>

	<cffunction name="isHTTPS" output="false">
		<cfreturn CGI.HTTPS eq "on">
	</cffunction>

	<cffunction name="_getName" access="public" output="false" returntype="string" hint="get current objects name">
		<cfargument name="cfc" type="any" required="false" default="#this#">
		<cfreturn super._getName(arguments.cfc)>
	</cffunction>

	<cffunction name="__getCurrentURL" output="false" returntype="string" hint="Gets the URL for the current page from CGI">
		<cfset var retURL = "">
		<cfset retURL = __getProtocol() & "://" & CGI.SERVER_NAME & CGI.SCRIPT_NAME>
		<cfif CGI.QUERY_STRING neq "">
			<cfset retURL = retURL & "?" & CGI.QUERY_STRING>
		</cfif>
		<cfreturn retURL>
	</cffunction>

	<cffunction name="__getProtocol" output="false">
		<cfreturn "http" & IIF(isHTTPS(), "s", "") />
	</cffunction>

	<cffunction name="_guessDelimiter" output="false" returntype="string" hint="return delimiter from delimiter-list (CR,SPACE,COMMA,PIPELINE,PLUS) based on first delimiter occurrance in instring">
		<cfargument name="instring" type="string" required="true" hint="string to return a delimiter for">

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

	<cffunction name="_getMethods" access="public" hint="gets all methods from given cfc without recursion">
		<cfargument name="cfc" type="any" required="true">

		<cfset var local = StructNew()>
		<cfset local.cfc  = arguments.cfc>
		<cfset local.result = ArrayNew(1)>

		<cfif IsSimpleValue(local.cfc)>
			<cftry>
				<cfset local.cfc = ObjectCreate(local.cfc) />
				<cfcatch type="any">
					<cfreturn QueryCreate(error="true", message=cfcatch.message, object=cfcatch) />
				</cfcatch>
			</cftry>
		</cfif>

		<cfif _isCFC(local.cfc)>
			<cfset local.result = _as2q(_getMethodsArray(getMetaData(local.cfc).functions))>
		<cfelse>
			<cfset local.result = _dumpJavaMethods(local.cfc)>
		</cfif>
		<cfreturn local.result />
	</cffunction>

	<cffunction name="_getReflectedName" output="false" hint="returns the value of the getName method on targetObj. This method by default returns an empty string">
		<cfargument name="targetObj"   type="any" required="true">
		<cftry>
			<cfreturn arguments.targetObj.getName()>
			<cfcatch type="any">
				<cfreturn "">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="_getReflectedNames" output="false">
		<cfargument name="targetArr" type="any"     required="true">
		<cfargument name="asList"    type="boolean" required="false" default="false">

		<cfset var local = StructNew()>
		<cfset local.result = ArrayNew(1)>
		<cftry>
			<cfloop from="1" to="#ArrayLen(arguments.targetArr)#" index="local.i">
				<cfset ArrayAppend(local.result, _getReflectedName(arguments.targetArr[local.i]))>
			</cfloop>
			<cfcatch type="any">
				<cfreturn "">
			</cfcatch>
		</cftry>

		<cfif arguments.asList>
			<cfreturn ArrayToList(local.result)>
		<cfelse>
			<cfreturn local.result>
		</cfif>
	</cffunction>

	<cffunction name="_dumpMethods" access="public" output="false" returntype="query" hint="dump java class">
		<cfargument name="meth" type="any">

		<cfset var local = StructNew()>

		<cfset local.result = ArrayNew(1)>

		<cfset local.m = arguments.meth>
		<cfloop from="1" to="#ArrayLen(local.m)#" index="local.i">
			<cfset local.mtemp = local.m[local.i]>
			<cfset local.st = StructNew()>
			<cfset local.st.name = _getReflectedName(local.mtemp)>
			<cfset local.st.args = _getReflectedNames(local.mtemp.getParameterTypes(), true)>
			<cfset local.st.retv = _getReflectedName(local.mtemp.getReturnType())>
			<cfset ArrayAppend(local.result, local.st)>
		</cfloop>

		<cfreturn _as2q(local.result)>
	</cffunction>

	<cffunction name="_dumpJavaMethods" access="public" output="false" returntype="query" hint="dump java class">
		<cfargument name="obj" type="any">
		<cfreturn _dumpMethods( arguments.obj.getClass().getMethods() )>
	</cffunction>

	<cffunction name="_getAllMethods" output="false" access="public" hint="gets all methods including extended methods from given cfc's metadata">
		<cfargument name="meta"   type="any" required="true">
		<cfargument name="result" type="array" required="false" default="#ArrayNew(1)#">

		<cfset var local    = StructNew()>
		<cfset local.meta   = arguments.meta>
		<cfset local.result = arguments.result>

		<cfif StructKeyExists(local.meta, "extends") AND StructKeyExists(local.meta, "functions")>
			<cfset local.stf = StructNew()>
			<cfset local.stf.extends   = local.meta.extends.name>
			<cfset local.stf.name      = local.meta.name>
			<cfset local.stf.functions = _as2q(_getMethodsArray(local.meta.functions))>
			<cfif StructKeyExists(local.meta, "hint")>
				<cfset local.stf.hint =  local.meta.hint>
			<cfelse>
				<cfset local.stf.hint =  "">
			</cfif>
			<cfif StructKeyExists(local.meta, "output")>
				<cfset local.stf.output =  local.meta.output>
			<cfelse>
				<cfset local.stf.output =  true>
			</cfif>
			<cfset ArrayAppend(local.result, local.stf)>
			<cfreturn _getAllMethods(local.meta.extends, local.result)>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_getMethodList" output="false" access="public" hint="gets all methods as an array">
		<cfargument name="cfc" type="any" required="true">
		<cfset var local = StructNew() />
		<cfset local.m =  _getMethods(arguments.cfc)>
		<cfreturn ValueList(local.m.name ) />
	</cffunction>

	<cffunction name="_getMethodsArray" output="false" access="public" hint="gets all methods as an array">
		<cfargument name="functions" type="array" required="true">

		<cfset var local = StructNew()>
		<cfset local.fns  = arguments.functions>
		<cfset local.result = ArrayNew(1)>

		<cfloop from="1" to="#ArrayLen(local.fns)#" index="local.i">
			<cfset local.fn = local.fns[local.i]>
			<cfset local.stf = StructNew()>
			<cfset local.stf.name = local.fn.name>
			<cfset local.stf.parameters = _getMethodArgs(local.fn.parameters)>
			<cfif StructKeyExists(local.fn, "returntype")>
				<cfset local.stf.returntype = local.fn.returntype>
			<cfelse>
				<cfset local.stf.returntype = "any">
			</cfif>
			<cfif StructKeyExists(local.fn, "access")>
				<cfset local.stf.access =  local.fn.access>
			<cfelse>
				<cfset local.stf.access =  "public">
			</cfif>
			<cfif StructKeyExists(local.fn, "hint")>
				<cfset local.stf.hint =  local.fn.hint>
			<cfelse>
				<cfset local.stf.hint =  "">
			</cfif>
			<cfif StructKeyExists(local.fn, "output")>
				<cfset local.stf.output =  local.fn.output>
			<cfelse>
				<cfset local.stf.output =  "true">
			</cfif>
			<cfset ArrayAppend(local.result, local.stf)>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_getMethodArgs" output="false" access="public" hint="gets the argument parameters for method">
		<cfargument name="args" type="array">

		<cfset var local = StructNew()>
		<cfset local.result = ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(arguments.args)#" index="local.i">
			<cfset local.param = arguments.args[local.i]>
			<cfset local.parout = StructCreate(
				   name = local.param.name
				 , required = false
				 , type = "any"
				 , default = ""
				 , hint = ""
			)>
			<cfset StructAppend(local.parout, local.param, true)>
			<cfset ArrayAppend(local.result, local.parout)>
		</cfloop>
		<cfreturn _as2q(local.result)>
	</cffunction>

	<cffunction name="__getattr" access="private" output="false" returntype="struct" hint="get the items in variablescope wirth methods excluded">
		<cfargument name="vars"  type="any" required="true" default="#variables#" />
		<cfset var local = StructCreate(out = StructCreate(), iter = iterator(arguments.vars))>

		<cfloop condition="#local.iter.whileHasNext()#">
			<cfif NOT _isMethod(local.iter.getCurrent()) AND local.iter.getKey() NEQ "this">
				<cfset StructInsert(local.out, local.iter.getKey(), local.iter.getCurrent(), true)>
			</cfif>
		</cfloop>

		<cfreturn local.out>
	</cffunction>
</cfcomponent>