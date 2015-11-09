<cfcomponent name="ArgumentsCollector" extends="AbstractArgumentsCollector">
	<cffunction name="init" output="No" returntype="ArgumentsCollector">
		<cfargument name="original" type="any" required="true" />
			<cfset _setOriginal(arguments.original)>
			<cfset _setOriginalKeys()>
			<cfset _setOriginalCount()>
			<cfset _setCollector(this)>
		<cfreturn this />
	</cffunction>

	<cffunction name="parseRule" output="true" access="public" returntype="boolean">
		<cfargument name="keylist" type="string" required="true">
		<cfargument name="typelist" type="string" required="true">

		<cfif getRuleObj().parseRule(arguments.keylist, arguments.typelist).isValidRule()>
			<cfset setRule( getRuleObj() )>
		</cfif>

		<cfreturn hasRule()>
	</cffunction>

	<cffunction name="mergeArgs" output="true" access="public" returntype="any">
		<cfargument name="mergedKey" type="string" required="false" default="argumentCollection">

		<cfset var lcl = StructCreate(
			  newArgsValue  = getKeyValue( arguments.mergedKey, StructCreate() )
			, newArgsStruct = StructCreate()
		)>
		<cfset StructAppend(lcl.newArgsValue, getArguments(), true)>
		<cfset StructInsert(lcl.newArgsStruct, arguments.mergedKey, getArguments(), true)>

		<cfset _setNewArgstruct(lcl.newArgsStruct)>

		<cfreturn this />
	</cffunction>

	<cffunction name="remapSingleNamedArg" output="true" access="public" returntype="any">
		<cfargument name="mapkeyto"  type="string" required="true">
		<cfargument name="mapvalueto"  type="string" required="false" default="">

		<cfset var lcl = StructCreate(keyto = arguments.mapkeyto, valto = arguments.mapvalueto)>

		<cfif lcl.valto neq  "">
			<cfset lcl.keyto = ListAppend(lcl.keyto, lcl.valto)>
		</cfif>

		<cfif getOriginalCount() eq 1>
			<cfset lcl.value   = getOriginal().valuesIterator().next()>
			<cfset lcl.newArgs = StructCreate()>
			<cfset StructInsert(lcl.newArgs, ListFirst(lcl.keyto), lcl.value.getKey(), true)>
			<cfset StructInsert(lcl.newArgs, ListLast(lcl.keyto), lcl.value.getValue(), true)>
			<cfset _setNewArgstruct(lcl.newArgs)>
		<cfelse>
			<cfthrow message="remapSingleNamedArg error this argcollection contains #getArgumentsCount()# arguments">
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="remapArgs" output="true" access="public" returntype="any">
		<cfargument name="inlist"  type="string" required="true">
		<cfargument name="outlist" type="string" required="false" default="">
		<cfargument name="strict"  type="boolean" required="false" default="true" hint="Whether to discard other keys in the return struct">

		<cfset var lcl = StructCreate()>
		<cfif arguments.strict>
			<cfset lcl.newArgs = StructCreate()>
		<cfelse>
			<cfset lcl.newArgs = getArguments().clone()>
		</cfif>

		<cfif arguments.outlist eq "">
			<cfset lcl.o  = getOriginal().valuesIterator()>
			<cfset lcl.oi = 0>
			<cfloop condition="#lcl.o.hasNext()#">
				<cfset lcl.oi = lcl.oi + 1>
				<cfif lcl.oi LTE ListLen(arguments.inlist)>
					<cfset lcl.ov = lcl.o.next()>
					<cfset lcl.inkey  = ListGetAt(arguments.inlist, lcl.oi)>
					<cfif NOT hasKey( lcl.inkey )>
						<cfset StructInsert(lcl.newArgs, lcl.inkey, lcl.ov.getValue(), true)>
					<cfelse>
						<cfset StructInsert(lcl.newArgs, lcl.inkey, getKeyValue(lcl.inkey), true)>
					</cfif>
				<cfelse>
					<cfbreak>
				</cfif>
			</cfloop>
		<cfelseif ListLen(arguments.inlist) eq ListLen(arguments.outlist)>
			<cfset lcl.keys = iterator(arguments.inlist)>
			<cfloop condition="#lcl.keys.hasNext()#">
				<cfif hasKey(lcl.keys.getKey())>
					<cfset lcl.temp = getKeyValue(lcl.keys.getKey())>
					<cfset StructDelete(lcl.newArgs, lcl.keys.getKey())>
					<cfset StructInsert(lcl.newArgs, ListGetAt(lcl.outlist, lcl.keys.getIndex()), lcl.temp, true)>
				</cfif>
			</cfloop>
		</cfif>
		<cfset _setNewArgstruct(lcl.newArgs)>

		<cfreturn this />
	</cffunction>


	<cffunction name="getRuleObj" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists( variables, "ruleObj")>
			<cfset variables.ruleObj = createObject("component", "ArgumentsCollectorRule").init(this)>
		</cfif>
		<cfreturn variables.ruleObj>
	</cffunction>

	<cffunction name="getOriginal" output="false" access="public" returntype="any">
		<cfreturn _getOriginal()>
	</cffunction>

	<cffunction name="_getOriginal" output="false" access="private" returntype="any">
		<cfif NOT StructKeyExists( variables, "original")>
			<cfthrow message="ArgumentsCollector.cfc: Original is undefined, call init to set." />
		</cfif>
		<cfreturn variables.original />
	</cffunction>

	<cffunction name="_setOriginal" output="false" access="private">
		<cfargument name="original" type="any" required="true" />
			<cfset variables.original = arguments.original />
		<cfreturn this />
	</cffunction>
</cfcomponent>
