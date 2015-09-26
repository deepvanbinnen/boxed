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
		
		<cfset var local = StructNew()>
		<cfset local.out = StructNew()>
		
		<cfif IsStruct(arguments.maplist) AND NOT StructIsEmpty(arguments.maplist)>
			<cfloop collection="#arguments.maplist#" item="local.i">
				<cfif hasProperty(local.i) AND NOT _isMethod(this[local.i])>
					<cfset StructInsert(local.out, arguments.maplist[local.i], this[local.i], true)>
				</cfif>
			</cfloop>
		<cfelseif IsSimpleValue(arguments.maplist) AND NOT arguments.maplist eq "">
			<cfloop list="#arguments.maplist#" index="local.i">
				<cfif hasProperty(local.i) AND NOT _isMethod(this[local.i])>
					<cfset StructInsert(local.out, local.i, this[local.i], true)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfloop collection="#this#" item="local.i">
				<cfif NOT _isMethod(this[local.i])>
					<cfset StructInsert(local.out, local.i, this[local.i], true)>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn local.out>
	</cffunction>
	
	<cffunction name="hasProperty" returntype="boolean" output="false" hint="returns true on success otherwise false">
		<cfargument name="key"   required="true"  type="string" hint="key to update">
		<cfreturn StructKeyExists(this, arguments.key)>
	</cffunction>
	
	<cffunction name="retainList" output="false">
		<cfargument name="sourcelist" type="string" required="true">
		<cfargument name="targetlist" type="string" required="true">
		
		<cfset var local = StructNew()>
		<cfset local.target = listToArray(arguments.targetlist)>
		<cfset local.source = listToArray(arguments.sourcelist)>
		<cfset local.target.retainAll(local.source)>
		
		<cfreturn ArrayToList(local.target)>
	</cffunction>
	
	<cffunction name="setFromList" output="false">
		<cfargument name="list" required="true" type="string" hint="list data">
		<cfargument name="force"  required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">
		
		<cfset var local = StructNew()>
		<cfloop list="#arguments.list#" index="local.key">
			<cfset setProperty(local.key, "", arguments.force, arguments.overwrite)>
		</cfloop>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setFromRecord" output="false">
		<cfargument name="record" required="true" type="query" hint="query data">
		<cfargument name="recidx" required="false" type="numeric" default="1" hint="the record index used if objectdata is queryable">
		<cfargument name="force"  required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">
			
		<cfset var local = StructNew()>
		<cfloop list="#arguments.record.columnlist#" index="local.column">
			<cfset local.value = "">
			<cfif arguments.record.recordcount GTE arguments.recidx>
				<cfset local.value = arguments.record[local.column][arguments.recidx]>
			</cfif>
			<cfset setProperty(local.column, local.value, arguments.force, arguments.overwrite)>
		</cfloop>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setFromStruct" output="false">
		<cfargument name="object" required="true" type="struct" hint="struct data">
		<cfargument name="force" required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">
	
		<cfset var local = StructNew()>
		<cfloop collection="#arguments.object#" item="local.key">
			<cfset setProperty(local.key, arguments.object[local.key], arguments.force, arguments.overwrite)>
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
		
		<cfset var local = StructNew()>
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
		
		<cfset var local = StructNew()>
		<cfset local.prop = arguments.orgPropName.replaceAll("(?i)^(#variables.prefix#)|_", "")>
		<cfreturn (local.prop eq arguments.getPropName)>
	</cffunction>
	
	<cffunction name="guessGetterProperty" output="false" hint="Determines propertyname from getter function name.">
		<cfargument name="propertyName" required="true" type="string" hint="The methodname that threw an error">
		
		<cfset var local = StructCreate(result = "")>
		<cfif hasProperty(arguments.propertyName)>
			<cfset local.result = arguments.propertyName>
		<cfelse>
			<!--- Loop properties and return the first key that matches --->
			<cfset local.properties = getProperties()>
			<cfloop collection="#local.properties#" item="local.i">
				<cfif matchGetterProperty(local.i, arguments.propertyName)>
					<cfset local.result = local.i>
					<cfbreak/>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn local.result>
	</cffunction>
	
	<cffunction name="OnMissingMethod" output="false" hint="Intercepts calls to getters and setters and fakes their calls.">
		<cfset var local = StructCreate(
			  result = ""
			, meth = arguments.missingMethodName
			, args = arguments.missingMethodArguments
		)>
		
		<cfif REFind("^([g|s]et)", local.meth) 
			AND ( 
			    (REFind("^(get)", local.meth) AND StructIsEmpty(local.args) )
			 OR (REFind("^(set)", local.meth) AND ArrayLen(local.args) eq 1 )
			)>
			<cfset local.result = guessGetterProperty(REReplace(local.meth, "^([g|s]et)", ""))>
			<cfif local.result NEQ "">
				<cfif REFind("^(get)", local.meth)>
					<cfreturn getProperty(local.result, "")>
				<cfelse>
					<cfreturn setProperty(local.result, local.args[1])>
				</cfif>
			</cfif>
		</cfif>
		
		<cfthrow message="No such method: #local.meth#. Tried to determine getter with prefix(es): #variables.prefix#">
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