<!---
Copyright 2009 Bharat Deepak Bhikharie

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->
<!---
Filename: ebxExecutionStack.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->
<cfcomponent hint="I represent the stack of executionContexts for the parser and am used whenever the parser does a request or has finished handling the last request">
	<cfset variables.MAXREQUESTS  = 100>
	<cfset variables.stack        = ArrayNew(1)>
	<cfset variables.executed     = ArrayNew(1)>
	<cfset variables.types        = StructNew()>
	<cfset variables.emptyContext = "">
	<cfset variables.current      = "">

	<cffunction name="init" returntype="ebxExecutionStack" hint="initialise context-stack with empty context">
		<cfargument name="emptyContext" type="ebxContext" required="true" hint="empty context to return if stack doesn't have items left">
			<cfset variables.emptyContext = arguments.emptyContext>
			<cfset setEmptyContext()>
			<cfset setCurrent(getEmptyContext())>
		<cfreturn this>
	</cffunction>

	<cffunction name="add" returntype="boolean" hint="adds context to active-stack, checks for maxreached and return true on succeed">
		<cfargument name="context" type="ebxContext" required="true" hint="context instance">
		<cfif maxReached()>
			<cfreturn false>
		</cfif>
		<cfset ArrayPrepend(variables.stack, arguments.context)>
		<cfset StructInsert(variables.types, arguments.context.getType(), true, true)>
		<cfset setCurrent(arguments.context)>
		<cfreturn true>
	</cffunction>

	<cffunction name="get" returntype="any" hint="return current context or context by index from stack, return empty context if index is invalid">
		<cfargument name="index" type="numeric" required="false" default="0">

		<cfif arguments.index eq 0>
			<cfreturn getCurrent()>
		<cfelse>
			<cfif getLength() GTE arguments.index>
				<cfreturn variables.stack[arguments.index]>
			</cfif>
			<cfreturn getEmptyContext()>
		</cfif>
	</cffunction>

	<cffunction name="getCurrent" returntype="any" hint="return active context">
		<cfreturn variables.current>
	</cffunction>

	<cffunction name="getEmptyContext" returntype="any" hint="return empty context">
		<cfreturn variables.emptyContext>
	</cffunction>

	<cffunction name="getLength" returntype="numeric" hint="number of elements in stack">
		<cfreturn ArrayLen(getStack())>
	</cffunction>

	<cffunction name="getExecutedStack" returntype="array" hint="return array of executed contexts">
		<cfreturn variables.executed>
	</cffunction>

	<cffunction name="getStack" returntype="array" hint="return array of active-contexts">
		<cfreturn variables.stack>
	</cffunction>

	<cffunction name="getTypes" returntype="struct" hint="return 'learned' context types">
		<cfreturn variables.types>
	</cffunction>

	<cffunction name="hasType" returntype="boolean" hint="check if type is known">
		<cfargument name="type" type="string" required="true" hint="type to check">
		<cfreturn StructKeyExists(variables.stack, arguments.type)>
	</cffunction>

	<cffunction name="hasMainRequest" returntype="boolean" hint="check if mainrequest has been added to stack">
		<cfargument name="type" type="string" required="true" hint="type to check">
		<cfreturn hasType("mainrequest")>
	</cffunction>

	<cffunction name="isMainRequest" returntype="boolean" hint="check if active context is main context">
		<cfreturn get().getType() eq "mainrequest">
	</cffunction>

	<cffunction name="maxReached" returntype="boolean" hint="check if max is reached">
		<cfreturn (getLength() GT variables.MAXREQUESTS)>
	</cffunction>

	<cffunction name="remove" returntype="boolean" hint="remove context from active-stack, add it to executed stack and update active-context">
		<cfif getLength()>
			<cfset ArrayAppend(variables.executed, getCurrent())>
			<cfset ArrayDeleteAt(variables.stack,1)>
			<cfset setCurrent(get(1))>
			<cfreturn true>
		</cfif>
		<cfset setEmptyContext()>
		<cfreturn false>
	</cffunction>

	<cffunction name="setCurrent" returntype="any" hint="set active context">
		<cfargument name="context" type="any" required="true" hint="context to 'archive'">
		<cfset variables.current = arguments.context>
		<cfreturn this>
	</cffunction>

	<cffunction name="setEmptyContext" returntype="any" hint="set active context to empty context">
		<cfset setCurrent(getEmptyContext())>
		<cfreturn this>
	</cffunction>

	<cffunction name="_dump" hint="dump component information">
		<h3>Stack</h3>
		<cfloop from="1" to="#Arraylen(variables.stack)#" index="i">
			<cfdump var="#variables.stack[i]._dump()#">
		</cfloop>
		<hr />
		<h3>Executed</h3>
		<cfloop from="1" to="#Arraylen(variables.executed)#" index="i">
			<cfdump var="#variables.executed[i]._dump()#">
		</cfloop>
	</cffunction>
</cfcomponent>