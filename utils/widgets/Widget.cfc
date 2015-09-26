<cfcomponent extends="AbstractWidget" displayname="Widget" output="false" hint="Interface for widget">
	<cffunction name="init" returntype="any" output="false" hint="Initialises Widget">
		<cfargument name="Display"   required="true"  type="any" hint="instance of display" />
		<cfargument name="Formatter" required="true"  type="any" hint="instance of formatter" />
		<cfargument name="Retriever" required="true"  type="any" hint="instance of retriever" />
		<cfargument name="Validator" required="true"  type="any" hint="instance of validator" />


			<cfset variables.display   = arguments.display.setWidget(this) />
			<cfset variables.retriever = arguments.retriever.setWidget(this) />
			<cfset variables.validator = arguments.validator.setWidget(this) />
			<cfset variables.formatter = arguments.formatter.setWidget(this) />

			<cfset super.init(this) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getDisplay" returntype="any" hint="returns the Display instance">
		<cftry>
			<cfreturn variables.display />
			<cfcatch type="any">
				<cfthrow message="There is no instance of display">
			</cfcatch>
		</cftry>
	</cffunction>



	<cffunction name="getFormatter" returntype="any" hint="returns the Formatter instance">
		<cftry>
			<cfreturn variables.formatter />
			<cfcatch type="any">
				<cfthrow message="There is no instance of formatter">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getRetriever" returntype="any" hint="returns the Retriever instance">
		<cftry>
			<cfreturn variables.retriever />
			<cfcatch type="any">
				<cfthrow message="There is no instance of retriever">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getValidator" returntype="any" hint="returns the Validator instance">
		<cftry>
			<cfreturn variables.validator />
			<cfcatch type="any">
				<cfthrow message="There is no instance of validator">
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>