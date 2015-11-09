<cfcomponent extends="cfc.utils.HTMLInterface" displayname="Taconite3" output="false" hint="CFC Wrapper for taconite 3">
	<cffunction name="init" returntype="Taconite3" output="false" hint="Initialises Taconite3">
			<cfset variables.attrib = StructCreate() />
		<cfreturn this />
	</cffunction>

	<cffunction name="setSelector" returntype="struct" output="false" hint=" Append the specified content to the specified element(s).">
		<cfargument name="selector" type="string" required="true" />
			<cfset variables.attrib = StructCreate( selector = arguments.selector )>
		<cfreturn this />
	</cffunction>

	<cffunction name="setContextNode" access="public" output="false" returntype="any">
		<cfargument name="contextnode" type="string" required="true" />
			<cfset variables.attrib = StructCreate( contextNodeID = arguments.contextnode, matchmode = "plain" )  />
		<cfreturn this>
	</cffunction>

	<cffunction name="setData" returntype="struct" output="false" hint=" Append the specified content to the specified element(s).">
		<cfargument name="data" type="string" required="true" />
			<cfset _setTagOutputBuffer( arguments.data )>
		<cfreturn this />
	</cffunction>

	<cffunction name="getSelector" returntype="struct" output="false" hint=" Append the specified content to the specified element(s).">
		<cfreturn variables.attrib />
	</cffunction>

	<cffunction name="getOutput" output="false" access="public" returntype="string" hint="Sets or appends the output ">
		<cfreturn REReplace( _getTextArg( _getOutputBuffer() ), "contextnodeid", "contextNodeID", "ALL") />
	</cffunction>

	<cffunction name="showOutput" output="true" access="public" returntype="any" hint="Sets or appends the output ">
		<cfoutput>#getOutput()#</cfoutput>
	</cffunction>

	<cffunction name="displayOutput" output="true" access="public" returntype="any" hint="Sets or appends the output ">
		<cfset showOutput() />
	</cffunction>

	<cffunction name="getTagContent" returntype="string" output="false" hint=" Append the specified content to the specified element(s).">
		<cfreturn _getTextArg(_getTagOutputBuffer()) />
	</cffunction>

	<cffunction name="addTag" returntype="any" output="false" hint=" Append the specified content to the specified element(s).">
		<cfargument name="content" type="string" required="true" hint="string to append to outputbuffer" />
		<cfreturn _setOutputBuffer(arguments.content) />
	</cffunction>

	<cffunction name="getTacoTag" returntype="any" output="false" hint=" Append the specified content to the specified element(s).">
		<cfargument name="tag"  type="string" required="true">
		<cfargument name="text" type="string" required="false">
		<cfargument name="attr" type="struct" required="false">
		<cfargument name="textmode" type="string" required="false" default="prepend" hint="where to add the given extra text: prepend|append|flush">

		<cfset var lcl = StructNew() />

		<!--- set --->
		<cfset lcl.tag = arguments.tag />
		<cfset lcl.text = _getTagContent() />
		<cfif StructKeyExists(arguments, "text")>
			<cfswitch expression="#arguments.textmode#">
				<cfcase value="prepend">
					<cfset lcl.text = arguments.text & lcl.text />
				</cfcase>
				<cfcase value="append">
					<cfset lcl.text = lcl.text & arguments.text />
				</cfcase>
				<cfcase value="flush">
					<cfset lcl.text = "" />
				</cfcase>
			</cfswitch>
		</cfif>
		<cfif StructKeyExists(arguments, "attr")>
			<cfset lcl.attr = arguments.attr />
		<cfelse>
			<cfset lcl.attr =  getSelector() />
		</cfif>

		<cfreturn super.get(argumentCollection = local) />
	</cffunction>

	<cffunction name="needCDATA" returntype="boolean" output="false" hint=" Append the specified content to the specified element(s).">
		<cfreturn StructKeyExists(getSelector(), "selector") />
	</cffunction>

	<cffunction name="appendChildren" returntype="any" output="false" hint=" Append the specified content to the specified element(s).">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />
		<cfreturn addTag(getTacoTag("taconite-append-as-children")) />
	</cffunction>

	<cffunction name="firstChild" returntype="any" output="false" hint=" Append the specified content to the specified element(s).">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />

		<cfreturn addTag(getTacoTag("taconite-append-as-first-child")) />
	</cffunction>

	<cffunction name="delete">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />

		<cfreturn addTag(getTacoTag(tag="taconite-delete", text="", textmode="flush")) />
	</cffunction>

	<cffunction name="insertAfter">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />

		<cfreturn addTag(getTacoTag("taconite-insert-after")) />
	</cffunction>

	<cffunction name="insertBefore">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />

		<cfreturn addTag(getTacoTag("taconite-insert-before")) />
	</cffunction>

	<cffunction name="replaceChildren">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />

		<cfreturn addTag(getTacoTag("taconite-replace-children")) />
	</cffunction>

	<cffunction name="replaceElement">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />

		<cfreturn addTag(getTacoTag("taconite-replace")) />
	</cffunction>

	<cffunction name="execjs">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />
		<!--- No attributes execption --->
		<cfreturn addTag( getTacoTag(tag="taconite-execute-javascript", attr=StructNew())) />
	</cffunction>

	<cffunction name="setattrib">
		<cfargument name="data"     required="false"  type="string" hint="string to add" />
		<cfargument name="selector" required="false"  type="string" hint="selector to use" />
		<cfargument name="isContextNodeSelector" required="false"  type="boolean" default="true" hint="contextNodeId or jQuery-selector, defaults to contextNodeId" />

		<cfset _parseTagArguments( arguments ) />

		<cfreturn addTag(getTacoTag("taconite-set-attributes")) />
	</cffunction>

	<cffunction name="redirect">
		<cfreturn addTag(getTacoTag("taconite-redirect") ) />
	</cffunction>

	<cffunction name="_parseTagArguments" output="false" access="public" returntype="any" hint="Sets or appends the output ">
		<cfargument name="orgArgs" required="true"  type="struct" hint="original argument collection" />

		<cfif StructKeyExists(arguments.orgArgs, "data")>
			<cfset setData(arguments.orgArgs.data) />
		</cfif>

		<cfif StructKeyExists(arguments.orgArgs, "selector") AND StructKeyExists(arguments.orgArgs, "isContextNodeSelector")>
			<cfif arguments.orgArgs.isContextNodeSelector>
				<cfset setContextNodeID(arguments.orgArgs.selector) />
			<cfelse>
				<cfset setSelector(arguments.orgArgs.selector) />
			</cfif>
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="_getTagContent" returntype="string" output="false" hint=" Append the specified content to the specified element(s).">
		<cfset var lcl = StructNew() />
		<cfset lcl.str = _getTextArg(_getTagOutputBuffer()) />
		<cfif needCDATA()>
			<cfset lcl.str = getCDATA(lcl.str) />
		</cfif>
		<cfset _resetTagOutputBuffer() />
		<cfreturn lcl.str />
	</cffunction>

	<cffunction name="_getTagOutputBuffer" output="false" access="public" returntype="array" hint="Sets or appends the output ">
		<cfif NOT StructKeyExists( variables, "tagOutput")>
			<cfset _resetTagOutputBuffer() />
		</cfif>
		<cfreturn variables.tagOutput />
	</cffunction>

	<cffunction name="_setTagOutputBuffer" output="false" access="private" returntype="any"  hint="Sets or appends the output ">
		<cfargument name="output" type="string" required="true" hint="string or array to append to output" />
			<cfset ArrayAppend( _getTagOutputBuffer(), arguments.output ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="_resetTagOutputBuffer" output="false" access="private" returntype="any"  hint="Sets or appends the output ">
		<cfset variables.tagOutput = ArrayCreate() />
		<cfreturn this />
	</cffunction>

	<cffunction name="_getOutputBuffer" output="false" access="public" returntype="array" hint="Sets or appends the output buffer">
		<cfif NOT StructKeyExists( variables, "outputBuffer")>
			<cfset _resetOutputBuffer() />
		</cfif>
		<cfreturn variables.outputBuffer />
	</cffunction>

	<cffunction name="_setOutputBuffer" output="false" access="private" returntype="any"  hint="Sets or appends the output buffer">
		<cfargument name="outputBuffer" type="string" required="true" hint="string or array to append to outputbuffer" />
			<cfset ArrayAppend( _getOutputBuffer(), arguments.outputBuffer ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="_resetOutputBuffer" output="false" access="private" returntype="any"  hint="Sets or appends the output buffer">
		<cfset variables.outputBuffer = ArrayCreate() />
		<cfreturn this />
	</cffunction>
</cfcomponent>
<!---

================================================================================
AVAILABLE ACTIONS
================================================================================

These are the available actions:

1.  taconite-append-as-children:  Append the specified content to the specified
element(s).

Example:
<taconite-append-as-children selector="body">
    <![CDATA[
        <p>End of page.</p>
    ]]>
</taconite-append-as-children>


2.  taconite-append-as-first-child:  Append the specified content as the first
child(ren) of the specified element(s).

Example:
<taconite-append-as-first-child selector="body">
    <![CDATA[
        <p>Start of page.</p>
    ]]>
</taconite-append-as-first-child>


3.  taconite-insert-before:  Append the specified content before the specified
element(s).

Example:
<taconite-insert-before selector="#item1">
    <![CDATA[
        <li>Now I am the first item!</li>
    ]]>
</taconite-insert-before>


4.  taconite-insert-after:  Append the specified content after the specified
element(s).

Example:
<taconite-insert-after selector="#item1">
    <![CDATA[
        <li>Now I am the second item.</li>
    ]]>
</taconite-insert-after>


5.  taconite-replace-children:  Replace all child elements of the specified
element(s) with the specified content.

Example:
<taconite-replace-children selector=".titles">
    <![CDATA[
        <option value="mr">Mr.</option>
        <option value="mrs">Mrs.</option>
        <option value="ms">Ms.</option>
    ]]>
</taconite-replace-children>


6.  taconite-replace:  Completely replace the specified element(s) with the
specified content.

Example:
<taconite-replace selector="#messages">
    <![CDATA[
        <p>I replaced an element that had an ID of "messsages".</p>
    ]]>
</taconite-replace>


7.  taconite-set-attributes:  Set the attribute values on the specified DOM
elements.

Example:
<taconite-set-attributes selector=".link" href="http://taconite.sf.net" rel="newvalue" />


8.  taconite-execute-javascript:  Execute/evaluate the specified JavaScript.

Example:

Example:
<taconite-execute-javascript>
    <![CDATA[
        alert("hello!!");
    ]]>
</taconite-execute-javascript>


9.  taconite-redirect:  Redirect the browser to the specified URL.

Example:
<taconite-redirect targetUrl="http://taconite.sf.net" />


10.  taconite-delete:  Delete the specfied elements from the DOM.

Example:
<taconite-delete selector=".buttons" /> --->