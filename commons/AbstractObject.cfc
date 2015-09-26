<cfcomponent output="false" extends="Introspect" hint="methods avaialable to all derived objects">
	<cfset variables.uuid  = createUUID() />
	<cfset variables.ctime = getTickCount() />

	<cffunction name="collect" returntype="any" output="true" hint="Create a collectable">
		<cfargument name="data" type="any" required="true" />
		<cfreturn _collectionObj(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="dumplogs" returntype="any" output="true" hint="Adds runtime message to log">
		<cfoutput>#__Dump().dumpData(getLogs())#</cfoutput>
	</cffunction>

	<cffunction name="getDS" output="false" access="public" returntype="string" hint="gets the datasource">
		<cfif NOT StructKeyExists( variables, "ds")>
			<cfthrow message="ds is undefined in scope variables." />
		</cfif>
		<cfreturn variables.ds />
	</cffunction>

	<cffunction name="getInstance" returntype="struct" hint="Returns value for given key or instance struct">
		<cfargument name="key" required="false" type="string" default="" />
		<cfif NOT StructKeyExists(variables,"instance")>
			<cfset variables.instance = StructNew() />
		</cfif>
		<cfif StructKeyExists(variables.instance, arguments.key)>
			<cfreturn variables.instance[arguments.key] />
		<cfelse>
			<cfreturn variables.instance />
		</cfif>
	</cffunction>

	<cffunction name="getLogs" returntype="array" output="false" hint="Getter for logs">
		<cftry>
			<cfreturn variables.logs />
			<cfcatch type="any">
				<cfthrow message="No such variable: logs" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getSnipex" returntype="any" output="false" hint="Getter for snipex">
		<cfif NOT StructKeyExists(variables, "snipex") OR StructKeyExists(arguments, "reset")>
			<cfset variables.snipex = createObject("component","cfc.SnipexConsumer").init() />
		</cfif>
		<cfreturn variables.snipex />
	</cffunction>

	<cffunction name="getUUID" returntype="string" access="public" hint="Getter for UUID">
		<cftry>
			<cfreturn variables.UUID />
			<cfcatch type="any">
				<cfthrow message="No such variable: variables.UUID" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getValueObject" returntype="any" hint="Returns a new value object for given data">
		<cfargument name="data" type="any" required="true">
		<cfreturn _valueObj(arguments.data) />
	</cffunction>

	<cffunction name="ife" output="false" access="public" returntype="any" hint="Returns first argument if defined and not empty, else second argument">
		<cfargument name="arg1" required="false" type="any">
		<cfargument name="arg2" required="false" type="any" default="false">
		<cfargument name="arg3" required="false" type="any">

		<!--- null check --->
		<cfif StructKeyExists(arguments, 'arg1')>
			<!--- iif --->
			<cfif IsBoolean(arguments.arg1)>
				<cfif arguments.arg1 OR (NOT arguments.arg1 AND NOT StructKeyExists(arguments, 'arg3'))>
					<cfreturn arguments.arg2>
				<cfelse>
					<cfif StructKeyExists(arguments, 'arg3')>
						<cfreturn arguments.arg3>
					</cfif>
				</cfif>
			</cfif>
			<!--- empty check --->
			<cfif (IsSimpleValue(arguments.arg1) AND TRIM(arguments.arg1) eq "")
				OR (IsStruct(arguments.arg1) AND StructIsEmpty(arguments.arg1))
				OR (IsArray(arguments.arg1) AND ArrayIsEmpty(arguments.arg1))>
				<cfreturn arguments.arg2>
			</cfif>
			<!--- return self --->
			<cfreturn arguments.arg1>
		<cfelse>
			<cfif StructKeyExists(arguments, 'arg3') >
				<cfreturn arguments.arg3>
			</cfif>
		</cfif>
		<!--- or just the default --->
		<cfreturn arguments.arg2>
	</cffunction>

	<cffunction name="rtlog" returntype="any" output="false" hint="Adds runtime message to log">
		<cfargument name="message" required="true"  type="string" hint="message : message to log">
		<cfargument name="data" required="false"  type="any" hint="data : any extra data">

		<cfif NOT StructKeyExists(variables, "logs")>
			<cfset variables.logs = ArrayNew(1) />
		</cfif>
		<cfset ArrayAppend(variables.logs, arguments) />
		<cfreturn this />
	</cffunction>

	<cffunction name="resetrtlog" returntype="any" output="false" hint="Resets runtime message-log">
		<cfset variables.logs = ArrayNew(1) />
	</cffunction>

	<cffunction name="setDS" output="false" access="public" returntype="any"  hint="sets the datasource">
		<cfargument name="ds" type="string" required="true" hint="is the name of the CF-datasource" />
			<cfset variables.ds = arguments.ds />
		<cfreturn this />
	</cffunction>

	<cffunction name="setInstance" returntype="any">
		<cfargument name="key" required="true" type="string" />
		<cfargument name="val" required="true" type="any" />

		<cfif StructKeyExists(getInstance(), arguments.key)>
			<cfset StructUpdate(getInstance(), arguments.key, arguments.val) />
		<cfelse>
			<cfset StructInsert(getInstance(), arguments.key, arguments.val) />
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="timesnap" output="true" hint="outputs num millisecs since last timesnap and since object creation time">
		<cfargument name="msg" required="false">
		<cfif NOT StructKeyExists(variables, "last_snap_time")>
			<cfset variables.last_snap_time = getTickCount()>
		</cfif>

		<cfoutput>
			<div class="timesnap">
				<div>
					<span class="creation-snap-time">#getTickCount()-variables.ctime#ms</span>
					<span class="seperator">&##xA0;</span>
					<span class="last-snap-time">#getTickCount()-variables.last_snap_time#ms</span>
				</div>
				<cfif StructKeyExists(arguments, "msg")>
					<div class="timesnap-message">#_dump(msg)#</div>
				</cfif>
				<hr />
			</div>
		</cfoutput>
	</cffunction>

	<cffunction name="utils" returntype="any" output="false" hint="Gets the utils cfc">
		<cfreturn __Utils() />
	</cffunction>

	<!--- PRIVATE METHODS --->
	<cffunction name="_args" access="public" output="false" returntype="struct" hint="Returns an explicit struct from argument">
		<cfif ArrayLen(arguments) AND StructKeyExists(arguments, "1") AND _isArgumentCollection(arguments[1])>
			<cfreturn __args(argumentCollection = arguments[1])>
		</cfif>
		<cfreturn __args(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="_call" access="public" returntype="any" hint="proxymethod which executes a methodcall for a given component with given arguments">
		<cfargument name="targetCFC"   type="any" required="true">
		<cfargument name="proxyMethod" type="any" required="true">
		<cfargument name="proxyArguments" type="struct" required="false" default="#StructNew()#">

		<cfset var local = StructNew()>
		<cfset local.result = StructNew()>
		<cfset local.result.errors = false>
		<cfset local.result.args   = arguments>

		<cftry>
			<cfinvoke component="#arguments.targetCFC#" method="#arguments.proxyMethod#" argumentcollection="#arguments.proxyArguments#" returnvariable="local.result.data"></cfinvoke>
			<cfcatch type="any">
				<cfset local.result.errors = true>
				<cfset local.result.data   = cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_collectionObj" output="false" returntype="any" hint="creates a generic collection object for given data">
		<cfargument name="data" type="any" required="true">
		<cfreturn __CollectionFactory().createCollectable(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="_doc" access="public" output="false">
		<cfargument name="cfc" required="true" type="any" default="#this#">
		<cfreturn __getUtils()._getDoc(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="_dump" access="public" output="false">
		<cfargument name="data"       required="false" type="any" default="#this#">
		<cfargument name="message"    required="false" type="string" default="">
		<cfargument name="dumpmethod" required="false" default="false" type="boolean">
		<cfreturn __Dump().dumpData(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="_isNull" access="public" output="false" returntype="boolean" hint="Returns true if no arguments are given to this method. This method was actually ment to inspect returnsVoid( someMethodCall() )">
		<cfreturn ArrayLen(arguments) eq 0>
	</cffunction>

	<cffunction name="_mapArgs" access="public" output="false" returntype="struct" hint="Returns an explicit struct from argument">
		<cfargument name="orgArgs" type="any" required="true">
		<cfargument name="argList" type="string" required="true">

		<!--- Enables your callee method to pass arguments more easy
		myMethod(){
			passedArgs = _mapArgs( arguments, "foo,bar");
			echo passedArgs;
		}
		myMethod(12,15)        -> {foo : 12, bar : 15}
		myMethod(foo=24,bar=8) -> {foo : 24, bar : 8}
		myMethod(31)           -> {foo : 31}
		myMethod(baz=57)       -> {baz : 57}
		 --->
		<cfset var local = StructCreate(
			  result = StructCreate()
			, iter = iterator( arguments.argList )
			, bnamed = NOT StructKeyExists(arguments.orgArgs, "1")
		)>

		<cfif local.bnamed>
			<cfset StructAppend(local.result, arguments.orgArgs, true )>
		<cfelse>
			<cfloop condition="#local.iter.whileHasNext()#">
				<cfif local.iter.getIndex() LTE ArrayLen(arguments.orgArgs)>
					<cfset StructAppend(local.result, arguments.orgArgs["#local.iter.getIndex()#"], true)>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="_valueObj" access="public" output="false" returntype="any" hint="creates a value object from given data">
		<cfargument name="data" type="any" required="true">
		<cfreturn createObject("component", "ValueObj").init(argumentCollection = arguments)>
	</cffunction>

	<!--- SUPER PRIVATE METHODS --->
	<cffunction name="__args" output="false" hint="Returns all defined arguments as a struct. Keys with undefined values, which are rendered as [undefined element] by CFDUMP, are filtered by this method.">
		<cfset var local = StructCreate(
			  result = StructCreate()
			, it = arguments.entrySet().iterator()
		)>
		<cfloop condition="local.it.hasNext()">
			<cfset local.curr = local.it.next()>
			<cfif local.curr.isdefined()>
				<cfset StructInsert(local.result, local.curr.getKey(), local.curr.getValue())>
			</cfif>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="__CollectionFactory" access="public" output="false">
		<cfif NOT StructKeyExists(variables, "__objCollectionFactory")>
			<cfset variables.__objCollectionFactory =  createObject("component", "collections.CollectionFactory")>
		</cfif>

		<cfreturn variables.__objCollectionFactory>
	</cffunction>

	<cffunction name="__Dump" access="public" output="false">
		<cfif NOT StructKeyExists(variables, "__objDump")>
			<cfset variables.__objDump = createObject("component", "Dump")>
		</cfif>

		<cfreturn variables.__objDump>
	</cffunction>

	<cffunction name="__getUtils" access="public" output="false">
		<cfreturn __Utils( argumentCollection = arguments ) />
	</cffunction>

	<cffunction name="__Utils" access="public" output="false">
		<cfif NOT StructKeyExists(variables, "__objUtils")>
			<cfset variables.__objUtils = createObject("component", "com.googlecode.dbseries.ebx.utils.utils")>
		</cfif>

		<cfreturn variables.__objUtils>
	</cffunction>
</cfcomponent>