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

		<cfset var local = StructCreate(args = CollectArgs(arguments), data = arguments.data)>

		<cfif local.args.parseRule("data,delimiter", "string,string")
			OR local.args.parseRule("data", "string")>
			<cfset local.args = local.args.getArguments()>
			<cfif NOT StructKeyExists(local.args, 'delimiter')>
				<cfset local.args.delimiter = ",">
			</cfif>
			<cfset local.data = ListToArray(local.args.data, local.args.delimiter)>
		</cfif>

		<cfreturn super.addAll( local.data )>
	</cffunction>

</cfcomponent>