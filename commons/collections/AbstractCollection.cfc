<cfcomponent output="false" extends="cfc.commons.AbstractObject" hint="Implementation of interface collection">
	<!---
	************************************************************************
	COLLECTION CFC GETTERS AND SETTERS
	************************************************************************ --->
	<cffunction name="getCollection" output="false">
		<cfreturn _getCollection()>
	</cffunction>

	<cffunction name="_getCollection" output="false" hint="get collection cfc">
		<cfif NOT StructKeyExists(variables, "collection")>
			<cfthrow message="No collection in AbstractCollection">
		</cfif>
		<cfreturn variables.collection>
	</cffunction>

	<cffunction name="_setCollection" output="false">
		<cfargument name="collection" type="any" required="true">
			<cfset variables.collection = arguments.collection>
		<cfreturn this>
	</cffunction>

	<!---
	************************************************************************
	IMPLEMENTED ABSTRACTED METHODS
	************************************************************************ --->
	<cffunction name="getData" output="false">
		<cftry>
			<cfreturn _getCollection()._getData(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getAll" output="false" hint="alias for getting data">
		<cfreturn getData()>
	</cffunction>

	<cffunction name="add" output="false" hint="calls _add method on collection">
		<cftry>
			<cfreturn _getCollection()._add(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="addAll" output="false" hint="calls _addAll method on collection">
		<cftry>
			<cfset _getCollection()._addAll(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="clear" output="false" hint="calls _clear method on collection">>
		<cftry>
			<cfset _getCollection()._clear(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="clone" output="false" hint="calls _clone method on collection">>
		<cftry>
			<cfreturn _getCollection()._clone(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="hasAll" output="false" hint="calls _hasAll method on collection">>
		<cftry>
			<cfset _getCollection()._hasAll(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfthrow message="Method 'hasAll' is not implemented in collection.">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="hasIndex" output="false" hint="calls _hasKey method on collection">>
		<cftry>
			<cfset _getCollection()._hasIndex(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="hasKey" output="false" hint="calls _hasKey method on collection">>
		<cftry>
			<cfset _getCollection()._hasKey(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="hasValue" output="false" hint="calls _hasValue method on collection">>
		<cftry>
			<cfset _getCollection()._hasValue(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="get" output="true" hint="calls _get method on collection">>
		<cftry>
			<cfreturn _getCollection()._get(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfthrow message="Method 'get' is not implemented in collection.">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="isEmpty" output="false" hint="calls _isEmpty method on collection">
		<cftry>
			<cfset _getCollection()._isEmpty(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="createIterator" output="false" hint="calls _addAll method on collection">
		<cftry>
			<cfreturn _getCollection()._createIterator(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfthrow message="Method '_createIterator' is not implemented in collection '#_getName(_getCollection())#'.">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="createPointer" output="false" hint="calls _addAll method on collection">
		<cftry>
			<cfreturn _getCollection()._createPointer(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfthrow message="Method '_createPointer' is not implemented in collection '#_getName(_getCollection())#'." detail="#cfcatch.Message# - #cfcatch.Detail#">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="remove" output="false" hint="calls _remove method on collection">
		<cftry>
			<cfset _getCollection()._remove(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="removeAll" output="false" hint="calls _removeAll method on collection">
		<cftry>
			<cfset _getCollection()._removeAll(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="removeElementsAt" output="false" hint="calls _removeElementsAt method on collection">
		<cftry>
			<cfset _getCollection()._removeElementsAt(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="retain" output="false" hint="calls _retain method on collection">
		<cftry>
			<cfset _getCollection()._retain(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="retainAll" output="false" hint="calls _retainAll method on collection">
		<cftry>
			<cfset _getCollection()._retainAll(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="retainElementsAt" output="false" hint="calls _retainElementsAt method on collection">
		<cftry>
			<cfset _getCollection()._retainElementsAt(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="set" output="false" hint="calls _set method on collection">
		<cftry>
			<cfset _getCollection()._set(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="size" output="false" hint="calls _size method on collection">
		<cftry>
			<cfreturn _getCollection()._size(argumentCollection = arguments)>
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>

	<!---
	************************************************************************
	DEFINED INTERFACE METHODS
	************************************************************************ --->
	<cffunction name="_add" output="false">
		<cfthrow message="Method '_add' is not implemented in collection.">
	</cffunction>

	<cffunction name="_addAll" output="false">
		<cfthrow message="Method '_addAll' is not implemented in collection.">
	</cffunction>

	<cffunction name="_clear" output="false">
		<cfthrow message="Method '_clear' is not implemented in collection.">
	</cffunction>

	<cffunction name="_clone" output="false">
		<cfthrow message="Method '_clone' is not implemented in collection.">
	</cffunction>

	<cffunction name="_hasAll" output="false">
		<cfthrow message="Method '_hasAll' is not implemented in collection.">
	</cffunction>

	<cffunction name="_hasKey" output="false">
		<cfthrow message="Method '_hasKey' is not implemented in collection.">
	</cffunction>

	<cffunction name="_hasIndex" output="false">
		<cfthrow message="Method '_hasIndex' is not implemented in collection.">
	</cffunction>

	<cffunction name="_hasValue" output="false">
		<cfthrow message="Method '_hasValue' is not implemented in collection.">
	</cffunction>

	<cffunction name="_get" output="true">
		<cfthrow message="Method '_get' is not implemented in collection.">
	</cffunction>

	<cffunction name="_getData" output="true">
		<cfthrow message="Method '_getData' is not implemented in collection.">
	</cffunction>

	<cffunction name="_isEmpty" output="false">
		<cfthrow message="Method '_isEmpty' is not implemented in collection.">
	</cffunction>

	<cffunction name="_createIterator" output="false">
		<cfthrow message="Method '_createIterator' is not implemented in collection '#_getName(_getCollection())#'.">
	</cffunction>

	<cffunction name="_createPointer" output="false">
		<cfthrow message="Method '_createPointer' is not implemented in collection '#_getName(_getCollection())#'.">
	</cffunction>

	<cffunction name="_remove" output="false">
		<cfthrow message="Method '_remove' is not implemented in collection.">
	</cffunction>

	<cffunction name="_retainAll" output="false">
		<cfthrow message="Method '_retainAll' is not implemented in collection.">
	</cffunction>

	<cffunction name="_removeAll" output="false">
		<cfthrow message="Method '_removeAll' is not implemented in collection.">
	</cffunction>

	<cffunction name="_set" output="false">
		<cfthrow message="Method '_set' is not implemented in collection.">
	</cffunction>

	<cffunction name="_size" output="false">
		<cfthrow message="Method '_size' is not implemented in collection.">
	</cffunction>
</cfcomponent>