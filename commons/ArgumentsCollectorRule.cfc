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
		<cfset var local = StructCreate( 
			  inkeys  = iterator( ListToArray( LCASE( getInKeyList() ) ) )
			, argkeys = ListToArray( LCASE( getOriginalKeys() ) )
			, typearr = ListToArray( LCASE( getInTypeList() ) )
			, outargs = StructCreate()
		)>
		
		<cfset local.noError = false>
		<cfloop condition="#local.inkeys.whileHasNext()#">
			<cfset local.noError = false>
			<cfset local.curr = local.inkeys.getCurrent()>
			<cfset local.idx  = local.inkeys.getIndex()>
			<cfif hasKey(local.curr) OR hasKey(local.idx)>
				<cfif hasKey(local.curr)>
					<cfset local.value = getKeyValue( local.curr )>
					<cfset local.argkeys.remove( local.curr )>
				<cfelseif hasKey(local.idx)>
					<cfset local.value = getKeyValue( local.idx )>
					<cfset local.argkeys.remove( JavaCast("string", local.idx) )>
				</cfif>
				<cfif StructKeyExists(local, "value") 
				AND (getDataType(local.value) eq local.typearr[local.idx]
						OR local.typearr[local.idx] eq 'any'
					)>
					<cfset StructInsert(local.outargs, local.curr, local.value) />
					<cfset local.noError = true>
				</cfif>
			</cfif>
			<cfif NOT local.noError>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfset _setValidRule(local.noError)>
		<cfif isValidRule()>
			<cfset _setXtraArgList(local.argkeys)>
			<cfset StructAppend(local.outargs, getXtraArgs())>
			<cfset _setNewArgStruct( local.outargs )>
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
