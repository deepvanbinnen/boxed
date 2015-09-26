/**
 * EBX JQUERY DEFAULT EXTENSIONS AND BINDINGS
 * 
 * Wraps the code into a try catch block to gracefully redirect stderr
 * 
 */
var debug = true;
try{
	(function($){
		/**
		 * JQUERY-OBJECT EXTENSIONS: EXTENDED PROPERTIES AND METHODS
		 * 
		 * Add default extensions
		 */
		$.extend( { 
			ebx : {
				processRegExpMatches : function(rx, s, cb, flg){
					var m=null; // match variable
					var rx = rx || ""; // RegExp-obj or regex-string
					var s=s||""; // in-string
					var cb=cb||console.debug; // setup callback method to which match is given, defaults to firebug's console.debug
					var flg = flg || ""; // regex flags only used if rx is string
					
					var rs=[],r; // results and callback-result
					
					// Check if rx = string and create RegExp-obj
					if(typeof(rx).toLowerCase()=="string" && rx!="") rx = new RegExp(rx, flg);
					
					// Check if rx is a RegExp and execute matching
					if(typeof(rx) == "object" && rx.constructor.name=="RegExp"){
						while(m=rx.exec(s)){
							r=cb(m); if(r) rs.push(r); // push callback result in array if any
						}
					}
					return rs;
				} // End of ebx.processRegExpMatches
				, taconiteGet :  function(e, data){
					if(e){
						e.preventDefault();
						var data = data || {};
						var u = $(this).attr("href") || "";
						if(u!=""){ 
							$.extend(data, {__tacoRequest : true });
							$.taconiteGet(u, data); 
						}
						else throw("No Ajax URL found in href");
					} else { throw("No event in method call"); }
				}  // End of ebx.taconiteGet
				, taconitePost :  function(e, data){
					if(e){
						e.preventDefault();
						var data = data || {};
						var u = $(this).attr("action") || "";
						$.extend(data, {__tacoRequest : true });
						if(u!="") $.taconitePost(u, data); 
						else throw("No Ajax URL found in href");
					} else { throw("No event in method call"); }
				}  // End of ebx.taconitePost
				, getObjectFromData : function(data){
					/**
					 * if data is a function, returns the applied function result
					 * else if data is object, the data
					 * otherwise an empty object
					 */
					if( data instanceof Object ) 
						return $.ebx.getAppliedData(data);
					else 
						return {};
				} // End of getObjectFromData
				, getAppliedData : function(data){
					/**
					 * if data is a function, returns the applied function result
					 * else returns data
					 */
					if( $.isFunction(data) ) {
						return data.apply(this, $.makeArray(arguments).slice(1));
					}
					else 
						return data;
				} // End of getAppliedData
				, getQStringValue : function(href, qStrVar){
					var props = href.split("?");
					if(props.length > 1) props = props[1].split("&");
					for(var t,i=0;i<props.length;i++){
						t = props[i].split("=");
						if(t[0] == qStrVar) 
							return [t1] ? t[1].join("=") : "";
					}
					return "";
				}
				, RandomString : {
					getRandomChar : function(charCase){
						/**
						 * gets a random character
						 */
						var charCase = charCase || "any";
						switch(charCase){
							case "upper":
							case "uppercase":
							case "u":
							case "U":
								return String.fromCharCode( getAlphaAsciiIndex( getRandomAlphaIndex(), false ) );
							case "lower":
							case "lowercase":
							case "l":
							case "L":
								return String.fromCharCode( getAlphaAsciiIndex( getRandomAlphaIndex(), true ) );
							default:
								return String.fromCharCode( getAlphaAsciiIndex( getRandomAlphaIndex(), getRandomBit() ) );
						} // End of switch
					} // End of getRandomChar
					, getRandomBit : function(){ return Math.floor(Math.random()*2);}
					, getRandomAlphaIndex: function(){ return Math.floor(Math.random()*26);}
					, getRandomNumIndex: function(){ return Math.floor(Math.random()*10);}
					, getAlphaAsciiIndex: function(index, lowercase){ return i+65+ (lowercase) ? 32 : 0;}
					, getNumAsciiIndex: function(index){ return (i%10)+48;}
				} // End of RandomString object 
			} // End of extension with key ebx
		}); // End of extensions
		
		/**
		 * JQUERY-SELECTOR EXTENSIONS: PLUGINS
		 */
		$.fn.extend({
			/**
			 * move the jQuery selector elements to target by clone-append-remove operations
			 */
			moveElements : function(trg) {
				$(this).clone().appendTo($(trg));
				$(this).remove();
			}
			, popup : function() {
				var uniqueName = function(){
					var s = "";
					for(var i=0;i<10;i++){
						s+=String.fromCharCode(Math.floor(Math.random()*26)+65+(Math.floor(Math.random()*2)*32));
					}
					return s;
				}
				var getWinProps = function(href){
					var s = new Array();
					var props = href.split("?");
					if(props.length > 1) props = props[1].split("&");
					for(var t,i=0;i<props.length;i++){
						t = props[i].split("=");
						if(t[0].split("popup_").length>1){
							s.push(props[i].split("popup_")[1]);
						}
					}
					return s.toString();
				}
				var href = $(this).attr("href") || "#";
				window.open(href, uniqueName(), getWinProps(href));
				return this;
			}
			, editable : function(mode){
				if($(this).attr("contentEditable") != mode) {
					$(this).attr("contentEditable", mode).toggleClass("active", mode).trigger("focus");
					return this;
				}
			}
		}); // pass in the jQuery.fn as object to be extended
		
		/**
		 * INJECT DOCUMENT READY EVENT
		 * 
		 * Add default bindings and plugin initialisation calls
		 */
		$(function($){
			/**
			 * DEFAULT BINDINGS 
			 */
			$("a.xhr").live("click", $.ebx.taconiteGet);
			$("form.xhr").live("submit", $.ebx.taconitePost);
			$("a.disabled").live("click", function(e){ e.preventDefault(); return false; });
			$("a.back").live("click", function(e){ e.preventDefault(); history.back(); return false; });
			$("input.terug").live("click", function(e){ e.preventDefault(); history.back(); return false; });
			$("a.popup").live("click", function(e){ e.preventDefault(); $(this).popup(e); return false; });
			$("a.submit").live("click", function(e){ e.preventDefault(); $(this).parent("form").trigger("submit"); return false; });
			$(".editable").live("click", function(e){ $(this).editable(true);});
			$(".editable").live("blur", function(e){ $(this).editable(false);});
		});
	})(jQuery);
}
catch(e){
	if(debug){
		alert('An error has occurred: '+e.message)
	}
}
finally{
	// alert('I am alerted regardless of the outcome above')
}