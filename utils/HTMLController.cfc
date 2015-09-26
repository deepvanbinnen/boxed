<cfcomponent extends="HTMLInterface">
	<cfset variables.mode   = "flush">
	<cfset variables.modes  = "flush,capture">
	<cfset variables.output = "">
	<cfset variables.stack  = QueryNew("tag,attr")>
	<cfset variables.captured = ArrayNew(1)>
	
	
	<cfset variables.field = StructNew()>
	<cfset variables.field.html      = "">
	<cfset variables.field.formfield = "">
	<cfset variables.field.label     = "">
	<cfset variables.field.options   = "">
	<cfset variables.field.submit    = "">
	<cfset variables.activefield = "">
	
	
	<cffunction name="textfield">
		<cfargument name="id"    type="string" required="true">
		<cfargument name="label" type="string" required="false" default="">
		
		<cfset var local = StructNew()>
		<cfset variables.field.label     = getLabel(text=arguments.label, for=arguments.id)>
		<cfset StructDelete(arguments, "label")>
		<cfset variables.field.formfield = getInput(argumentCollection = arguments, name=arguments.id)>
		<cfset variables.field.html      = variables.field.label & variables.field.formfield>
		<cfset variables.activefield = "html">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="selectfield">
		<cfargument name="id"      type="string" required="true">
		<cfargument name="label"   type="string" required="false" default="">
		<cfargument name="options" type="any"    required="false" default="a,b,c">
		<cfargument name="selected" type="string" required="false" default="">
		
		<cfset var local = StructNew()>
		<cfset variables.field.label     = getLabel(text=arguments.label, for=arguments.id)>
		<cfset StructDelete(arguments, "label")>
		<cfset variables.field.options = getSelectOptions(data = arguments.options, selected = arguments.selected)>
		<cfset StructDelete(arguments, "options")>
		<cfset StructDelete(arguments, "selected")>
		<cfset variables.field.formfield = getSelect(argumentCollection = arguments, name=arguments.id, text = ArrayToList(variables.field.options, CHR(10)))>
		<cfset variables.field.html      = variables.field.label & variables.field.formfield>
		<cfset variables.activefield = "html">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="submitbutton">
		<cfargument name="value" type="string" required="true">
		<cfargument name="id"    type="string" required="false" default="btnSubmit">
		
		<cfset var local = StructNew()>
		<cfset variables.field.formfield = getInput(argumentCollection = arguments, type="submit", name=arguments.id)>
		<cfset variables.activefield = "formfield">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="field">
		<cfset variables.activefield = "html">
		<cfset setActiveField(variables.field.label & variables.field.formfield)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="label">
		<cfset variables.activefield = "label">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="formfield">
		<cfset variables.activefield = "formfield">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getActiveField">
		<cfif StructKeyExists(variables.field, variables.activefield)>
			<cfreturn  variables.field[variables.activefield]>
		</cfif>
		<cfreturn "">
	</cffunction>
	
	<cffunction name="setActiveField">
		<cfargument name="value" type="string" required="false" default="">
		<cfargument name="activefield" type="string" required="false" default="#variables.activefield#">
		
		<cfset variables.activefield = arguments.activefield>
		<cfif StructKeyExists(variables.field, variables.activefield)>
			<cfset variables.field[variables.activefield] = arguments.value>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="wrapit">
		<cfset var local = Structnew()>
			<cfset setActiveField( 
				value = get(
					  argumentCollection = arguments
					, text = getActiveField()
				)
			)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="tag">
		<cfset setActiveField(get(argumentCollection = arguments), "html")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="tagc">
		<cfif html() neq "">
			<cfset capture()>
		</cfif>
		<cfreturn tag(argumentCollection = arguments)>
	</cffunction>
	
	<cffunction name="flush">
		<cfoutput>#getOutput()#</cfoutput>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="html">
		<cfreturn getActiveField()>
	</cffunction>
	
	<cffunction name="capture">
		<cfargument name="output" type="string" required="false" default="#html()#">
			<cfset ArrayAppend(variables.captured, arguments.output)>
			<cfset setActiveField(value = "")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="wrapCapture">
		<cfset var local = Structnew()>
			<cfset setActiveField( 
				value = get(
					  argumentCollection = arguments
					, text = getCapturedHTML()
				)
			)>
			<cfset variables.captured = ArrayNew(1)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getCaptured">
		<cfreturn variables.captured>
	</cffunction>
	
	<cffunction name="getCapturedHTML">
		<cfreturn ArrayToList(getCaptured(), CHR(10))>
	</cffunction>
	
	<cffunction name="getOutput">
		<cfreturn getCapturedHTML()>
	</cffunction>
	
	<cffunction name="setOutput">
		<cfargument name="output" type="string" required="false" default="#variables.output#">
		
		<cfset var local = StructNew()>
		<cfset variables.output = arguments.output>
		<cfloop from="1" to="#variables.stack.recordcount#" step="-1" index="local.i">
			<cfset variables.output = get(variables.stack["tag"][local.i], variables.stack["attr"][local.i], variables.output)>
		</cfloop>
		
		<cfif variables.mode eq "flush">
			<cfset flush()>
		<cfelse>
			<cfset capture()>
		</cfif>
	</cffunction>
	
	<cffunction name="getC">
		<cfargument name="tag" type="string" required="true">
		<cfargument name="attr" type="string" required="false" default="">
		
		<cfif NOT StructKeyExists(arguments, "text")>
			<cfset QueryAddRow(variables.stack)>
			<cfset QuerySetCell(variables.stack, "tag", arguments.tag)>
			<cfset QuerySetCell(variables.stack, "attr", arguments.attr)>
		<cfelse>	
			<cfset setOutput(super.get(argumentCollection=arguments))>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setFlush">
		<cfset variables.mode   = "flush">
	</cffunction>
	
	 <cffunction name="setCapture">
		<cfset variables.mode   = "capture">
	</cffunction>
	
	
</cfcomponent>