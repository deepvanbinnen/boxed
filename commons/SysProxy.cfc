<cfcomponent name="SysProxy" extends="AbstractObject" hint="I provide an interface for interacting with the OS/JVM">
	<cffunction name="bashexec" returntype="string" hint="Proxies cfexecute and runs command in a bash-shell returns result">
		<cfargument name="cmd"  type="string" required="true" hint="the shell command to execute" />
		<cfargument name="timeout" type="numeric"    required="false" default="20" hint="timeoutvalue for cfexecute defaults to 10ms" />

		<cfset var localvar = StructNew() />
		<cfset localvar.shell = "/bin/bash">
		<cfset localvar.result = "">
		<cfset localvar.errresult = "">
		<cfset localvar.args = "" />

		<cftry>
			<!--- THIS DOES NOT WORK IN CF-VERSIONS LT 8

			<cfexecute
				name="/bin/bash"
				arguments="-c #CHR(34)##bashEscape(arguments.cmd)##CHR(34)#"
				variable="localvar.result"
				errorVariable="localvar.errresult"
				timeout="#arguments.timeout#">
			</cfexecute> --->

			<cfexecute
				name="/bin/bash"
				arguments="-c #CHR(34)##bashEscape(arguments.cmd)##CHR(34)#"
				variable="localvar.result"
				timeout="#arguments.timeout#">
			</cfexecute>
			<cfif StructKeyExists(localvar, "result") AND StructKeyExists(localvar, "errresult")
				AND localvar.result eq "" AND localvar.errresult neq "">
				<cfset localvar.result = localvar.errresult />
			</cfif>
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.ExecutionError"
					message="BashCommand failed (timeout: #arguments.timeout#): #arguments.cmd#"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
		<cfreturn localvar.result>
	</cffunction>

	<cffunction name="bashEscape" returntype="string" output="false" hint="escapes (multiline) string suitable for use in bash">
		<cfargument name="str"  type="string" required="true" hint="the string to escape" />

		<cfset var lcl = StructNew() />
		<cfset lcl.string = TRIM(arguments.str) />
		<cfset lcl.escapes = "((\\?)(\n|!|$|#CHR(34)#|\\))" />
		<cfset lcl.string = REReplace(lcl.string, lcl.escapes, "\\\3", "ALL") />
		<!--- trailing backslash verwijderen *ouch* --->
		<cfif RIGHT(lcl.string,1) EQ "\" AND RIGHT(lcl.string,2) NEQ "\\">
			<cfset lcl.string = LEFT(lcl.string, LEN(lcl.string)-1) />
		</cfif>
		<cfreturn lcl.string />
	</cffunction>

	<cffunction name="execute" returntype="string" hint="Proxies cfexecute and returns the variable result">
		<cfargument name="cmd"  type="string" required="true" hint="the shell command to execute" />
		<cfargument name="args" type="any"    required="false" default="" hint="shell command arguments as array or string" />
		<cfargument name="timeout" type="numeric"    required="false" default="10" hint="timeoutvalue for cfexecute defaults to 10ms" />

		<cfset var lcl = StructNew() />
		<cftry>
			<cfexecute name="#arguments.cmd#" arguments="#arguments.args#" timeout="#arguments.timeout#" variable="lcl.result"  />
			<cfreturn lcl.result />
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.ExecutionError"
					message="Command (timeout: #arguments.timeout#): #arguments.cmd# #args.toString()#"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="listdir" returntype="query" hint="Proxies cfdirectory where action is list. If dirstring is a filename, lists the directory the file is in.">
		<cfargument name="dir"     type="string" required="true" hint="absolute path to (file)directory to list" />
		<cfargument name="recurse" type="boolean" required="false" default="false" hint="recurse subdirectories flag" />
		<cfargument name="type"    type="string" required="false" default="all" hint="only return folders (type=dir) or files (type=file)" />
		<cfargument name="sort"    type="string" required="false" default="name" hint="sort columns" />
		<cfargument name="filter"  type="string" required="false" default="" hint="names to filter" />

		<cfset var lcl = StructNew() />
		<cftry>
			<cfset lcl.dir = arguments.dir>
			<cfif NOT DirectoryExists(lcl.dir)>
				<cfset lcl.dir = getDirectoryFromPath(lcl.dir)>
			</cfif>
			<!--- Quick and dirty --->
			<cfif arguments.filter EQ "">
				<cfdirectory type="#arguments.type#" action="list" directory="#lcl.dir#" name="lcl.result" recurse="#arguments.recurse#" sort="#arguments.sort#" />
			<cfelse>
				<cfdirectory type="#arguments.type#" action="list" directory="#lcl.dir#" name="lcl.result" recurse="#arguments.recurse#" sort="#arguments.sort#" filter="#arguments.filter#" />
			</cfif>
			<cfreturn lcl.result />
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.DirectoryListing"
					message="Unable to get dirlisting for #getDirectoryFromPath(arguments.dir)#"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="findFiles" output="false" hint="Recursively search a directory and find files based on name">
		<cfargument name="name" required="true"  type="any" hint="The name to search for" />
		<cfargument name="dir"   required="true"  type="any" hint="Root to start looking" />
		<cfargument name="recurse" type="boolean" required="false" default="true" hint="recurse subdirectories flag" />
		<cfargument name="type"    type="string" required="false" default="file" hint="only return folders (type=dir) or files (type=file)" />
		<cfargument name="sort"    type="string" required="false" default="name" hint="sort columns" />

		<cfreturn listdir(dir=arguments.dir, recurse=arguments.recurse, type=arguments.type, sort=arguments.sort, filter=arguments.name) />
	</cffunction>

	<cffunction name="displayFile" output="true" hint="Read and display content from file">
		<cfargument name="filename"  required="true" type="string">

		<cfset var lcl = StructNew()>
		<cftry>
			<cfset lcl.source = readFile(arguments.filename) />
			<cfoutput>#lcl.source#</cfoutput>
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.FileReadFailure"
					message="Unable to read file #arguments.filename#"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="tempFile" output="false" hint="Creates a temporary file">
		<cfargument name="content"  required="true" type="string">

		<cfset var lcl = StructNew()>
		<cftry>
			<cfset lcl.tmpfile = getTempFile( getTempDirectory(), "tmp" )>
			<cfset writeFile(lcl.tmpfile, arguments.content)>
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.TempFileFailure"
					message="Unable to write tempfile #lcl.tmpfile#"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
		<cfreturn lcl.tmpfile>
	</cffunction>

	<cffunction name="readFile" output="false" hint="Reads content from file">
		<cfargument name="filename"  required="true" type="string">

		<cfset var lcl = StructNew()>
		<cftry>
			<cffile action="read" file="#arguments.filename#" variable="lcl.source" />
			<cfcatch type="any">
				<cftry>
					<cffile action="readbinary" file="#arguments.filename#" variable="lcl.source" />
					<cfset lcl.source = Trim(lcl.source) />
					<cfcatch type="any">
						<cfrethrow />
					</cfcatch>
				</cftry>
				<cfthrow
					type="SysProxy.FileReadFailure"
					message="Unable to read file #arguments.filename#"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
		<cfreturn lcl.source>
	</cffunction>

	<cffunction name="writeFile" access="public" returntype="any" output="false"  hint="Writes content to file">
		<cfargument name="filename" required="true" type="string" hint="absolute path to filename">
		<cfargument name="filecontent" required="true" type="string" hint="content to write">
		<cfargument name="append" required="false" type="boolean" default="false" hint="appends content to file">
		<cfargument name="charset" required="false" type="string" default="utf-8" hint="sets charset for content">

		<cfset var lcl = StructCreate(action="write")>
		<cftry>
			<cfif arguments.append>
				<cfset lcl.action = "append">
			<cfelse>
				<cfset lcl.action = "write">
			</cfif>
			<cffile action="#lcl.action#" file="#arguments.filename#" output="#arguments.filecontent#" charset="#arguments.charset#" />
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.FileWriteFailure"
					message="Unable to write file #arguments.filename#"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deleteFile" access="public" returntype="any" output="false"  hint="Delete file">
		<cfargument name="filename" required="true" type="string" hint="absolute path to filename">
		<cfif FileExists(arguments.filename)>
			<cffile action="delete" file="#arguments.filename#" />
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>

	<cffunction name="rmfiles" access="public" returntype="any" output="false" hint="removes all files given as arguments">
		<cfset var lcl = StructNew()>
		<cfloop from="1" to="#ArrayLen(arguments)#" index="lcl.i">
			<cfset lcl.arg = arguments[lcl.i] />
			<cfif IsSimpleValue(lcl.arg)>
				<cfset deleteFile(lcl.arg) />
			<cfelseif IsArray(lcl.arg)>
				<cfset rmfiles(lcl.arg) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="acceptsGZ" access="public" returntype="boolean" output="false"  hint="Does the client accept gzip encoded stream">
		<cfreturn cgi.HTTP_ACCEPT_ENCODING contains "gzip" />
	</cffunction>

	<cffunction name="mimeMap" access="public" returntype="any" output="false"  hint="Does the client accept gzip encoded stream">
		<cfif NOT StructKeyExists(variables, "gzMimeMap")>
			<cfset setMimeMap( IndexedStructCreate("text/html,text/javascript", ArrayCreate("text/html,application/x-javascript"))) />
		</cfif>

		<cfreturn variables.gzMimeMap>
	</cffunction>

	<cffunction name="setMimeMap" access="public" returntype="any" output="false"  hint="Does the client accept gzip encoded stream">
		<cfargument name="gzMimeMap" required="true" type="any" hint="mime-type for stream">
			<cfset variables.gzMimeMap = arguments.gzMimeMap>
		<cfreturn this />
	</cffunction>

	<cffunction name="getGZMime" access="public" returntype="string" output="false"  hint="Find GZ-mime for mime">
		<cfargument name="mimetype" required="true" type="string" hint="mime-type for stream">
		<cfreturn ife(mimeMap().findKey(arguments.mimetype), arguments.mimetype) />
	</cffunction>

	<cffunction name="getMime" access="public" returntype="string" output="false"  hint="Find mime for GZ-mime">
		<cfargument name="gzmimetype" required="true" type="string" hint="mime-type for stream">
		<cfreturn ife(mimeMap().findValue(arguments.gzmimetype), arguments.gzmimetype) />
	</cffunction>

	<cffunction name="streamMimeContent" access="public" returntype="any" output="false"  hint="Streams filecontent to client with cfcontent and a mime-type">
		<cfargument name="mimetype"    required="true" type="string" hint="mime-type for stream">
		<cfargument name="filecontent" required="true" type="any" hint="content to stream">
		<cfargument name="reset"       required="false" type="boolean" default="true" hint="discard preceding output">

		<cfset var lcl = StructNew() />
		<cftry>
			<cfset lcl.out = toBinary( toBase64( trim( arguments.filecontent ) ) )>
			<cfheader name="Content-Length" value="#ArrayLen(lcl.out)#">
			<cfcontent type="#arguments.mimetype#" variable="#lcl.out#" reset="#arguments.reset#" />

			<cfcatch type="any">
				<cfthrow
					type="SysProxy.StreamContentError"
					message="Mime-stream failed"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="gzStreamMimeContent" access="public" returntype="any" output="false"  hint="Streams filecontent to client with cfcontent and a mime-type">
		<cfargument name="mimetype"     required="true" type="string" hint="mime-type for stream">
		<cfargument name="filecontent"  required="true" type="any" hint="content to stream">
		<cfargument name="fallbackMime" required="false" type="string" hint="optional fallback mimetype if gzip-accept is false. defaults to mapped html-mimetype from mimeMap">
		<cfargument name="reset"        required="false" type="boolean" default="true" hint="discard preceding output">

		<cfset var lcl = StructNew() />
		<cftry>
			<cfif acceptsGZ()>
				<cfset lcl.gzbytes = gzByteArray( arguments.filecontent )>
				<cfheader name="Content-Encoding" value="gzip">
				<cfheader name="Content-Length" value="#ArrayLen(lcl.gzbytes)#">
				<cfcontent type="#arguments.mimetype#" variable="#lcl.gzbytes#" reset="#arguments.reset#" />
			<cfelse>
				<cfset streamMimeContent(
					  ife( arguments.fallbackMime, getMime(arguments.mimeType) )
					, arguments.filecontent
					, arguments.reset
				)>
			</cfif>
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.GZStreamContentError"
					message="Mime-stream failed"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="gzByteArray" returntype="any" hint="Returns GZIP ByteArray used for streaming gzip content" output="false">
		<cfargument name="content" type="string" required="true" hint="content to return compressed bytearray for" />
		<cfset var lcl = StructNew() />
		<cftry>
			<cfset lcl.bos = createObject("java","java.io.ByteArrayOutputStream") >
			<cfset lcl.bos.init()>
			<cfset lcl.gzipStream = createObject("java","java.util.zip.GZIPOutputStream")>
			<cfset lcl.gzipStream.init(lcl.bos) >
			<cfset lcl.gzipStream.write(arguments.content.getBytes("utf-8")) >
			<cfset lcl.gzipStream.close()>
			<cfset lcl.bos.flush()>
			<cfset lcl.bos.close()>
			<cfreturn lcl.bos.toByteArray()>
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.GZConversionError"
					message="Unable to compress content to byte-array"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="etag" access="public" returntype="any" output="false"  hint="Responds to etagged requests">
		<cfargument name="requestOutput" required="true" type="any" hint="hashable (page)output">

		<cfset var hashed = Hash(arguments.requestOutput) />
		<cfheader name="ETag" value='"#hashed#"' />
		<cfif StructKeyExists(CGI, 'HTTP_IF_NONE_MATCH') and CGI.HTTP_IF_NONE_MATCH contains hashed>
			<cfcontent reset="yes" />
			<cfheader statuscode="304" statustext="Not Modified" />
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>

	<cffunction name="getAvailableFonts" returntype="array" hint="Returns available fonts from JVM">
		<cfset var lcl = StructNew() />
		<cftry>
			<cfset lcl.env = createObject("java", "java.awt.GraphicsEnvironment").getLocalGraphicsEnvironment() />
			<cfreturn lcl.env.getAvailableFontFamilyNames() />
			<cfcatch type="any">
				<cfthrow
					type="SysProxy.AvailableFontsError"
					message="Unable to get available fonts from JVM"
					detail="#cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getExtensionedFile" output="false" hint="Returns filename with extension added, if it does not end with it">
		<cfargument name="filename" required="true" type="string" hint="filename" />
		<cfargument name="extension" required="true" type="string" hint="extension" />

		<cfreturn IIF(
			  ListLast(arguments.filename,".") neq arguments.extension
			, DE( ListAppend(arguments.filename, arguments.extension, ".") )
			, DE( arguments.filename )
		) />
	</cffunction>

	<cffunction name="getFullFileName" output="false" hint="Returns filename with path added, handles os.path.delimiter issues. if the filename already contains (a portion of) the path the paths are merged">
		<cfargument name="name" required="true" type="string" hint="filename" />
		<cfargument name="dir" required="false" type="string" default="" hint="path to file" />

		<cfset var lcl = StructNew() />
		<cfset lcl.stripped_name = REREplace(arguments.name, "^#arguments.dir#", "") />
		<cfif lcl.stripped_name EQ "">
			<!--- dir is already fully included, bail out --->
			<cfreturn arguments.name />
		</cfif>
		<cfset lcl.stripped_name = ListAppend(arguments.dir, lcl.stripped_name, "/") />
		<cfreturn REREplace(lcl.stripped_name, "/{1,}", "/", "ALL") />
	</cffunction>
</cfcomponent>