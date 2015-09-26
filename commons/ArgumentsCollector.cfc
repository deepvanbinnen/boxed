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
		
		<cfset var local = StructCreate( 
			  newArgsValue  = getKeyValue( arguments.mergedKey, StructCreate() ) 
			, newArgsStruct = StructCreate()
		)>
		<cfset StructAppend(local.newArgsValue, getArguments(), true)>
		<cfset StructInsert(local.newArgsStruct, arguments.mergedKey, getArguments(), true)>
		
		<cfset _setNewArgstruct(local.newArgsStruct)>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="remapSingleNamedArg" output="true" access="public" returntype="any">
		<cfargument name="mapkeyto"  type="string" required="true">
		<cfargument name="mapvalueto"  type="string" required="false" default="">
		
		<cfset var local = StructCreate(keyto = arguments.mapkeyto, valto = arguments.mapvalueto)>
		
		<cfif local.valto neq  "">
			<cfset local.keyto = ListAppend(local.keyto, local.valto)>
		</cfif>
		
		<cfif getOriginalCount() eq 1>
			<cfset local.value   = getOriginal().valuesIterator().next()>
			<cfset local.newArgs = StructCreate()>
			<cfset StructInsert(local.newArgs, ListFirst(local.keyto), local.value.getKey(), true)>
			<cfset StructInsert(local.newArgs, ListLast(local.keyto), local.value.getValue(), true)>
			<cfset _setNewArgstruct(local.newArgs)>
		<cfelse>
			<cfthrow message="remapSingleNamedArg error this argcollection contains #getArgumentsCount()# arguments">
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="remapArgs" output="true" access="public" returntype="any">
		<cfargument name="inlist"  type="string" required="true">
		<cfargument name="outlist" type="string" required="false" default="">
		<cfargument name="strict"  type="boolean" required="false" default="true" hint="Whether to discard other keys in the return struct">
		
		<cfset var local = StructCreate()>
		<cfif arguments.strict>
			<cfset local.newArgs = StructCreate()>
		<cfelse>
			<cfset local.newArgs = getArguments().clone()>
		</cfif>
		
		<cfif arguments.outlist eq "">
			<cfset local.o  = getOriginal().valuesIterator()>
			<cfset local.oi = 0>
			<cfloop condition="#local.o.hasNext()#">
				<cfset local.oi = local.oi + 1>
				<cfif local.oi LTE ListLen(arguments.inlist)>
					<cfset local.ov = local.o.next()>
					<cfset local.inkey  = ListGetAt(arguments.inlist, local.oi)>
					<cfif NOT hasKey( local.inkey )>
						<cfset StructInsert(local.newArgs, local.inkey, local.ov.getValue(), true)>
					<cfelse>
						<cfset StructInsert(local.newArgs, local.inkey, getKeyValue(local.inkey), true)>
					</cfif>
				<cfelse>
					<cfbreak>
				</cfif>
			</cfloop>
		<cfelseif ListLen(arguments.inlist) eq ListLen(arguments.outlist)>
			<cfset local.keys = iterator(arguments.inlist)>
			<cfloop condition="#local.keys.hasNext()#">
				<cfif hasKey(local.keys.getKey())>
					<cfset local.temp = getKeyValue(local.keys.getKey())>
					<cfset StructDelete(local.newArgs, local.keys.getKey())>
					<cfset StructInsert(local.newArgs, ListGetAt(local.outlist, local.keys.getIndex()), local.temp, true)>
				</cfif>
			</cfloop>
		</cfif>
		<cfset _setNewArgstruct(local.newArgs)>
		
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
