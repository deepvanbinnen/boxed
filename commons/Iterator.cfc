<cfcomponent output="false">
	<!--- Packaged in nl.e_vision.utilities --->
	<!--- Iterable properties --->
	<cfset variables.iterable  = ""><!--- Iterable object --->
	<cfset variables.ittype    = ""><!--- Java Object (quick lookup) class --->
	<cfset variables.fulltype  = ""><!--- Java Object full class --->
	<cfset variables.native    = false><!--- Flags if an object has a native iterator --->
	<cfset variables.itstruct  = StructNew()><!--- If requested, iterable items as a struct --->
	<cfset variables.itarray   = ArrayNew(1)><!--- If requested, iterable items as a struct --->
	
	<!--- Iteration properties --->
	<cfset variables.current   = ""><!--- Current item --->
	<cfset variables.curridx   = "0"><!--- Current item-key-index as num --->
	<cfset variables.currkey   = ""><!--- Current item-key --->
	<cfset variables.length    = 0><!--- Collection length --->
	<cfset variables.bnext     = false><!--- More items left to iterate over --->
	<cfset variables.listdelim = ","><!--- used for list collection --->
	<cfset variables.valuemap  = ","><!--- used for list collection --->
	
	<!--- IterationRestriction properties --->
	<cfset variables.maxiters    = -1><!--- maximum iterations to do, -1=(loop over entire collection) --->
	<cfset variables.bmaxreached = false><!--- maximum reached flag --->
	
	<!--- properties to prevent infite loop --->
	<cfset variables.nextiter    = 0><!--- value of the next iteration: declared for possible implementation of skipping items in Iterable --->
	<cfset variables.NUMINFDET   = 1000><!--- NUM(ber)INF(inite)DET(ection): iteration value at which to bail out --->
	<!--- Iterable public properties: reflects private properties--->
	<cfset this.length  = variables.length>
	<cfset this.current = variables.current>
	<cfset this.index   = variables.curridx>
	<cfset this.key     = variables.currkey>
	<cfset this.done    = true>
	
	
	<cffunction name="init">
		<cfif ArrayLen(arguments) eq 1>
			<cfreturn create(arguments[1])>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="create">
		<cfargument name="iterable" type="any">
		<cfset this.done    = false>
		<cfset _setIterable(arguments.iterable)>
		<cfset _setIterableType()>
		<cfreturn _setProperties()>
	</cffunction>
	
	
	<cffunction name="reset">
		<cfargument name="iterable" type="any">
		<cfreturn create(getIterable())>
	</cffunction>
	
	<cffunction name="hasNext">
		<cfset variables.nextiter = variables.nextiter + 1>
		<cfif NOT maxreached()>
			<cfif isNative()>
				<cfreturn getIterable().hasNext()>
			</cfif>
			<cfreturn variables.bnext>
		</cfif>
		<cfreturn false>
	</cffunction>
	
	<cffunction name="whileHasNext">
		<cfif hasNext()>
			<cfset next()>
			<cfreturn true>
		</cfif>
		<cfset this.done = true>
		<cfreturn false>
	</cffunction>
	
	<cffunction name="next">
		<cfset _setValues()>
		<cfreturn getCurrent()>
	</cffunction>
	
	<cffunction name="get" output="false">
		<cfreturn getCurrent()>
	</cffunction>
	
	<cffunction name="close">
		<cfloop condition="#whileHasNext()#">
		</cfloop>
	</cffunction>
	
	<cffunction name="getCurrent" output="false">
		<cfreturn variables.current>
	</cffunction>
	
	<cffunction name="getIndex" output="false">
		<cfreturn variables.curridx>
	</cffunction>
	
	<cffunction name="getKey" output="false">
		<cfreturn variables.currkey>
	</cffunction>
	
	<cffunction name="getValue" output="false">
		<cfreturn getCurrent()>
	</cffunction>
	
	<cffunction name="getLength" output="false">
		<cfreturn variables.length>
	</cffunction>
	
	<cffunction name="getIterable" output="false">
		<cfreturn variables.iterable>
	</cffunction>
	
	<cffunction name="getIterableType" output="false">
		<cfreturn variables.ittype>
	</cffunction>
	
	<cffunction name="isNative" output="false">
		<cfreturn variables.native>
	</cffunction>
	
	<cffunction name="getValueMap" output="false">
		<cfreturn variables.valuemap>
	</cffunction>
	
	<cffunction name="numericKey">
		<cfreturn IsNumeric(getKey())>
	</cffunction>	
	
	<cffunction name="toStruct">
		<cfloop condition="#whileHasNext()#">
			<cfif numericKey()>
				<cfset ArrayAppend(variables.itarray, get())>
			</cfif>
			<cfset _toStruct()>
		</cfloop>
		<cfreturn variables.itstruct>
	</cffunction>
	
	<cffunction name="toArr">
		<cfset toStruct()>
		<cfreturn variables.itstruct>
	</cffunction>
	
	<cffunction name="_setCurrent">
		<cfargument name="current" type="any">
		<cfif StructKeyExists(arguments, "current")>
			<cfset variables.current = arguments.current>
			<cfset this.current = variables.current>
		</cfif>
	</cffunction>
	
	<cffunction name="_setNextIndex">
		<cfset variables.curridx = variables.curridx + 1>
		<cfset this.index = variables.curridx>
	</cffunction>
	
	<cffunction name="_setCurrentKey">
		<cfargument name="key" type="any">
		<cfset variables.currkey = arguments.key>
		<cfset this.key = variables.currkey>
	</cffunction>
	
	<cffunction name="_setValues">
		<cfset var it = getIterable()>
		<cfset var tmp = "">
		<cfset var col = "">
		
		<cfswitch expression="#getIterableType()#">
			<cfcase value="array">
				<cfset _setNextIndex()>
				<cfset _setCurrentKey(getIndex())>
				<cfset _setCurrent(it.next())>
			</cfcase>
			<cfcase value="struct,fasthashtable$valueset">
				<cfset it = it.next()>
				<cfset _setNextIndex()>
				<cfset _setCurrentKey(it.getKey())>
				<cftry>
					<cfset _setCurrent(it.getValue())>
					<cfcatch type="any">
						<cfset _setCurrent(it)>
					</cfcatch>
				</cftry>
			</cfcase>
			<cfcase value="argumentcollection">
				<cfset it = it.next()>
				<cfset tmp = getValueMap().next()>
				<cfset _setNextIndex()>
				<cfset _setCurrentKey(it)>
				<cfset _setCurrent(tmp.getValue())>
			</cfcase>
			<cfcase value="string">
				<cfif hasNext()>
					<cfset _setNextIndex()>
					<cfset _setHasNext()>
					<cfset _setCurrentKey(getIndex())>
					<cfset _setCurrent(ListGetAt(it, getIndex(), variables.listdelim))>
				</cfif>
			</cfcase>
			<cfcase value="_query">
				<cfif hasNext()>
					<cfset _setNextIndex()>
					<cfset _setHasNext()>
					<cfset tmp= StructNew()>
					<cfloop list="#it.columnlist#" index="col">
						<cfset StructInsert(tmp, col, it[col][getIndex()])>
					</cfloop>
					<cfset _setCurrentKey(StructKeyList(tmp))>
					<cfset _setCurrent(tmp)>
				</cfif>
			</cfcase>
			
			<cfdefaultcase>
				<cfthrow message="Unhandled set!">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="_setProperties">
		<cfset var it = getIterable()>
		<cfset var tmp = "">
		<cfswitch expression="#getIterableType()#">
			<cfcase value="array">
				<cfset _setNative(true)>
				<cfset _setLength(it.size())>
				<cfset _setIterable(it.iterator())>
			</cfcase>
			<cfcase value="struct">
				<cfset _setNative(true)>
				<cfset _setLength(it.size())>
				<cfset _setIterable(it.entrySet().iterator())>
			</cfcase>
			<cfcase value="string">
				<cfset _setNative(false)>
				<cfset _setLength(ListLen(it, variables.listdelim))>
				<cfset _setHasNext()>
			</cfcase>
			<cfcase value="_query">
				<cfset _setNative(false)>
				<cfset _setLength(it.recordcount)>
				<cfset _setHasNext()>
			</cfcase>
			<cfcase value="argumentcollection">
				<cfset _setNative(true)>
				<cfset _setLength(it.size())>
				<cfset _setIterable(it.keySet().iterator())>
				<cfset _setValueMap(it.values().iterator())>
			</cfcase>
			<cfcase value="fasthashtable$valueset">
				<cfset _setNative(true)>
				<cfset _setLength(it.size())>
				<cfset _setIterable(it.iterator())>
			</cfcase>
			<cfdefaultcase>
				<cfif IsDefined("it.iterator")>
					<cfreturn it.iterator()>
				</cfif>
				<cfoutput><p>#variables.fulltype#: #getIterableType()#</p></cfoutput>
				<!--- <cfset tmp = variables.inspector.init(getMetaData(getIterable()))>
				
				<cfdump var="#tmp.getMethodList()#"> --->
			</cfdefaultcase>
		</cfswitch>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="_setIterableType">
		<cfset var type = "">
		<cftry>
			<cfset type = getMetaData(getIterable()).name>
			<cfcatch type="any">
				<cftry>
					<cfif IsQuery(getIterable())>
						<cfset type = "_query">
					<cfelse>
						<cfset type = getMetaData(getIterable().getClass()).getName()>
					</cfif>
					<cfcatch type="any">
						<cfthrow message="Unable to determine iterabletype">
					</cfcatch>
				</cftry>
			</cfcatch>
		</cftry>
		<cfset variables.fulltype = type>
		<cfset variables.ittype   = LCASE(ListLast(type, "."))>
	</cffunction>
	
	<cffunction name="_setIterable">
		<cfargument name="iterable" type="any">
		<cfset variables.iterable = arguments.iterable>
	</cffunction>
	
	<cffunction name="_setHasNext">
		<cfset variables.bnext = ((getIndex()+1) lte getLength())>
	</cffunction>
	
	<cffunction name="_setLength">
		<cfargument name="length" type="any">
		<cfset variables.length = arguments.length>
		<cfset this.length      = variables.length>
	</cffunction>
	
	<cffunction name="_setNative">
		<cfargument name="native" type="boolean">
		<cfset variables.native = arguments.native>
	</cffunction>
	
	<cffunction name="_setValueMap">
		<cfargument name="valuemap" type="any">
		<cfset variables.valuemap = arguments.valuemap>
	</cffunction>
	
	<cffunction name="_toStruct">
		<cfset StructInsert(variables.itstruct, variables.currkey, variables.current, true)>
	</cffunction>
	
	<cffunction name="maxreached">
		<cfif variables.bmaxreached>
			<cfreturn true>
		<cfelseif variables.nextiter gt variables.NUMINFDET>
			<cfthrow message="This looks like an infinite loop...">
		<cfelse>
			<cfset variables.bmaxreached = (variables.maxiters neq -1 AND getCurrentIndex() gte variables.maxiters)>
		</cfif>
		<cfset this.done = variables.bmaxreached>
		<cfreturn variables.bmaxreached>
	</cffunction>
</cfcomponent>