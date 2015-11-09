<cfcomponent name="AbstractArgumentsCollector" extends="AbstractObject">
	<cffunction name="getCollector" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists( variables, "collector")>
			<cfthrow message="collector is undefined in AbstractArgumentsCollector" />
		</cfif>
		<cfreturn variables.collector />
	</cffunction>

	<cffunction name="getArguments" output="false" access="public" returntype="struct">
		<cfif NOT StructKeyExists( variables, "newArgStruct")>
			<cfset _setNewArgstruct( getOriginal() )>
		</cfif>
		<cfreturn variables.newArgStruct />
	</cffunction>

	<cffunction name="getByIndex" output="false" access="public" returntype="any">
		<cfargument name="index" required="true" type="numeric" default="1">
		<cfreturn getOriginal().get(arguments.index)>
	</cffunction>

	<cffunction name="getOriginal" output="false" access="public" returntype="any">
		<cfreturn getCollector().getOriginal()>
	</cffunction>

	<cffunction name="getOriginalCount" output="false" access="public" returntype="numeric">
		<cfreturn ArrayLen( getOriginal() ) />
	</cffunction>

	<cffunction name="getOriginalKeys" output="false" access="public" returntype="string">
		<cfreturn StructKeyList( getOriginal() ) />
	</cffunction>

	<cffunction name="getKeyValue" output="true" access="public" returntype="any">
		<cfargument name="key" type="any" required="true">
		<cfargument name="ret" type="any" required="false" default="" hint="value to return if key does not exist">

		<cfset var lcl = StructNew()>
		<cfif hasKey( arguments.key )>
			<cftry>
				<!--- NOTE: Must cast because of possible datatype discrepancy --->
				<cfreturn getOriginal().get(JavaCast('string', arguments.key)) />
				<cfcatch type="any">
					<!--- silently supress error --->
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn arguments.ret />
	</cffunction>

	<cffunction name="getRule" output="false" access="public" returntype="any">
		<cfif NOT hasRule()>
			<cfreturn getRuleObj()>
		</cfif>
		<cfreturn variables.rule />
	</cffunction>

	<cffunction name="getRuleObj" output="false" access="public" returntype="any">
		<cfreturn getCollector().getRuleObj() />
	</cffunction>

	<cffunction name="getXtraArgList" output="false" access="private" returntype="any">
		<cfif NOT StructKeyExists( variables, "XtraArgList")>
			<cfset _setXtraArgList("")>
		</cfif>
		<cfreturn variables.XtraArgList />
	</cffunction>

	<cffunction name="getXtraArgs" output="true" access="private" returntype="any">
		<cfset var lcl = StructCreate( iter = iterator( getXtraArgList() ), result = StructCreate() )>
		<cfloop condition="#lcl.iter.whileHasNext()#">
			<cfif hasKey( lcl.iter.getCurrent() )>
				<cfset StructInsert(lcl.result, "UNNAMEDARG_#lcl.iter.getCurrent()#", getKeyValue( lcl.iter.getCurrent() ))>
			</cfif>
		</cfloop>
		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="isNamed" output="false" access="public" returntype="any">
		<cfreturn hasArguments() AND NOT IsNumeric( ListFirst( getOriginalKeys() ) )>
	</cffunction>

	<cffunction name="hasArguments" output="false" access="public" returntype="boolean">
		<cfreturn getOriginalCount() neq 0 />
	</cffunction>

	<cffunction name="hasKey" output="false" access="public" returntype="boolean">
		<cfargument name="key" type="string" required="true">
		<cfreturn StructKeyExists( getOriginal(), arguments.key ) />
	</cffunction>

	<cffunction name="hasRule" output="No" returntype="boolean">
		<cfreturn StructKeyExists( variables, "rule") />
	</cffunction>

	<cffunction name="hasValidRule" output="No" returntype="boolean">
		<cfreturn getRule().isValidRule() />
	</cffunction>

	<cffunction name="removeRule" output="false" access="public">
		<cfif hasRule()>
			<cfset StructDelete( variables, "rule")>
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="setRule" output="false" access="public">
		<cfargument name="rule" type="any" required="true" />
			<cfset variables.rule = arguments.rule />
		<cfreturn this />
	</cffunction>

	<cffunction name="_setXtraArgList" output="false" access="private">
		<cfargument name="XtraArgList" type="any" required="false" default="" />
			<cfset variables.XtraArgList = arguments.XtraArgList />
		<cfreturn this />
	</cffunction>

	<cffunction name="_setOriginalKeys" output="false" access="private" returntype="any">
		<cfset this.keys = getOriginalKeys()>
		<cfreturn this />
	</cffunction>

	<cffunction name="_setOriginalCount" output="false" access="private" returntype="any">
		<cfset this.count = getOriginalCount()>
		<cfreturn this />
	</cffunction>

	<cffunction name="_setCollector" output="false" access="private" returntype="any">
		<cfargument name="collector" type="any" required="true" />
			<cfset variables.collector = arguments.collector />
		<cfreturn this />
	</cffunction>

	<cffunction name="_setNewArgstruct" output="false" access="private" returntype="any">
		<cfargument name="newArgStruct" type="struct" required="false" default="#StructNew()#" />
			<cfset variables.newArgStruct = arguments.newArgStruct />
			<cfset this.newArgStruct = arguments.newArgStruct />
		<cfreturn this />
	</cffunction>
</cfcomponent>