<cfcomponent output="false" hint="Reflection CFC for Java Stack Object">
	<!--- Based on: http://java.sun.com/j2se/1.4.2/docs/api/java/util/Stack.html --->
	<cffunction name="init" access="public" returntype="Stack" hint="initialises java stack">
		<cfset variables.stack = createObject("java", "java.util.Stack").init() />
		<cfreturn this />
	</cffunction>

	<cffunction name="_getStack" access="private" returntype="any" hint="gets the java object">
		<cfreturn variables.stack />
	</cffunction>

	<cffunction name="push" access="public" returntype="any" hint="Pushes an item onto the top of this stack and returns the item pushed">
		<cfargument name="item" type="any" required="true" hint="the item to be pushed onto this stack" />
		<cfreturn _getStack().push(arguments.item) />
	</cffunction>

	<cffunction name="pop" access="public" returntype="any" hint="Removes the object at the top of this stack and returns that object as the value of this function.">
		<cfreturn _getStack().pop() />
	</cffunction>

	<cffunction name="peek" access="public" returntype="any" hint="Looks at the object at the top of this stack without removing it from the stack. ">
		<cfreturn _getStack().peek() />
	</cffunction>

	<cffunction name="empty" access="public" returntype="boolean" hint="Tests if this stack is empty. ">
		<cfreturn _getStack().empty() />
	</cffunction>

	<cffunction name="search" access="public" returntype="any" hint="Returns the 1-based position where an object is on this stack. The return value -1  indicates that the object is not on the stack.">
		<cfargument name="o" type="any" required="true" hint="the desired object" />
		<cfreturn _getStack().search(arguments.o) />
	</cffunction>
</cfcomponent>