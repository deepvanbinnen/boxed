<cfcomponent extends="cfc.commons.AbstractObject" output="false" hint="I am the base component for generating HTML/XML based on arguments">
	<cfset variables.ATTR_QUAL  = 34><!--- defaults to doublequote --->
	<cfset variables.SELF_CLOSE = "textarea,strong,em,a,h1,h2,h3,h4,h5,h6,p,div,span,option"><!--- list of html tags that need a closing tag even if body text is empty --->

	<cffunction name="init">
		<cfargument name="qualifier"  required="false" type="any" default="#variables.ATTR_QUAL#">

		<cfif IsSimpleValue(arguments.qualifier)>
			<cfif IsNumeric(arguments.qualifier)>
				<cfset variables.ATTR_QUAL = arguments.qualifier>
			<cfelse>
				<cfset variables.ATTR_QUAL = Left(arguments.qualifier,1)>
			</cfif>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="get" hint="converts arguments and creates a full HTML tag based on tag attribute struct and body">
		<cfargument name="tag"  required="true"  type="string">
		<cfargument name="text" required="false" type="any" default="">
		<cfargument name="attr" required="false" type="any"    default="">

		<cfset var lcl = StructNew()>
		<cfset lcl.attr = getArgAttribs(arguments)>

		<cfreturn getHTML(LCASE(arguments.tag), _getTextArg(arguments.text), getAttribString(lcl.attr))>
	</cffunction>

	<cffunction name="write" output="true" hint="outputs html passing arguments to the get method">
		<cfset writeHTML( get(argumentCollection = arguments) ) />
	</cffunction>

	<cffunction name="writeHTML" output="true" hint="outputs html passing arguments to the get method">
		<cfargument name="text" required="false" type="string" default="">
		<cfoutput>#arguments.text#</cfoutput>
	</cffunction>

	<cffunction name="getArgAttribs" hint="get a struct of attributes based on a given arguments structure">
		<cfargument name="orgArgs" type="struct" required="true">

		<cfset var local      = StructNew()>
		<cfset lcl.skip     = "tag,text">
		<cfset lcl.attrName = "attr">
		<cfset lcl.attrIdx  = "2">
		<cfset lcl.attribs  = StructNew()>

		<cfloop collection="#arguments.orgArgs#" item="lcl.key">
			<!--- Check for attr argument --->
			<cfif (IsNumeric(lcl.key) AND lcl.key eq lcl.attrIdx) OR lcl.key eq lcl.attrName>
				<cfif IsSimpleValue(arguments.orgArgs[lcl.key]) AND NOT arguments.orgArgs[lcl.key] eq "">
					<!---
					Bail out immediately if given attribs are string and contain a value
					Processing this type is way too complex
					--->
					<cfreturn arguments.orgArgs[lcl.key]>
				<cfelseif IsStruct(arguments.orgArgs[lcl.key])>
					<cfset StructAppend(lcl.attribs, arguments.orgArgs[lcl.key], true)>
				</cfif>
			<!--- Check for arguments other than [tag,text,attr] --->
			<cfelseif NOT ListFindNoCase(lcl.skip, lcl.key)>
				<cfset StructInsert(lcl.attribs, lcl.key, arguments.orgArgs[lcl.key], FALSE)>
			</cfif>
		</cfloop>
		<cfreturn lcl.attribs>
	</cffunction>

	<cffunction name="getAttribString" hint="get a tag's attributes string from struct">
		<cfargument name="attribs"   required="false" type="any" default="">
		<cfargument name="delimiter" required="false" type="string" default=" ">

		<cfset var local  = StructNew()>
		<cfset lcl.attr = ArrayNew(1)>
		<cfif IsSimpleValue(arguments.attribs)>
			<cfset ArrayAppend(lcl.attr,arguments.attribs)>
		<cfelseif IsStruct(arguments.attribs)>
			<cfloop collection="#arguments.attribs#" item="lcl.key">
				<cfif IsSimpleValue(arguments.attribs[lcl.key]) AND (arguments.attribs[lcl.key] neq "" OR lcl.key EQ "value")>
					<cfset ArrayAppend(lcl.attr, getPair(lcl.key, arguments.attribs[lcl.key]))>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn ArrayToList(lcl.attr, arguments.delimiter)>
	</cffunction>

	<cffunction name="getHTML" hint="return a XHTML/XML tag string based on given arguments">
		<cfargument name="tag"  required="true"  type="string">
		<cfargument name="text" required="false" type="string" default="">
		<cfargument name="attr" required="false" type="string" default="">

		<cfset var lcl = StructNew()>
		<cfset lcl.html = ArrayNew(1)>

		<!--- Open tag --->
		<cfset ArrayAppend(lcl.html, "<")>
		<cfset ArrayAppend(lcl.html, arguments.tag)>

		<!--- Set attributes --->
		<cfif arguments.attr neq "">
			<cfset ArrayAppend(lcl.html, " ")>
			<cfset ArrayAppend(lcl.html, arguments.attr)>
		</cfif>

		<!--- Determine closing and close tag --->
		<cfif arguments.text neq "" OR ListFindNoCase(variables.SELF_CLOSE,arguments.tag)>
			<cfset ArrayAppend(lcl.html, ">")>
			<cfset ArrayAppend(lcl.html, arguments.text)>
			<cfset ArrayAppend(lcl.html, "</")>
			<cfset ArrayAppend(lcl.html, arguments.tag)>
			<cfset ArrayAppend(lcl.html, ">")>
		<cfelse>
			<cfset ArrayAppend(lcl.html, " />")>
		</cfif>
		<cfreturn ArrayToList(lcl.html,"")>
	</cffunction>

	<cffunction name="getPair" hint="return a key-value-string suitable for use in tag attributes">
		<cfargument name="key"   required="true"  type="string">
		<cfargument name="value" required="false" type="string" default="">

		<cfreturn LCASE(arguments.key) & "=" & CHR(variables.ATTR_QUAL) & arguments.value & CHR(variables.ATTR_QUAL)>
	</cffunction>

	<cffunction name="getCDATA" hint="return a key-value-string suitable for use in tag attributes">
		<cfargument name="string"   required="true"  type="string">

		<cfreturn "<![CDATA[ " & CHR(10) & arguments.string & CHR(10) & " ]]>" />
	</cffunction>


	<cffunction name="_getTextArg">
		<cfargument name="text"  required="true" type="any" hint="the passed text argument">

		<cfif IsArray(arguments.text)>
			<cfset arguments.text = ArrayToList(arguments.text, chr(10))>
		</cfif>

		<cfreturn arguments.text />
	</cffunction>

</cfcomponent>