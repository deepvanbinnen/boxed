try{
	jQuery(function($){
		$.fn.extend( {
			popup : function() {
			/**
			 * Opent element's href via javascript's window.open en
			 * leest popup window properties uit de href url-variabelen met als naam popup_[window-property]
			 * vb: <a href="index.cfm?act=popup.show&popup_width=600&popup_height=400&popup_scrollbars=0" class="popup">mijn popup</a>
			 * doet een window.open op 'index.cfm?act=popup.show'en properties "width=600,height=400,scrollbars=0"
			 */
				var uniqueName = function(){
					/**
					 * retourneert een 10 karakters lange string voor gebruik als unieke windownaam
					 */
					var s = "";
					for(var i=0;i<10;i++){
						s+=String.fromCharCode(Math.floor(Math.random()*26)+65+(Math.floor(Math.random()*2)*32));
					}
					return s;
				}
				var getWinProps = function(href){
					/**
					 * doorzoekt href op window-properties
					 */
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
				
				/**
				 * afhandeling window.open
				 */
				var href = $(this).attr("href") || "#";
				window.open(href, uniqueName(), getWinProps(href));
				return this;
			}
		});
		/**
		 * Hangt aan onclick op een a met class='popup' de call naar popup() en disabled de click
		 */
		$("a.popup").live("click", function(e){ e.preventDefault(); $(this).popup(e); return false; });
	});
} catch(e) {
	alert(e.message);
}