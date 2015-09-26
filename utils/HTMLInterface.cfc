<cfcomponent extends="HTML">
	<cffunction name="init">
		<cfargument name="attr_qualifier"  required="false" type="any" default="34">
			<cfset setAutoFillFormFields(true) />
		<cfreturn super.init(arguments.attr_qualifier)>
	</cffunction>

	<cffunction name="getAutoFillFormFields">
		<cfif NOT StructKeyExists(variables, "autoFillFormFields")>
			<cfset setAutoFillFormFields(true) />
		</cfif>
		<cfreturn variables.autoFillFormFields />
	</cffunction>

	<cffunction name="setAutoFillFormFields">
		<cfargument name="flag"  required="false" type="boolean" default="true">
			<cfset variables.autoFillFormFields = arguments.flag />
		<cfreturn this />
	</cffunction>

	<cffunction name="getP">
		<cfreturn getParagraph(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayP">
		<cfoutput>#getP(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getH">
		<cfreturn getHeader(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayH">
		<cfoutput>#getH(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getA">
		<cfreturn getLink(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayA">
		<cfoutput>#getA(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getImage">
		<cfargument name="src"    required="true" type="string">
		<cfargument name="alt"    required="false" type="string" default="">
		<cfargument name="border" required="false" type="numeric" default="0">

		<cfset arguments.tag = "img">
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayImage">
		<cfoutput>#getImage(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getParagraph">
		<cfargument name="text"  required="true" type="any">
		<cfargument name="class" required="false" type="string" default="">

		<cfset arguments.tag  = "p">
		<cfset arguments.text = _getTextArg(arguments.text) />
		<cfreturn get(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="displayParagraph">
		<cfoutput>#getParagraph(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getForm">
		<cfargument name="action" required="false" type="string" default="" />
		<cfargument name="text"   required="false" type="any" default="" />
		<cfargument name="name"   required="false" type="string" default="" />
		<cfargument name="method" required="false" type="string" default="POST" />

		<cfset arguments.tag = "form">
		<cfset arguments.text = _getTextArg(arguments.text) />
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayForm">
		<cfoutput>#getForm(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getFieldset">
		<cfargument name="text"  required="true" type="any">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset arguments.tag = "fieldset">
		<cfif IsArray(arguments.text)>
			<cfset arguments.text = ArrayToList(arguments.text, chr(10))>
		</cfif>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayFieldset">
		<cfoutput>#getFieldset(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getLegend">
		<cfargument name="text"  required="true" type="string">

		<cfset arguments.tag = "legend">
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayLegend">
		<cfoutput>#getLegend(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getLink">
		<cfargument name="href"  required="false" type="string" default="##">
		<cfargument name="text"  required="false" type="string" default="">
		<cfset arguments.tag = "a">
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayLink">
		<cfoutput>#getLink(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getDiv">
		<cfargument name="text"  required="false" type="any" default="">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset arguments.tag = "div">
		<cfset arguments.text = _getTextArg(arguments.text) />
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayDiv">
		<cfoutput>#getDiv(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getSpan">
		<cfargument name="text"  required="true" type="any">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset arguments.tag = "span">
		<cfif IsArray(arguments.text)>
			<cfset arguments.text = ArrayToList(arguments.text, chr(10))>
		</cfif>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displaySpan">
		<cfoutput>#getSpan(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getDL">
		<cfargument name="text"  required="true" type="any">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset arguments.tag = "dl">
		<cfif IsArray(arguments.text)>
			<cfset arguments.text = ArrayToList(arguments.text, chr(10))>
		</cfif>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayDL">
		<cfoutput>#getDL(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getDT">
		<cfargument name="text"  required="true" type="any">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset arguments.tag = "dt">
		<cfif IsArray(arguments.text)>
			<cfset arguments.text = ArrayToList(arguments.text, chr(10))>
		</cfif>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayDT">
		<cfoutput>#getDT(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getDD">
		<cfargument name="text"  required="true" type="any">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset arguments.tag = "dd">
		<cfif IsArray(arguments.text)>
			<cfset arguments.text = ArrayToList(arguments.text, chr(10))>
		</cfif>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayDD">
		<cfoutput>#getDD(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="eachLI">
		<cfargument name="text"  required="true" type="array">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset var local = StructNew() />
		<cfset local.out = ArrayNew(1) />
		<cfloop from="1" to="#ArrayLen(arguments.text)#" index="local.i">
			<cfset ArrayAppend(local.out, getLI(argumentCollection=arguments, text=arguments.text[local.i]))>
		</cfloop>
		<cfreturn ArrayToList(local.out, chr(10)) />
	</cffunction>


	<cffunction name="getLI">
		<cfargument name="text"  required="true" type="any">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset arguments.tag = "li">
		<cfif IsArray(arguments.text)>
			<cfset arguments.text = ArrayToList(arguments.text, chr(10))>
		</cfif>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayLI">
		<cfoutput>#getLI(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getUL">
		<cfargument name="text"  required="true" type="any">
		<cfargument name="class" required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="">

		<cfset var local = StructNew() />
		<cfset arguments.tag = "ul">
		<cfif IsArray(arguments.text)>
			<cfset local.text = ArrayToList(arguments.text, chr(10))>
			<cfif NOT REFind("^<li", local.text)>
				<cfset arguments.text = eachLI(arguments.text, chr(10))>
			<cfelse>
				<cfset arguments.text = ArrayToList(local.text, chr(10))>
			</cfif>
		</cfif>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayUL">
		<cfoutput>#getUL(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getHeader">
		<cfargument name="text"  required="true" type="string">
		<cfargument name="level" required="false" type="numeric" default="1">
		<cfargument name="class" required="false" type="string" default="">

		<cfset arguments.tag = "h#arguments.level#">
		 <cfset StructDelete(arguments, "level")>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayHeader">
		<cfoutput>#getHeader(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getH2">
		<cfargument name="text"  required="true" type="string">
		<cfargument name="class" required="false" type="string" default="">

		<cfset arguments.level = 2>
		<cfreturn getHeader(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayH2">
		<cfoutput>#getH2(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getH3">
		<cfargument name="text"  required="true" type="string">
		<cfargument name="class" required="false" type="string" default="">

		<cfset arguments.level = 3>
		<cfreturn getHeader(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayH3">
		<cfoutput>#getH3(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getH4">
		<cfargument name="text"  required="true" type="string">
		<cfargument name="class" required="false" type="string" default="">

		<cfset arguments.level = 4>
		<cfreturn getHeader(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayH4">
		<cfoutput>#getH4(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getH5">
		<cfargument name="text"  required="true" type="string">
		<cfargument name="class" required="false" type="string" default="">

		<cfset arguments.level = 5>
		<cfreturn getHeader(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayH5">
		<cfoutput>#getH5(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getH6">
		<cfargument name="text"  required="true" type="string">
		<cfargument name="class" required="false" type="string" default="">

		<cfset arguments.level = 6>
		<cfreturn getHeader(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayH6">
		<cfoutput>#getH6(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getRadio">
		<cfargument name="name"    required="true"  type="string" default="">
		<cfargument name="id"      required="false"  type="string" default="#arguments.name#">
		<cfargument name="checked" required="false" type="boolean" default="false">

		<cfset arguments.type = "radio">
		<cfif arguments.checked>
			<cfset arguments.checked = "checked">
		<cfelse>
			<cfif getAutoFillFormFields() AND hasFormVar(arguments.name, false) AND getFormVar(arguments.name, false)>
				<cfset arguments.checked = "checked">
			<cfelse>
				<cfset StructDelete(arguments, "checked")>
			</cfif>
		</cfif>
		<cfreturn getInput(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayRadio">
		<cfoutput>#getRadio(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getInput">
		<cfargument name="name"  required="true"  type="string" default="">
		<cfargument name="value" required="false" type="string" default="">
		<cfargument name="type"  required="false" type="string" default="text">
		<cfargument name="id"    required="false"  type="string" default="#arguments.name#">

		<cfset var local = StructNew() />
		<cfset arguments.tag = "input">
		<cfif NOT StructKeyExists(arguments, "value") AND getAutoFillFormFields() AND hasFormVar(arguments.name)>
			<cfset arguments.value = getFormVar(arguments.name) />
		</cfif>

		<cfif StructKeyExists(arguments, "label")>
			<cfif StructKeyExists(arguments, "labelclass")>
				<cfset local.label = getLabel( for=arguments.id, text=arguments.label, class=arguments.labelclass ) >
				<cfset StructDelete( arguments, "labelclass") />
			<cfelse>
				<cfset local.label = getLabel( for=arguments.id, text=arguments.label ) >
			</cfif>
			<cfset StructDelete( arguments, "label") />

			<cfset local.labelright = false />
			<cfif StructKeyExists(arguments, "labelright")>
				<cfif arguments.labelright>
					<cfset local.labelright = true />
				</cfif>
				<cfset StructDelete( arguments, "labelright") />
			</cfif>
			<cfset local.input = get(argumentCollection=arguments) />
			<cfif local.labelright>
				<cfset local.input = local.input & local.label />
			<cfelse>
				<cfset local.input = local.label & local.input />
			</cfif>
		<cfelse>
			<cfset local.input = get(argumentCollection=arguments) />
		</cfif>

		<cfreturn local.input />
	</cffunction>

	<cffunction name="getTextarea">
		<cfargument name="name"  required="true"  type="string" default="">
		<cfargument name="value" required="false" type="string" default="">
		<cfargument name="cols"  required="false" type="string" default="">
		<cfargument name="rows"  required="false" type="string" default="">
		<cfargument name="id"    required="false" type="string" default="#arguments.name#">

		<cfset arguments.tag  = "textarea">

		<cfif NOT StructKeyExists(arguments, "value") AND getAutoFillFormFields() AND hasFormVar(arguments.name)>
			<cfset arguments.value = getFormVar(arguments.name) />
		</cfif>
		<cfset arguments.text = arguments.value>
		<cfset StructDelete(arguments, "value")>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayTextArea">
		<cfargument name="name"  required="true"  type="string" default="">
		<cfargument name="value" required="false" type="string" default="">
		<cfoutput>#getTextArea(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="displayInput">
		<cfoutput>#getInput(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getCheckbox">
		<cfargument name="name"    required="true"  type="string" default="">
		<cfargument name="checked" required="false" type="boolean" default="false">
		<cfargument name="id"      required="false" type="string" default="#arguments.name#">

		<cfset arguments.type = "checkbox">
		<cfif arguments.checked>
			<cfset arguments.checked = "checked">
		<cfelse>
			 <cfset StructDelete(arguments, "checked")>
		</cfif>
		<cfreturn getInput(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayCheckbox">
		<cfargument name="name"    required="true"  type="string" default="">
		<cfargument name="checked" required="false" type="boolean" default="false">
		<cfargument name="id"      required="false" type="string" default="#arguments.name#">

		<cfoutput>#getCheckbox(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getHidden">
		<cfargument name="name"  required="true"  type="string" default="">
		<cfargument name="value" required="false" type="string" default="">

		<cfset arguments.type = "hidden">
		<cfreturn getInput(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayHidden">
		<cfoutput>#getHidden(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getPassword">
		<cfargument name="name"  required="true"  type="string">
		<cfargument name="value" required="false" type="string" default="">
		<cfset arguments.type = "password">
		<cfreturn getInput(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayPassword">
		<cfoutput>#getPassword(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getSubmit">
		<cfargument name="value" required="false" type="string" default="">
		<cfargument name="name"  required="true"  type="string" default="btnSubmit">
		<cfset arguments.type = "submit">
		<cfreturn getInput(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displaySubmit">
		<cfoutput>#getSubmit(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getButton">
		<cfargument name="value" required="false" type="string" default="">
		<cfargument name="name"  required="true"  type="string" default="btnSubmit">
		<cfset arguments.type = "button">
		<cfreturn getInput(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayButton">
		<cfoutput>#getButton(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getLabel">
		<cfargument name="text" required="false" type="string" default="">
		<cfargument name="for"  required="false"  type="string" default="">
		<cfset arguments.tag = "label">
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayLabel">
		<cfoutput>#getLabel(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getPre">
		<cfargument name="text" required="false" type="string" default="">
		<cfargument name="for"  required="false"  type="string" default="">
		<cfset arguments.tag = "pre">
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displayPre">
		<cfoutput>#getPre(argumentCollection=arguments)#</cfoutput>
	</cffunction>


	<cffunction name="getSourceTextarea">
		<cfargument name="name"  required="true"  type="string" default="">
		<cfargument name="value" required="false" type="string" default="">
		<cfset arguments.value = HTMLEditFormat(Trim(arguments.value)) />
		<cfreturn getTextarea(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="displaySourceArea">
		<cfargument name="name"  required="true"  type="string" default="">
		<cfargument name="value" required="false" type="string" default="">
		<cfoutput>#getSourceTextarea(argumentCollection=arguments)#</cfoutput>
	</cffunction>


	<cffunction name="getOption">
		<cfargument name="value"    required="false" type="string"  default="">
		<cfargument name="text"     required="false" type="string"  default="#arguments.value#">
		<cfargument name="selected" required="false" type="boolean" default="false">

		<cfif arguments.selected>
			<cfset arguments.selected = "selected">
		<cfelse>
			 <cfset StructDelete(arguments, "selected")>
		</cfif>
		<cfset arguments.tag = "option">

		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="getSelect">
		<cfargument name="name" required="true"  type="string" default="">
		<cfargument name="text" required="true"  type="string" default="">
		<cfargument name="id"   required="false" type="string" default="#arguments.name#">

		<cfset arguments.tag = "select">
		<cfif StructKeyExists(arguments, "options") AND NOT Len(Trim(arguments.text))>
			<cfset arguments.data = arguments.options />
			<cfset StructDelete(arguments, "options") />
			<cfset arguments.text = getSelectOptionList(argumentCollection = arguments) />
			<cfset structDeleteList(arguments, "options,data,keylist,selected,empty,emptyvalue,emptytext,delimiter")>
		</cfif>
		<cfreturn get(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="displaySelect">
		<cfoutput>#getSelect(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="getSelectOptionList" returntype="string" hint="returns an string of HTML options used in select">
		<cfargument name="data"       required="true"   type="any"                     hint="any object that contains data">
		<cfargument name="keylist"    required="false"  type="string"  default=""      hint="struct: the keys to create pairs for; query: columns used for key and value in this order">
		<cfargument name="selected"   required="false"  type="string"  default=""      hint="the value for the selected option(s)">
		<cfargument name="empty"      required="false"  type="boolean" default="false" hint="empty option">
		<cfargument name="emptyvalue" required="false"  type="string"  default=""      hint="empty option value">
		<cfargument name="emptytext"  required="false"  type="string"  default=""      hint="empty option text">
		<cfargument name="delimiter"  required="false"  type="string"  default="#CHR(10)#"      hint="string to use as array to list delimiter">

		<cfset var local = StructNew()>
		<cfreturn ArrayToList(getSelectOptions(argumentCollection = arguments), arguments.delimiter)>
	</cffunction>

	<cffunction name="getSelectOptions" returntype="array" hint="returns an array of HTML options used in select">
		<cfargument name="data"       required="true"   type="any"                     hint="any object that contains data">
		<cfargument name="keylist"    required="false"  type="string"  default=""      hint="struct: the keys to create pairs for; query: columns used for key and value in this order">
		<cfargument name="selected"   required="false"  type="string"  default=""      hint="the value for the selected option(s)">
		<cfargument name="empty"      required="false"  type="boolean" default="false" hint="empty option">
		<cfargument name="emptyvalue" required="false"  type="string"  default="" hint="empty option value">
		<cfargument name="emptytext"  required="false"  type="string"  default="" hint="empty option text">

		<cfset var local = StructNew()>
		<!--- Option array to return --->
		<cfset local.options = ArrayNew(1)>
		<cfif IsQuery(arguments.data) AND arguments.keylist neq "">
			<cfset local.keycol = "">
			<cfset local.valcol = "">
			<cfif ListFindNoCase(arguments.data.columnlist, ListFirst(arguments.keylist))>
				<cfset local.keycol = ListFirst(arguments.keylist)>
			</cfif>
			<cfif ListFindNoCase(arguments.data.columnlist, ListLast(arguments.keylist))>
				<cfset local.valcol = ListLast(arguments.keylist)>
			</cfif>
			<cfif local.keycol eq "" OR local.valcol eq "">
				<cfreturn _getErrorArr("select options from query")>
			<cfelse>
				<cfloop query="arguments.data">
					<cfset ArrayAppend(
						  local.options
						, getOption(
							  value=arguments.data[local.keycol][currentrow]
							, text=arguments.data[local.valcol][currentrow]
							, selected=(arguments.data[local.keycol][currentrow] eq arguments.selected)
						)
					)>
				</cfloop>
			</cfif>
		<cfelseif IsStruct(arguments.data)>
			<cfif NOT ListLen(arguments.keylist)>
				<cfset arguments.keylist = StructKeyList(arguments.data)>
			</cfif>
			<cfloop list="#arguments.keylist#" index="local.thiskey">
				<cfif StructKeyExists(arguments.data, local.thiskey) AND IsSimpleValue(arguments.data[local.thiskey])>
					<cfset ArrayAppend(
						  local.options
						, getOption(
							  value=local.thiskey
							, text=arguments.data[local.thiskey]
							, selected=(local.thiskey eq arguments.selected)
						)
					)>
				</cfif>
			</cfloop>
		<cfelseif IsArray(arguments.data)>
		<cfelseif IsSimpleValue(arguments.data)>
			<cfloop list="#arguments.data#" index="local.value">
				<cfset ArrayAppend(
						  local.options
						, getOption(
							  value=local.value
							, text=local.value
							, selected=(local.value eq arguments.selected)
						)
					)>
			</cfloop>
		</cfif>

		<cfif arguments.empty OR Len(arguments.emptyvalue) OR Len(arguments.emptytext)>
			<cfset ArrayPrepend(local.options, getOption(arguments.emptyvalue, arguments.emptytext))>
		</cfif>

		<cfreturn local.options>
	</cffunction>

	<cffunction name="getSVG">
		<cfargument name="data" required="true" type="string" hint="relative path to svg image">
		<cfargument name="name" required="false" type="string"  default="" hint="name for object">
		<cfargument name="width" required="false" type="string"  hint="width for object">
		<cfargument name="height" required="false" type="string"  hint="height for object">

		<cfset arguments.tag = "object">
		<cfset arguments.type="image/svg+xml">

		<cfreturn get(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="displaySVG">
		<cfargument name="data" required="true" type="string" hint="relative path to svg image">
		<cfargument name="name" required="false" type="string"  default="" hint="name for object">
		<cfargument name="width" required="false" type="string"  hint="width for object">
		<cfargument name="height" required="false" type="string"  hint="height for object">

		<cfoutput>#getSVG(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="_getErrorString">
		<cfargument name="message"  required="true" type="string">
		<cfreturn "Error occurred: #arguments.message#">
	</cffunction>

	<cffunction name="_getErrorArr">
		<cfargument name="message"  required="true" type="string">
		<cfset var local = ArrayNew(1)>
		<cfset ArrayAppend(local, _getErrorString(argumentCollection = arguments))>
		<cfreturn local>
	</cffunction>
</cfcomponent>