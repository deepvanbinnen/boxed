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

		<cfset var lcl = StructNew()>
		<cfset lcl.cfc  = arguments.cfc>
		<cfset lcl.result = false>

		<cfif _isCFC(lcl.cfc)>
			<cfset lcl.fns = getMetaData(lcl.cfc).functions>
			<cfloop from="1" to="#ArrayLen(lcl.fns)#" index="lcl.i">
				<cfset lcl.fn = lcl.fns[lcl.i]>
				<cfif lcl.fn.name eq arguments.func>
					<cfset lcl.result = _getMethodArgs(lcl.fn.parameters)>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn lcl.result>
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

		<cfset var lcl = StructNew()>
		<cfset lcl.DELIMITERS = "10,13,32,44,124,43"><!--- CR,SPACE,COMMA,PIPELINE,PLUS, --->
		<cfset lcl.instring = TRIM(arguments.instring)>

		<cfif lcl.instring neq "">
			<cfloop from="1" to="#Len(arguments.instring)#" index="lcl.i">
				<cfset lcl.value = ASC(MID(arguments.instring,lcl.i,1))>
				<cfif ListFind(lcl.DELIMITERS, lcl.value)>
					<cfreturn CHR(lcl.value)>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn "">
	</cffunction>

	<cffunction name="_getMethods" access="public" hint="gets all methods from given cfc without recursion">
		<cfargument name="cfc" type="any" required="true">

		<cfset var lcl = StructNew()>
		<cfset lcl.cfc  = arguments.cfc>
		<cfset lcl.result = ArrayNew(1)>

		<cfif IsSimpleValue(lcl.cfc)>
			<cftry>
				<cfset lcl.cfc = ObjectCreate(lcl.cfc) />
				<cfcatch type="any">
					<cfreturn QueryCreate(error="true", message=cfcatch.message, object=cfcatch) />
				</cfcatch>
			</cftry>
		</cfif>

		<cfif _isCFC(lcl.cfc)>
			<cfset lcl.result = _as2q(_getMethodsArray(getMetaData(lcl.cfc).functions))>
		<cfelse>
			<cfset lcl.result = _dumpJavaMethods(lcl.cfc)>
		</cfif>
		<cfreturn lcl.result />
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

		<cfset var lcl = StructNew()>
		<cfset lcl.result = ArrayNew(1)>
		<cftry>
			<cfloop from="1" to="#ArrayLen(arguments.targetArr)#" index="lcl.i">
				<cfset ArrayAppend(lcl.result, _getReflectedName(arguments.targetArr[lcl.i]))>
			</cfloop>
			<cfcatch type="any">
				<cfreturn "">
			</cfcatch>
		</cftry>

		<cfif arguments.asList>
			<cfreturn ArrayToList(lcl.result)>
		<cfelse>
			<cfreturn lcl.result>
		</cfif>
	</cffunction>

	<cffunction name="_dumpMethods" access="public" output="false" returntype="query" hint="dump java class">
		<cfargument name="meth" type="any">

		<cfset var lcl = StructNew()>

		<cfset lcl.result = ArrayNew(1)>

		<cfset lcl.m = arguments.meth>
		<cfloop from="1" to="#ArrayLen(lcl.m)#" index="lcl.i">
			<cfset lcl.mtemp = lcl.m[lcl.i]>
			<cfset lcl.st = StructNew()>
			<cfset lcl.st.name = _getReflectedName(lcl.mtemp)>
			<cfset lcl.st.args = _getReflectedNames(lcl.mtemp.getParameterTypes(), true)>
			<cfset lcl.st.retv = _getReflectedName(lcl.mtemp.getReturnType())>
			<cfset ArrayAppend(lcl.result, lcl.st)>
		</cfloop>

		<cfreturn _as2q(lcl.result)>
	</cffunction>

	<cffunction name="_dumpJavaMethods" access="public" output="false" returntype="query" hint="dump java class">
		<cfargument name="obj" type="any">
		<cfreturn _dumpMethods( arguments.obj.getClass().getMethods() )>
	</cffunction>

	<cffunction name="_getAllMethods" output="false" access="public" hint="gets all methods including extended methods from given cfc's metadata">
		<cfargument name="meta"   type="any" required="true">
		<cfargument name="result" type="array" required="false" default="#ArrayNew(1)#">

		<cfset var local    = StructNew()>
		<cfset lcl.meta   = arguments.meta>
		<cfset lcl.result = arguments.result>

		<cfif StructKeyExists(lcl.meta, "extends") AND StructKeyExists(lcl.meta, "functions")>
			<cfset lcl.stf = StructNew()>
			<cfset lcl.stf.extends   = lcl.meta.extends.name>
			<cfset lcl.stf.name      = lcl.meta.name>
			<cfset lcl.stf.functions = _as2q(_getMethodsArray(lcl.meta.functions))>
			<cfif StructKeyExists(lcl.meta, "hint")>
				<cfset lcl.stf.hint =  lcl.meta.hint>
			<cfelse>
				<cfset lcl.stf.hint =  "">
			</cfif>
			<cfif StructKeyExists(lcl.meta, "output")>
				<cfset lcl.stf.output =  lcl.meta.output>
			<cfelse>
				<cfset lcl.stf.output =  true>
			</cfif>
			<cfset ArrayAppend(lcl.result, lcl.stf)>
			<cfreturn _getAllMethods(lcl.meta.extends, lcl.result)>
		</cfif>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="_getMethodList" output="false" access="public" hint="gets all methods as an array">
		<cfargument name="cfc" type="any" required="true">
		<cfset var lcl = StructNew() />
		<cfset lcl.m =  _getMethods(arguments.cfc)>
		<cfreturn ValueList(lcl.m.name ) />
	</cffunction>

	<cffunction name="_getMethodsArray" output="false" access="public" hint="gets all methods as an array">
		<cfargument name="functions" type="array" required="true">

		<cfset var lcl = StructNew()>
		<cfset lcl.fns  = arguments.functions>
		<cfset lcl.result = ArrayNew(1)>

		<cfloop from="1" to="#ArrayLen(lcl.fns)#" index="lcl.i">
			<cfset lcl.fn = lcl.fns[lcl.i]>
			<cfset lcl.stf = StructNew()>
			<cfset lcl.stf.name = lcl.fn.name>
			<cfset lcl.stf.parameters = _getMethodArgs(lcl.fn.parameters)>
			<cfif StructKeyExists(lcl.fn, "returntype")>
				<cfset lcl.stf.returntype = lcl.fn.returntype>
			<cfelse>
				<cfset lcl.stf.returntype = "any">
			</cfif>
			<cfif StructKeyExists(lcl.fn, "access")>
				<cfset lcl.stf.access =  lcl.fn.access>
			<cfelse>
				<cfset lcl.stf.access =  "public">
			</cfif>
			<cfif StructKeyExists(lcl.fn, "hint")>
				<cfset lcl.stf.hint =  lcl.fn.hint>
			<cfelse>
				<cfset lcl.stf.hint =  "">
			</cfif>
			<cfif StructKeyExists(lcl.fn, "output")>
				<cfset lcl.stf.output =  lcl.fn.output>
			<cfelse>
				<cfset lcl.stf.output =  "true">
			</cfif>
			<cfset ArrayAppend(lcl.result, lcl.stf)>
		</cfloop>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="_getMethodArgs" output="false" access="public" hint="gets the argument parameters for method">
		<cfargument name="args" type="array">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(arguments.args)#" index="lcl.i">
			<cfset lcl.param = arguments.args[lcl.i]>
			<cfset lcl.parout = StructCreate(
				   name = lcl.param.name
				 , required = false
				 , type = "any"
				 , default = ""
				 , hint = ""
			)>
			<cfset StructAppend(lcl.parout, lcl.param, true)>
			<cfset ArrayAppend(lcl.result, lcl.parout)>
		</cfloop>
		<cfreturn _as2q(lcl.result)>
	</cffunction>

	<cffunction name="__getattr" access="private" output="false" returntype="struct" hint="get the items in variablescope wirth methods excluded">
		<cfargument name="vars"  type="any" required="true" default="#variables#" />
		<cfset var lcl = StructCreate(out = StructCreate(), iter = iterator(arguments.vars))>

		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfif NOT _isMethod(lcl.iter.getCurrent()) AND lcl.iter.getKey() NEQ "this">
				<cfset StructInsert(lcl.out, lcl.iter.getKey(), lcl.iter.getCurrent(), true)>
			</cfif>
		</cfloop>

		<cfreturn lcl.out>
	</cffunction>
</cfcomponent>