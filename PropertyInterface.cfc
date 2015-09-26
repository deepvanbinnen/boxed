<!---
Copyright 2009 Bharat Deepak Bhikharie

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->
<!--- 
Filename: PropertyInterface.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->
<cfcomponent extends="com.googlecode.dbseries.ebx.utils.utils" hint="I am an interface for the this scope" output="false">
	<cffunction name="getProperty" returntype="any" access="public" hint="return property value or if the property does not exist default value which defaults to empty string">
		<cfargument name="key"     required="true"  type="string" hint="key to get">
		<cfargument name="default" required="false" type="any"    default="" hint="default value to return if key doesn't exist">
	
		<cfif hasProperty(arguments.key)>
			<cfreturn this[arguments.key]>
		</cfif>
		<cfreturn arguments.default>
	</cffunction>
	
	<cffunction name="getProperties" returntype="struct" access="public" hint="set properties from a data object">
		<cfargument name="maplist" required="false" type="any" default="" hint="propertylist or struct used to remap keys">
		
		<cfset var local = StructNew()>
		<cfset local.out = StructNew()>
		
		<cfif IsStruct(arguments.maplist)>
			<cfloop collection="#arguments.maplist#" item="local.i">
				<cfif hasProperty(local.i)>
					<cfset StructInsert(local.out, arguments.maplist[local.i], getProperty(local.i), true)>
				</cfif>
			</cfloop>
		<cfelseif IsSimpleValue(arguments.maplist)>
			<cfloop list="#arguments.maplist#" index="local.i">
				<cfif hasProperty(local.i)>
					<cfset StructInsert(local.out, local.i, getProperty(local.i), true)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfloop collection="#this#" item="local.i">
				<cfif IsSimpleValue(getProperty(local.i))>
					<cfset StructInsert(local.out, local.i, getProperty(local.i), true)>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn local.out>
	</cffunction>
	
	<cffunction name="hasProperty" returntype="boolean" access="public" hint="returns true on success otherwise false">
		<cfargument name="key"   required="true"  type="string" hint="key to update">
		<cfreturn StructKeyExists(this, arguments.key)>
	</cffunction>
	
	<cffunction name="retainList" access="public">
		<cfargument name="sourcelist" type="string" required="true">
		<cfargument name="targetlist" type="string" required="true">
		
		<cfset var local = StructNew()>
		<cfif arguments.targetlist neq "">
			<cfset local.target = ArrayNew(1)>
			<cfloop list="#arguments.targetlist#" index="local.item">
				<cfif ListFind(arguments.sourcelist, local.item)>
					<cfset ArrayAppend(local.target, local.item)>
				</cfif>
			</cfloop>
			<!--- retainAll does not seem to work arrggh!
			<cfset local.target = listToArray(arguments.targetlist)>
			<cfset local.source = listToArray(arguments.sourcelist)>
			<cfset local.target.retainAll(local.source)>
			 --->
			<cfreturn ArrayToList(local.target)>
		<cfelse>
			<cfreturn arguments.sourcelist>
		</cfif>
	</cffunction>
	
	<cffunction name="setFromList" access="private">
		<cfargument name="list" required="true" type="string" hint="list data">
		<cfargument name="force"  required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">
		<cfargument name="keylist"   required="false" type="string"  default=""      hint="only properties from the list of keys">
		
		<cfset var local = StructNew()>
		<cfset local.list = retainList(arguments.list, arguments.keylist)>
		<cfloop list="#local.list#" index="local.key">
			<cfset setProperty(local.key, "", arguments.force, arguments.overwrite)>
		</cfloop>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setFromRecord" access="private">
		<cfargument name="record" required="true" type="query" hint="query data">
		<cfargument name="recidx" required="false" type="numeric" default="1" hint="the record index used if objectdata is queryable">
		<cfargument name="force"  required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">
		<cfargument name="keylist"   required="false" type="string"  default=""      hint="only properties from the list of keys">
			
		<cfset var local = StructNew()>
		<cfset local.list = retainList(arguments.record.columnlist, arguments.keylist)>
		<cfloop list="#local.list#" index="local.column">
			<cfset local.value = "">
			<cfif arguments.record.recordcount GTE arguments.recidx>
				<cfset local.value = arguments.record[local.column][arguments.recidx]>
			</cfif>
			<cfset setProperty(local.column, local.value, arguments.force, arguments.overwrite)>
		</cfloop>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setFromStruct" access="private">
		<cfargument name="object"    required="true"  type="struct"  hint="struct data">
		<cfargument name="force"     required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true"  hint="overwrite property">
		<cfargument name="keylist"   required="false" type="string"  default=""      hint="only properties from the list of keys">
	
		<cfset var local = StructNew()>
		<cfset local.list = retainList(StructKeyList(arguments.object), arguments.keylist)>
		<cfloop list="#local.list#" index="local.key">
			<cfset setProperty(local.key, arguments.object[local.key], arguments.force, arguments.overwrite)>
		</cfloop>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setProperty" returntype="boolean" access="public" hint="returns true on success otherwise false">
		<cfargument name="key"       required="true"  type="string"  hint="key to update">
		<cfargument name="value"     required="false" type="any"     default="" hint="value for the key">
		<cfargument name="force"     required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true" hint="overwrite property">
	
		<cfif arguments.force OR hasProperty(arguments.key) AND arguments.overwrite>
			<cfif NOT hasProperty(arguments.key) OR arguments.overwrite>
				<cfset this[arguments.key] = arguments.value>
			</cfif>
			<cfreturn true>
		</cfif>
		
		<cfreturn false>
	</cffunction>
	
	<cffunction name="setProperties" access="private" hint="set properties from a data object">
		<cfargument name="data"      required="true"  type="any"     hint="any value keys can be extracted">
		<cfargument name="force"     required="false" type="boolean" default="false" hint="force setting property">
		<cfargument name="overwrite" required="false" type="boolean" default="true"  hint="overwrite property">
		<cfargument name="recidx"    required="false" type="numeric" default="1"     hint="the record index used if objectdata is queryable">
		<cfargument name="keylist"   required="false" type="string"  default=""      hint="only properties from the list of keys">
		
		<cfset var local = StructNew()>
		
		<cfif IsQuery(arguments.data)>
			<cfset setFromRecord(arguments.data, arguments.recidx, arguments.force, arguments.overwrite, arguments.keylist)>
		<cfelseif IsStruct(arguments.data)>
			<cfset setFromStruct(arguments.data, arguments.force, arguments.overwrite, arguments.keylist)>
		<cfelseif ListLen(arguments.data)>
			<cfset setFromList(arguments.data, arguments.force, arguments.overwrite, arguments.keylist)>
		</cfif>
		
		<cfreturn true>
	</cffunction>
</cfcomponent>	