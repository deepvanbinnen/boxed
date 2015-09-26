<cfcomponent output="false" extends="cfc.commons.AbstractIterator" hint="Observes an iterator and provides a method ">
	<cffunction name="init" hint="gets the state of the iterator">
		<cfargument name="iterator" type="any" required="true">
			<cfset setIter( arguments.iterator )>
			<cfset setState()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getState" hint="gets the state of the iterator">
		<cfif NOT StructKeyExists(variables, "state")>
			<cfthrow message="No state available">
		</cfif>
		<cfreturn variables.state>
	</cffunction>
	
	<cffunction name="hasState" hint="checks given state against the state of the iterator">
		<cfargument name="state" type="string" required="false" default="start">
		<cfreturn getState() eq arguments.state>
	</cffunction>
	
	<cffunction name="iterates" hint="Checks and sets state and if applicable executes iteration">
		<cfif hasState("stop")>
			<cfset getIter().reset()>
		</cfif>
		
		<cfif getIter().hasNext()>
			<cfset setState("run")>
			<cfset getIter().next()>
			<cfreturn true>
		</cfif>
		
		<cfset setState("stop")>
		<cfreturn false>
	</cffunction>
	
	<cffunction name="setState" hint="describes the state of the iterator">
		<cfargument name="state" type="string" required="false" default="start">
			<cfset variables.state = arguments.state>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>