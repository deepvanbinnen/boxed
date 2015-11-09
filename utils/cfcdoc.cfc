<cfcomponent hint="I generate documentation for the given CFC" extends="utils">
	<cfset __constructor(
	 	  cfc     = this
		, pdfname = createUUID() & ".pdf"
		, maxdepth = "-1"
	)>

	<cffunction name="init" access="public" output="false" returntype="any" hint="initialise with a cfc and">
		<cfargument name="cfc" type="any" required="false" default="#getCFC()#">
		<cfargument name="pdfname" type="string" required="false" default="#getPDFName()#">
		<cfargument name="maxdepth" type="string" required="false" default="#getMaxDepth()#">

			<cfset setCFC(arguments.cfc)>
			<cfset setPDFName(arguments.pdfname)>
			<cfset setMaxDepth(arguments.maxdepth)>

		<cfreturn this>
	</cffunction>

	<cffunction name="getCFC"  returntype="any" hint="getter for cfc">
		<cfreturn variables.cfc>
	</cffunction>

	<cffunction name="getPDFName"  returntype="string" hint="getter for pdf-name">
		<cfreturn variables.pdfname>
	</cffunction>

	<cffunction name="getMaxDepth"  returntype="numeric" hint="gets maximum depth the documenter follows extension">
		<cfreturn variables.maxdepth>
	</cffunction>

	<cffunction name="setCFC" returntype="any" hint="setter for cfc, returns this">
		<cfargument name="cfc" type="any" required="true" hint="a cfc instance">

			<cfif _isCFC(arguments.cfc)>
				<cfset variables.cfc = arguments.cfc>
			<cfelse>
				<cftry>
					<cfset variables.cfc = createObject("component", arguments.cfc)>
					<cfcatch type="any">
						<cfdump var="#arguments#">
						<cfdump var="#cfcatch#"><cfabort>
						<!--- <cfthrow message="Invalid CFC #arguments.cfc#" detail="#arguments.cfc.toString()#"> --->
					</cfcatch>
				</cftry>
			</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setPDFName" returntype="any" hint="setter for pdf-name, returns this">
		<cfargument name="pdfname" type="string" required="true">
			<cfif arguments.pdfname neq "">
				<cfset variables.pdfname = arguments.pdfname>
			<cfelse>
				<cfset variables.pdfname = _getName(getCFC()) & ".pdf">
			</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setMaxDepth" returntype="any" hint="setter for pdf-name, returns this">
		<cfargument name="maxdepth" type="numeric" required="true">
			<cfset variables.maxdepth = arguments.maxdepth>
		<cfreturn this>
	</cffunction>

	<cffunction name="getPDF" returntype="Any" hint="create PDF with given filename for the documenation html">
		<cfargument name="cfc" type="any" required="false" default="#getCFC()#">
		<cfargument name="pdfname" type="string" required="false" default="#getPDFName()#">
		<cfargument name="maxdepth" type="string" required="false" default="#getMaxDepth()#">

		<cfset setCFC(arguments.cfc)>
		<cfset setPDFName(arguments.pdfname)>
		<cfset setMaxDepth(arguments.maxdepth)>

		<cfdocument format="PDF" saveAsName="#getPDFName()#">
			<cfoutput>
				<style type="text/css">
				html, body, div, span, applet, object, iframe,
				h1, h2, h3, h4, h5, h6, p, blockquote, pre,
				a, abbr, acronym, address, big, cite, code,
				del, dfn, em, font, img, ins, kbd, q, s, samp,
				small, strike, strong, sub, sup, tt, var,
				dl, dt, dd, ol, ul, li,
				fieldset, form, label, legend,
				table, caption, tbody, tfoot, thead, tr, th, td{
				  font-family:Verdana, Arial, Helvetica, sans-serif;
				}

				div {margin: 1em 0; font-size: 1em;}
				table {border: 1px solid black; border-width: 1px 0 0 1px; border-collapse: collapse;  margin: 0; padding: 0;}
				th, td {border: 1px solid black; border-width: 0 1px 1px 0; text-align: left; vertical-align: top; margin: 0; padding: 0.4em 0.5em;}
				table table, table table th, table table td{border-width: 0;}
				table table th, table table td{font-size: 100%;}
				span.runtime-expression{font-size: 80%;}
				/* table td.params, table td.params table.params td.default {width: 100%;}*/
				</style>
				#pf().freetheSource(_getHTML()).get()#
			</cfoutput>
		</cfdocument>
	</cffunction>

	<cffunction name="getHTML" returntype="string" hint="generate the documenation html">
		<cfargument name="cfc" type="any" required="false" default="#getCFC()#">
		<cfargument name="maxdepth" type="string" required="false" default="#getMaxDepth()#">

			<cfset setCFC(arguments.cfc)>
			<cfset setMaxDepth(arguments.maxdepth)>

		<cfreturn _getHTML()>
	</cffunction>

	<cffunction name="getStory" returntype="string" hint="generate the documenation html">
		<cfargument name="cfc" type="any" required="false" default="#getCFC()#">
		<cfargument name="maxdepth" type="string" required="false" default="#getMaxDepth()#">

			<cfset setCFC(arguments.cfc)>
			<cfset setMaxDepth(arguments.maxdepth)>

		<cfreturn _getStory()>
	</cffunction>

	<cffunction name="displayDocs" returntype="any" output="true" access="remote" hint="generate the documenation html">
		<cfargument name="cfc" type="any" required="false" default="#getCFC()#">
		<cfargument name="maxdepth" type="string" required="false" default="#getMaxDepth()#">

		<cfoutput>#getStory(argumentCollection=arguments)#</cfoutput>
	</cffunction>

	<cffunction name="_getMethodAsRow" returntype="string" hint="gets documentation for method rendered as tablerow">
		<cfargument name="meth" type="any" required="true" hint="introspected method struct">

		<cfset var lcl = StructCreate(meth = arguments.meth, pars = iterator(arguments.meth.parameters), result = "")>

		<cfsavecontent variable="localvar.result">
			<cfoutput>
				<tr id="#localvar.meth.name#">
					<td class="name">#localvar.meth.name#</td>
					<td class="params">
						<cfif localvar.pars.getLength()>
							<table class="params" cellpadding="0" cellspacing="0">
							<cfloop condition="#localvar.pars.whileHasNext()#">
								<cfif localvar.pars.getIndex() MOD 2>
									<cfset localvar.param_row_class = "odd">
								<cfelse>
									<cfset localvar.param_row_class = "even">
								</cfif>
								<cfif localvar.pars.getIndex() eq 1>
									<cfset localvar.param_row_class = ListAppend(localvar.param_row_class, "first", " ")>
								</cfif>
								<cfif localvar.pars.getIndex() eq localvar.pars.getLength()>
									<cfset localvar.param_row_class = ListAppend(localvar.param_row_class, "last", " ")>
								</cfif>
								<tr class="#localvar.param_row_class#">
									<td class="name">#localvar.pars.getCurrent().name#</td>
									<td class="datatype">#localvar.pars.getCurrent().type#</td>
									<td class="required">#localvar.pars.getCurrent().required#</td>
									<td class="default">
										<cfif localvar.pars.getCurrent().default neq "[runtime expression]">
											#localvar.pars.getCurrent().default#
										<cfelse>
											<span class="runtime-expression">#localvar.pars.getCurrent().default#</span>
										</cfif>
									</td>
									<td class="hint">#localvar.pars.getCurrent().hint#</td>
								</tr>
							</cfloop>
							</table>
						</cfif>
					</td>
					<td class="returntype">#localvar.meth.returntype#</td>
					<td class="access">#localvar.meth.access#</td>
					<td class="hint">#localvar.meth.hint#</td>
				</tr>
			</cfoutput>
		</cfsavecontent>

		<cfreturn localvar.result>
	</cffunction>

	<cffunction name="_getMethodsAsTable" returntype="string" hint="gets documentation for methods in the iterator rendered as tablerow">
		<cfargument name="methiter" type="any" required="true" hint="iterator over introspected methods">

		<cfset var lcl = StructCreate(iter = arguments.methiter, result = "")>

		<cfsavecontent variable="localvar.result">
			<cfoutput>
				<cfloop condition="#localvar.iter.whileHasNext()#">
					#_getMethodAsRow(localvar.iter.getCurrent())#
				</cfloop>
			</cfoutput>
		</cfsavecontent>

		<cfreturn _getHTMLMethodsTable(localvar.result)>
	</cffunction>

	<cffunction name="_getHTMLMethodsTable" returntype="string" hint="gets documentation for methods in the iterator rendered as tablerow">
		<cfargument name="tbody" type="string" required="true" hint="iterator over introspected methods">

		<cfset var lcl = StructCreate(result = "")>

		<cfsavecontent variable="lcl.result">
			<cfoutput>
				<table class="methods" cellpadding="0" cellspacing="0">
					<tr>
						<th class="name">Name</th>
						<th class="params">Parameters</th>
						<th class="returntype">Returntype</th>
						<th class="access">Access</th>
						<th class="hint">Hint</th>
					</tr>
					<tbody>
						#tbody#
					</tbody>
				</table>
			</cfoutput>
		</cfsavecontent>

		<cfreturn lcl.result>
	</cffunction>

	<cffunction name="_getMethodsAsText" returntype="array" hint="gets documentation for methods in the iterator rendered as tablerow">
		<cfargument name="methiter" type="any" required="true" hint="iterator over introspected methods">
		<cfargument name="str" type="any" required="true" hint="iterator over introspected methods">

		<cfset var lcl = StructCreate(iter = arguments.methiter)>

		<cfloop condition="#localvar.iter.whileHasNext()#">
			<cfset ArrayAppend(arguments.str, getSnipex().getReplacedSnippet(110, localvar.iter.getCurrent())) />
			<cfset arguments.str = _getArgumentsAsText(iterator(lcl.iter.getCurrent().parameters), arguments.str ) />
		</cfloop>

		<cfreturn arguments.str>
	</cffunction>

	<cffunction name="_getArgumentsAsText" returntype="array" hint="gets documentation for methods in the iterator rendered as tablerow">
		<cfargument name="argiter" type="any" required="true" hint="iterator over introspected methods">
		<cfargument name="str" type="any" required="true" hint="iterator over introspected methods">

		<cfset var lcl = StructCreate(iter = arguments.argiter, result = "")>
		<cfloop condition="#localvar.iter.whileHasNext()#">
			<cfset ArrayAppend(arguments.str, getSnipex().getReplacedSnippet(111, localvar.iter.getCurrent())) />
		</cfloop>

		<cfreturn arguments.str>
	</cffunction>

	<cffunction name="_getHTML" returntype="string" hint="generate the documenation html">
		<cfset var lcl = StructCreate(
			docs = getAllMethods(getCFC())
		)>
		<cfset var iter       = iterator(localvar.docs)>
		<cfset var meth       = "">
		<cfset var meth_iter  = "">
		<cfset var param_iter = "">
		<cfset var param_row_class = "">
		<cfset var max_depth = getMaxDepth()>

		<cfsavecontent variable="localvar.html">
			<cfoutput>
				<cfloop condition="#iter.whileHasNext()#">

					<cfset meth = iter.current.functions>

					<cfquery name="meth" dbtype="query">
					SELECT * FROM meth ORDER BY access, name
					</cfquery>

					<cfset meth_iter = iterator(meth)>

					<cfloop condition="#meth_iter.whileHasNext()#">
						<h2 class="name">#meth_iter.current.name# (#TRIM(meth_iter.getLength())#)</h2>
						<div class="hint">#meth_iter.current.hint#</div>
						#_getMethodsAsTable(meth_iter)#
					</cfloop>

					<cfif max_depth neq -1 AND meth_iter.getIndex() eq max_depth>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfoutput>
		</cfsavecontent>

		<cfreturn localvar.html>
	</cffunction>

	<cffunction name="_getStory" returntype="string" hint="generate the documenation html">
		<cfargument name="cfc" type="any" required="false" default="#getCFC()#">
		<cfargument name="maxdepth" type="string" required="false" default="#getMaxDepth()#">

		<cfset var lcl = StructCreate(
			docs = getAllMethods(arguments.cfc)
		)>
		<cfset var iter       = iterator(lcl.docs)>
		<cfset var meth       = "">
		<cfset var meth_iter  = "">
		<cfset var param_iter = "">
		<cfset var param_row_class = "">
		<cfset var max_depth = getMaxDepth(arguments.maxdepth)>
		<cfset var str = ArrayCreate() />
		<cfset var bms = ArrayCreate() /><!--- Bookmarks --->


		<cftry>
			<cfloop condition="#iter.whileHasNext()#">
				<cfset ArrayAppend(str, html().getH(text=ListLast(iter.getCurrent().name,"."), level=iter.getIndex())) />
				<!--- Add component doc-string --->
				<cfset ArrayAppend(str, getSnipex().getReplacedSnippet(109, iter.current)) />

				<!--- Resort methods on access and name and loop 'm --->
				<cfset meth = iter.current.functions>
				<cfquery name="meth" dbtype="query">
				SELECT * FROM meth ORDER BY access, name
				</cfquery>

				<!--- Add component doc-string --->
				<cfset meth_iter = iterator(meth)>
				<cfloop condition="#meth_iter.whileHasNext()#">
					<!--- Add method Header, Tabled output and doc-string from snipex and loop arguments --->
					<cfset ArrayAppend(bms, html().getA(href="###meth_iter.getCurrent().name#", text=meth_iter.getCurrent().name, class="bookmark")) />
					<cfset ArrayAppend(str, html().getH(level=3, text=meth_iter.getCurrent().name, id=meth_iter.getCurrent().name)) />
					<cfset ArrayAppend(str, _getHTMLMethodsTable(_getMethodAsRow(meth_iter.getCurrent()))) />
					<cfset ArrayAppend(str, html().getDiv(text=getSnipex().getReplacedSnippet(110, meth_iter.getCurrent()))) />
					<cfset param_iter = iterator(meth_iter.getCurrent().parameters)>
					<cfloop condition="#param_iter.whileHasNext()#">
						<!--- Add arguments doc-string --->
						<cfset localvar.args = param_iter.getCurrent() />
						<cfset localvar.args.argOrder = param_iter.getIndex() />
						<cfset localvar.args.MethodName = meth_iter.getCurrent().name />

						<cfset ArrayAppend(str, html().getDiv(text=getSnipex().getReplacedSnippet(111, localvar.args))) />
					</cfloop>
				</cfloop>

				<cfif max_depth neq -1 AND iter.getIndex() eq max_depth>
					<cfbreak>
				</cfif>
			</cfloop>

			<cfcatch type="any">
				<cfset ArrayAppend(str, cfcatch.Message & " " & cfcatch.Detail) />
			</cfcatch>

		</cftry>
		<cfreturn html().getUL(id="bookmarksmenu", text=html().eachLI(bms)) & html().getDiv(id="docsbody", text=ArrayToList(str, CHR(10))) />
	</cffunction>

</cfcomponent>