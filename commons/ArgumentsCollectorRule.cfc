<cfcomponent name="ArgumentsCollectorRule" extends="AbstractArgumentsCollector">
	<cffunction name="init" output="No" returntype="any">
		<cfargument name="collector" type="any" required="true" />
		<cfargument name="keylist"   type="string" required="false" default="" />
		<cfargument name="typelist"  type="string" required="false" default="" />
			<cfset _setCollector(arguments.collector) />
			<cfset parseRule(arguments.keylist, arguments.typelist)>
		<cfreturn this />
	</cffunction>

	<cffunction name="parseRule" output="yes" returntype="any">
		<cfargument name="keylist"   type="string" required="false" default="" />
		<cfargument name="typelist"  type="string" required="false" default="" />
			<cfset _setValidRule(false)>
			<cfset _setRule(arguments.keylist, arguments.typelist)>
		<cfreturn _parseRule()>
	</cffunction>

	<cffunction name="isValidRule" output="No" returntype="boolean">
		<cfif NOT StructKeyExists( variables, "validRule")>
			<cfset _setValidRule(false)>
		</cfif>
		<cfreturn variables.validRule />
	</cffunction>

	<cffunction name="getInKeyList" output="false" access="public" returntype="string">
		<cfif NOT StructKeyExists( variables, "inKeyList")>
			<cfset _setInKeyList("") />
		</cfif>
		<cfreturn variables.inKeyList />
	</cffunction>

	<cffunction name="getInTypeList" output="false" access="public" returntype="string">
		<cfif NOT StructKeyExists( variables, "inTypeList")>
			<cfset _setInTypeList("") />
		</cfif>
		<cfreturn variables.inTypeList />
	</cffunction>

	<cffunction name="_setRule" output="false" access="private" returntype="any">
		<cfargument name="keylist" type="any" required="false" default="" />
		<cfargument name="typelist" type="any" required="false" default="" />

		<cfif arguments.keylist neq "" AND ListLen(arguments.keylist) eq ListLen(arguments.typelist)>
			<cfset _setInKeyList(arguments.keylist) />
			<cfset _setInTypeList(arguments.typelist) />
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="_parseRule" output="yes" returntype="any">
		<cfset var lcl = StructCreate(
			  inkeys  = iterator( ListToArray( LCASE( getInKeyList() ) ) )
			, argkeys = ListToArray( LCASE( getOriginalKeys() ) )
			, typearr = ListToArray( LCASE( getInTypeList() ) )
			, outargs = StructCreate()
		)>

		<cfset lcl.noError = false>
		<cfloop condition="#lcl.inkeys.whileHasNext()#">
			<cfset lcl.noError = false>
			<cfset lcl.curr = lcl.inkeys.getCurrent()>
			<cfset lcl.idx  = lcl.inkeys.getIndex()>
			<cfif hasKey(lcl.curr) OR hasKey(lcl.idx)>
				<cfif hasKey(lcl.curr)>
					<cfset lcl.value = getKeyValue( lcl.curr )>
					<cfset lcl.argkeys.remove( lcl.curr )>
				<cfelseif hasKey(lcl.idx)>
					<cfset lcl.value = getKeyValue( lcl.idx )>
					<cfset lcl.argkeys.remove( JavaCast("string", lcl.idx) )>
				</cfif>
				<cfif StructKeyExists(local, "value")
				AND (getDataType(lcl.value) eq lcl.typearr[lcl.idx]
						OR lcl.typearr[lcl.idx] eq 'any'
					)>
					<cfset StructInsert(lcl.outargs, lcl.curr, lcl.value) />
					<cfset lcl.noError = true>
				</cfif>
			</cfif>
			<cfif NOT lcl.noError>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfset _setValidRule(lcl.noError)>
		<cfif isValidRule()>
			<cfset _setXtraArgList(lcl.argkeys)>
			<cfset StructAppend(lcl.outargs, getXtraArgs())>
			<cfset _setNewArgStruct( lcl.outargs )>
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="_setInKeyList" output="false" access="private" returntype="any">
		<cfargument name="inKeyList" type="string" required="false" default="" />
			<cfset variables.inKeyList = arguments.inKeyList />
			<cfset this.inKeyList = arguments.inKeyList />
		<cfreturn this />
	</cffunction>

	<cffunction name="_setInTypeList" output="false" access="private" returntype="any">
		<cfargument name="inTypeList" type="string" required="false" default="" />
			<cfset variables.inTypeList = arguments.inTypeList />
			<cfset this.inTypeList = arguments.inTypeList />
		<cfreturn this />
	</cffunction>

	<cffunction name="_setValidRule" output="false" access="private" returntype="any">
		<cfargument name="flag" type="boolean" required="false" default="false" />
			<cfset variables.validRule = arguments.flag />
		<cfreturn this />
	</cffunction>
</cfcomponent>
