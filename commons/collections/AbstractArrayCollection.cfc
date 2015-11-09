<cfcomponent output="false" extends="Collection" hint="Abstract collection implementation for arrays">
	<cffunction name="_add" output="false" hint="add data to array">
		<cfargument name="data" type="any" required="true">
			<cfset ArrayAppend( getData(), arguments.data ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="_addAll" output="false" hint="concatenate arrays">
		<cfargument name="data" type="array" required="true">

		<cfset var lcl = StructNew() />
		<cfset lcl.l = ArrayLen(arguments.data) />
		<cfloop from="1" to="#lcl.l#" index="lcl.i">
			<cfset ArrayAppend( getData(), arguments.data[lcl.i] ) />
		</cfloop>
		<cfreturn this />
	</cffunction>

	<cffunction name="_createPointer" returntype="any">
		<cfreturn ObjectCreate("cfc.commons.collections.ArrayPointer").init( this )>
	</cffunction>

	<cffunction name="_createIterator" output="false" hint="create the iterator for this collection">
		<cfreturn ObjectCreate("cfc.commons.collections.ArrayIterator").init( createPointer() )>
	</cffunction>

	<cffunction name="_get" output="false">
		<cfargument name="index" type="numeric" required="true">
		<cfset var lcl = StructNew() />
		<cftry>
			<cfset lcl.arr = getData() />
			<cfreturn lcl.arr[arguments.index] />
			<cfcatch type="any">
				<cfthrow message="Index out of range: #arguments.index#.">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="_hasIndex" output="false" returntype="boolean" hint="verify if index is valid, this does not check if value at index might be null!">
		<cfargument name="index" type="numeric" required="true" />
		<cfreturn arguments.index GT 0 AND arguments.index LTE ArrayLen( getData() )>
	</cffunction>

	<cffunction name="_indexOf" output="false" hint="finds the index for a value, this is a JAVA hack!">
		<cfargument name="value" type="any" required="true" />
		<cfreturn getData().indexOf(arguments.value)>
	</cffunction>

	<cffunction name="_isEmpty" output="false" hint="check emptyness data">
		<cfreturn ArrayLen( getData() ) EQ 0 />
	</cffunction>

	<cffunction name="_iterator" output="false" hint="return an iterator">
		<!--- Needs to be implemented --->
	</cffunction>

	<cffunction name="_lastIndexOf" output="false" hint="finds the last index of an element, this is a JAVA hack!">
		<cfargument name="value" type="any" required="true" />
		<cfreturn getData().lastIndexOf(arguments.value)>
	</cffunction>

	<cffunction name="_remove" output="false" hint="Removes by value. This is a JAVA hack!">
		<cfargument name="data" type="any" required="true" />
			<cfset getData().remove( arguments.data )>
		<cfreturn this>
	</cffunction>

	<cffunction name="_removeAll" output="false" hint="Removes all by value. This is a JAVA hack!">
		<cfargument name="data" type="array" required="true" />
			<cfset getData().removeAll( arguments.data )>
		<cfreturn this>
	</cffunction>

	<cffunction name="_removeElementAt" output="false" hint="Removes by index.">
		<cfargument name="index" type="numeric" required="true" />
			<cfset ArrayDeleteAt(getData(), arguments.index) />
		<cfreturn this>
	</cffunction>

	<cffunction name="_removeElementsAt" output="true" hint="Removes by list of indices.">
		<cfargument name="indexlist" type="string" required="true" hint="list of indexes to remove" />
		<cfargument name="delimiter" type="string" required="false" default="," />

		<cfset var lcl = StructNew()>
		<!---
			Since the remove operation modifies the array
			this might cause the index to be another element
			than the expected one.

			To prevent issues with this behaviour start removal
			by index from the end of the array so that the index item
			to remove is actually the one you did mean to remove.

			Example:
			orgArr = ['a','b','c','d','e','f'] // the original array
			removeIndexes = (3,5) // indexes to remove
			destArr = ['a','b','d','f'] // the destination array (what the result should be)

			just processing the list causes:
			1) orgArr with index 3 removed is: ['a','b','d','e','f']
			2) orgArr with index 5 removed is: ['a','b','d','e']
			3) thus destArr=['a','b','d','e'] is wrong!

			after resorting the list descending, processing causes:
			1) orgArr with highest index 5 removed is: ['a','b','c','d','f']
			2) orgArr with next highest index 3 removed is: ['a','b','d','f']
			3) thus destArr=['a','b','d','f'] is correct!

		--->
		<cfset lcl.list = ListSort(arguments.indexlist, "numeric", "desc", arguments.delimiter)>
		<cfloop list="#lcl.list#" index="lcl.index">
			<cfif IsNumeric(lcl.index) AND lcl.index GT 0 AND lcl.index LTE ArrayLen( getData() )>
				<cfset ArrayDeleteAt( getData(), lcl.index )>
			</cfif>
		</cfloop>

		<cfreturn this>
	</cffunction>

	<cffunction name="_retainAll" output="false" hint="this is a JAVA hack!">
		<cfargument name="data" type="array" required="true" />
		<cfreturn getData().retainAll(arguments.data)>
	</cffunction>

	<cffunction name="_retainElementsAt" output="false" hint="this is a JAVA hack!">
		<cfargument name="indexlist" type="string" required="true" />
		<cfargument name="delimiter" type="string" required="false" default="," />

		<cfset var lcl = StructNew()>
		<cfset lcl.arr = getData() />
		<cfset lcl.retain = ArrayNew(1) />
		<cfloop list="#lcl.indexlist#" index="lcl.index" delimiters="#arguments.delimiter#">
			<cfif IsNumeric(lcl.index) AND lcl.index GT 0 AND lcl.index LTE ArrayLen( getData() )>
				<cfset ArrayAppend(lcl.retain, lcl.arr[lcl.index] ) />
			</cfif>
		</cfloop>
		<cfset getData().retainAll(lcl.retain) />
		<cfreturn this>
	</cffunction>

	<cffunction name="_set" output="false" hint="sets an element at given index. this is a JAVA hack!">
		<cfargument name="index" type="numeric" required="true" />
		<cfargument name="value" type="any" required="true" />

		<cfreturn getData().setElementAt(arguments.value, arguments.index-1)>
	</cffunction>

	<cffunction name="_size" output="false" returntype="numeric" hint="returns the size">
		<cfreturn ArrayLen(getData()) />
	</cffunction>

	<cffunction name="_slice" output="false" returntype="any" hint="slices the data the array and  is a JAVA hack!">
		<cfargument name="start" type="numeric" required="true" />
		<cfargument name="end" type="numeric" required="true" />

		<cfreturn getData().subList(arguments.start-1, arguments.end)>
	</cffunction><!--- --->
</cfcomponent>