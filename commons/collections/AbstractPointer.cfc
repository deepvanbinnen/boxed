<cfcomponent name="AbstractPointer" extends="cfc.commons.collections.AbstractCollection">
	<cffunction name="setPointer" output="yes" returntype="any" hint="updates the values in the Pointer">
		<cfargument name="index"      type="numeric" required="false" default="0" />
		<cfargument name="key"        type="string"  required="false" default="" />
		<cfargument name="value"      type="any"     required="false" />
			<cfset _setIndex(arguments.index) />
			<cfset _setKey(arguments.key) />
			<cfif StructKeyExists(arguments, "value")>
				<cfset _setValue(arguments.value) />
			</cfif>
			<!--- <cfset _setIsNull(arguments.index LTE 0) /> --->
		<cfreturn this />
	</cffunction>

	<cffunction name="getIndex" output="No" returntype="numeric">
		<cfreturn _getPointer()._getIndex(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="getKey" output="No" returntype="string">
		<cfreturn _getPointer()._getKey(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="getValue" output="No" returntype="any">
		<cfreturn _getPointer()._getValue(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="next" output="No" returntype="any">
		<cfif hasNext()>
			<cfset setPointer(getIndex()+1)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="previous" output="No" returntype="any">
		<cfif hasPrevious()>
			<cfset setPointer(getIndex()-1)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="first" output="No" returntype="any">
		<cfset setPointer(1)>
		<cfreturn this>
	</cffunction>

	<cffunction name="last" output="No" returntype="any">
		<cfset _getPointer().setPointer( index=size() )>
		<cfreturn this>
	</cffunction>

	<cffunction name="hasNext" output="false" returntype="boolean">
		<cfreturn getIndex() GTE 0 AND getIndex() LT size()>
	</cffunction>

	<cffunction name="hasPrevious" output="No" returntype="boolean">
		<cfreturn getIndex() GT 1>
	</cffunction>

	<cffunction name="isFirst" output="No" returntype="boolean">
		<cfreturn getIndex() EQ 1>
	</cffunction>

	<cffunction name="isLast" output="No" returntype="boolean">
		<cfreturn getIndex() GTE size()>
	</cffunction>

	<cffunction name="isNullPointer" output="No" returntype="boolean">
		<cfreturn _getIsNull(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="setNullPointer" output="No" returntype="any">
			<cfset _setIsNull(true) />
		<cfreturn this>
	</cffunction>

	<cffunction name="_getIsNull" output="false" access="public" returntype="numeric">
		<cfif NOT StructKeyExists( variables, "isnull")>
			<cfset _setIsNull(true)>
		</cfif>
		<cfreturn variables.isnull />
	</cffunction>

	<cffunction name="_setIsNull" output="false" access="public">
		<cfargument name="isnull" type="boolean" required="true" />
			<cfset variables.isnull = arguments.isnull />
			<cfset this.isnull = arguments.isnull />
		<cfreturn this />
	</cffunction>

	<cffunction name="_getIndex" output="false" access="public" returntype="numeric">
		<cfif NOT StructKeyExists( variables, "index")>
			<cfthrow message="Index is undefined in variables-scope." />
		</cfif>
		<cfreturn variables.index />
	</cffunction>

	<cffunction name="_setIndex" output="false" access="public">
		<cfargument name="index" type="numeric" required="true" />
			<cfset variables.index = arguments.index />
			<cfset this.index = arguments.index />
		<cfreturn this />
	</cffunction>

	<cffunction name="_getKey" output="false" access="public" returntype="string">
		<cfif NOT StructKeyExists( variables, "key")>
			<cfthrow message="Key is undefined in variables-scope." />
		</cfif>
		<cfreturn variables.key />
	</cffunction>

	<cffunction name="_setKey" output="false" access="public">
		<cfargument name="key" type="any" required="true" />
			<cfset variables.key = arguments.key />
			<cfset this.key = arguments.key />
		<cfreturn this />
	</cffunction>

	<cffunction name="_getValue" output="false" access="public" returntype="any">
		<cfreturn _getPointer().get( argumentCollection=arguments ) />
	</cffunction>

	<cffunction name="_setValue" output="false" access="public">
		<cfargument name="value" type="any" required="true" />
			<cfset variables.value = arguments.value />
			<cfset this.value = arguments.value />
		<cfreturn this />
	</cffunction>

	<cffunction name="_getPointer" output="false" access="public" returntype="any">
		<cfif NOT StructKeyExists( variables, "pointer")>
			<cfthrow message="Pointer is undefined in variables-scope." />
		</cfif>
		<cfreturn variables.pointer />
	</cffunction>

	<cffunction name="_setPointer" output="false" access="public">
		<cfargument name="pointer" type="any" required="true" />
			<cfset variables.pointer = arguments.pointer />
		<cfreturn this />
	</cffunction>
</cfcomponent>
