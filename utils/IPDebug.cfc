<cfcomponent name="IPDebug" hint="global tester for CGI.REMOTE_ADDR (meant for debugging); a single instance for this component should be added in the application/session scope">
	<cfset this.ips = StructNew()>
	<cfset this.ips["e-Vision"] = "193.172.88.205">
	<cfset this.ips["e-Vision2"] = "193.172.88.223">
	<cfset this.ips["deepak"]   = "83.85.101.59">
	<cfset this.ips["mirthe"]   = "83.163.6.108">
	<cfset this.ips["kees"]     = "213.84.17.8">
	<cfset this.ips["edi"]      = "94.210.127.179">
	<cfset this.iplist = "">

	<cfset variables.knownIPS = StructNew()>

	<cffunction name="init" returntype="IPDebug" hint="instantiate component">
		<cfset _setIpList()>
		<cfreturn this>
	</cffunction>

	<cffunction name="isCurrentIP" returntype="boolean" hint="return true if given ip is remote addr">
		<cfargument name="ipaddr" type="string" required="false">
		<cfreturn CGI.REMOTE_ADDR eq arguments.ipaddr>
	</cffunction>

	<cffunction name="testIP" returntype="boolean" hint="return true if ip is in debugging ips">
		<cfargument name="ipaddr" type="string" required="false" default="#CGI.REMOTE_ADDR#">
		<cfreturn ListFind(getIpList(), arguments.ipaddr)>
	</cffunction>

	<cffunction name="testOwner" returntype="boolean" hint="return true if the owners ip is in debugging ips">
		<cfargument name="owner" type="string" required="false" default="">
		<cfreturn testIP(getIpByOwner(arguments.owner)) AND isCurrentIP(getIpByOwner(arguments.owner))>
	</cffunction>

	<cffunction name="getIpList" returntype="string" hint="return the list of debugging ips">
		<cfreturn this.iplist>
	</cffunction>

	<cffunction name="getIpOwners" returntype="struct" hint="return the struct of debugging ipowners">
		<cfreturn this.ips>
	</cffunction>

	<cffunction name="getIpByOwner" returntype="string" hint="return the ip for an owner">
		<cfargument name="owner"  type="string" required="true">
		<cfif StructKeyExists(this.ips, arguments.owner)>
			<cfreturn this.ips[arguments.owner]>
		</cfif>
		<cfreturn "">
	</cffunction>

	<cffunction name="addIP" returntype="boolean" hint="return true if add is successfull">
		<cfargument name="ipaddr" type="string" required="false" default="#CGI.REMOTE_ADDR#">
		<cfargument name="owner"  type="string" required="false" default="#CreateUUID()#">

		<!--- break out if IP is known or owner is an empty string --->
		<cfif arguments.owner eq '' OR testIP(arguments.ipaddr)>
			<cfreturn FALSE>
		</cfif>

		<cfset StructInsert(this.ips, arguments.owner, arguments.ipaddr, TRUE)>
		<cfset _setIpList()>

		<cfreturn TRUE>
	</cffunction>

	<cffunction name="addIPByOwner" returntype="boolean" hint="return true if ip is known and add is succesfull">
		<cfargument name="owner"  type="string" required="true">

		<!--- break out if owner is unknown --->
		<cfif NOT StructKeyExists(variables.knownIPS, arguments.owner)>
			<cfreturn FALSE>
		</cfif>

		<cfreturn addIP(variables.knownIPS[arguments.owner], arguments.owner)>
	</cffunction>

	<cffunction name="_setIpList" access="private" returntype="string" hint="set ips in a list">
		<cfset var lcl = StructNew()>
		<cfset this.iplist = "">
		<cfloop collection="#this.ips#" item="lcl.owner">
			<cfset this.iplist = ListAppend(this.iplist, getIpByOwner(lcl.owner))>
		</cfloop>
	</cffunction>
</cfcomponent>