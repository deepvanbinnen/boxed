<cfcomponent displayname="XHTML" output="false" hint="XHTML-related Base">
	<cffunction name="init" returntype="any" output="false" hint="Initialises XHTML">
		<cfreturn this />
	</cffunction>

	<cffunction name="isWhitespace" hint="returns a boolean indicating if given argument is a whitespace character">
		<cfargument name="s" type="string" required="true" hint="the character to check">
		<cfif LEN(arguments.s)>
			<cfreturn REFind("[\s]", LEFT(arguments.s,1)) />
		</cfif>
		<cfreturn false />
	</cffunction>

	<cffunction name="isLetterOrDigit" hint="returns a boolean indicating if given argument is a whitespace character">
		<cfargument name="s" type="string" required="true" hint="the character to check">
		<cfif LEN(arguments.s)>
			<cfreturn REFind("[\w]", LEFT(arguments.s,1)) />
		</cfif>
		<cfreturn false />
	</cffunction>

	<cffunction name="isLetter" hint="returns a boolean indicating if given argument is a whitespace character">
		<cfargument name="s" type="string" required="true" hint="the character to check">
		<cfif LEN(arguments.s)>
			<cfreturn REFind("[a-zA-Z]", LEFT(arguments.s,1)) />
		</cfif>
		<cfreturn false />
	</cffunction>


	<cffunction name="Html2Xml" returntype="string" access="remote" hint="returns html document as xml string based on ">
		<cfargument name="s" type="string" required="true" hint="html string to convert">
		<!---
		Java Port from: http://sourceforge.net/projects/light-html2xml/
		Author: Deepak Bhikharie
		Company: e-Vision
		WWW: www.e-vision.nl
		Date: 08-May-2010 18:27PM CET
		--->
		<!--- Orginal copyright below
		// Copyright (C) 2008 Alain COUTHURES
		//
		// This program is free software; you can redistribute it and/or
		// modify it under the terms of the GNU General Public License
		// as published by the Free Software Foundation; either version 2
		// of the License, or (at your option) any later version.
		//
		// This program is distributed in the hope that it will be useful,
		// but WITHOUT ANY WARRANTY; without even the implied warranty of
		// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
		// GNU General Public License for more details.
		//
		// You should have received a copy of the GNU General Public License
		// along with this program; if not, write to the Free Software
		// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
		 --->

		<cfset var local = StructNew() />
		<cfset local.states = StructNew() />
		<cfset local.states.text = "text" />
		<cfset local.states.tag = "tag" />
		<cfset local.states.endtag = "endtag" />
		<cfset local.states.attrtext = "attrtext" />
		<cfset local.states.script = "script" />
		<cfset local.states.endscript = "endscript" />
		<cfset local.states.specialtag = "specialtag" />
		<cfset local.states.comment = "comment" />
		<cfset local.states.skipcdata = "skipcdata" />
		<cfset local.states.entity = "entity" />
		<cfset local.states.namedentity = "namedentity" />
		<cfset local.states.numericentity = "numericentity" />
		<cfset local.states.hexaentity = "hexaentity" />
		<cfset local.states.tillgt = "tillgt" />
		<cfset local.states.tillquote = "tillquote" />
		<cfset local.states.tillinst = "tillinst" />
		<cfset local.states.andgt = "andgt" />

		<cfset local.namedentities = StructNew() />
		<cfset local.emptytags = "" />
		<cfset local.autoclosetags = StructNew() />

		<cfset StructInsert(local.namedentities, "AElig",  198, TRUE) />
		<cfset StructInsert(local.namedentities, "Aacute",  193, TRUE) />
		<cfset StructInsert(local.namedentities, "Acirc",  194, TRUE) />
		<cfset StructInsert(local.namedentities, "Agrave",  192, TRUE) />
		<cfset StructInsert(local.namedentities, "Alpha",  913, TRUE) />
		<cfset StructInsert(local.namedentities, "Aring",  197, TRUE) />
		<cfset StructInsert(local.namedentities, "Atilde",  195, TRUE) />
		<cfset StructInsert(local.namedentities, "Auml",  196, TRUE) />
		<cfset StructInsert(local.namedentities, "Beta",  914, TRUE) />
		<cfset StructInsert(local.namedentities, "Ccedil",  199, TRUE) />
		<cfset StructInsert(local.namedentities, "Chi",  935, TRUE) />
		<cfset StructInsert(local.namedentities, "Dagger",  8225, TRUE) />
		<cfset StructInsert(local.namedentities, "Delta",  916, TRUE) />
		<cfset StructInsert(local.namedentities, "ETH",  208, TRUE) />
		<cfset StructInsert(local.namedentities, "Eacute",  201, TRUE) />
		<cfset StructInsert(local.namedentities, "Ecirc",  202, TRUE) />
		<cfset StructInsert(local.namedentities, "Egrave",  200, TRUE) />
		<cfset StructInsert(local.namedentities, "Epsilon",  917, TRUE) />
		<cfset StructInsert(local.namedentities, "Eta",  919, TRUE) />
		<cfset StructInsert(local.namedentities, "Euml",  203, TRUE) />
		<cfset StructInsert(local.namedentities, "Gamma",  915, TRUE) />
		<cfset StructInsert(local.namedentities, "Iacute",  205, TRUE) />
		<cfset StructInsert(local.namedentities, "Icirc",  206, TRUE) />
		<cfset StructInsert(local.namedentities, "Igrave",  204, TRUE) />
		<cfset StructInsert(local.namedentities, "Iota",  921, TRUE) />
		<cfset StructInsert(local.namedentities, "Iuml",  207, TRUE) />
		<cfset StructInsert(local.namedentities, "Kappa",  922, TRUE) />
		<cfset StructInsert(local.namedentities, "Lambda",  923, TRUE) />
		<cfset StructInsert(local.namedentities, "Mu",  924, TRUE) />
		<cfset StructInsert(local.namedentities, "Ntilde",  209, TRUE) />
		<cfset StructInsert(local.namedentities, "Nu",  925, TRUE) />
		<cfset StructInsert(local.namedentities, "OElig",  338, TRUE) />
		<cfset StructInsert(local.namedentities, "Oacute",  211, TRUE) />
		<cfset StructInsert(local.namedentities, "Ocirc",  212, TRUE) />
		<cfset StructInsert(local.namedentities, "Ograve",  210, TRUE) />
		<cfset StructInsert(local.namedentities, "Omega",  937, TRUE) />
		<cfset StructInsert(local.namedentities, "Omicron",  927, TRUE) />
		<cfset StructInsert(local.namedentities, "Oslash",  216, TRUE) />
		<cfset StructInsert(local.namedentities, "Otilde",  213, TRUE) />
		<cfset StructInsert(local.namedentities, "Ouml",  214, TRUE) />
		<cfset StructInsert(local.namedentities, "Phi",  934, TRUE) />
		<cfset StructInsert(local.namedentities, "Pi",  928, TRUE) />
		<cfset StructInsert(local.namedentities, "Prime",  8243, TRUE) />
		<cfset StructInsert(local.namedentities, "Psi",  936, TRUE) />
		<cfset StructInsert(local.namedentities, "Rho",  929, TRUE) />
		<cfset StructInsert(local.namedentities, "Scaron",  352, TRUE) />
		<cfset StructInsert(local.namedentities, "Sigma",  931, TRUE) />
		<cfset StructInsert(local.namedentities, "THORN",  222, TRUE) />
		<cfset StructInsert(local.namedentities, "Tau",  932, TRUE) />
		<cfset StructInsert(local.namedentities, "Theta",  920, TRUE) />
		<cfset StructInsert(local.namedentities, "Uacute",  218, TRUE) />
		<cfset StructInsert(local.namedentities, "Ucirc",  219, TRUE) />
		<cfset StructInsert(local.namedentities, "Ugrave",  217, TRUE) />
		<cfset StructInsert(local.namedentities, "Upsilon",  933, TRUE) />
		<cfset StructInsert(local.namedentities, "Uuml",  220, TRUE) />
		<cfset StructInsert(local.namedentities, "Xi",  926, TRUE) />
		<cfset StructInsert(local.namedentities, "Yacute",  221, TRUE) />
		<cfset StructInsert(local.namedentities, "Yuml",  376, TRUE) />
		<cfset StructInsert(local.namedentities, "Zeta",  918, TRUE) />
		<cfset StructInsert(local.namedentities, "aacute",  225, TRUE) />
		<cfset StructInsert(local.namedentities, "acirc",  226, TRUE) />
		<cfset StructInsert(local.namedentities, "acute",  180, TRUE) />
		<cfset StructInsert(local.namedentities, "aelig",  230, TRUE) />
		<cfset StructInsert(local.namedentities, "agrave",  224, TRUE) />
		<cfset StructInsert(local.namedentities, "alpha",  945, TRUE) />
		<cfset StructInsert(local.namedentities, "and",  8743, TRUE) />
		<cfset StructInsert(local.namedentities, "ang",  8736, TRUE) />
		<cfset StructInsert(local.namedentities, "aring",  229, TRUE) />
		<cfset StructInsert(local.namedentities, "asymp",  8776, TRUE) />
		<cfset StructInsert(local.namedentities, "atilde",  227, TRUE) />
		<cfset StructInsert(local.namedentities, "auml",  228, TRUE) />
		<cfset StructInsert(local.namedentities, "bdquo",  8222, TRUE) />
		<cfset StructInsert(local.namedentities, "beta",  946, TRUE) />
		<cfset StructInsert(local.namedentities, "brvbar",  166, TRUE) />
		<cfset StructInsert(local.namedentities, "bull",  8226, TRUE) />
		<cfset StructInsert(local.namedentities, "cap",  8745, TRUE) />
		<cfset StructInsert(local.namedentities, "ccedil",  231, TRUE) />
		<cfset StructInsert(local.namedentities, "cedil",  184, TRUE) />
		<cfset StructInsert(local.namedentities, "cent",  162, TRUE) />
		<cfset StructInsert(local.namedentities, "chi",  967, TRUE) />
		<cfset StructInsert(local.namedentities, "circ",  710, TRUE) />
		<cfset StructInsert(local.namedentities, "clubs",  9827, TRUE) />
		<cfset StructInsert(local.namedentities, "cong",  8773, TRUE) />
		<cfset StructInsert(local.namedentities, "copy",  169, TRUE) />
		<cfset StructInsert(local.namedentities, "crarr",  8629, TRUE) />
		<cfset StructInsert(local.namedentities, "cup",  8746, TRUE) />
		<cfset StructInsert(local.namedentities, "curren",  164, TRUE) />
		<cfset StructInsert(local.namedentities, "dagger",  8224, TRUE) />
		<cfset StructInsert(local.namedentities, "darr",  8595, TRUE) />
		<cfset StructInsert(local.namedentities, "deg",  176, TRUE) />
		<cfset StructInsert(local.namedentities, "delta",  948, TRUE) />
		<cfset StructInsert(local.namedentities, "diams",  9830, TRUE) />
		<cfset StructInsert(local.namedentities, "divide",  247, TRUE) />
		<cfset StructInsert(local.namedentities, "eacute",  233, TRUE) />
		<cfset StructInsert(local.namedentities, "ecirc",  234, TRUE) />
		<cfset StructInsert(local.namedentities, "egrave",  232, TRUE) />
		<cfset StructInsert(local.namedentities, "empty",  8709, TRUE) />
		<cfset StructInsert(local.namedentities, "emsp",  8195, TRUE) />
		<cfset StructInsert(local.namedentities, "ensp",  8194, TRUE) />
		<cfset StructInsert(local.namedentities, "epsilon",  949, TRUE) />
		<cfset StructInsert(local.namedentities, "equiv",  8801, TRUE) />
		<cfset StructInsert(local.namedentities, "eta",  951, TRUE) />
		<cfset StructInsert(local.namedentities, "eth",  240, TRUE) />
		<cfset StructInsert(local.namedentities, "euml",  235, TRUE) />
		<cfset StructInsert(local.namedentities, "euro",  8364, TRUE) />
		<cfset StructInsert(local.namedentities, "exists",  8707, TRUE) />
		<cfset StructInsert(local.namedentities, "fnof",  402, TRUE) />
		<cfset StructInsert(local.namedentities, "forall",  8704, TRUE) />
		<cfset StructInsert(local.namedentities, "frac12",  189, TRUE) />
		<cfset StructInsert(local.namedentities, "frac14",  188, TRUE) />
		<cfset StructInsert(local.namedentities, "frac34",  190, TRUE) />
		<cfset StructInsert(local.namedentities, "gamma",  947, TRUE) />
		<cfset StructInsert(local.namedentities, "ge",  8805, TRUE) />
		<cfset StructInsert(local.namedentities, "harr",  8596, TRUE) />
		<cfset StructInsert(local.namedentities, "hearts",  9829, TRUE) />
		<cfset StructInsert(local.namedentities, "hellip",  8230, TRUE) />
		<cfset StructInsert(local.namedentities, "iacute",  237, TRUE) />
		<cfset StructInsert(local.namedentities, "icirc",  238, TRUE) />
		<cfset StructInsert(local.namedentities, "iexcl",  161, TRUE) />
		<cfset StructInsert(local.namedentities, "igrave",  236, TRUE) />
		<cfset StructInsert(local.namedentities, "infin",  8734, TRUE) />
		<cfset StructInsert(local.namedentities, "int",  8747, TRUE) />
		<cfset StructInsert(local.namedentities, "iota",  953, TRUE) />
		<cfset StructInsert(local.namedentities, "iquest",  191, TRUE) />
		<cfset StructInsert(local.namedentities, "isin",  8712, TRUE) />
		<cfset StructInsert(local.namedentities, "iuml",  239, TRUE) />
		<cfset StructInsert(local.namedentities, "kappa",  954, TRUE) />
		<cfset StructInsert(local.namedentities, "lambda",  923, TRUE) />
		<cfset StructInsert(local.namedentities, "laquo",  171, TRUE) />
		<cfset StructInsert(local.namedentities, "larr",  8592, TRUE) />
		<cfset StructInsert(local.namedentities, "lceil",  8968, TRUE) />
		<cfset StructInsert(local.namedentities, "ldquo",  8220, TRUE) />
		<cfset StructInsert(local.namedentities, "le",  8804, TRUE) />
		<cfset StructInsert(local.namedentities, "lfloor",  8970, TRUE) />
		<cfset StructInsert(local.namedentities, "lowast",  8727, TRUE) />
		<cfset StructInsert(local.namedentities, "loz",  9674, TRUE) />
		<cfset StructInsert(local.namedentities, "lrm",  8206, TRUE) />
		<cfset StructInsert(local.namedentities, "lsaquo",  8249, TRUE) />
		<cfset StructInsert(local.namedentities, "lsquo",  8216, TRUE) />
		<cfset StructInsert(local.namedentities, "macr",  175, TRUE) />
		<cfset StructInsert(local.namedentities, "mdash",  8212, TRUE) />
		<cfset StructInsert(local.namedentities, "micro",  181, TRUE) />
		<cfset StructInsert(local.namedentities, "middot",  183, TRUE) />
		<cfset StructInsert(local.namedentities, "minus",  8722, TRUE) />
		<cfset StructInsert(local.namedentities, "mu",  956, TRUE) />
		<cfset StructInsert(local.namedentities, "nabla",  8711, TRUE) />
		<cfset StructInsert(local.namedentities, "nbsp",  160, TRUE) />
		<cfset StructInsert(local.namedentities, "ndash",  8211, TRUE) />
		<cfset StructInsert(local.namedentities, "ne",  8800, TRUE) />
		<cfset StructInsert(local.namedentities, "ni",  8715, TRUE) />
		<cfset StructInsert(local.namedentities, "not",  172, TRUE) />
		<cfset StructInsert(local.namedentities, "notin",  8713, TRUE) />
		<cfset StructInsert(local.namedentities, "nsub",  8836, TRUE) />
		<cfset StructInsert(local.namedentities, "ntilde",  241, TRUE) />
		<cfset StructInsert(local.namedentities, "nu",  925, TRUE) />
		<cfset StructInsert(local.namedentities, "oacute",  243, TRUE) />
		<cfset StructInsert(local.namedentities, "ocirc",  244, TRUE) />
		<cfset StructInsert(local.namedentities, "oelig",  339, TRUE) />
		<cfset StructInsert(local.namedentities, "ograve",  242, TRUE) />
		<cfset StructInsert(local.namedentities, "oline",  8254, TRUE) />
		<cfset StructInsert(local.namedentities, "omega",  969, TRUE) />
		<cfset StructInsert(local.namedentities, "omicron",  959, TRUE) />
		<cfset StructInsert(local.namedentities, "oplus",  8853, TRUE) />
		<cfset StructInsert(local.namedentities, "or",  8744, TRUE) />
		<cfset StructInsert(local.namedentities, "ordf",  170, TRUE) />
		<cfset StructInsert(local.namedentities, "ordm",  186, TRUE) />
		<cfset StructInsert(local.namedentities, "oslash",  248, TRUE) />
		<cfset StructInsert(local.namedentities, "otilde",  245, TRUE) />
		<cfset StructInsert(local.namedentities, "otimes",  8855, TRUE) />
		<cfset StructInsert(local.namedentities, "ouml",  246, TRUE) />
		<cfset StructInsert(local.namedentities, "para",  182, TRUE) />
		<cfset StructInsert(local.namedentities, "part",  8706, TRUE) />
		<cfset StructInsert(local.namedentities, "permil",  8240, TRUE) />
		<cfset StructInsert(local.namedentities, "perp",  8869, TRUE) />
		<cfset StructInsert(local.namedentities, "phi",  966, TRUE) />
		<cfset StructInsert(local.namedentities, "pi",  960, TRUE) />
		<cfset StructInsert(local.namedentities, "piv",  982, TRUE) />
		<cfset StructInsert(local.namedentities, "plusmn",  177, TRUE) />
		<cfset StructInsert(local.namedentities, "pound",  163, TRUE) />
		<cfset StructInsert(local.namedentities, "prime",  8242, TRUE) />
		<cfset StructInsert(local.namedentities, "prod",  8719, TRUE) />
		<cfset StructInsert(local.namedentities, "prop",  8733, TRUE) />
		<cfset StructInsert(local.namedentities, "psi",  968, TRUE) />
		<cfset StructInsert(local.namedentities, "radic",  8730, TRUE) />
		<cfset StructInsert(local.namedentities, "raquo",  187, TRUE) />
		<cfset StructInsert(local.namedentities, "rarr",  8594, TRUE) />
		<cfset StructInsert(local.namedentities, "rceil",  8969, TRUE) />
		<cfset StructInsert(local.namedentities, "rdquo",  8221, TRUE) />
		<cfset StructInsert(local.namedentities, "reg",  174, TRUE) />
		<cfset StructInsert(local.namedentities, "rfloor",  8971, TRUE) />
		<cfset StructInsert(local.namedentities, "rho",  961, TRUE) />
		<cfset StructInsert(local.namedentities, "rlm",  8207, TRUE) />
		<cfset StructInsert(local.namedentities, "rsaquo",  8250, TRUE) />
		<cfset StructInsert(local.namedentities, "rsquo",  8217, TRUE) />
		<cfset StructInsert(local.namedentities, "sbquo",  8218, TRUE) />
		<cfset StructInsert(local.namedentities, "scaron",  353, TRUE) />
		<cfset StructInsert(local.namedentities, "sdot",  8901, TRUE) />
		<cfset StructInsert(local.namedentities, "sect",  167, TRUE) />
		<cfset StructInsert(local.namedentities, "shy",  173, TRUE) />
		<cfset StructInsert(local.namedentities, "sigma",  963, TRUE) />
		<cfset StructInsert(local.namedentities, "sigmaf",  962, TRUE) />
		<cfset StructInsert(local.namedentities, "sim",  8764, TRUE) />
		<cfset StructInsert(local.namedentities, "spades",  9824, TRUE) />
		<cfset StructInsert(local.namedentities, "sub",  8834, TRUE) />
		<cfset StructInsert(local.namedentities, "sube",  8838, TRUE) />
		<cfset StructInsert(local.namedentities, "sum",  8721, TRUE) />
		<cfset StructInsert(local.namedentities, "sup",  8835, TRUE) />
		<cfset StructInsert(local.namedentities, "sup1",  185, TRUE) />
		<cfset StructInsert(local.namedentities, "sup3",  179, TRUE) />
		<cfset StructInsert(local.namedentities, "supe",  8839, TRUE) />
		<cfset StructInsert(local.namedentities, "szlig",  223, TRUE) />
		<cfset StructInsert(local.namedentities, "tau",  964, TRUE) />
		<cfset StructInsert(local.namedentities, "there4",  8756, TRUE) />
		<cfset StructInsert(local.namedentities, "theta",  952, TRUE) />
		<cfset StructInsert(local.namedentities, "thetasym",  977, TRUE) />
		<cfset StructInsert(local.namedentities, "thinsp",  8201, TRUE) />
		<cfset StructInsert(local.namedentities, "thorn",  254, TRUE) />
		<cfset StructInsert(local.namedentities, "tilde",  732, TRUE) />
		<cfset StructInsert(local.namedentities, "times",  215, TRUE) />
		<cfset StructInsert(local.namedentities, "trade",  8482, TRUE) />
		<cfset StructInsert(local.namedentities, "uacute",  250, TRUE) />
		<cfset StructInsert(local.namedentities, "uarr",  8593, TRUE) />
		<cfset StructInsert(local.namedentities, "ucirc",  251, TRUE) />
		<cfset StructInsert(local.namedentities, "ugrave",  249, TRUE) />
		<cfset StructInsert(local.namedentities, "uml",  168, TRUE) />
		<cfset StructInsert(local.namedentities, "up2",  178, TRUE) />
		<cfset StructInsert(local.namedentities, "upsih",  978, TRUE) />
		<cfset StructInsert(local.namedentities, "upsilon",  965, TRUE) />
		<cfset StructInsert(local.namedentities, "uuml",  252, TRUE) />
		<cfset StructInsert(local.namedentities, "xi",  958, TRUE) />
		<cfset StructInsert(local.namedentities, "yacute",  253, TRUE) />
		<cfset StructInsert(local.namedentities, "yen",  165, TRUE) />
		<cfset StructInsert(local.namedentities, "yuml",  255, TRUE) />
		<cfset StructInsert(local.namedentities, "zeta",  950, TRUE) />
		<cfset StructInsert(local.namedentities, "zwj",  8205, TRUE) />
		<cfset StructInsert(local.namedentities, "zwnj",  8204, TRUE) />

		<cfset local.emptytags = ListAppend(emptytags, "area") />
		<cfset local.emptytags = ListAppend(emptytags, "base") />
		<cfset local.emptytags = ListAppend(emptytags, "basefont") />
		<cfset local.emptytags = ListAppend(emptytags, "br") />
		<cfset local.emptytags = ListAppend(emptytags, "col") />
		<cfset local.emptytags = ListAppend(emptytags, "frame") />
		<cfset local.emptytags = ListAppend(emptytags, "hr") />
		<cfset local.emptytags = ListAppend(emptytags, "img") />
		<cfset local.emptytags = ListAppend(emptytags, "input") />
		<cfset local.emptytags = ListAppend(emptytags, "isindex") />
		<cfset local.emptytags = ListAppend(emptytags, "link") />
		<cfset local.emptytags = ListAppend(emptytags, "meta") />
		<cfset local.emptytags = ListAppend(emptytags, "param") />

		<cfset StructInsert(local.autoclosetags, "basefont", "") />
		<cfset local.autoclosetags["basefont"] = ListAppend(local.autoclosetags["basefont"],"basefont") />
		<cfset StructInsert(local.autoclosetags, "colgroup", "") />
		<cfset local.autoclosetags["colgroup"] = ListAppend(local.autoclosetags["colgroup"],"colgroup") />
		<cfset StructInsert(local.autoclosetags, "dd", "") />
		<cfset local.autoclosetags["dd"] = ListAppend(local.autoclosetags["dd"],"colgroup") />
		<cfset StructInsert(local.autoclosetags, "dt", "") />
		<cfset local.autoclosetags["dt"] = ListAppend(local.autoclosetags["dt"],"dt") />
		<cfset StructInsert(local.autoclosetags, "li", "") />
		<cfset local.autoclosetags["li"] = ListAppend(local.autoclosetags["li"],"li") />
		<cfset StructInsert(local.autoclosetags, "p", "") />
		<cfset local.autoclosetags["p"] = ListAppend(local.autoclosetags["p"],"p") />
		<cfset StructInsert(local.autoclosetags, "thead", "") />
		<cfset local.autoclosetags["thead"] = ListAppend(local.autoclosetags["thead"],"tbody") />
		<cfset local.autoclosetags["thead"] = ListAppend(local.autoclosetags["thead"],"tfoot") />
		<cfset StructInsert(local.autoclosetags, "tbody", "") />
		<cfset local.autoclosetags["tbody"] = ListAppend(local.autoclosetags["tbody"],"thead") />
		<cfset local.autoclosetags["tbody"] = ListAppend(local.autoclosetags["tbody"],"tfoot") />
		<cfset StructInsert(local.autoclosetags, "tfoot", "") />
		<cfset local.autoclosetags["tfoot"] = ListAppend(local.autoclosetags["tfoot"],"thead") />
		<cfset local.autoclosetags["tfoot"] = ListAppend(local.autoclosetags["tfoot"],"tbody") />
		<cfset StructInsert(local.autoclosetags, "th", "") />
		<cfset local.autoclosetags["th"] = ListAppend(local.autoclosetags["th"],"td") />
		<cfset StructInsert(local.autoclosetags, "td", "") />
		<cfset local.autoclosetags["td"] = ListAppend(local.autoclosetags["td"],"th") />
		<cfset local.autoclosetags["td"] = ListAppend(local.autoclosetags["td"],"td") />
		<cfset StructInsert(local.autoclosetags, "tr", "") />
		<cfset local.autoclosetags["tr"] = ListAppend(local.autoclosetags["tr"],"tr") />

		<cfset local.r2 = "" />
		<cfset local.r = "" />
		<cfset local.limit = Len(arguments.s) />
		<cfset local.state = local.states.text />
		<cfset local.prevstate = local.state />

		<cfset local.opentags = createObject("component", "cfc.ebx.commons.collections.java.Stack").init()>
		<cfset local.name = "" />
		<cfset local.tagname = "" />
		<cfset local.attrname = "" />
		<cfset local.attrs = "" />
		<cfset local.attrnames = "" />
		<cfset local.entvalue = 0 />
		<cfset local.attrdelim = '"' />
		<cfset local.attrvalue = "" />
		<cfset local.cs = "" />
		<cfset local.prec = ' ' />
		<cfset local.preprec = ' ' />
		<cfset local.c = ' ' />
		<cfset local.start = 0 />
		<cfset local.encoding = "" />

		<cfif (arguments.s.charAt(0) EQ InputBaseN("0xEF", 16)  AND  arguments.s.charAt(1) EQ InputBaseN("0xBB", 16)  AND  arguments.s.charAt(2) EQ InputBaseN("0xBF",16))>
			<cfset local.encoding =  "utf-8" />
			<cfset local.start =  3 />
		<cfelse>
			<cfset local.encoding =  "iso-8859-1" />
			<cfset local.start =  0 />
		</cfif>
		<cfset local.i = local.start />
		<cfset local.gswitch = true>
		<cfloop condition="local.gswitch">
			<cfset local.gswitch = (local.i LT local.limit AND ((local.r2 EQ "" AND local.r EQ "") OR (NOT local.opentags.empty())))>
			<!--- break wordt onderin de loop afgevangen --->
			<cfif (local.r.length() GT 10240)>
				<cfset local.r2 = local.r2 + local.r />
				<cfset local.r =  "" />
			</cfif>
			<cftry>
				<cfset local.c =  arguments.s.charAt(local.i) />
				<cfset local.switch_handled = false />
				<cfloop condition="NOT local.switch_handled">
					<cfswitch expression="#local.state#">
						<cfcase value="text">
							<cfif (local.c EQ '<')	>
								<cfset local.name =  "" />
								<cfset local.tagname =  "" />
								<cfset local.attrname =  "" />
								<cfset local.attrs =  "" />
								<cfset local.attrnames = "" />
								<cfset local.state =  local.states.tag />
								<cfbreak />
							</cfif>
							<cfif (NOT isWhitespace(local.c)  AND  local.opentags.empty())>
								<cfset local.r = local.r & "<html>" />
								<cfset local.opentags.push("html") />
							</cfif>
							<cfif (isWhitespace(local.c)  AND  local.opentags.empty())>
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '&')	>
								<cfset local.name =  "" />
								<cfset local.entvalue =  0 />
								<cfset local.prevstate =  local.state />
								<cfset local.state =  local.states.entity />
								<cfbreak />
							</cfif>
							<cfset local.r = local.r & local.c />
							<cfbreak />
						</cfcase>
						<cfcase value="tag">
							<cfif (local.c EQ '?'  AND  local.tagname EQ "") >
								<cfset local.state =  local.states.tillinst />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '!'  AND  local.tagname EQ "") >
								<cfset local.state =  local.states.specialtag />
								<cfset local.prec =  ' ' />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '/'  AND  local.name EQ ""  AND  local.tagname EQ "") >
								<cfset local.state =  local.states.endtag />
								<cfset local.name =  "" />
								<cfbreak />
							</cfif>
							<cfif (isWhitespace(local.c))	>
								<cfif (local.name EQ "")	>
									<cfbreak />
								</cfif>
								<cfif (local.tagname EQ ""  AND  local.name NEQ  "_")>
									<cfset local.tagname =  local.name />
									<cfset local.name =  "" />
									<cfbreak />
								</cfif>
								<cfif (local.attrname EQ "") >
									<cfset local.attrname =  local.name.toLowerCase() />
									<cfset local.name =  "" />
									<cfbreak />
								</cfif>
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '=')	>
								<cfif (local.attrname EQ "") >
									<cfset local.attrname =  local.name.toLowerCase() />
									<cfset local.name =  "" />
								</cfif>
								<cfset local.state =  local.states.tillquote />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '/'  AND  (NOT local.tagname EQ ""  OR NOT local.name EQ "")) >
								<cfif (local.tagname EQ "") >
									<cfset local.tagname =  local.name />
								</cfif>
								<cfset local.tagname =  local.tagname.toLowerCase() />
								<cfif (NOT local.tagname EQ "html"  AND  local.opentags.empty()) >
									<cfset local.r = local.r & "<html>" />
									<cfset local.opentags.push("html") />
								</cfif>
								<cfif (local.autoclosetags.containsKey(local.tagname) AND NOT local.opentags.empty())>
									<cfset local.prevtag = local.opentags.peek() />
									<cfif ListFind(local.autoclosetags.get(local.tagname), local.prevtag)>
										<cfset local.opentags.pop() />
										<cfset local.r = local.r & "</" & local.prevtag & ">" />
									</cfif>
								</cfif>
								<cfif local.tagname EQ "tr" AND local.opentags.peek() EQ "table">
									<cfset local.r = local.r & "<tbody>" />
									<cfset local.opentags.push("tbody") />
								</cfif>
								<cfset local.r = local.r & "<" & local.tagname & local.attrs & "/>" />
								<cfset local.state =  local.states.tillgt />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '>')	>
								<cfif (local.tagname EQ ""  AND  NOT local.name EQ "") >
									<cfset local.tagname =  name />
								</cfif>
								<cfif (NOT local.tagname EQ "") >
									<cfset local.tagname =  local.tagname.toLowerCase() />
									<cfif (NOT local.tagname EQ "html"  AND  local.opentags.empty())	>
										<cfset local.r = local.r & "<html>" />
										<cfset local.opentags.push("html") />
									</cfif>
									<cfif (local.autoclosetags.containsKey(local.tagname) AND NOT local.opentags.empty())	>
										<cfset local.prevtag = local.opentags.peek() />
										<cfif ListFind(local.autoclosetags.get(local.tagname), local.prevtag)>
											<cfset local.opentags.pop() />
											<cfset local.r = local.r & "</" & local.prevtag & ">" />
										</cfif>
									</cfif>
									<cfif (local.tagname EQ "tr"  AND  opentags.peek() EQ "table") >
										<cfset local.r = local.r & "<tbody>" />
										<cfset local.opentags.push("tbody") />
									</cfif>
									<cfif (ListFind(local.emptytags,local.tagname))>
										<cfset local.r = local.r & "<" & local.tagname.toLowerCase() & local.attrs & "/>" />
									<cfelse>
										<cfset local.opentags.push(local.tagname) />
										<cfset local.r = local.r & "<" & local.tagname & local.attrs & ">" />
										<cfif (local.tagname EQ "script") >
											<cfset local.r = local.r & "<![CDATA[" />
											<cfset local.opentags.pop() />
											<cfset local.state =  local.states.script />
											<cfbreak />
										</cfif>
									</cfif>
									<cfset local.state =  local.states.text />
									<cfbreak />
								</cfif>
							</cfif>
							<cfif (local.attrname EQ "_") >
								<cfloop condition="(ListFind(local.attrnames, local.attrname))">
									<cfset local.attrname = local.attrname & "_" />
								</cfloop>
							</cfif>
							<cfif (NOT local.attrname EQ ""  AND  NOT ListFind(local.attrnames, local.attrname)  AND  NOT local.attrname EQ "xmlns") >
								<cfset local.attrs = local.attrs & " " & "=\"" & local.attrname & "\"" />
								<cfset local.attrname =  "" />
							</cfif>
							<cfset local.cs =  "" & local.c />
							<!---
							name += (Character.isLetterOrDigit(c) && name != "") || Character.isLetter(c) ? cs : (name EQ "" ? "_" : (c == '-' ? "-" : (!name EQ "_" ? "_" : "")));
							Translated to:
							--->
							<cfif (isLetterOrDigit(local.c) AND local.name NEQ "") OR isLetter(local.c)>
								<cfset local.name = local.name & local.cs />
							<cfelse>
								<cfif local.name EQ "">
									<cfset local.name = local.name & "_" />
								<cfelse>
									<cfif local.c eq "-">
										<cfset local.name = local.name & "-" />
									<cfelse>
										<cfif NOT local.name EQ "_">
											<cfset local.name = local.name & "_" />
										</cfif>
									</cfif>
								</cfif>
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="endtag">
							<cfif (local.c EQ '>') >
								<cfset local.name =  local.name.toLowerCase() />
								<cfif (opentags.search(name)  NEQ  -1) >
									<cfset local.prevtag = local.opentags.pop() />
									<cfloop condition="(local.prevtag NEQ local.name) ">
										<cfset local.r = local.r & "</" & local.prevtag & ">" />
										<cfset local.prevtag = local.opentags.pop() />
									</cfloop>
									<cfset local.r = local.r & "</" & local.name & ">" />
								<cfelse>
									<cfif (local.name NEQ "html"  AND  local.opentags.empty()) >
										<cfset local.r = local.r & "<html>" />
										<cfset local.opentags.push("html") />
									</cfif>
								</cfif>
								<cfset local.state =  local.states.text />
								<cfbreak />
							</cfif>
							<cfif (isWhitespace(local.c)) >
								<cfbreak />
							</cfif>
							<cfset local.cs =  "" & local.c />
							<cfif isLetterOrDigit(local.c)>
								<cfset local.name = local.name & local.cs />
							<cfelse>
								<cfif local.name NEQ "_">
									<cfset local.name = local.name & "_" />
								</cfif>
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="attrtext">
							<cfif (local.c EQ local.attrdelim  OR  (isWhitespace(local.c)  AND  local.attrdelim EQ ' ')) >
								<cfif (local.attrname EQ "_") >
									<cfloop condition="(ListFind(local.attrnames, local.attrname)) ">
										<cfset local.attrname = local.attrname & "_" />
									</cfloop>
								</cfif>
								<cfif (NOT ListFind(local.attrnames, local.attrname)  AND  NOT local.attrname EQ "xmlns") >
									<cfset ListAppend(local.attrnames, local.attrname) />
									<cfset local.attrs = local.attrs & " " & local.attrname & '="' & local.attrvalue & '"' />
								</cfif>
								<cfset local.attrname =  "" />
								<cfset local.state =  local.states.tag />
								<cfbreak />
							</cfif>
							<cfif (local.attrdelim EQ ' '  AND  (local.c EQ '/'  OR  local.c EQ '>')) >
								<cfset local.tagname =  local.tagname.toLowerCase() />
								<cfif (NOT local.tagname EQ "html"  AND  local.opentags.empty()) >
									<cfset local.r = local.r & "<html>" />
									<cfset local.opentags.push("html") />
								</cfif>
								<cfif (local.autoclosetags.containsKey(local.tagname)  AND NOT local.opentags.empty()) >
									<cfset local.prevtag = local.opentags.peek() />
									<cfif (ListFind(local.autoclosetags.get(local.tagname), local.prevtag)) >
										<cfset local.opentags.pop() />
										<cfset local.r = local.r & "</" & local.prevtag & ">" />
									</cfif>
								</cfif>
								<cfif (local.attrname EQ "_") >
									<cfloop condition="(ListFind(local.attrnames, local.attrname)) ">
										<cfset local.attrname = local.attrname & "_" />
									</cfloop>
								</cfif>
								<cfif (NOT ListFind(local.attrnames, local.attrname)  AND  NOT local.attrname EQ "xmlns") >
									<cfset local.attrnames.add(local.attrname) />
									<cfset local.attrs = local.attrs & " " & local.attrname & '="' & local.attrvalue & '"' />
								</cfif>
								<cfset local.attrname =  "" />
								<cfif (local.c EQ '/') >
									<cfset local.r = local.r & "<" & local.tagname & local.attrs & "/>" />
									<cfset local.state =  local.states.tillgt />
									<cfbreak />
								</cfif>
								<cfif (local.c EQ '>') >
									<cfif ListFind(local.emptytags, local.tagname) >
										<cfset local.r = local.r & "<" & local.tagname & local.attrs & "/>" />
										<cfset local.state =  local.states.text />
										<cfbreak />
									<cfelse>
										<cfset local.opentags.push(local.tagname) />
										<cfset local.r = local.r & "<" & local.tagname & local.attrs & ">" />
										<cfif (local.tagname EQ "script") >
											<cfset local.r = local.r & "<![CDATA[" />
											<cfset local.opentags.pop() />
											<cfset local.prec =  ' ' />
											<cfset local.preprec =  ' ' />
											<cfset local.state =  local.states.script />
											<cfbreak />
										</cfif>
										<cfset local.state =  local.states.text />
										<cfbreak />
									</cfif>
								</cfif>
							</cfif>
							<cfif (local.c EQ '&') >
								<cfset local.name =  "" />
								<cfset local.entvalue =  0 />
								<cfset local.prevstate =  state />
								<cfset local.state =  local.states.entity />
								<cfbreak />
							</cfif>
							<cfset local.cs =  "" & local.c />
							<cfif local.c EQ '"'>
								<cfset local.attrvalue = local.attrvalue & "&quot;" />
							<cfelse>
								<cfif local.c EQ "'">
									<cfset local.attrvalue = local.attrvalue & "&apos;" />
								<cfelse>
									<cfset local.attrvalue = local.attrvalue & local.cs />
								</cfif>
							</cfif>
							<cfbreak />
						</cfcase>

						<cfcase value="script">
							<cfif (local.c EQ '/'  AND  local.prec EQ '<')>
								<cfset local.state =  local.states.endscript />
								<cfset local.name =  "" />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '['  AND  local.prec EQ '!'  AND  local.preprec EQ '<') >
								<cfset local.state =  local.states.skipcdata />
								<cfset local.name =  "<![" />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '>'  AND  local.prec EQ ']'  AND  local.preprec EQ ']') >
									<cfset local.c =  local.r.charAt(local.r.length() - 3) />
									<cfset local.r =  local.r.substring(0, local.r.length() - 4) />
							</cfif>
							<cfset local.r = local.r & local.c />
							<cfset local.preprec =  local.prec />
							<cfset local.prec =  local.c />
							<cfbreak />
						</cfcase>
						<cfcase value="endscript">
							<cfif (local.c EQ '>'  AND  local.name.toLowerCase() EQ "script") >
								<cfset local.r =  r.substring(0, r.length() - 1) />
								<cfset local.r = local.r & "]]></script>" />
								<cfset local.state =  local.states.text />
								<cfbreak />
							</cfif>
							<cfset local.name = local.name + local.c />
							<cfset local.sscr = "script" />
							<cfif (!sscr.startsWith(local.name.toLowerCase())) >
								<cfset local.r = local.r & local.name />
								<cfset local.state =  local.states.script />
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="specialtag">
							<cfif (c  NEQ  '-') >
								<cfset local.state =  local.states.tillgt />
								<cfbreak />
							</cfif>
							<cfif (prec EQ '-') >
								<cfset local.state =  local.states.comment />
								<cfset local.preprec =  ' ' />
								<cfbreak />
							</cfif>
							<cfset local.prec = local.c />
							<cfbreak />
						</cfcase>
						<cfcase value="comment">
							<cfif (local.c EQ '>'  AND  prec EQ '-'  AND  preprec EQ '-') >
								<cfset local.state =  local.states.text />
								<cfbreak />
							</cfif>
							<cfset local.preprec =  local.prec />
							<cfset local.prec =  local.c />
							<cfbreak />
						</cfcase>
						<cfcase value="skipcdata">
							<cfif (local.name EQ "<![CDATA[") >
								<cfset local.state =  local.states.script />
								<cfbreak />
							</cfif>
							<cfset local.name = local.name & local.c />
							<cfset local.scdata = "<![CDATA[" />
							<cfif (NOT local.scdata.startsWith(local.name)) >
								<cfset local.r = local.r & local.name />
								<cfset local.state =  local.states.script />
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="entity">
							<cfif (local.c EQ CHR(35)) >
								<cfset local.state =  local.states.numericentity />
								<cfbreak />
							</cfif>
							<cfset local.name = local.name & local.c />
							<cfset local.state =  local.states.namedentity />
							<cfbreak />
						</cfcase>
						<cfcase value="numericentity">
							<cfif (local.c EQ 'x'  OR  local.c EQ 'X') >
								<cfset local.state =  local.states.hexaentity />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ ';') >
								<cfset local.ent = "&##" & local.entvalue & ";" />
								<cfif (local.prevstate EQ local.states.text) >
									<cfset local.r = local.r & local.ent />
								<cfelse>
									<cfset local.attrvalue = local.attrvalue & local.ent />
								</cfif>
								<cfset local.state =  prevstate />
								<cfbreak />
							</cfif>
							<cfset local.entvalue =  entvalue * 10 & local.c - '0' />
							<cfbreak />
						</cfcase>
						<cfcase value="hexaentity">
							<cfif (local.c EQ ';') >
								<cfset local.ent = "&##" & local.entvalue & ";" />
								<cfif (local.prevstate EQ local.states.text)	>
									<cfset local.r = local.r & local.ent />
								<cfelse>
									<cfset local.attrvalue = local.attrvalue & local.ent />
								</cfif>
								<cfset local.state =  prevstate />
								<cfbreak />
							</cfif>
							<!--- <cfset local.entvalue =  local.entvalue * 16 & (Character.isDigit(c) ? local.c - '0' : Character.toUpperCase(c) - 'A') /> --->
							<cfset local.entvalue = "DEEBAC">
							<cfbreak />
						</cfcase>
						<cfcase value="namedentity">
							<cfif (local.c EQ ';') >
								<cfset local.ent = "" />
								<cfset local.name =  local.name.toLowerCase() />
								<cfif (local.name EQ "amp"  OR  local.name EQ "lt"  OR  local.name EQ "gt"  OR  local.name EQ "quot"  OR  local.name EQ "apos") >
									<cfset local.ent =  "&" + local.name + ";" />
									<cfset local.name =  "" />
									<cfif (local.prevstate EQ local.states.text) >
										<cfset local.r = local.r & local.ent />
									<cfelse>
										<cfset local.attrvalue = local.attrvalue + local.ent />
									</cfif>
									<cfset local.state =  prevstate />
									<cfbreak />
								</cfif>
								<cfif (ListFind(local.namedentities, local.name)) >
									<cfset local.entvalue =  local.namedentities.get(local.name) />
								<cfelse>
									<cfset local.entvalue =  0 />
								</cfif>
								<cfset local.ent =  "&" + local.entvalue + ";" />
								<cfset local.name =  "" />
								<cfif (local.prevstate EQ local.states.text) >
									<cfset local.r = local.r & local.ent />
								<cfelse>
									<cfset local.attrvalue = local.attrvalue + local.ent />
								</cfif>
								<cfset local.state =  prevstate />
								<cfbreak />
							</cfif>
							<cfif (NOT isLetterOrDigit(local.c)  OR  local.name.length() GT 6)>
								<cfset local.ent = "&amp;" & local.name />
								<cfset local.name =  "" />
								<cfif (local.prevstate EQ local.states.text) >
									<cfset local.r = local.r & local.ent />
								<cfelse>
									<cfset local.attrvalue = local.attrvalue + local.ent />
								</cfif>
								<cfset local.state =  prevstate />
								<cfset local.i = local.i - 1 />
								<cfbreak />
							</cfif>
							<cfset local.name = local.name & local.c />
							<cfbreak />
						</cfcase>
						<cfcase value="tillinst">
							<cfif (local.c EQ '?') >
									<cfset local.state =  local.states.andgt />
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="andgt">
							<cfif (local.c EQ '>') >
								<cfset local.state =  local.states.text />
								<cfbreak />
							</cfif>
							<cfset local.state =  local.states.tillinst />
							<cfbreak />
						</cfcase>
						<cfcase value="tillgt">
							<cfif (local.c EQ '>') >
								<cfset local.state =  local.states.text />
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="tillquote">
							<cfif (isWhitespace(local.c)) >
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '"'  OR  local.c EQ "'") >
								<cfset local.attrdelim =  local.c />
								<cfset local.attrvalue =  "" />
								<cfset local.state =  local.states.attrtext />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '/'  OR  local.c EQ '>') >
								<cfif (local.attrname EQ "_") >
									<cfloop condition="(ListFind(local.attrnames, local.attrname))">
										<cfset local.attrname = local.attrname & "_" />
									</cfloop>
								</cfif>
								<cfif (NOT ListFind(local.attrnames, local.attrname)  AND  NOT local.attrname EQ "xmlns") >
									<cfset local.attrnames.add(local.attrname) />
									<cfset local.attrs = local.attrs & " " & local.attrname & '= "' & attrvalue & '"' />
								</cfif>
								<cfset local.attrname =  "" />
							</cfif>
							<cfif (local.c EQ '/') >
								<cfset local.r = local.r & "<" & local.tagname.toLowerCase() & local.attrs & "/>" />
								<cfset local.state =  local.states.tillgt />
								<cfbreak />
							</cfif>
							<cfif (local.c EQ '>') >
								<cfset local.tagname =  local.tagname.toLowerCase() />
								<cfif (NOT local.tagname EQ "html"  AND  local.opentags.empty()) >
									<cfset local.r = local.r & "<html>" />
									<cfset local.opentags.push("html") />
								</cfif>
								<cfif (local.autoclosetags.containsKey(local.tagname) AND NOT local.opentags.empty())>
									<cfset local.prevtag = local.opentags.peek() />
									<cfif (ListFind(local.autoclosetags.get(local.tagname), local.prevtag))>
										<cfset local.opentags.pop() />
										<cfset local.r = local.r & "</" & local.prevtag & ">" />
									</cfif>
								</cfif>
								<cfif ListFind(local.emptytags, local.tagname)>
									<cfset local.r = local.r & "<" & local.tagname & local.attrs & "/>" />
									<cfset local.state =  local.states.text />
									<cfbreak />
								<cfelse>
									<cfset local.opentags.push(local.tagname) />
									<cfset local.r = local.r & "<" & local.tagname & local.attrs & ">" />
									<cfif (local.tagname EQ "script") >
										<cfset local.r = local.r & "<![CDATA[" />
										<cfset local.opentags.pop() />
										<cfset local.state =  local.states.script />
										<cfbreak />
									</cfif>
								</cfif>
							</cfif>
							<cfset local.attrdelim =  ' ' />
							<cfset local.attrvalue =  "" & local.c />
							<cfset local.state =  local.states.attrtext />
							<cfbreak />
						</cfcase>
					</cfswitch>
					<cfset local.switch_handled = true />
				</cfloop>
				<cfcatch type="any">
					<cfoutput><p>#cfcatch.message# #cfcatch.detail# <cfdump var="#cfcatch#"></p></cfoutput>
					<cfset local.switch_handled = true />
					<cfbreak />
				</cfcatch>
			</cftry>
			<cfset local.i = local.i + 1 />
			<cfif local.i GTE local.limit>
				<cfbreak>
			</cfif>
			<!--- <cfif local.i LTE 1000>
				<cfoutput>#local.i# [#local.state#]: #local.r#: #local.tagname#<br /></cfoutput>
			<cfelse>
				<cfbreak />
			</cfif> --->
		</cfloop>
		<cfloop condition="(NOT local.opentags.empty())">
			<cfset local.r = local.r & "</" & local.opentags.pop() & ">" />
		</cfloop>
		<cfset local.r2 = local.r2 & local.r />
		<cfdump var="#local.i#">
		<cfreturn '<?xml version="1.0" encoding="' & local.encoding & '"?>' & CHR(10) & local.r2 />
	</cffunction>
</cfcomponent>