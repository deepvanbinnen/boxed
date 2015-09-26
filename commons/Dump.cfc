<cfcomponent extends="Introspect">
	<cffunction name="init" returntype="any" access="public" hint="initialises dump">
		<cfargument name="targetObj" type="any" required="true">
		<cfargument name="maxDepth" required="false" type="numeric" default="1">

			<cfset variables.targetObj = arguments.targetObj />
			<cfset variables.maxDepth = arguments.maxDepth />

		<cfreturn this />
	</cffunction>

	<cffunction name="dumpData" returntype="string" hint="dumps data">
		<cfargument name="data"       required="false" type="any" default="#this#">
		<cfargument name="message"    required="false" type="string" default="">
		<cfargument name="dumpmethod" required="false" default="false" type="boolean">

		<cfset var lcl = StructNew()>

		<cfsavecontent variable="lcl.result">
			<cfif NOT StructKeyExists(variables, "__style__")>
				<cfset variables.__style__ = true>
				<cfoutput><style type="text/css">#getCSS()#</style></cfoutput>
			</cfif>
			<cfoutput>
				<cfif arguments.message neq "">
					<div class="dump-message">#arguments.message#:</div>
				</cfif>
				<cfswitch expression="#getDataType(arguments.data)#">
					<cfcase value="string">
						<cfreturn arguments.data />
					</cfcase>
					<cfcase value="struct,argcollection">
						<cfoutput>#dumpStruct(arguments.data)#</cfoutput>
					</cfcase>
					<cfcase value="exception">
						<cfoutput>#dumpCatch(arguments.data)#</cfoutput>
					</cfcase>
					<cfcase value="array">
						<cfoutput>#dumpArray(arguments.data)#</cfoutput>
						<!--- <cfreturn "<strong>Array:</strong> " & ArrayLen(arguments.data) /> --->
					</cfcase>
					<cfcase value="methods">
						<cfoutput>#dumpMethods(arguments.data)#</cfoutput>
						<!--- <cfreturn "<strong>Methods:</strong> " & _getReflectedNames(targetArr=arguments.data, asList=true) /> --->
					</cfcase>
					<cfcase value="method">
						<cfoutput>#dumpMethod(arguments.data)#</cfoutput>
						<!--- <cfreturn "<strong>Method:</strong> " & _getReflectedName(targetObj=arguments.data) /> --->
					</cfcase>
					<cfcase value="query">
						<cfoutput>#dumpQuery(arguments.data)#</cfoutput>
						<!--- <cfreturn "<strong>Query:</strong> " & arguments.data.columnlist & " [#arguments.data.recordcount# records]" /> --->
					</cfcase>
					<cfcase value="cfc">
						<cfoutput>#dumpCFC(arguments.data)#</cfoutput>
					</cfcase>
					<cfdefaultcase>
						<cfreturn "Unknown: " & getDataType(arguments.data) & ":" & getMetaData(arguments.data).toString() />
					</cfdefaultcase>
				</cfswitch>
			</cfoutput>
		</cfsavecontent>

		<cfreturn TRIM(lcl.result)>
	</cffunction>

	<cffunction name="_formatData" returntype="string" output="false" hint="Returns formatted data">
		<cfargument name="data"     required="true"  type="any" hint="The data to format" />
		<cfargument name="curdepth" required="true"  type="numeric" hint="The current depth" />

		<cfswitch expression="#getDataType(arguments.data)#">
			<cfcase value="string">
				<cfreturn arguments.data />
			</cfcase>
			<cfcase value="struct">
				<cfreturn "<strong>Struct (#isObject(arguments.data)#):</strong> " & StructKeyList(arguments.data) />
			</cfcase>
			<cfcase value="array">
				<cfreturn "<strong>Array:</strong> " & ArrayLen(arguments.data) />
			</cfcase>
			<cfcase value="methods">
				<cfreturn "<strong>Methods:</strong> " & _getReflectedNames(targetArr=arguments.data, asList=true) />
			</cfcase>
			<cfcase value="method">
				<cfreturn "<strong>Method:</strong> " & _getReflectedName(targetObj=arguments.data) />
			</cfcase>
			<cfcase value="query">
				<cfreturn "<strong>Query:</strong> " & arguments.data.columnlist & " [#arguments.data.recordcount# records]" />
			</cfcase>
			<cfcase value="cfc">
				<cfreturn "<strong>Object:</strong> " & getDataType(arguments.data) />
			</cfcase>
			<cfdefaultcase>
				<cfreturn "Unknown: " & getMetaData(arguments.data).toString() />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="getCSS" access="public" returntype="string" output="false">
		<cfset var lcl = StructNew() />
		<cfsavecontent variable="lcl.result">
		div.dump, table.dump { font-family: Arial, Verdana, "Bitstream Vera", "Lucida", Helvetica; }
		div.caught .message, div.caught .detail, div.caught .type, div.caught .tagcontext, div.caught .stacktrace
		{ padding: 0.2em 0.5em;}
		div.caught p.message {margin: 0; font-weight: bold;}
		div.caught div.detail, div.caught div.type { }
		table.dump {
			font-size: 85%; border-width: 0.1em;
			border-collapse: collapse; border-style: solid;
		}
		table.dump th, table.dump td {
			border-width: 0.3em; border-style: solid;
			text-align: left; vertical-align: top;
			padding: 0; margin: 0;
		}
		table.dump th { color: white; font-weight: bold; padding: 0.2em 0.4em;}
		table.dump td { width: 100%; background: antiquewhite; font-size: 110%;}

		table.array {border-bottom: none;}
		table.array, table.array th, table.array td {border-color: darkkhaki;}
		table.array th {background: olive !important; }
		span.array {}
		span.array strong {background: green; color: white; font-weight: bold;}

		table.struct, table.struct th, table.struct td {border-color: cornflowerblue;}
		table.struct th {background: steelblue !important;}
		span.struct {}
		span.struct strong {background: steelblue; color: white; font-weight: bold;}

		table.query {border-bottom: none;}
		table.query, table.query th, table.query td {border-color: purple;}
		table.query th {background: #660066 !important;}
		span.query {}
		span.query strong {background: #660066; color: white; font-weight: bold;}
		td.string {padding: 0.2em 0.4em !important;}

		.cfc, .cfc th, .cfc td {border-color: #CC0000;}
		.cfc th {background: #FF0000;}
		span.cfc {border: 0.1em solid #FF0000;}
		span.cfc strong {background: #FF0000; color: white; font-weight: bold;}

		div.caught {font-size: 80%; border: 0.2em solid silver; background: whitesmoke; padding: 0.25em;}
		div.caught div {border: 0.3em solid gainsboro;}
		div.caught div strong.function, div.caught div strong em {font-size: 90%;}
		div.caught div strong em {font-style: normal; font-size: 80%;}
		</cfsavecontent>

		<cfset variables.cssoutput = true />

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="dumpStruct" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true">

		<cfset var lcl = StructNew() />

		<cfsavecontent variable="lcl.result"><cfoutput>
		<table class="dump struct">
			<cfloop collection="#arguments.data#" item="lcl.name">
				<cfset lcl.value = arguments.data[lcl.name]>
				<cfif StructKeyExists(lcl, "value")>
				<tr>
					<th>#lcl.name#</th>
					<td class="#getDataType(lcl.value)#">#dumpData(lcl.value)#</td>
				</tr>
				</cfif>
			</cfloop>
		</table>
		</cfoutput></cfsavecontent>

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="dumpArray" access="public" returntype="string" output="false">
		<cfargument name="data" type="array" required="true">

		<cfset var lcl = StructNew() />

		<cfsavecontent variable="lcl.result"><cfoutput>
		<table class="array dump">
			<cfloop from="1" to="#ArrayLen(arguments.data)#" index="lcl.index">
				<cfset lcl.value = arguments.data[lcl.index]>
				<tr>
					<th>#lcl.index#</th>
					<td class="#getDataType(lcl.value)#">#dumpData(lcl.value)#</td>
				</tr>
			</cfloop>
		</table>
		</cfoutput></cfsavecontent>

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="dumpQuery" access="public" returntype="string" output="false">
		<cfargument name="data" type="query" required="true">

		<cfset var lcl = StructNew() />

		<cfsavecontent variable="lcl.result"><cfoutput>
		<table class="query dump">
			<tr>
				<th>&nbsp;</th>
				<cfloop list="#arguments.data.columnlist#" index="lcl.column">
					<th>#lcl.column#</th>
				</cfloop>
			</tr>
			<cfloop query="arguments.data">
				<tr>
					<td>#arguments.data.currentrow#</td>
					<cfloop list="#arguments.data.columnlist#" index="lcl.column">
						<cfset lcl.value = arguments.data[lcl.column][arguments.data.currentrow]>
						<td class="#getDataType(lcl.value)#">#dumpData(lcl.value)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
		</cfoutput></cfsavecontent>

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="dumpCFC" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true">

		<cfset var lcl = StructNew() />
		<cfset lcl.meta = getMetaData(arguments.data) />
		<cfsavecontent variable="lcl.result"><cfoutput>
		<table class="cfc dump">
			<cfloop list="#StructKeyList(lcl.meta)#" index="lcl.key">
				<cfset lcl.value = lcl.meta[lcl.key]>
				<tr>
					<th>#lcl.key#</th>
					<td class="#getDataType(lcl.value)#">#dumpData(lcl.value)#</td>
				</tr>
			</cfloop>
		</table>
		</cfoutput></cfsavecontent>

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="dumpMethod" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true">

		<cfset var lcl = StructNew() />
		<cfset lcl.meta = getMetaData(arguments.data) />

		<!--- Setup args with inspected defaults --->
		<cfset lcl.args = ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(lcl.meta.parameters)#" index="lcl.i">
			<cfset lcl.parameter = lcl.meta.parameters[lcl.i]>
			<cfif NOT StructKeyExists(lcl.parameter, "type")>
				<cfset lcl.parameter.type = "any" />
			</cfif>
			<cfif NOT StructKeyExists(lcl.parameter, "default")>
				<cfset lcl.parameter.default = "[undefined]" />
			</cfif>
			<cfif NOT StructKeyExists(lcl.parameter, "required")>
				<cfset lcl.parameter.required = false />
			</cfif>
			<cfif NOT StructKeyExists(lcl.parameter, "hint")>
				<cfset lcl.parameter.hint = "" />
			</cfif>
			<cfset ArrayAppend(lcl.args, lcl.parameter)>
		</cfloop>

		<cfsavecontent variable="lcl.result"><cfoutput>
			<table class="method dump">
				<tr>
					<th>#lcl.meta.name#</th>
					<td>
						<table class="arguments dump">
							<tr>
								<th>name</th>
								<th>type</th>
								<th>required</th>
								<th>default</th>
								<th>hint</th>
							</tr>
							<cfloop from="1" to="#ArrayLen(lcl.args)#" index="lcl.i">
								<cfset lcl.arg = lcl.args[lcl.i]>
								<tr>
									<td>#lcl.arg.name#</td>
									<td>#lcl.arg.type#</td>
									<td>#lcl.arg.required#</td>
									<td>#lcl.arg.default#</td>
									<td>#lcl.arg.hint#</td>
								</tr>
							</cfloop>
						</table>
					</td>
				</tr>
			</table>
		</cfoutput></cfsavecontent>

		<cfreturn lcl.result />
	</cffunction>

	<cffunction name="dumpCatch" access="public" returntype="string" output="false">
		<cfargument name="caught" type="any" required="true">

		<cfset var local = StructNew() />

		<cfset local.cght = arguments.caught />
		<cfsavecontent variable="local.result"><cfoutput>
			<div class="dump caught">
				<div>
					<p class="message">#local.cght.message#</p>
					<div class="detail">#local.cght.detail#</div>
					<cfif StructKeyExists( local.cght, "type")>
						<div class="type">
							<cfswitch expression="#local.cght.type#">
								<cfcase value="Database">
									<cfoutput>
										<dl class="database">
											<!-- <dt>queryError:</dt><dd class="message">#local.cght.queryError#</dd> -->
											<dt>SQL:</dt><dd class="source">#local.cght.Sql#</dd>
											<dt>WHERE:</dt><dd class="params">#local.cght.where#</dd>
										</dl>
									</cfoutput>
								</cfcase>
								<cfcase value="Application">
									<cfif StructKeyExists(local.cght, "func")>
										<cfoutput>
											Function: <strong>#local.cght.func#</strong><strong>@<em>#local.cght.templatePath#</em></strong>
										</cfoutput>
									</cfif>
								</cfcase>
								<cfcase value="Expression">
									<!--- No extra valueable content in cfcatch --->
								</cfcase>
								<cfcase value="missingInclude">
									<cfoutput>
										<cfdump var="#local.cght#">
									</cfoutput>
								</cfcase>
								<cfdefaultcase>
									<cfoutput>#local.cght.Type#</cfoutput>
									<!--- <cfdump var="#arguments.caught#"> --->
								</cfdefaultcase>
							</cfswitch>
						</div>
					</cfif>
					<cfif StructKeyExists( local.cght, "tagcontext") AND ArrayLen(local.cght.tagcontext)>
						<ul class="tagcontext">
							<cfloop from="1" to="#ArrayLen(local.cght.tagcontext)#" index="local.i">
								<cfset local.fnrx = "(.*?)(\$func([a-zA-Z0-9_]+?)\.)(.*)">
								<cfset local.trace = local.cght.tagcontext[local.i]>
								<li>#local.trace.template# (line:#local.trace.line#):
									<cfif StructKeyExists(local.trace, "raw_trace") AND REFindNoCase(local.fnrx, local.trace.raw_trace)>
										<strong class="function">#REReplaceNoCase(local.trace.raw_trace, local.fnrx, "\3")#</strong>
									<cfelse>
										<cfif StructKeyExists(local.trace, "type")>
											<strong><em>#local.trace.type#</em></strong>
										</cfif>
									</cfif>
								</li>
							</cfloop>
						</ul>
					<cfelseif StructKeyExists( local.cght, "stacktrace") >
						<div class="stacktrace">
							<cfoutput>#friendlyStackTrace(local.cght.stacktrace)#</cfoutput>
						</div>
					</cfif>
				</div>
			</div>
		</cfoutput></cfsavecontent>

		<cfreturn dumpData(local.result) />
	</cffunction>

	<cffunction name="friendlyStackTrace" output="false">
		<cfargument name="stacktrace" type="string" required="true">
		<cfreturn ArrayToList(
			REMatch(
				"\$func[A-Z0-9]{1,}.runFunction\(.*?[^\)]\)"
				, arguments.stacktrace
			)
			, "<br />"
		)>
	</cffunction>

	<cffunction name="getName">
		<cfargument name="targetObj"   type="any" required="true">
		<cftry>
			<cfreturn arguments.targetObj.getName()>
			<cfcatch type="any">
				<cfreturn "">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getNames">
		<cfargument name="targetArr" type="any"     required="true">
		<cfargument name="asList"    type="boolean" required="false" default="false">

		<cfset var lcl = StructNew()>
		<cfset lcl.result = ArrayNew(1)>
		<cftry>
			<cfloop from="1" to="#ArrayLen(arguments.targetArr)#" index="lcl.i">
				<cfset ArrayAppend(lcl.result, getName(arguments.targetArr[lcl.i]))>
			</cfloop>
			<cfcatch type="any">
				<cfreturn "">
			</cfcatch>
		</cftry>

		<cfif arguments.asList>
			<cfreturn ArrayToList(lcl.result)>
		<cfelse>
			<cfreturn lcl.result>
		</cfif>
	</cffunction>

	<cffunction name="getMethodList">
		<cfargument name="object" type="any" required="false" default="#variables.object#">
		<cfreturn getNames(arguments.object, true)>
	</cffunction>

	<cffunction name="getMethods">
		<cfargument name="object" type="any" required="false" default="#variables.object#">
		<cfreturn getNames(arguments.object)>
	</cffunction>

	<cffunction name="_dump" access="public" output="false" returntype="struct">
		<cfset var i = "">
		<cfset var j = "">
		<cfset var tmp ="">
		<cfset var ret = structnew()>
		<cfloop collection="#this#" item="i">
			<cfif lcase(left(i, 3)) EQ "get">
				<cftry>
					<cfinvoke component="#this#" method="#i#" returnvariable="tmp"/>
					<!--- if its an object, call its _dump() method --->
					<cfif isObject(tmp)>
						<cfset tmp = tmp._dump()>
					<!--- if its an array, call each elements dump method in turn --->
					<cfelseif isArray(tmp) AND structkeyexists(tmp[1], "_dump")>
						<cfloop from="1" to="#arraylen(tmp)#" index="j">
							<cfset tmp[j] = tmp[j]._dump()>
						</cfloop>
					</cfif>
					<cfset ret[replacenocase(i, "get", "")] = tmp>
					<cfcatch type="any">

					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		<cfreturn ret />
	</cffunction>

	<cffunction name="_dumpClass" access="public" output="false" returntype="struct" hint="dump defined methods from java class">
		<cfargument name="cls" type="any" hint="the CFdata">
		<cfargument name="typeConv" type="numeric" default="0">

		<cfset var lcl = StructNew()>

		<cfswitch expression="#arguments.typeConv#">
			<cfcase value="1">
				<!--- getByMetaData --->
				<cfset arguments.cls = getMetadata(arguments.cls).getClass()>
			</cfcase>
			<cfdefaultcase>
				<cfif IsQuery(arguments.cls)>
					<cfset arguments.cls = arguments.cls.getClass()>
				<cfelseif NOT _isClass(arguments.cls)>
					<cfset arguments.cls = arguments.cls.getClass()>
				</cfif>
			</cfdefaultcase>
		</cfswitch>

		<cfset lcl.cls = arguments.cls>
		<cfset lcl.result = StructNew()>

		<cfset lcl.result.name   = lcl.cls.getName()>
		<cfset lcl.result.fields = getNames(lcl.cls.getFields())>
		<cfset lcl.result.methods = _dumpMethods(lcl.cls.getMethods())>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="_dumpMethods" access="public" output="false" returntype="query" hint="dump java class">
		<cfargument name="meth" type="any">

		<cfset var lcl = StructNew()>

		<cfset lcl.result = ArrayNew(1)>

		<cfset lcl.m = arguments.meth>
		<cfloop from="1" to="#ArrayLen(lcl.m)#" index="lcl.i">
			<cfset lcl.mtemp = lcl.m[lcl.i]>
			<cfset lcl.st = StructNew()>
			<cfset lcl.st.name = lcl.mtemp.getName()>
			<cfset lcl.st.args = ArrayToList(getNames(lcl.mtemp.getParameterTypes()))>
			<cfset lcl.st.retv = lcl.mtemp.getReturnType().getName()>
			<cfset ArrayAppend(lcl.result, lcl.st)>
		</cfloop>

		<cfreturn _as2q(lcl.result)>
	</cffunction>

	<cffunction name="_dumpJavaMethods" access="public" output="false" returntype="query" hint="dump java class">
		<cfargument name="obj" type="any">
		<cfreturn _dumpMethods( arguments.obj.getClass().getMethods() )>
	</cffunction>


</cfcomponent>