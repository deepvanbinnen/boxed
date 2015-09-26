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
Filename: AbstractStructCollection.cfc
Date: Mon Oct 26 15:51:09 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->


<!---
Filename: AbstractStructCollection.cfc
Date: Mon Oct 26 15:50:18 CET 2009
Author: Bharat Deepak Bhikharie
Project info: http://code.google.com/p/dbseries/wiki/ebx
--->

<cfcomponent extends="Collection" hint="Abstract struct object">
	<cffunction name="addAll">
		<cfargument name="data" type="any" required="true">
		<cfargument name="filter" type="any" required="false">

		<cfset getCollection().putAll( _toStruct( argumentCollection = arguments ))>
		<!--- <cfset StructAppend(getCollection(),  _toStruct( argumentCollection = arguments ), true)> --->

		<cfreturn this>
	</cffunction>


</cfcomponent>