<cfcomponent name="OrderedStruct" hint="simulate a struct with keys kept in order">
	<cfset this.arr  = ArrayNew(1)><!--- The array that will hold the values --->
	<cfset this.keys = ""><!--- The keys used for the array entries --->

	<cffunction name="init" returntype="OrderedStruct" hint="instantiate component">
		<cfargument name="keylist"   type="string" required="false" default="">
		<cfargument name="values" type="array" required="false" default="#ArrayNew(1)#">

			<cfset this.keys = arguments.keylist>
			<cfset this.arr  = arguments.values>

		<cfreturn this>
	</cffunction>

	<cffunction name="findKey" returntype="any" hint="return the key for a value">
		<cfargument name="value" type="any" required="true">
		<cfargument name="index" type="numeric" required="false" default="0">

		<cfset var idx = ListFind(this.keys, arguments.value)>
		<cfif idx AND ArrayLen(this.arr) GTE idx>
			<cfreturn this.arr[idx]>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="findValue" returntype="any" hint="return the value for a key">
		<cfargument name="value" type="any" required="true">
		<cfargument name="index" type="numeric" required="false" default="0">

		<cfset var idx = this.arr.indexOf(arguments.value, arguments.index)>
		<cfif idx neq -1>
			<cfreturn ListGetAt(this.keys, idx+1)>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="getAll" returntype="array" hint="return the array of values">
		<cfreturn this.arr>
	</cffunction>

	<cffunction name="getKeys" returntype="string" hint="return the keys used for the array values">
		<cfreturn this.keys>
	</cffunction>

	<cffunction name="getValues" returntype="array" hint="return the array of values">
		<cfreturn getAll()>
	</cffunction>

	<cffunction name="hasKey" returntype="boolean" hint="return true if a key exists">
		<cfargument name="key" type="string" required="true" hint="key to lookup">
		<cfreturn ListFind(this.keys, arguments.key)>
	</cffunction>

	<cffunction name="contains" returntype="boolean" hint="alias for haskey">
		<cfargument name="key" type="string" required="true" hint="key to lookup">
		<cfreturn hasKey(arguments.key)>
	</cffunction>

	<cffunction name="set" returntype="OrderedStruct" hint="update value for key or insert key with given value if it doesn't exist">
		<cfargument name="key" type="string" required="true" hint="key to add or update">
		<cfargument name="value" type="any" required="false" default="" hint="value for the key">
		<cfargument name="index" type="numeric" required="false" default="0" hint="index where search will start, when trying to find the position of key in keylist">

		<cfif hasKey(arguments.key)>
			<cfset this.arr[getIdx(arguments.key, arguments.index)] = arguments.value>
		<cfelse>
			<cfset insertKey(arguments.key, arguments.value)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="get" returntype="any" hint="get the value for a key, if a key is used multiple times a start-index can be given for finding the array position from that index">
		<cfargument name="key" type="string" required="true" hint="key to get the value for">
		<cfargument name="index" type="numeric" required="false" default="0" hint="index where search will start, when trying to find the position of key in keylist">

		<cfset var Local = StructNew()>
		<cfset Local.Found = getIdx(arguments.key, arguments.index)>
		<cfif Local.Found gt 0 AND ArrayLen(this.arr) gte Local.Found>
			<cfreturn this.arr[Local.Found]>
		</cfif>

		<cfreturn "">
	</cffunction>

	<cffunction name="add" returntype="OrderedStruct" hint="add value to array and if no key is given, use the arrayindex as key">
		<cfargument name="value" type="any" required="true" hint="value to add">
		<cfargument name="key" type="string" required="false" default="#ArrayLen(this.arr)+1#" hint="key to use for the entry, defaults to position in the array">

		<cfset insertKey(arguments.key, arguments.value)>
		<cfreturn this>
	</cffunction>

	<cffunction name="remove" returntype="OrderedStruct" hint="remove key and value from the arrayset">
		<cfargument name="key" type="string" required="true" hint="key to remove">
		<cfargument name="index" type="numeric" required="false" default="0" hint="index where search will start, when trying to find the position of key in keylist">

		<cfset var Local = StructNew()>
		<cfif hasKey(arguments.key)>
			<cfset Local.Found = getIdx(arguments.key, arguments.index)>
			<cfset this.keys = ListDeleteAt(this.keys, Local.Found)>
			<cfset ArrayDeleteAt(this.arr, Local.Found)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="iget" returntype="any" hint="get the arrayvalue for a position">
		<cfargument name="index" type="numeric" required="true" hint="position to get the array value from">

		<cfif arguments.index gt 0 AND ArrayLen(this.arr) gte arguments.index>
			<cfreturn this.arr[arguments.index]>
		</cfif>

		<cfreturn "">
	</cffunction>

	<cffunction name="lastid" returntype="string" hint="return last key added to the arrayset">
		<cfreturn ListLast(this.keys)>
	</cffunction>

	<cffunction name="getIdx" returntype="numeric" hint="get the array position for a key, if a key is used multiple times a start-index can be given for finding the position from that index">
		<cfargument name="key"   type="string" required="true" hint="key to get the index for">
		<cfargument name="index" type="numeric" required="false" default="0" hint="index where search will start, when trying to find the position of key in keylist">

		<cfset var Local   = StructNew()>
		<cfset Local.jList = ListToArray(this.keys)>
		<cfset Local.Found = Local.jList.indexOf(arguments.key, arguments.index)+1>

		<cfreturn Local.Found>
	</cffunction>

	<cffunction name="insertKey" returntype="OrderedStruct" hint="insert value to the array and insert key to the keylist">
		<cfargument name="key" type="string" required="true" hint="key to add">
		<cfargument name="value" type="any" required="false" default="" hint="value to add">

		<cfset this.keys = ListAppend(this.keys,arguments.key)>
		<cfset ArrayAppend(this.arr, arguments.value)>

		<cfreturn this>
	</cffunction>

</cfcomponent>