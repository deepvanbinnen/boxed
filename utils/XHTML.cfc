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

		<cfset var lcl = StructNew() />
		<cfset lcl.states = StructNew() />
		<cfset lcl.states.text = "text" />
		<cfset lcl.states.tag = "tag" />
		<cfset lcl.states.endtag = "endtag" />
		<cfset lcl.states.attrtext = "attrtext" />
		<cfset lcl.states.script = "script" />
		<cfset lcl.states.endscript = "endscript" />
		<cfset lcl.states.specialtag = "specialtag" />
		<cfset lcl.states.comment = "comment" />
		<cfset lcl.states.skipcdata = "skipcdata" />
		<cfset lcl.states.entity = "entity" />
		<cfset lcl.states.namedentity = "namedentity" />
		<cfset lcl.states.numericentity = "numericentity" />
		<cfset lcl.states.hexaentity = "hexaentity" />
		<cfset lcl.states.tillgt = "tillgt" />
		<cfset lcl.states.tillquote = "tillquote" />
		<cfset lcl.states.tillinst = "tillinst" />
		<cfset lcl.states.andgt = "andgt" />

		<cfset lcl.namedentities = StructNew() />
		<cfset lcl.emptytags = "" />
		<cfset lcl.autoclosetags = StructNew() />

		<cfset StructInsert(lcl.namedentities, "AElig",  198, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Aacute",  193, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Acirc",  194, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Agrave",  192, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Alpha",  913, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Aring",  197, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Atilde",  195, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Auml",  196, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Beta",  914, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Ccedil",  199, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Chi",  935, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Dagger",  8225, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Delta",  916, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ETH",  208, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Eacute",  201, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Ecirc",  202, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Egrave",  200, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Epsilon",  917, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Eta",  919, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Euml",  203, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Gamma",  915, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Iacute",  205, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Icirc",  206, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Igrave",  204, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Iota",  921, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Iuml",  207, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Kappa",  922, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Lambda",  923, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Mu",  924, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Ntilde",  209, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Nu",  925, TRUE) />
		<cfset StructInsert(lcl.namedentities, "OElig",  338, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Oacute",  211, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Ocirc",  212, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Ograve",  210, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Omega",  937, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Omicron",  927, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Oslash",  216, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Otilde",  213, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Ouml",  214, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Phi",  934, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Pi",  928, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Prime",  8243, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Psi",  936, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Rho",  929, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Scaron",  352, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Sigma",  931, TRUE) />
		<cfset StructInsert(lcl.namedentities, "THORN",  222, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Tau",  932, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Theta",  920, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Uacute",  218, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Ucirc",  219, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Ugrave",  217, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Upsilon",  933, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Uuml",  220, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Xi",  926, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Yacute",  221, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Yuml",  376, TRUE) />
		<cfset StructInsert(lcl.namedentities, "Zeta",  918, TRUE) />
		<cfset StructInsert(lcl.namedentities, "aacute",  225, TRUE) />
		<cfset StructInsert(lcl.namedentities, "acirc",  226, TRUE) />
		<cfset StructInsert(lcl.namedentities, "acute",  180, TRUE) />
		<cfset StructInsert(lcl.namedentities, "aelig",  230, TRUE) />
		<cfset StructInsert(lcl.namedentities, "agrave",  224, TRUE) />
		<cfset StructInsert(lcl.namedentities, "alpha",  945, TRUE) />
		<cfset StructInsert(lcl.namedentities, "and",  8743, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ang",  8736, TRUE) />
		<cfset StructInsert(lcl.namedentities, "aring",  229, TRUE) />
		<cfset StructInsert(lcl.namedentities, "asymp",  8776, TRUE) />
		<cfset StructInsert(lcl.namedentities, "atilde",  227, TRUE) />
		<cfset StructInsert(lcl.namedentities, "auml",  228, TRUE) />
		<cfset StructInsert(lcl.namedentities, "bdquo",  8222, TRUE) />
		<cfset StructInsert(lcl.namedentities, "beta",  946, TRUE) />
		<cfset StructInsert(lcl.namedentities, "brvbar",  166, TRUE) />
		<cfset StructInsert(lcl.namedentities, "bull",  8226, TRUE) />
		<cfset StructInsert(lcl.namedentities, "cap",  8745, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ccedil",  231, TRUE) />
		<cfset StructInsert(lcl.namedentities, "cedil",  184, TRUE) />
		<cfset StructInsert(lcl.namedentities, "cent",  162, TRUE) />
		<cfset StructInsert(lcl.namedentities, "chi",  967, TRUE) />
		<cfset StructInsert(lcl.namedentities, "circ",  710, TRUE) />
		<cfset StructInsert(lcl.namedentities, "clubs",  9827, TRUE) />
		<cfset StructInsert(lcl.namedentities, "cong",  8773, TRUE) />
		<cfset StructInsert(lcl.namedentities, "copy",  169, TRUE) />
		<cfset StructInsert(lcl.namedentities, "crarr",  8629, TRUE) />
		<cfset StructInsert(lcl.namedentities, "cup",  8746, TRUE) />
		<cfset StructInsert(lcl.namedentities, "curren",  164, TRUE) />
		<cfset StructInsert(lcl.namedentities, "dagger",  8224, TRUE) />
		<cfset StructInsert(lcl.namedentities, "darr",  8595, TRUE) />
		<cfset StructInsert(lcl.namedentities, "deg",  176, TRUE) />
		<cfset StructInsert(lcl.namedentities, "delta",  948, TRUE) />
		<cfset StructInsert(lcl.namedentities, "diams",  9830, TRUE) />
		<cfset StructInsert(lcl.namedentities, "divide",  247, TRUE) />
		<cfset StructInsert(lcl.namedentities, "eacute",  233, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ecirc",  234, TRUE) />
		<cfset StructInsert(lcl.namedentities, "egrave",  232, TRUE) />
		<cfset StructInsert(lcl.namedentities, "empty",  8709, TRUE) />
		<cfset StructInsert(lcl.namedentities, "emsp",  8195, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ensp",  8194, TRUE) />
		<cfset StructInsert(lcl.namedentities, "epsilon",  949, TRUE) />
		<cfset StructInsert(lcl.namedentities, "equiv",  8801, TRUE) />
		<cfset StructInsert(lcl.namedentities, "eta",  951, TRUE) />
		<cfset StructInsert(lcl.namedentities, "eth",  240, TRUE) />
		<cfset StructInsert(lcl.namedentities, "euml",  235, TRUE) />
		<cfset StructInsert(lcl.namedentities, "euro",  8364, TRUE) />
		<cfset StructInsert(lcl.namedentities, "exists",  8707, TRUE) />
		<cfset StructInsert(lcl.namedentities, "fnof",  402, TRUE) />
		<cfset StructInsert(lcl.namedentities, "forall",  8704, TRUE) />
		<cfset StructInsert(lcl.namedentities, "frac12",  189, TRUE) />
		<cfset StructInsert(lcl.namedentities, "frac14",  188, TRUE) />
		<cfset StructInsert(lcl.namedentities, "frac34",  190, TRUE) />
		<cfset StructInsert(lcl.namedentities, "gamma",  947, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ge",  8805, TRUE) />
		<cfset StructInsert(lcl.namedentities, "harr",  8596, TRUE) />
		<cfset StructInsert(lcl.namedentities, "hearts",  9829, TRUE) />
		<cfset StructInsert(lcl.namedentities, "hellip",  8230, TRUE) />
		<cfset StructInsert(lcl.namedentities, "iacute",  237, TRUE) />
		<cfset StructInsert(lcl.namedentities, "icirc",  238, TRUE) />
		<cfset StructInsert(lcl.namedentities, "iexcl",  161, TRUE) />
		<cfset StructInsert(lcl.namedentities, "igrave",  236, TRUE) />
		<cfset StructInsert(lcl.namedentities, "infin",  8734, TRUE) />
		<cfset StructInsert(lcl.namedentities, "int",  8747, TRUE) />
		<cfset StructInsert(lcl.namedentities, "iota",  953, TRUE) />
		<cfset StructInsert(lcl.namedentities, "iquest",  191, TRUE) />
		<cfset StructInsert(lcl.namedentities, "isin",  8712, TRUE) />
		<cfset StructInsert(lcl.namedentities, "iuml",  239, TRUE) />
		<cfset StructInsert(lcl.namedentities, "kappa",  954, TRUE) />
		<cfset StructInsert(lcl.namedentities, "lambda",  923, TRUE) />
		<cfset StructInsert(lcl.namedentities, "laquo",  171, TRUE) />
		<cfset StructInsert(lcl.namedentities, "larr",  8592, TRUE) />
		<cfset StructInsert(lcl.namedentities, "lceil",  8968, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ldquo",  8220, TRUE) />
		<cfset StructInsert(lcl.namedentities, "le",  8804, TRUE) />
		<cfset StructInsert(lcl.namedentities, "lfloor",  8970, TRUE) />
		<cfset StructInsert(lcl.namedentities, "lowast",  8727, TRUE) />
		<cfset StructInsert(lcl.namedentities, "loz",  9674, TRUE) />
		<cfset StructInsert(lcl.namedentities, "lrm",  8206, TRUE) />
		<cfset StructInsert(lcl.namedentities, "lsaquo",  8249, TRUE) />
		<cfset StructInsert(lcl.namedentities, "lsquo",  8216, TRUE) />
		<cfset StructInsert(lcl.namedentities, "macr",  175, TRUE) />
		<cfset StructInsert(lcl.namedentities, "mdash",  8212, TRUE) />
		<cfset StructInsert(lcl.namedentities, "micro",  181, TRUE) />
		<cfset StructInsert(lcl.namedentities, "middot",  183, TRUE) />
		<cfset StructInsert(lcl.namedentities, "minus",  8722, TRUE) />
		<cfset StructInsert(lcl.namedentities, "mu",  956, TRUE) />
		<cfset StructInsert(lcl.namedentities, "nabla",  8711, TRUE) />
		<cfset StructInsert(lcl.namedentities, "nbsp",  160, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ndash",  8211, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ne",  8800, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ni",  8715, TRUE) />
		<cfset StructInsert(lcl.namedentities, "not",  172, TRUE) />
		<cfset StructInsert(lcl.namedentities, "notin",  8713, TRUE) />
		<cfset StructInsert(lcl.namedentities, "nsub",  8836, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ntilde",  241, TRUE) />
		<cfset StructInsert(lcl.namedentities, "nu",  925, TRUE) />
		<cfset StructInsert(lcl.namedentities, "oacute",  243, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ocirc",  244, TRUE) />
		<cfset StructInsert(lcl.namedentities, "oelig",  339, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ograve",  242, TRUE) />
		<cfset StructInsert(lcl.namedentities, "oline",  8254, TRUE) />
		<cfset StructInsert(lcl.namedentities, "omega",  969, TRUE) />
		<cfset StructInsert(lcl.namedentities, "omicron",  959, TRUE) />
		<cfset StructInsert(lcl.namedentities, "oplus",  8853, TRUE) />
		<cfset StructInsert(lcl.namedentities, "or",  8744, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ordf",  170, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ordm",  186, TRUE) />
		<cfset StructInsert(lcl.namedentities, "oslash",  248, TRUE) />
		<cfset StructInsert(lcl.namedentities, "otilde",  245, TRUE) />
		<cfset StructInsert(lcl.namedentities, "otimes",  8855, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ouml",  246, TRUE) />
		<cfset StructInsert(lcl.namedentities, "para",  182, TRUE) />
		<cfset StructInsert(lcl.namedentities, "part",  8706, TRUE) />
		<cfset StructInsert(lcl.namedentities, "permil",  8240, TRUE) />
		<cfset StructInsert(lcl.namedentities, "perp",  8869, TRUE) />
		<cfset StructInsert(lcl.namedentities, "phi",  966, TRUE) />
		<cfset StructInsert(lcl.namedentities, "pi",  960, TRUE) />
		<cfset StructInsert(lcl.namedentities, "piv",  982, TRUE) />
		<cfset StructInsert(lcl.namedentities, "plusmn",  177, TRUE) />
		<cfset StructInsert(lcl.namedentities, "pound",  163, TRUE) />
		<cfset StructInsert(lcl.namedentities, "prime",  8242, TRUE) />
		<cfset StructInsert(lcl.namedentities, "prod",  8719, TRUE) />
		<cfset StructInsert(lcl.namedentities, "prop",  8733, TRUE) />
		<cfset StructInsert(lcl.namedentities, "psi",  968, TRUE) />
		<cfset StructInsert(lcl.namedentities, "radic",  8730, TRUE) />
		<cfset StructInsert(lcl.namedentities, "raquo",  187, TRUE) />
		<cfset StructInsert(lcl.namedentities, "rarr",  8594, TRUE) />
		<cfset StructInsert(lcl.namedentities, "rceil",  8969, TRUE) />
		<cfset StructInsert(lcl.namedentities, "rdquo",  8221, TRUE) />
		<cfset StructInsert(lcl.namedentities, "reg",  174, TRUE) />
		<cfset StructInsert(lcl.namedentities, "rfloor",  8971, TRUE) />
		<cfset StructInsert(lcl.namedentities, "rho",  961, TRUE) />
		<cfset StructInsert(lcl.namedentities, "rlm",  8207, TRUE) />
		<cfset StructInsert(lcl.namedentities, "rsaquo",  8250, TRUE) />
		<cfset StructInsert(lcl.namedentities, "rsquo",  8217, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sbquo",  8218, TRUE) />
		<cfset StructInsert(lcl.namedentities, "scaron",  353, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sdot",  8901, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sect",  167, TRUE) />
		<cfset StructInsert(lcl.namedentities, "shy",  173, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sigma",  963, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sigmaf",  962, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sim",  8764, TRUE) />
		<cfset StructInsert(lcl.namedentities, "spades",  9824, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sub",  8834, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sube",  8838, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sum",  8721, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sup",  8835, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sup1",  185, TRUE) />
		<cfset StructInsert(lcl.namedentities, "sup3",  179, TRUE) />
		<cfset StructInsert(lcl.namedentities, "supe",  8839, TRUE) />
		<cfset StructInsert(lcl.namedentities, "szlig",  223, TRUE) />
		<cfset StructInsert(lcl.namedentities, "tau",  964, TRUE) />
		<cfset StructInsert(lcl.namedentities, "there4",  8756, TRUE) />
		<cfset StructInsert(lcl.namedentities, "theta",  952, TRUE) />
		<cfset StructInsert(lcl.namedentities, "thetasym",  977, TRUE) />
		<cfset StructInsert(lcl.namedentities, "thinsp",  8201, TRUE) />
		<cfset StructInsert(lcl.namedentities, "thorn",  254, TRUE) />
		<cfset StructInsert(lcl.namedentities, "tilde",  732, TRUE) />
		<cfset StructInsert(lcl.namedentities, "times",  215, TRUE) />
		<cfset StructInsert(lcl.namedentities, "trade",  8482, TRUE) />
		<cfset StructInsert(lcl.namedentities, "uacute",  250, TRUE) />
		<cfset StructInsert(lcl.namedentities, "uarr",  8593, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ucirc",  251, TRUE) />
		<cfset StructInsert(lcl.namedentities, "ugrave",  249, TRUE) />
		<cfset StructInsert(lcl.namedentities, "uml",  168, TRUE) />
		<cfset StructInsert(lcl.namedentities, "up2",  178, TRUE) />
		<cfset StructInsert(lcl.namedentities, "upsih",  978, TRUE) />
		<cfset StructInsert(lcl.namedentities, "upsilon",  965, TRUE) />
		<cfset StructInsert(lcl.namedentities, "uuml",  252, TRUE) />
		<cfset StructInsert(lcl.namedentities, "xi",  958, TRUE) />
		<cfset StructInsert(lcl.namedentities, "yacute",  253, TRUE) />
		<cfset StructInsert(lcl.namedentities, "yen",  165, TRUE) />
		<cfset StructInsert(lcl.namedentities, "yuml",  255, TRUE) />
		<cfset StructInsert(lcl.namedentities, "zeta",  950, TRUE) />
		<cfset StructInsert(lcl.namedentities, "zwj",  8205, TRUE) />
		<cfset StructInsert(lcl.namedentities, "zwnj",  8204, TRUE) />

		<cfset lcl.emptytags = ListAppend(emptytags, "area") />
		<cfset lcl.emptytags = ListAppend(emptytags, "base") />
		<cfset lcl.emptytags = ListAppend(emptytags, "basefont") />
		<cfset lcl.emptytags = ListAppend(emptytags, "br") />
		<cfset lcl.emptytags = ListAppend(emptytags, "col") />
		<cfset lcl.emptytags = ListAppend(emptytags, "frame") />
		<cfset lcl.emptytags = ListAppend(emptytags, "hr") />
		<cfset lcl.emptytags = ListAppend(emptytags, "img") />
		<cfset lcl.emptytags = ListAppend(emptytags, "input") />
		<cfset lcl.emptytags = ListAppend(emptytags, "isindex") />
		<cfset lcl.emptytags = ListAppend(emptytags, "link") />
		<cfset lcl.emptytags = ListAppend(emptytags, "meta") />
		<cfset lcl.emptytags = ListAppend(emptytags, "param") />

		<cfset StructInsert(lcl.autoclosetags, "basefont", "") />
		<cfset lcl.autoclosetags["basefont"] = ListAppend(lcl.autoclosetags["basefont"],"basefont") />
		<cfset StructInsert(lcl.autoclosetags, "colgroup", "") />
		<cfset lcl.autoclosetags["colgroup"] = ListAppend(lcl.autoclosetags["colgroup"],"colgroup") />
		<cfset StructInsert(lcl.autoclosetags, "dd", "") />
		<cfset lcl.autoclosetags["dd"] = ListAppend(lcl.autoclosetags["dd"],"colgroup") />
		<cfset StructInsert(lcl.autoclosetags, "dt", "") />
		<cfset lcl.autoclosetags["dt"] = ListAppend(lcl.autoclosetags["dt"],"dt") />
		<cfset StructInsert(lcl.autoclosetags, "li", "") />
		<cfset lcl.autoclosetags["li"] = ListAppend(lcl.autoclosetags["li"],"li") />
		<cfset StructInsert(lcl.autoclosetags, "p", "") />
		<cfset lcl.autoclosetags["p"] = ListAppend(lcl.autoclosetags["p"],"p") />
		<cfset StructInsert(lcl.autoclosetags, "thead", "") />
		<cfset lcl.autoclosetags["thead"] = ListAppend(lcl.autoclosetags["thead"],"tbody") />
		<cfset lcl.autoclosetags["thead"] = ListAppend(lcl.autoclosetags["thead"],"tfoot") />
		<cfset StructInsert(lcl.autoclosetags, "tbody", "") />
		<cfset lcl.autoclosetags["tbody"] = ListAppend(lcl.autoclosetags["tbody"],"thead") />
		<cfset lcl.autoclosetags["tbody"] = ListAppend(lcl.autoclosetags["tbody"],"tfoot") />
		<cfset StructInsert(lcl.autoclosetags, "tfoot", "") />
		<cfset lcl.autoclosetags["tfoot"] = ListAppend(lcl.autoclosetags["tfoot"],"thead") />
		<cfset lcl.autoclosetags["tfoot"] = ListAppend(lcl.autoclosetags["tfoot"],"tbody") />
		<cfset StructInsert(lcl.autoclosetags, "th", "") />
		<cfset lcl.autoclosetags["th"] = ListAppend(lcl.autoclosetags["th"],"td") />
		<cfset StructInsert(lcl.autoclosetags, "td", "") />
		<cfset lcl.autoclosetags["td"] = ListAppend(lcl.autoclosetags["td"],"th") />
		<cfset lcl.autoclosetags["td"] = ListAppend(lcl.autoclosetags["td"],"td") />
		<cfset StructInsert(lcl.autoclosetags, "tr", "") />
		<cfset lcl.autoclosetags["tr"] = ListAppend(lcl.autoclosetags["tr"],"tr") />

		<cfset lcl.r2 = "" />
		<cfset lcl.r = "" />
		<cfset lcl.limit = Len(arguments.s) />
		<cfset lcl.state = lcl.states.text />
		<cfset lcl.prevstate = lcl.state />

		<cfset lcl.opentags = createObject("component", "cfc.ebx.commons.collections.java.Stack").init()>
		<cfset lcl.name = "" />
		<cfset lcl.tagname = "" />
		<cfset lcl.attrname = "" />
		<cfset lcl.attrs = "" />
		<cfset lcl.attrnames = "" />
		<cfset lcl.entvalue = 0 />
		<cfset lcl.attrdelim = '"' />
		<cfset lcl.attrvalue = "" />
		<cfset lcl.cs = "" />
		<cfset lcl.prec = ' ' />
		<cfset lcl.preprec = ' ' />
		<cfset lcl.c = ' ' />
		<cfset lcl.start = 0 />
		<cfset lcl.encoding = "" />

		<cfif (arguments.s.charAt(0) EQ InputBaseN("0xEF", 16)  AND  arguments.s.charAt(1) EQ InputBaseN("0xBB", 16)  AND  arguments.s.charAt(2) EQ InputBaseN("0xBF",16))>
			<cfset lcl.encoding =  "utf-8" />
			<cfset lcl.start =  3 />
		<cfelse>
			<cfset lcl.encoding =  "iso-8859-1" />
			<cfset lcl.start =  0 />
		</cfif>
		<cfset lcl.i = lcl.start />
		<cfset lcl.gswitch = true>
		<cfloop condition="lcl.gswitch">
			<cfset lcl.gswitch = (lcl.i LT lcl.limit AND ((lcl.r2 EQ "" AND lcl.r EQ "") OR (NOT lcl.opentags.empty())))>
			<!--- break wordt onderin de loop afgevangen --->
			<cfif (lcl.r.length() GT 10240)>
				<cfset lcl.r2 = lcl.r2 + lcl.r />
				<cfset lcl.r =  "" />
			</cfif>
			<cftry>
				<cfset lcl.c =  arguments.s.charAt(lcl.i) />
				<cfset lcl.switch_handled = false />
				<cfloop condition="NOT lcl.switch_handled">
					<cfswitch expression="#lcl.state#">
						<cfcase value="text">
							<cfif (lcl.c EQ '<')	>
								<cfset lcl.name =  "" />
								<cfset lcl.tagname =  "" />
								<cfset lcl.attrname =  "" />
								<cfset lcl.attrs =  "" />
								<cfset lcl.attrnames = "" />
								<cfset lcl.state =  lcl.states.tag />
								<cfbreak />
							</cfif>
							<cfif (NOT isWhitespace(lcl.c)  AND  lcl.opentags.empty())>
								<cfset lcl.r = lcl.r & "<html>" />
								<cfset lcl.opentags.push("html") />
							</cfif>
							<cfif (isWhitespace(lcl.c)  AND  lcl.opentags.empty())>
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '&')	>
								<cfset lcl.name =  "" />
								<cfset lcl.entvalue =  0 />
								<cfset lcl.prevstate =  lcl.state />
								<cfset lcl.state =  lcl.states.entity />
								<cfbreak />
							</cfif>
							<cfset lcl.r = lcl.r & lcl.c />
							<cfbreak />
						</cfcase>
						<cfcase value="tag">
							<cfif (lcl.c EQ '?'  AND  lcl.tagname EQ "") >
								<cfset lcl.state =  lcl.states.tillinst />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '!'  AND  lcl.tagname EQ "") >
								<cfset lcl.state =  lcl.states.specialtag />
								<cfset lcl.prec =  ' ' />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '/'  AND  lcl.name EQ ""  AND  lcl.tagname EQ "") >
								<cfset lcl.state =  lcl.states.endtag />
								<cfset lcl.name =  "" />
								<cfbreak />
							</cfif>
							<cfif (isWhitespace(lcl.c))	>
								<cfif (lcl.name EQ "")	>
									<cfbreak />
								</cfif>
								<cfif (lcl.tagname EQ ""  AND  lcl.name NEQ  "_")>
									<cfset lcl.tagname =  lcl.name />
									<cfset lcl.name =  "" />
									<cfbreak />
								</cfif>
								<cfif (lcl.attrname EQ "") >
									<cfset lcl.attrname =  lcl.name.toLowerCase() />
									<cfset lcl.name =  "" />
									<cfbreak />
								</cfif>
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '=')	>
								<cfif (lcl.attrname EQ "") >
									<cfset lcl.attrname =  lcl.name.toLowerCase() />
									<cfset lcl.name =  "" />
								</cfif>
								<cfset lcl.state =  lcl.states.tillquote />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '/'  AND  (NOT lcl.tagname EQ ""  OR NOT lcl.name EQ "")) >
								<cfif (lcl.tagname EQ "") >
									<cfset lcl.tagname =  lcl.name />
								</cfif>
								<cfset lcl.tagname =  lcl.tagname.toLowerCase() />
								<cfif (NOT lcl.tagname EQ "html"  AND  lcl.opentags.empty()) >
									<cfset lcl.r = lcl.r & "<html>" />
									<cfset lcl.opentags.push("html") />
								</cfif>
								<cfif (lcl.autoclosetags.containsKey(lcl.tagname) AND NOT lcl.opentags.empty())>
									<cfset lcl.prevtag = lcl.opentags.peek() />
									<cfif ListFind(lcl.autoclosetags.get(lcl.tagname), lcl.prevtag)>
										<cfset lcl.opentags.pop() />
										<cfset lcl.r = lcl.r & "</" & lcl.prevtag & ">" />
									</cfif>
								</cfif>
								<cfif lcl.tagname EQ "tr" AND lcl.opentags.peek() EQ "table">
									<cfset lcl.r = lcl.r & "<tbody>" />
									<cfset lcl.opentags.push("tbody") />
								</cfif>
								<cfset lcl.r = lcl.r & "<" & lcl.tagname & lcl.attrs & "/>" />
								<cfset lcl.state =  lcl.states.tillgt />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '>')	>
								<cfif (lcl.tagname EQ ""  AND  NOT lcl.name EQ "") >
									<cfset lcl.tagname =  name />
								</cfif>
								<cfif (NOT lcl.tagname EQ "") >
									<cfset lcl.tagname =  lcl.tagname.toLowerCase() />
									<cfif (NOT lcl.tagname EQ "html"  AND  lcl.opentags.empty())	>
										<cfset lcl.r = lcl.r & "<html>" />
										<cfset lcl.opentags.push("html") />
									</cfif>
									<cfif (lcl.autoclosetags.containsKey(lcl.tagname) AND NOT lcl.opentags.empty())	>
										<cfset lcl.prevtag = lcl.opentags.peek() />
										<cfif ListFind(lcl.autoclosetags.get(lcl.tagname), lcl.prevtag)>
											<cfset lcl.opentags.pop() />
											<cfset lcl.r = lcl.r & "</" & lcl.prevtag & ">" />
										</cfif>
									</cfif>
									<cfif (lcl.tagname EQ "tr"  AND  opentags.peek() EQ "table") >
										<cfset lcl.r = lcl.r & "<tbody>" />
										<cfset lcl.opentags.push("tbody") />
									</cfif>
									<cfif (ListFind(lcl.emptytags,lcl.tagname))>
										<cfset lcl.r = lcl.r & "<" & lcl.tagname.toLowerCase() & lcl.attrs & "/>" />
									<cfelse>
										<cfset lcl.opentags.push(lcl.tagname) />
										<cfset lcl.r = lcl.r & "<" & lcl.tagname & lcl.attrs & ">" />
										<cfif (lcl.tagname EQ "script") >
											<cfset lcl.r = lcl.r & "<![CDATA[" />
											<cfset lcl.opentags.pop() />
											<cfset lcl.state =  lcl.states.script />
											<cfbreak />
										</cfif>
									</cfif>
									<cfset lcl.state =  lcl.states.text />
									<cfbreak />
								</cfif>
							</cfif>
							<cfif (lcl.attrname EQ "_") >
								<cfloop condition="(ListFind(lcl.attrnames, lcl.attrname))">
									<cfset lcl.attrname = lcl.attrname & "_" />
								</cfloop>
							</cfif>
							<cfif (NOT lcl.attrname EQ ""  AND  NOT ListFind(lcl.attrnames, lcl.attrname)  AND  NOT lcl.attrname EQ "xmlns") >
								<cfset lcl.attrs = lcl.attrs & " " & "=\"" & lcl.attrname & "\"" />
								<cfset lcl.attrname =  "" />
							</cfif>
							<cfset lcl.cs =  "" & lcl.c />
							<!---
							name += (Character.isLetterOrDigit(c) && name != "") || Character.isLetter(c) ? cs : (name EQ "" ? "_" : (c == '-' ? "-" : (!name EQ "_" ? "_" : "")));
							Translated to:
							--->
							<cfif (isLetterOrDigit(lcl.c) AND lcl.name NEQ "") OR isLetter(lcl.c)>
								<cfset lcl.name = lcl.name & lcl.cs />
							<cfelse>
								<cfif lcl.name EQ "">
									<cfset lcl.name = lcl.name & "_" />
								<cfelse>
									<cfif lcl.c eq "-">
										<cfset lcl.name = lcl.name & "-" />
									<cfelse>
										<cfif NOT lcl.name EQ "_">
											<cfset lcl.name = lcl.name & "_" />
										</cfif>
									</cfif>
								</cfif>
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="endtag">
							<cfif (lcl.c EQ '>') >
								<cfset lcl.name =  lcl.name.toLowerCase() />
								<cfif (opentags.search(name)  NEQ  -1) >
									<cfset lcl.prevtag = lcl.opentags.pop() />
									<cfloop condition="(lcl.prevtag NEQ lcl.name) ">
										<cfset lcl.r = lcl.r & "</" & lcl.prevtag & ">" />
										<cfset lcl.prevtag = lcl.opentags.pop() />
									</cfloop>
									<cfset lcl.r = lcl.r & "</" & lcl.name & ">" />
								<cfelse>
									<cfif (lcl.name NEQ "html"  AND  lcl.opentags.empty()) >
										<cfset lcl.r = lcl.r & "<html>" />
										<cfset lcl.opentags.push("html") />
									</cfif>
								</cfif>
								<cfset lcl.state =  lcl.states.text />
								<cfbreak />
							</cfif>
							<cfif (isWhitespace(lcl.c)) >
								<cfbreak />
							</cfif>
							<cfset lcl.cs =  "" & lcl.c />
							<cfif isLetterOrDigit(lcl.c)>
								<cfset lcl.name = lcl.name & lcl.cs />
							<cfelse>
								<cfif lcl.name NEQ "_">
									<cfset lcl.name = lcl.name & "_" />
								</cfif>
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="attrtext">
							<cfif (lcl.c EQ lcl.attrdelim  OR  (isWhitespace(lcl.c)  AND  lcl.attrdelim EQ ' ')) >
								<cfif (lcl.attrname EQ "_") >
									<cfloop condition="(ListFind(lcl.attrnames, lcl.attrname)) ">
										<cfset lcl.attrname = lcl.attrname & "_" />
									</cfloop>
								</cfif>
								<cfif (NOT ListFind(lcl.attrnames, lcl.attrname)  AND  NOT lcl.attrname EQ "xmlns") >
									<cfset ListAppend(lcl.attrnames, lcl.attrname) />
									<cfset lcl.attrs = lcl.attrs & " " & lcl.attrname & '="' & lcl.attrvalue & '"' />
								</cfif>
								<cfset lcl.attrname =  "" />
								<cfset lcl.state =  lcl.states.tag />
								<cfbreak />
							</cfif>
							<cfif (lcl.attrdelim EQ ' '  AND  (lcl.c EQ '/'  OR  lcl.c EQ '>')) >
								<cfset lcl.tagname =  lcl.tagname.toLowerCase() />
								<cfif (NOT lcl.tagname EQ "html"  AND  lcl.opentags.empty()) >
									<cfset lcl.r = lcl.r & "<html>" />
									<cfset lcl.opentags.push("html") />
								</cfif>
								<cfif (lcl.autoclosetags.containsKey(lcl.tagname)  AND NOT lcl.opentags.empty()) >
									<cfset lcl.prevtag = lcl.opentags.peek() />
									<cfif (ListFind(lcl.autoclosetags.get(lcl.tagname), lcl.prevtag)) >
										<cfset lcl.opentags.pop() />
										<cfset lcl.r = lcl.r & "</" & lcl.prevtag & ">" />
									</cfif>
								</cfif>
								<cfif (lcl.attrname EQ "_") >
									<cfloop condition="(ListFind(lcl.attrnames, lcl.attrname)) ">
										<cfset lcl.attrname = lcl.attrname & "_" />
									</cfloop>
								</cfif>
								<cfif (NOT ListFind(lcl.attrnames, lcl.attrname)  AND  NOT lcl.attrname EQ "xmlns") >
									<cfset lcl.attrnames.add(lcl.attrname) />
									<cfset lcl.attrs = lcl.attrs & " " & lcl.attrname & '="' & lcl.attrvalue & '"' />
								</cfif>
								<cfset lcl.attrname =  "" />
								<cfif (lcl.c EQ '/') >
									<cfset lcl.r = lcl.r & "<" & lcl.tagname & lcl.attrs & "/>" />
									<cfset lcl.state =  lcl.states.tillgt />
									<cfbreak />
								</cfif>
								<cfif (lcl.c EQ '>') >
									<cfif ListFind(lcl.emptytags, lcl.tagname) >
										<cfset lcl.r = lcl.r & "<" & lcl.tagname & lcl.attrs & "/>" />
										<cfset lcl.state =  lcl.states.text />
										<cfbreak />
									<cfelse>
										<cfset lcl.opentags.push(lcl.tagname) />
										<cfset lcl.r = lcl.r & "<" & lcl.tagname & lcl.attrs & ">" />
										<cfif (lcl.tagname EQ "script") >
											<cfset lcl.r = lcl.r & "<![CDATA[" />
											<cfset lcl.opentags.pop() />
											<cfset lcl.prec =  ' ' />
											<cfset lcl.preprec =  ' ' />
											<cfset lcl.state =  lcl.states.script />
											<cfbreak />
										</cfif>
										<cfset lcl.state =  lcl.states.text />
										<cfbreak />
									</cfif>
								</cfif>
							</cfif>
							<cfif (lcl.c EQ '&') >
								<cfset lcl.name =  "" />
								<cfset lcl.entvalue =  0 />
								<cfset lcl.prevstate =  state />
								<cfset lcl.state =  lcl.states.entity />
								<cfbreak />
							</cfif>
							<cfset lcl.cs =  "" & lcl.c />
							<cfif lcl.c EQ '"'>
								<cfset lcl.attrvalue = lcl.attrvalue & "&quot;" />
							<cfelse>
								<cfif lcl.c EQ "'">
									<cfset lcl.attrvalue = lcl.attrvalue & "&apos;" />
								<cfelse>
									<cfset lcl.attrvalue = lcl.attrvalue & lcl.cs />
								</cfif>
							</cfif>
							<cfbreak />
						</cfcase>

						<cfcase value="script">
							<cfif (lcl.c EQ '/'  AND  lcl.prec EQ '<')>
								<cfset lcl.state =  lcl.states.endscript />
								<cfset lcl.name =  "" />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '['  AND  lcl.prec EQ '!'  AND  lcl.preprec EQ '<') >
								<cfset lcl.state =  lcl.states.skipcdata />
								<cfset lcl.name =  "<![" />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '>'  AND  lcl.prec EQ ']'  AND  lcl.preprec EQ ']') >
									<cfset lcl.c =  lcl.r.charAt(lcl.r.length() - 3) />
									<cfset lcl.r =  lcl.r.substring(0, lcl.r.length() - 4) />
							</cfif>
							<cfset lcl.r = lcl.r & lcl.c />
							<cfset lcl.preprec =  lcl.prec />
							<cfset lcl.prec =  lcl.c />
							<cfbreak />
						</cfcase>
						<cfcase value="endscript">
							<cfif (lcl.c EQ '>'  AND  lcl.name.toLowerCase() EQ "script") >
								<cfset lcl.r =  r.substring(0, r.length() - 1) />
								<cfset lcl.r = lcl.r & "]]></script>" />
								<cfset lcl.state =  lcl.states.text />
								<cfbreak />
							</cfif>
							<cfset lcl.name = lcl.name + lcl.c />
							<cfset lcl.sscr = "script" />
							<cfif (!sscr.startsWith(lcl.name.toLowerCase())) >
								<cfset lcl.r = lcl.r & lcl.name />
								<cfset lcl.state =  lcl.states.script />
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="specialtag">
							<cfif (c  NEQ  '-') >
								<cfset lcl.state =  lcl.states.tillgt />
								<cfbreak />
							</cfif>
							<cfif (prec EQ '-') >
								<cfset lcl.state =  lcl.states.comment />
								<cfset lcl.preprec =  ' ' />
								<cfbreak />
							</cfif>
							<cfset lcl.prec = lcl.c />
							<cfbreak />
						</cfcase>
						<cfcase value="comment">
							<cfif (lcl.c EQ '>'  AND  prec EQ '-'  AND  preprec EQ '-') >
								<cfset lcl.state =  lcl.states.text />
								<cfbreak />
							</cfif>
							<cfset lcl.preprec =  lcl.prec />
							<cfset lcl.prec =  lcl.c />
							<cfbreak />
						</cfcase>
						<cfcase value="skipcdata">
							<cfif (lcl.name EQ "<![CDATA[") >
								<cfset lcl.state =  lcl.states.script />
								<cfbreak />
							</cfif>
							<cfset lcl.name = lcl.name & lcl.c />
							<cfset lcl.scdata = "<![CDATA[" />
							<cfif (NOT lcl.scdata.startsWith(lcl.name)) >
								<cfset lcl.r = lcl.r & lcl.name />
								<cfset lcl.state =  lcl.states.script />
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="entity">
							<cfif (lcl.c EQ CHR(35)) >
								<cfset lcl.state =  lcl.states.numericentity />
								<cfbreak />
							</cfif>
							<cfset lcl.name = lcl.name & lcl.c />
							<cfset lcl.state =  lcl.states.namedentity />
							<cfbreak />
						</cfcase>
						<cfcase value="numericentity">
							<cfif (lcl.c EQ 'x'  OR  lcl.c EQ 'X') >
								<cfset lcl.state =  lcl.states.hexaentity />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ ';') >
								<cfset lcl.ent = "&##" & lcl.entvalue & ";" />
								<cfif (lcl.prevstate EQ lcl.states.text) >
									<cfset lcl.r = lcl.r & lcl.ent />
								<cfelse>
									<cfset lcl.attrvalue = lcl.attrvalue & lcl.ent />
								</cfif>
								<cfset lcl.state =  prevstate />
								<cfbreak />
							</cfif>
							<cfset lcl.entvalue =  entvalue * 10 & lcl.c - '0' />
							<cfbreak />
						</cfcase>
						<cfcase value="hexaentity">
							<cfif (lcl.c EQ ';') >
								<cfset lcl.ent = "&##" & lcl.entvalue & ";" />
								<cfif (lcl.prevstate EQ lcl.states.text)	>
									<cfset lcl.r = lcl.r & lcl.ent />
								<cfelse>
									<cfset lcl.attrvalue = lcl.attrvalue & lcl.ent />
								</cfif>
								<cfset lcl.state =  prevstate />
								<cfbreak />
							</cfif>
							<!--- <cfset lcl.entvalue =  lcl.entvalue * 16 & (Character.isDigit(c) ? lcl.c - '0' : Character.toUpperCase(c) - 'A') /> --->
							<cfset lcl.entvalue = "DEEBAC">
							<cfbreak />
						</cfcase>
						<cfcase value="namedentity">
							<cfif (lcl.c EQ ';') >
								<cfset lcl.ent = "" />
								<cfset lcl.name =  lcl.name.toLowerCase() />
								<cfif (lcl.name EQ "amp"  OR  lcl.name EQ "lt"  OR  lcl.name EQ "gt"  OR  lcl.name EQ "quot"  OR  lcl.name EQ "apos") >
									<cfset lcl.ent =  "&" + lcl.name + ";" />
									<cfset lcl.name =  "" />
									<cfif (lcl.prevstate EQ lcl.states.text) >
										<cfset lcl.r = lcl.r & lcl.ent />
									<cfelse>
										<cfset lcl.attrvalue = lcl.attrvalue + lcl.ent />
									</cfif>
									<cfset lcl.state =  prevstate />
									<cfbreak />
								</cfif>
								<cfif (ListFind(lcl.namedentities, lcl.name)) >
									<cfset lcl.entvalue =  lcl.namedentities.get(lcl.name) />
								<cfelse>
									<cfset lcl.entvalue =  0 />
								</cfif>
								<cfset lcl.ent =  "&" + lcl.entvalue + ";" />
								<cfset lcl.name =  "" />
								<cfif (lcl.prevstate EQ lcl.states.text) >
									<cfset lcl.r = lcl.r & lcl.ent />
								<cfelse>
									<cfset lcl.attrvalue = lcl.attrvalue + lcl.ent />
								</cfif>
								<cfset lcl.state =  prevstate />
								<cfbreak />
							</cfif>
							<cfif (NOT isLetterOrDigit(lcl.c)  OR  lcl.name.length() GT 6)>
								<cfset lcl.ent = "&amp;" & lcl.name />
								<cfset lcl.name =  "" />
								<cfif (lcl.prevstate EQ lcl.states.text) >
									<cfset lcl.r = lcl.r & lcl.ent />
								<cfelse>
									<cfset lcl.attrvalue = lcl.attrvalue + lcl.ent />
								</cfif>
								<cfset lcl.state =  prevstate />
								<cfset lcl.i = lcl.i - 1 />
								<cfbreak />
							</cfif>
							<cfset lcl.name = lcl.name & lcl.c />
							<cfbreak />
						</cfcase>
						<cfcase value="tillinst">
							<cfif (lcl.c EQ '?') >
									<cfset lcl.state =  lcl.states.andgt />
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="andgt">
							<cfif (lcl.c EQ '>') >
								<cfset lcl.state =  lcl.states.text />
								<cfbreak />
							</cfif>
							<cfset lcl.state =  lcl.states.tillinst />
							<cfbreak />
						</cfcase>
						<cfcase value="tillgt">
							<cfif (lcl.c EQ '>') >
								<cfset lcl.state =  lcl.states.text />
							</cfif>
							<cfbreak />
						</cfcase>
						<cfcase value="tillquote">
							<cfif (isWhitespace(lcl.c)) >
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '"'  OR  lcl.c EQ "'") >
								<cfset lcl.attrdelim =  lcl.c />
								<cfset lcl.attrvalue =  "" />
								<cfset lcl.state =  lcl.states.attrtext />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '/'  OR  lcl.c EQ '>') >
								<cfif (lcl.attrname EQ "_") >
									<cfloop condition="(ListFind(lcl.attrnames, lcl.attrname))">
										<cfset lcl.attrname = lcl.attrname & "_" />
									</cfloop>
								</cfif>
								<cfif (NOT ListFind(lcl.attrnames, lcl.attrname)  AND  NOT lcl.attrname EQ "xmlns") >
									<cfset lcl.attrnames.add(lcl.attrname) />
									<cfset lcl.attrs = lcl.attrs & " " & lcl.attrname & '= "' & attrvalue & '"' />
								</cfif>
								<cfset lcl.attrname =  "" />
							</cfif>
							<cfif (lcl.c EQ '/') >
								<cfset lcl.r = lcl.r & "<" & lcl.tagname.toLowerCase() & lcl.attrs & "/>" />
								<cfset lcl.state =  lcl.states.tillgt />
								<cfbreak />
							</cfif>
							<cfif (lcl.c EQ '>') >
								<cfset lcl.tagname =  lcl.tagname.toLowerCase() />
								<cfif (NOT lcl.tagname EQ "html"  AND  lcl.opentags.empty()) >
									<cfset lcl.r = lcl.r & "<html>" />
									<cfset lcl.opentags.push("html") />
								</cfif>
								<cfif (lcl.autoclosetags.containsKey(lcl.tagname) AND NOT lcl.opentags.empty())>
									<cfset lcl.prevtag = lcl.opentags.peek() />
									<cfif (ListFind(lcl.autoclosetags.get(lcl.tagname), lcl.prevtag))>
										<cfset lcl.opentags.pop() />
										<cfset lcl.r = lcl.r & "</" & lcl.prevtag & ">" />
									</cfif>
								</cfif>
								<cfif ListFind(lcl.emptytags, lcl.tagname)>
									<cfset lcl.r = lcl.r & "<" & lcl.tagname & lcl.attrs & "/>" />
									<cfset lcl.state =  lcl.states.text />
									<cfbreak />
								<cfelse>
									<cfset lcl.opentags.push(lcl.tagname) />
									<cfset lcl.r = lcl.r & "<" & lcl.tagname & lcl.attrs & ">" />
									<cfif (lcl.tagname EQ "script") >
										<cfset lcl.r = lcl.r & "<![CDATA[" />
										<cfset lcl.opentags.pop() />
										<cfset lcl.state =  lcl.states.script />
										<cfbreak />
									</cfif>
								</cfif>
							</cfif>
							<cfset lcl.attrdelim =  ' ' />
							<cfset lcl.attrvalue =  "" & lcl.c />
							<cfset lcl.state =  lcl.states.attrtext />
							<cfbreak />
						</cfcase>
					</cfswitch>
					<cfset lcl.switch_handled = true />
				</cfloop>
				<cfcatch type="any">
					<cfoutput><p>#cfcatch.message# #cfcatch.detail# <cfdump var="#cfcatch#"></p></cfoutput>
					<cfset lcl.switch_handled = true />
					<cfbreak />
				</cfcatch>
			</cftry>
			<cfset lcl.i = lcl.i + 1 />
			<cfif lcl.i GTE lcl.limit>
				<cfbreak>
			</cfif>
			<!--- <cfif lcl.i LTE 1000>
				<cfoutput>#lcl.i# [#lcl.state#]: #lcl.r#: #lcl.tagname#<br /></cfoutput>
			<cfelse>
				<cfbreak />
			</cfif> --->
		</cfloop>
		<cfloop condition="(NOT lcl.opentags.empty())">
			<cfset lcl.r = lcl.r & "</" & lcl.opentags.pop() & ">" />
		</cfloop>
		<cfset lcl.r2 = lcl.r2 & lcl.r />
		<cfdump var="#lcl.i#">
		<cfreturn '<?xml version="1.0" encoding="' & lcl.encoding & '"?>' & CHR(10) & lcl.r2 />
	</cffunction>
</cfcomponent>