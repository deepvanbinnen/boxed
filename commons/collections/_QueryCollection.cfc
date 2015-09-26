<cfcomponent output="false" extends="AbstractCollection" hint="Query object">
	<cffunction name="createPointer" returntype="any" hint="bla die bla blie">
		<cfreturn ObjectCreate("cfc.commons.collections.QueryPointer").init(this, getColumns().createPointer())>
	</cffunction>

	<cffunction name="createIterator" output="false" hint="create the iterator for this collection 123">
		<cfreturn ObjectCreate("cfc.commons.collections.QueryIterator").init( createPointer() )>
	</cffunction>

	<cffunction name="_createIterObserver" output="false" hint="creates iterator observer">
		<cfreturn ObjectCreate("cfc.commons.collections.IterationObserver").init( createIterator() )>
	</cffunction>

	<cffunction name="getIterObserver" output="false" hint="add element to collection">
		<cfif NOT StructKeyExists(variables, "iterObserver")>
			<cfset variables.iterObserver = _createIterObserver()>
		</cfif>
		<cfreturn variables.iterObserver>
	</cffunction>

	<cffunction hint="iterates with a self resetting iterator"
			name="iterate">
		<cfreturn getIterObserver().iterates()>
	</cffunction>

	<cffunction name="getCurrent" hint="add element to collection">
		<cfreturn getIterObserver().getValue()>
	</cffunction>

	<cffunction name="getIndex" hint="add element to collection">
		<cfreturn getIterObserver().getIndex()>
	</cffunction>

	<cffunction name="getKey" hint="add element to collection">
		<cfreturn getIterObserver().getKey()>
	</cffunction>

	<cffunction name="getColumns" hint="add element to collection">
		<cfif NOT StructKeyExists(variables, "columns")>
			<cfset setColumns()>
		</cfif>
		<cfreturn variables.columns>
	</cffunction>

	<cffunction name="setColumns" hint="add element to collection">
		<cfargument name="columns" type="string" default="#getKeys()#">
			<cfset variables.columns =  _collectionObj(arguments.columns)>
		<cfreturn this>
	</cffunction>

	<cffunction name="add" hint="add element to collection">
		<cfset var local = StructCreate(
			  data = StructCreate(argumentCollection = arguments)
			, key = ""
		)>
		<cfif StructKeyExists(arguments, "data")>
			<cfset local.data = arguments.data>
		</cfif>
		<cfif StructKeyExists(arguments, "key")>
			<cfset local.key = arguments.key>
		</cfif>

		<cfreturn _add(argumentCollection = local)>
	</cffunction>

	<cffunction name="_add" hint="add element to collection">
		<cfargument name="data" type="any"    required="true">
		<cfargument name="key"  type="string" required="false" default="">

		<cfset var local = StructNew()>
		<cfif IsArray(arguments.data) AND ArrayLen(arguments.data) eq ListLen(variables.collection.columnlist)>
			<cfset _setQueryRow(arguments.data)>
		<cfelseif IsStruct(arguments.data)>
			<cfset local.keys = ArrayNew(1)>
			<cfset local.vals = ArrayNew(1)>
			<cfloop collection="#arguments.data#" item="local.key">
				<cfset ArrayAppend(local.keys,local.key)>
				<cfset ArrayAppend(local.vals,arguments.data[local.key])>
			</cfloop>
			<cfset _setQueryRow(local.vals,local.keys)>
		<cfelseif IsSimpleValue(arguments.data)>
			<cfset _setQueryRow(_listAsArray(arguments.data, arguments.key))>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="addAll">
		<cfargument name="data" type="any" required="true">

		<cfset var local = StructNew()>

		<cfif IsQuery(arguments.data)>
			<cfloop query="arguments.data">
				<cfset _setQueryRow(_rowAsArray(currentrow, arguments.data))>
			</cfloop>
		<cfelseif IsStruct(arguments.data)>
			<cfset add(arguments.data)>
		<cfelseif IsArray(arguments.data) AND ArrayLen(arguments.data)>
			<cfloop	from="1" to="#ArrayLen(arguments.data)#" index="local.i">
				<cfif IsStruct(arguments.data[local.i])>
					<cfset add(arguments.data[local.i])>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="filter" hint="I return a copy of the collection with the filter applied" returntype="any">
		<cfset var local = StructCreate(iter = iterator(arguments))>
		<cfset var q = getCollection()>

		<cfquery name="local.result" dbtype="query">
		SELECT *
		FROM  q
		WHERE 1 = 1
			<cfloop condition="#local.iter.whileHasNext()#">
				<cfif hasKey(local.iter.getKey())>
					AND #local.iter.getKey()# IN (<cfqueryparam value="#local.iter.getValue()#" list="true">)
				</cfif>
			</cfloop>
		</cfquery>

		<cfreturn _newInstance(local.result)>
	</cffunction>

	<cffunction name="isEmpty">
		<cftry>
			<cfreturn variables.collection.recordcount eq 0>
			<cfcatch type="any">
				<cfreturn true>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="remove">
		<cfargument name="indexkey" type="string" required="true">

			<cfif IsNumeric(arguments.indexkey) AND arguments.indexkey LTE variables.collection.recordcount>
				<cfset variables.collection.RemoveRows(arguments.indexkey-1, 1)>
				<cfreturn true>
