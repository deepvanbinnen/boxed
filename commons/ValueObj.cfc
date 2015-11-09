<cfcomponent extends="Introspect" output="false" hint="Getter/setter interface for the this-scope. In order to use this component the CF-Engine must implement OnMissingMethod! Usage of this object may obfuscate your code. Handle with care.">
	<cfset __constructor(
		  prefix = ""
		, rxfix = ""
	)>
	<cffunction name="init" output="false" hint="sets variables in the this scope from any data object">
		<cfargument name="data"   required="false" type="any" default="#__getattr()#" hint="any object that can be mapped to property data, defaults to variable scope">
		<cfargument name="prefix" required="false" type="string" default="" hint="Prefix to ignore in propertynames when guessing property getter. See the OnMissingMethod construction">
		<cfargument name="rxfix"  required="false" type="string" default="" hint="Regex-delete to apply on property keys when matching property from getter method">

			<cfset setProperties(data=arguments.data, force=true)>
			<cfset variables.prefix = arguments.prefix>
			<cfset variables.rxfix = arguments.rxfix>
		<cfreturn this>
	</cffunction>

	<cffunction name="get" returntype="any" output="false" hint="Alias for getProperty">
		<cfargument name="key"     required="true"  type="string" hint="key to get">
		<cfargument name="default" required="false" type="any"    default="" hint="default value to return if key doesn't exist">
		<cfreturn getProperty(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getProperty" returntype="any" output="false" hint="return property value or if the property does not exist default value which defaults to empty string">
		<cfargument name="key"     required="true"  type="string" hint="key to get">
		<cfargument name="default" required="false" type="any"    default="" hint="default value to return if key doesn't exist">

		<cfif hasProperty(arguments.key)>
			<cfreturn this[arguments.key]>
		</cfif>
		<cfreturn arguments.default>
	</cffunction>

	<cffunction name="getProperties" returntype="struct" output="false" hint="set properties from a data object">
		<cfargument name="maplist" required="false" type="any" default="" hint="propertylist or struct used to remap keys">

		<cfset var lcl = StructNew()>
		<cfset lcl.out = StructNew()>

		<cfif IsStruct(arguments.maplist) AND NOT StructIsEmpty(arguments.maplist)>
			<cfloop collection="#arguments.maplist#" item="lcl.i">
				<cfif hasProperty(lcl.i) AND NOT _isMethod(this[lcl.i])>
					<cfset StructInsert(lcl.out, arguments.maplist[lcl.i], this[lcl.i], true)>
				</cfif>
			</cfloop>
		<cfelseif IsSimpleValue(arguments.maplist) AND NOT arguments.maplist eq "">
			<cfloop list="#arguments.maplist#" index="lcl.i">
				<cfif hasProperty(lcl.i) AND NOT _isMethod(this[lcl.i])>
					<cfset StructInsert(lcl.out, lcl.i, this[lcl.i], true)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfloop collection="#this#" item="lcl.i">
				<cfif NOT _isMethod(this[lcl.i])>
					<cfset StructInsert(lcl.out, lcl.i, this[lcl.i], true)>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn lcl.out>
	</cffunction>

	<cffunction name="hasProperty" returntype="boolean" output="false" hint="returns true on success otherwise false">
		<cfargument name="key"   required="true"  type="string" hint="key to update">
		<cfreturn StructKeyExists(this, arguments.key)>
	</cffunction>

	<cffunction name="retainList" output="false">
		<cfargument name="sourcelist" type="string" required="true">
		<cfargument name="targetlist" type="string" required="true">

		<cfset var lcl = StructNew()>
		<cfset lcl.target = listToArray(arguments.targetlist)>
		<cfset lcl.source = listToArray(arguments.sourcelist)>
		<cfset lcl.target.retainAll(lcl.source)>

		<cfreturn ArrayToList(lcl.target)>
	</cffunction>

	<cffunction name="setFromList" output="false">
		<cfargument name="list" required="true" type="string" hint="list data">
		<cfargument name="force"  required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">

		<cfset var lcl = StructNew()>
		<cfloop list="#arguments.list#" index="lcl.key">
			<cfset setProperty(lcl.key, "", arguments.force, arguments.overwrite)>
		</cfloop>

		<cfreturn this>
	</cffunction>

	<cffunction name="setFromRecord" output="false">
		<cfargument name="record" required="true" type="query" hint="query data">
		<cfargument name="recidx" required="false" type="numeric" default="1" hint="the record index used if objectdata is queryable">
		<cfargument name="force"  required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">

		<cfset var lcl = StructNew()>
		<cfloop list="#arguments.record.columnlist#" index="lcl.column">
			<cfset lcl.value = "">
			<cfif arguments.record.recordcount GTE arguments.recidx>
				<cfset lcl.value = arguments.record[lcl.column][arguments.recidx]>
			</cfif>
			<cfset setProperty(lcl.column, lcl.value, arguments.force, arguments.overwrite)>
		</cfloop>

		<cfreturn this>
	</cffunction>

	<cffunction name="setFromStruct" output="false">
		<cfargument name="object" required="true" type="struct" hint="struct data">
		<cfargument name="force" required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">

		<cfset var lcl = StructNew()>
		<cfloop collection="#arguments.object#" item="lcl.key">
			<cfset setProperty(lcl.key, arguments.object[lcl.key], arguments.force, arguments.overwrite)>
		</cfloop>

		<cfreturn this>
	</cffunction>

	<cffunction name="setProperty" returntype="any" output="false" hint="returns true on success otherwise false">
		<cfargument name="key"   required="true"  type="string"  hint="key to update">
		<cfargument name="value" required="false" type="any"     default="" hint="value for the key">
		<cfargument name="force"     required="false" type="boolean" default="false" hint="force creation of property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">

		<cfif arguments.force OR hasProperty(arguments.key) AND arguments.overwrite>
			<cfif NOT hasProperty(arguments.key) OR arguments.overwrite>
				<cfset this[arguments.key] = arguments.value>
			</cfif>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="setProperties" output="false" hint="set properties from a data object">
		<cfargument name="data"   required="true"  type="any"     hint="the object that holds the data">
		<cfargument name="force"  required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite"  required="false" type="boolean" default="true" hint="overwrite property">
		<cfargument name="recidx" required="false" type="numeric" default="1" hint="the record index used if objectdata is queryable">

		<cfset var lcl = StructNew()>
		<cfif IsQuery(arguments.data)>
			<cfset setFromRecord(arguments.data, arguments.recidx, arguments.force, arguments.overwrite)>
		<cfelseif IsStruct(arguments.data)>
			<cfset setFromStruct(arguments.data, arguments.force, arguments.overwrite)>
		<cfelseif ListLen(arguments.data)>
			<cfset setFromList(arguments.data, arguments.force, arguments.overwrite)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="matchGetterProperty" output="false" hint="Reformats orignal propertyname to the keyname most likely used as getter and checks if it matches the given getter propertyname.">
		<cfargument name="orgPropName" required="true" type="string" hint="Original propertyname">
		<cfargument name="getPropName" required="true" type="string" hint="Getter propertyname">

		<cfset var lcl = StructNew()>
		<cfset lcl.prop = arguments.orgPropName.replaceAll("(?i)^(#variables.prefix#)|_", "")>
		<cfreturn (lcl.prop eq arguments.getPropName)>
	</cffunction>

	<cffunction name="guessGetterProperty" output="false" hint="Determines propertyname from getter function name.">
		<cfargument name="propertyName" required="true" type="string" hint="The methodname that threw an error">

		<cfset var lcl = StructCreate(result = "")>
		<cfif hasProperty(arguments.propertyName)>
			<cfset lcl.result = arguments.propertyName>
		<cfelse>
			<!--- Loop properties and return the first key that matches --->
			<cfset lcl.properties = getProperties()>
			<cfloop collection="#lcl.properties#" item="lcl.i">
				<cfif matchGetterProperty(lcl.i, arguments.propertyName)>
					<cfset lcl.result = lcl.i>
					<cfbreak/>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="OnMissingMethod" output="false" hint="Intercepts calls to getters and setters and fakes their calls.">
		<cfset var lcl = StructCreate(
			  result = ""
			, meth = arguments.missingMethodName
			, args = arguments.missingMethodArguments
		)>

		<cfif REFind("^([g|s]et)", lcl.meth)
			AND (
			    (REFind("^(get)", lcl.meth) AND StructIsEmpty(lcl.args) )
			 OR (REFind("^(set)", lcl.meth) AND ArrayLen(lcl.args) eq 1 )
			)>
			<cfset lcl.result = guessGetterProperty(REReplace(lcl.meth, "^([g|s]et)", ""))>
			<cfif lcl.result NEQ "">
				<cfif REFind("^(get)", lcl.meth)>
					<cfreturn getProperty(lcl.result, "")>
				<cfelse>
					<cfreturn setProperty(lcl.result, lcl.args[1])>
				</cfif>
			</cfif>
		</cfif>

		<cfthrow message="No such method: #lcl.meth#. Tried to determine getter with prefix(es): #variables.prefix#">
		<cfabort />
	</cffunction>

	<cffunction name="_dump" returntype="any" output="false" hint="return property value or if the property does not exist default value which defaults to empty string">
		<cfargument name="outputType" type="string" required="false" default="struct" hint="specifies the returntype can be struct or string">
		<cfif outputType eq "string">
			<cfreturn super._dump(getProperties())>
		<cfelse>
			<cfreturn getProperties()>
		</cfif>
	</cffunction>
</cfcomponent>