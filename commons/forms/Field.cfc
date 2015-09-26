<cfcomponent displayname="Field" output="false" hint="field.">
	<cffunction name="init" returntype="Field" output="false" hint="Initialises Field">
		<cfreturn this />
	</cffunction>
		<cffunction name="getName" returntype="string" output="false" hint="Getter for name">
		<cftry>
			<cfreturn variables.name />
			<cfcatch type="any">
				<cfthrow message="No such variable: name" />
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="setName" returntype="any" output="false" hint="Setter for name">
		<cfargument name="name" required="true"  type="string" hint="name : string">
			<cfset variables.name = arguments.name/>
			<cfset this.name = arguments.name />
		<cfreturn this />
	</cffunction>
		<cffunction name="getId" returntype="string" output="false" hint="Getter for id">
		<cftry>
			<cfreturn variables.id />
			<cfcatch type="any">
				<cfthrow message="No such variable: id" />
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="setId" returntype="any" output="false" hint="Setter for id">
		<cfargument name="id" required="true"  type="string" hint="id : string">
			<cfset variables.id = arguments.id/>
			<cfset this.id = arguments.id />
		<cfreturn this />
	</cffunction>
		<cffunction name="getValue" returntype="string" output="false" hint="Getter for value">
		<cftry>
			<cfreturn variables.value />
			<cfcatch type="any">
				<cfthrow message="No such variable: value" />
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="setValue" returntype="any" output="false" hint="Setter for value">
		<cfargument name="value" required="true"  type="string" hint="value : string">
			<cfset variables.value = arguments.value/>
			<cfset this.value = arguments.value />
		<cfreturn this />
	</cffunction>
		<cffunction name="getValueMap" returntype="any" output="false" hint="Getter for valueMap">
		<cftry>
			<cfreturn variables.valueMap />
			<cfcatch type="any">
				<cfthrow message="No such variable: valueMap" />
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="setValueMap" returntype="any" output="false" hint="Setter for valueMap">
		<cfargument name="valueMap" required="true"  type="any" hint="valueMap : any">
			<cfset variables.valueMap = arguments.valueMap/>
			<cfset this.valueMap = arguments.valueMap />
		<cfreturn this />
	</cffunction>
		<cffunction name="getSelIndex" returntype="-1" output="false" hint="Getter for selIndex">
		<cftry>
			<cfreturn variables.selIndex />
			<cfcatch type="any">
				<cfthrow message="No such variable: selIndex" />
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="setSelIndex" returntype="any" output="false" hint="Setter for selIndex">
		<cfargument name="selIndex" required="true"  type="-1" hint="selIndex : -1">
			<cfset variables.selIndex = arguments.selIndex/>
			<cfset this.selIndex = arguments.selIndex />
		<cfreturn this />
	</cffunction>
		<cffunction name="getValidator" returntype="Validator" output="false" hint="Getter for validator">
		<cftry>
			<cfreturn variables.validator />
			<cfcatch type="any">
				<cfthrow message="No such variable: validator" />
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="setValidator" returntype="any" output="false" hint="Setter for validator">
		<cfargument name="validator" required="true"  type="Validator" hint="validator : Validator">
			<cfset variables.validator = arguments.validator/>
			<cfset this.validator = arguments.validator />
		<cfreturn this />
	</cffunction>
</cfcomponent>