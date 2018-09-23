#!/home/munetal/bin/gosh

(add-load-path "/home/munetal/www")

(use www.cgi)
(use gauche.parameter)
(require "sql")
(import sql-query)
(use cgiTools)
(use text.html-lite)
(use template-engine)
(use rfc.cookie)
(use srfi-1)
(use rfc.uri)

(define html-form "
<%
(let* ( (searchMethod (cgi-get-parameter \"searchMethod\" (param) :default \"serviceName\"))
	(gameNum (string->number (car (car (doSel dbObj 
						  \"SELECT Count(ServiceId) AS COUNT FROM ServiceName 
						  WHERE  ServiceName.ServiceId in 
						  (SELECT ServiceId FROM ServiceTag WHERE Tag like ?)\"
						  (list \"ゲーム\") '( \"COUNT\" ))))))
	(mmoNum (string->number (car (car (doSel dbObj 
						  \"SELECT Count(ServiceId) AS COUNT FROM ServiceName 
						  WHERE  ServiceName.ServiceId in 
						  (SELECT ServiceId FROM ServiceTag WHERE Tag like ?)\"
						  (list \"MMO\") '( \"COUNT\" ))))))
	(fpsNum (string->number (car (car (doSel dbObj 
						  \"SELECT Count(ServiceId) AS COUNT FROM ServiceName 
						  WHERE  ServiceName.ServiceId in 
						  (SELECT ServiceId FROM ServiceTag WHERE Tag like ?)\"
						  (list \"FPS\") '( \"COUNT\" ))))))
	(bisinesuNum (string->number (car (car (doSel dbObj 
						  \"SELECT Count(ServiceId) AS COUNT FROM ServiceName 
						  WHERE  ServiceName.ServiceId in 
						  (SELECT ServiceId FROM ServiceTag WHERE Tag like ?)\"
						  (list \"ビジネス\") '( \"COUNT\" ))))))
	(movieNum (string->number (car (car (doSel dbObj 
						  \"SELECT Count(ServiceId) AS COUNT FROM ServiceName 
						  WHERE  ServiceName.ServiceId in 
						  (SELECT ServiceId FROM ServiceTag WHERE Tag like ?)\"
						  (list \"動画\") '( \"COUNT\" ))))))
	)
  (begin
%>
<HTML>
<HEAD>
<META http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8 \">
<META http-equiv=\"Content-Style-Type\" content=\"text/css\">
<TITLE></TITLE>
<LINK rel=\"stylesheet\" href=\"main.css\" type=\"text/css\">
</HEAD>
<BODY>
<div id=\"content\">
<h1>Share_Account</H1>
<a href=\"result.scm?searchMethod=tagName&name=ゲーム\">ゲーム（<%=gameNum%>）</a>
<a href=\"result.scm?searchMethod=tagName&name=MMO\">ＭＭＯ（<%=mmoNum%>）</a>
<a href=\"result.scm?searchMethod=tagName&name=FPS\">ＦＰＳ（<%=fpsNum%>）</a>
<a href=\"result.scm?searchMethod=tagName&name=ビジネス\">ビジネス（<%=bisinesuNum%>）</a>
<a href=\"result.scm?searchMethod=tagName&name=動画\">動画（<%=movieNum%>）</a>
<BR>
<BR>
<div id=\"theme\">
<div id=\"login\">
<form method=\"GET\" action=\"result.scm\">
<div><BR>
<div id=\"jyouken\">
<%  (if (string=? \"serviceName\" searchMethod)
      ((lambda ()
	%>サービス名<%
	))
      ((lambda ()
	%><a href=\"search.scm?searchMethod=serviceName\">サービス名</a><%))
      )
%>　| 

<%  (if (string=? \"tagName\" searchMethod)
      ((lambda ()
	%>タグ<%
	))
      ((lambda ()
	%><a href=\"search.scm?searchMethod=tagName\">タグ</a><%))
      )
%>
<form method=\"get\" action=\"result.scm\">
</div><br>
<input value=\"\" name=\"name\" type=\"text\"  size = \"50\" /><BR>
<BR>
<input type=\"hidden\" name=\"searchMethod\" value=\"<%=searchMethod%>\">
<input type=\"submit\" value=\"検索\"></div>
</form>
</div>
</div>
</div>
<div id= \"footer\"> 
<a href=\"contact.html\">連絡先</a> 
<a href=\"what.html\">これって何？</a> 
<a href=\"tos.html\">利用規約</a>  </div>
</BODY>
</HTML>
<%
))
%>
")

(print "Content-Type: text/html")

(parameterize ((dbObj (dbStart)) (param (cgi-get-strings)))
(begin
(rendering-template html-form)
(dbClose dbObj)
))
