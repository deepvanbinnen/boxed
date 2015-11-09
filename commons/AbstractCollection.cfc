<cfcomponent output="false" extends="AbstractObject" hint="Abstract collection object">
	<cfset variables.collection = "">

	<cffunction name="init">
		<cfif ArrayLen(arguments) GT 0>
			<cfset variables.collection = arguments[1]>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="add" hint="add element to collection">
		<cfargument name="data" type="any" required="true">
		<cfargument name="key"  type="string" required="false" default="">

		<cfset var lcl = StructNew()>
		<cfif IsArray(variables.collection)>
			<cfset ArrayAppend(variables.collection, arguments.data)>
		<cfelseif IsQuery(variables.collection)>
			<cfif IsArray(arguments.data) AND ArrayLen(arguments.data) eq ListLen(variables.collection.columnlist)>
				<cfset _setQueryRow(arguments.data)>
			<cfelseif IsStruct(arguments.data)>
				<cfset _setQueryRow(_structValueArray(arguments.data), structKeyArray(arguments.data))>
			<cfelseif IsSimpleValue(arguments.data)>
				<cfset _setQueryRow(_listAsArray(arguments.data, arguments.key))>
			</cfif>
		<cfelseif IsStruct(variables.collection) AND arguments.key neq "">
			<cfset variables.collection[arguments.key] = arguments.data>
		<cfelseif IsSimpleValue(variables.collection) AND IsSimpleValue(variables.data)>
			<cfif arguments.key eq "">
				<cfset arguments.key = ",">
			<cfelseif IsNumeric(arguments.key)>
				<cfset arguments.key = CHR(arguments.key)>
			</cfif>
			<cfset ListAppend(variables.collection, arguments.data, arguments.key)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="_setQueryRow" hint="set query row">
		<cfargument name="data" type="array" required="true">
		<cfargument name="cols"  type="array" required="false" default="#ListToArray(variables.collection.columnlist)#">
		<cfargument name="row"  type="numeric" required="false" default="0">

		<cfif ArrayLen(arguments.data) EQ ArrayLen(arguments.cols)>
			<cfif arguments.row eq 0>
				<cfset QueryAddRow(variables.collection)>
				<cfset arguments.row = variables.collection.recordcount>
			</cfif>
			<cfif arguments.row LTE variables.collection.recordcount>
				<cfloop from="1" to="#ArrayLen(arguments.data)#" index="lcl.i">
					<cfset QuerySetCell(variables.collection, arguments.cols[lcl.i], arguments.data[lcl.i], arguments.row)>
				</cfloop>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="_listAsArray" hint="row as array">
		<cfargument name="list"      type="string" required="true">
		<cfargument name="delimiter" type="any" required="false" default="">

		<cfif arguments.delimiter eq "">
			<cfset arguments.delimiter = ",">
		<cfelseif IsNumeric(arguments.delimiter)>
			<cfset arguments.delimiter = CHR(arguments.delimiter)>
		</cfif>

		<cfreturn ListToArray(arguments.list, arguments.delimiter)>
	</cffunction>

	<cffunction name="_rowAsArray" hint="row as array">
		<cfargument name="row" type="numeric" required="true">
		<cfargument name="query" type="query" required="false" default="#variables.collection#">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = ArrayNew(1)>
		<cfloop list="#arguments.query.columnlist#" index="lcl.col">
			<cfset ArrayAppend(lcl.result, arguments.query[lcl.col][arguments.row])>
		</cfloop>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="_structValueArray" returntype="array">
		<cfargument name="data" type="struct" required="true">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = ArrayNew(1)>

		<cfset lcl.keys = StructKeyArray(arguments.data)>
		<cfloop from="1" to="#ArrayLen(arguments.data)#" index="lcl.i">
			<cfset ArrayAppend(lcl.result, arguments.data[lcl.i])>
		</cfloop>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="addAll">
		<cfargument name="data" type="any" required="true">

		<cfset var lcl = StructNew()>

		<!--- <cfif IsArray(variables.collection)>
			<cfif IsSimpleValue(arguments.data)>
				<cfset arguments.data = ListToArray(arguments.data)>
				<cfset  variables.collection.addAll(arguments.data)>
			</cfif>

		<cfelseif IsQuery(variables.collection)>
			<cfif IsQuery(arguments.data)>
				<cfloop query="arguments.data">
					<cfset _setQueryRow(_rowAsArray(currentrow, arguments.data))>
				</cfloop>
			<cfelseif IsStruct(arguments.data)>
				<cfset add(arguments.data)>
			<cfelseif IsArray(arguments.data) AND ArrayLen(arguments.data)>
				<cfloop	from="1" to="#ArrayLen(arguments.data)#" index="lcl.i">
					<cfif IsStruct(arguments.data[lcl.i])>
						<cfset add(arguments.data[lcl.i])>
					</cfif>
				</cfloop>
			</cfif>
		<cfelseif IsStruct(variables.collection) AND arguments.key neq "">
			<cfset StructAppend(variables.collection, arguments.data)>
		<cfelseif IsSimpleValue(variables.collection) AND IsSimpleValue(arguments.data)>
			<cfset ListAppend(variables.collection, arguments.data)>
		</cfif> --->

		<cfreturn this>
	</cffunction>

	<cffunction name="clear">
		<cfif IsArray(variables.collection) OR IsStruct(variables.collection) OR IsQuery(variables.collection)>
			<cfset variables.collection.clear()>
		<cfelseif IsSimpleValue(variables.collection)>
			<cfset variables.collection = "">
		</cfif>

	</cffunction>

	<cffunction name="contains" hint="I return true if the collection contains the element" returntype="boolean">
		<cfargument name="element" type="any" required="true">

		<cfset var lcl = StructNew()>

		<cfif IsArray(variables.collection)>
			<cfreturn variables.collection.indexOf(arguments.element) neq -1>
		<cfelseif IsQuery(variables.collection)>
			<cfreturn ListToArray(variables.collection.columnlist).indexOf(arguments.element.toUpperCase())+1>
		<cfelseif IsStruct(variables.collection)>
			<cfreturn variables.collection.contains(arguments.element)>
		<cfelseif IsSimpleValue(variables.collection)>
			<cfreturn variables.collection.toArray().indexOf(arguments.element)>
		</cfif>
	</cffunction>

	<cffunction name="containsAll">
		<cfargument name="elements" type="any" required="true">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = true>

		<cfif IsSimpleValue(arguments.elements)>
			<cfloop list="#arguments.elements#" index="lcl.item">
				<cfif NOT this.contains(lcl.item)>
					<cfreturn false>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn true>

	</cffunction>

	<cffunction name="isEmpty">
		<cfif IsArray(variables.collection)>
			<cfreturn variables.collection.isEmpty()>
		<cfelseif IsQuery(variables.collection)>
			<cfreturn variables.collection.recordcount eq 0>
		<cfelseif IsStruct(variables.collection)>
			<cfreturn StructIsEmpty(variables.collection)>
		<cfelseif IsSimpleValue(variables.collection)>
			<cfreturn variables.collection eq "">
		</cfif>
	</cffunction>

	<cffunction name="iterator">
		<cfif NOT StructKeyExists(variables, "factory")>
			<cfset variables.iterFactory = createObject("component", "cfc.commons.iterators.DBIteratorFactory")>
		</cfif>
		<cfreturn variables.iterFactory.create( getAll() )>
	</cffunction>

	<cffunction name="remove">
		<cfargument name="indexkey" type="string" required="true">

		<cfif IsArray(variables.collection)>
			<cfset ArrayDeleteAt(variables.collection, arguments.indexkey)>
			<cfreturn true>
		<cfelseif IsQuery(variables.collection)>
			<cfif IsNumeric(arguments.indexkey) AND arguments.indexkey LTE variables.collection.recordcount>
				<cfset variables.collection.RemoveRows(arguments.indexkey-1, 1)>
				<cfreturn true>
