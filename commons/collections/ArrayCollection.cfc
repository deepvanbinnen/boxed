<cfcomponent output="false" extends="AbstractArrayCollection" hint="Abstract array object">
	<cffunction name="init" output="false">
		<cfargument name="data" type="array" required="false">
		<cfif NOT StructKeyExists(arguments, "data")>
			<cfset arguments.data = ArrayNew(1) />
		</cfif>
		<cfset super.init(arguments.data, this) />
		<cfreturn this>
	</cffunction>

	<cffunction name="addAll" output="true">
		<cfargument name="data" type="any" required="true">

		<cfset var lcl = StructCreate(args = CollectArgs(arguments), data = arguments.data)>

		<cfif lcl.args.parseRule("data,delimiter", "string,string")
			OR lcl.args.parseRule("data", "string")>
			<cfset lcl.args = lcl.args.getArguments()>
			<cfif NOT StructKeyExists(lcl.args, 'delimiter')>
				<cfset lcl.args.delimiter = ",">
			</cfif>
			<cfset lcl.data = ListToArray(lcl.args.data, lcl.args.delimiter)>
		</cfif>

		<cfreturn super.addAll( lcl.data )>
	</cffunction>

</cfcomponent>