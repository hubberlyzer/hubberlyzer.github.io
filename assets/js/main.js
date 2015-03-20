var Main = function(){
	// pie chart that shows the count of languages
	var topLangByRepos = function(){
		var ctxCount = document.getElementById("lang-count").getContext("2d");

		var tpl = 
			"<ul class=\"legend-lists <%=name.toLowerCase()%>-legend\"> \
			<% for (var i=0; i<langCount.length; i++){%> \
			<li><div class=\"legend-color\" style=\"background-color:<%=langCount[i].color%>\"></div> \
			<%if(langCount[i].label){%><%=langCount[i].label%> (<%=langCount[i].value%>)<%}%> \
			</li><%}%></ul>"

		var langCountChart = new Chart(ctxCount).Pie(langCount, {
			legendTemplate : tpl
		});
		document.getElementById("lang-count-lengend").innerHTML = langCountChart.generateLegend();
		
	};

	var topLangByStars = function(){
		var ctxStar = document.getElementById("lang-star").getContext("2d");

		var langStarChart = new Chart(ctxStar).Bar(langStarCompare);
		
	};

	var topLangByRatio = function(){
		var ctxStarRatio = document.getElementById("lang-ratio").getContext("2d");

		var langStarRatioChart = new Chart(ctxStarRatio).Bar(langStarRatio, {
			barShowStroke: false
		});
		
	};

	var topTabs = function(){
		$('#top-star-tab a').click(function (e) {
		  e.preventDefault();
		  console.log("here");
		  $(this).tab('show');
		})
	}

	return {
		init: function(){
			topLangByRepos();
			topLangByStars();
			topLangByRatio();
			// topTabs();
		}
	};
}();