<!--- 			<cfelse>
				<cfset lcl.colnum = variables.collection.findColumn(arguments.indexkey)>
				<cfif lcl.colnum>
					<cfloop from="1" to="#variables.collection.recordcount#" index="lcl.row">
						<cfdump var="#variables.collection.getRow(lcl.row-1).getRowData()#">
 						<cfset ArrayDeleteAt(variables.collection.getRow(lcl.row-1), lcl.colnum)>
					</cfloop>
				</cfif>
				<cfoutput>#lcl.colnum#</cfoutput> --->
			</cfif>
		<cfelseif IsStruct(variables.collection)>
			<cfreturn StructIsEmpty(variables.collection)>
		<cfelseif IsSimpleValue(variables.collection)>
			<cfreturn variables.collection eq "">
		</cfif>

		<cfreturn false>
	</cffunction>

	<cffunction name="retainAll">
		<cfargument name="keys" type="string" required="true">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = true>

		<cfif IsSimpleValue(arguments.keys)>
			<cfloop from="#variables.collection.recordcount#" to="1" step="-1" index="lcl.rownum">
				<cfif NOT ListFind(arguments.keys,lcl.rownum)>
					<cfset this.remove(lcl.rownum)>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn true>
	</cffunction>

	<cffunction name="removeAll">
		<cfargument name="keys" type="string" required="true">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = true>

		<cfif IsSimpleValue(arguments.keys)>
			<cfloop list="#ListSort(arguments.keys, 'numeric', 'desc')#" index="lcl.key">
				<cfif NOT this.remove(lcl.key)>
					<cfreturn false>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn true>
	</cffunction>

	<cffunction name="getAll">
		<cfreturn variables.collection>
	</cffunction>

	<cffunction name="size">
		<cfif IsArray(variables.collection)>
			<cfreturn variables.collection.size()>
		<cfelseif IsQuery(variables.collection)>
			<cfreturn variables.collection.recordcount>
		<cfelseif IsStruct(variables.collection)>
			<cfreturn StructIsEmpty(variables.collection)>
		<cfelseif IsSimpleValue(variables.collection)>
			<cfreturn variables.collection eq "">
		</cfif>

		<cfreturn variables.collection.size()>
	</cffunction>

	<cffunction name="set">
		<cfargument name="indexkey" type="string" required="true">
		<cfargument name="data"     type="any"    required="true">

		<cfif IsArray(variables.collection)>
			<cfreturn variables.collection.indexOf(arguments.element) neq -1>
		<cfelseif IsQuery(variables.collection)>
			<cfif IsNumeric(arguments.indexkey)>
				<cfif IsStruct(arguments.data)>
					<cfset _setQueryRow(_structValueArray(arguments.data), structKeyArray(arguments.data), arguments.indexkey)>
				</cfif>
			</cfif>
		<cfelseif IsStruct(variables.collection)>
			<cfreturn StructIsEmpty(variables.collection)>
		<cfelseif IsSimpleValue(variables.collection)>
			<cfreturn variables.collection eq "">
		</cfif>

		<cfreturn variables.collection.recordcount>
	</cffunction>

	<cffunction name="getCollection">
		<cfreturn getAll()>
	</cffunction>

	<cffunction name="setCollection">
		<cfargument name="collection"     type="any"    required="true">
			<cfset variables.collection = arguments.collection>
		<cfreturn this>
	</cffunction>
</cfcomponent>