<cfcomponent extends="com.googlecode.dbseries.ebx.utils.utils" displayname="AbstractWidget" output="false" hint="Interface for widget">
	<cffunction name="init" returntype="any" output="false" hint="Initialises Display">
		<cfargument name="Widget" required="true"  type="any" hint="instance of widget" />
		<cfargument name="value" required="false"  type="any" default="" hint="value for the widget" />

		<cfset variables.instance = StructNew() />
		<cfset variables.instance.elements   = QueryNew("label,element,currval") />
		<cfset variables.instance.value      = "" />
		<cfset variables.instance.cftype     = "string" />
		<cfset variables.instance.isvalidval = true />
		<cfset setWidget(arguments.widget)>

		<cfreturn this />
	</cffunction>

	<cffunction name="getWidget" returntype="any" hint="returns the Widget instance">
		<cftry>
			<cfreturn variables.widget />
			<cfcatch type="any">
				<cfthrow message="There is no instance of widget">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getDisplay" returntype="any" hint="returns the Display instance from Widget">
		<cftry>
			<cfreturn getWidget().getDisplay() />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getValidator" returntype="any" hint="returns the getValidator instance from Widget">
		<cftry>
			<cfreturn getWidget().getValidator() />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getRetriever" returntype="any" hint="returns the getRetriever instance from Widget">
		<cftry>
			<cfreturn getWidget().getRetriever() />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setWidget" returntype="any" hint="returns the Widget instance">
		<cfargument name="Widget" required="true"  type="any" hint="instance of widget" />
			<cfset variables.widget = arguments.Widget />
		<cfreturn this />
	</cffunction>

</cfcomponent>