<!--- 			<cfelse>
				<cfset local.colnum = variables.collection.findColumn(arguments.indexkey)>
				<cfif local.colnum>
					<cfloop from="1" to="#variables.collection.recordcount#" index="local.row">
						<cfdump var="#variables.collection.getRow(local.row-1).getRowData()#">
 						<cfset ArrayDeleteAt(variables.collection.getRow(local.row-1), local.colnum)>
					</cfloop>
				</cfif>
				<cfoutput>#local.colnum#</cfoutput> --->
			</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="retainAll">
		<cfargument name="keys" type="string" required="true">

		<cfset var local = StructNew()>
		<cfset local.result = true>

		<cfif IsSimpleValue(arguments.keys)>
			<cfloop from="#variables.collection.recordcount#" to="1" step="-1" index="local.rownum">
				<cfif NOT ListFind(arguments.keys,local.rownum)>
					<cfset this.remove(local.rownum)>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn true>
	</cffunction>

	<cffunction name="size">
		<cfreturn variables.collection.recordcount>
	</cffunction>

	<cffunction name="slice" hint="take a slice out of a list">
		<cfargument name="list"  required="true" type="string">
		<cfargument name="start" required="false" type="numeric" default="0">
		<cfargument name="end"   required="false" type="numeric" default="#ListLen(arguments.list)#">

		<cfset var local = StructNew()>
		<cfset local.arr = ListToArray(arguments.list)>
		<cfif arguments.end GT ListLen(arguments.list)>
			<cfset arguments.end = ArrayLen(local.arr)>
		</cfif>
		<cfreturn ArrayToList(local.arr.subList(arguments.start, arguments.end))>
	</cffunction>

	<cffunction name="getCell" hint="gets a cell from the collection">
		<cfargument name="column" required="true" type="string">
		<cfargument name="row"    required="false" type="numeric" default="#size()#">
		<cfif arguments.row LTE size() AND hasKey(arguments.column)>
			<cfreturn variables.collection[arguments.column][arguments.row]>
		</cfif>
		<cfreturn arguments.column & ":" & arguments.row>
	</cffunction>

	<cffunction name="get">
		<cfargument name="indexkey" type="numeric" required="false" default="1" hint="rownumber defaults to last row">
		<cfreturn getByIndex(arguments.indexkey)>
	</cffunction>

	<cffunction name="getColumnValueList">
		<cfargument name="column" required="true" type="string">
		<cfif hasKey(arguments.column)>
			<cfreturn ArrayToList(variables.collection[arguments.column])>
		</cfif>
		<cfreturn variables.collection>
	</cffunction>

	<cffunction name="getByIndex">
		<cfargument name="indexkey" type="numeric" required="false" default="#size()#" hint="rownumber defaults to last row">
		<cfargument name="keys"     type="any"     required="false" default="#getKeys()#" hint="list of columns or struct with columnnames mapped to aliasnames">

		<cfset var local = StructCreate(result = "")>
		<cfif arguments.indexkey LTE size()>
			<cfif ListLen(arguments.keys) GT 1>
				<cfset local.result = StructCreate()>
				<cfloop list="#arguments.keys#" index="local.col">
					<cfset StructInsert(local.result, local.col, getCell(local.col, arguments.indexkey), TRUE)>
				</cfloop>
				<cfif StructIsEmpty(local.result)>
					<cfset local.result = "">
				</cfif>
			<cfelse>
				<cfset local.result =  getCell(arguments.keys, arguments.indexkey)>
			</cfif>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="hasKey">
		<cfargument name="key" type="string" required="true" hint="check if column exists">

		<cfreturn ListFindNoCase(getKeys(), arguments.key)>
	</cffunction>


	<cffunction name="getKeys">
		<cfreturn variables.collection.columnlist>
	</cffunction>

	<cffunction name="set">
		<cfargument name="indexkey" type="string" required="true">
		<cfargument name="data"     type="any"    required="true">

		<cfif IsNumeric(arguments.indexkey)>
			<cfif IsStruct(arguments.data)>
				<cfset _setQueryRow(_structValueArray(arguments.data), structKeyArray(arguments.data), arguments.indexkey)>
			</cfif>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="_setQueryRow" output="false" hint="set query row">
		<cfargument name="data" type="array" required="true">
		<cfargument name="cols"  type="array" required="false" default="#ListToArray(_getCollection().columnlist)#">
		<cfargument name="row"  type="numeric" required="false" default="0">

		<cfif ArrayLen(arguments.data) EQ ArrayLen(arguments.cols)>
			<cfif arguments.row eq 0>
				<cfset QueryAddRow(_getCollection())>
				<cfset arguments.row = _getCollection().recordcount>
			</cfif>
			<cfif arguments.row LTE _getCollection().recordcount>
				<cfloop from="1" to="#ArrayLen(arguments.data)#" index="local.i">
					<cfset QuerySetCell(_getCollection(), arguments.cols[local.i], arguments.data[local.i], arguments.row)>
				</cfloop>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="_rowAsArray" output="false" hint="row as array">
		<cfargument name="row" type="numeric" required="true">
		<cfargument name="query" type="query" required="false" default="#_getCollection()#">

		<cfset var local = StructNew()>
		<cfset local.result = ArrayNew(1)>
		<cfloop list="#arguments.query.columnlist#" index="local.col">
			<cfset ArrayAppend(local.result, arguments.query[local.col][arguments.row])>
		</cfloop>

		<cfreturn local.result>
	</cffunction>
</cfcomponent>




