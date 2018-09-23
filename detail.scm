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
(let* ()
  (begin
%>
<HTML>
<HEAD>
<META http-equiv=\"Content-Type\" content=\"text/html\">
<META http-equiv=\"Content-Style-Type\" content=\"text/css\">
<TITLE></TITLE>
<LINK rel=\"stylesheet\" href=\"main.css\" type=\"text/css\">
</HEAD>
<BODY>
<DIV id=\"content\">
<h1>Share_Account</H1>
<div id=\"theme\">
<div id=\"text\">
<div id=\"result\">
アカウント名：<BR>
パスワード：<BR>
サービスのURL:<BR>
</div>
</div>
</div>
</div>
<div id= \"footer\"> 連絡先 これって何？ 利用規約 </div>
</BODY>
</HTML>
<%
))
%>
")

(print "Content-Type: text/html charset=Shift_JIS")
(parameterize ((dbObj (dbStart)) (param (cgi-get-strings)))
(begin
(rendering-template html-form)
(dbClose dbObj)
))
