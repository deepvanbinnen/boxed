<cfcomponent output="false" extends="AbstractCollection" hint="Creates collection object">
	<cffunction name="init" output="false">
		<cfargument name="data" type="any" required="true" hint="data" />
		<cfargument name="cfc"  type="any" required="false" hint="concrete implementation cfc providing methods to maintain the data, defaults to this" />
			<cfset setData( arguments.data ) />
			<cfif StructKeyExists( arguments, "cfc" )>
				<cfset super._setCollection( arguments.cfc ) />
			<cfelse>
				<cfset super._setCollection( this ) />
			</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="getData" output="false" hint="get collection data ">
		<cfif NOT StructKeyExists(variables, "data")>
			<cfthrow message="There is no data available in #_getName(this)#">
		</cfif>
		<cfreturn variables.data>
	</cffunction>

	<cffunction name="setData" output="false" hint="set collection data">
		<cfargument name="data" required="true" type="any">
			<cfset variables.data = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getCollection" output="false" hint="alias for getting data">
		<cfreturn getData()>
	</cffunction>

	<cffunction name="getPointer" output="false" hint="alias for getting data">
		<cfif NOT StructKeyExists(variables, "myPointer")>
			<cfset variables.myPointer = super.createPointer( argumentCollection=arguments ) />
		</cfif>
		<cfreturn variables.myPointer />
	</cffunction>

	<cffunction name="getIterator" output="false" hint="alias for getting data">
		<cfif NOT StructKeyExists(variables, "myIterator")>
			<cfset variables.myIterator = super.createIterator( argumentCollection=arguments ) />
		</cfif>
		<cfreturn variables.myIterator />
	</cffunction>

	<cffunction name="_getData" output="false">
		<cfreturn getData() />
	</cffunction>

	<cffunction name="_clear" output="false" hint="clear the array, this is a JAVA hack!">
		<cfreturn getData().clear()>
	</cffunction>

	<cffunction name="_clone" output="false" hint="clone the array, this is a JAVA hack!">
		<cfreturn getData().clone()>
	</cffunction>


</cfcomponent>