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
(let* ((searchMethod (cgi-get-parameter \"searchMethod\" (param) :default \"serviceName\"))
       (serviceId (cgi-get-parameter \"id\" (param) :default \"\"))
       (searchNum (cgi-get-parameter \"searchNum\" (param) :default 1 :convert string->number))
       (name (car (doSel dbObj #`\"SELECT ServiceId , Name , Comment , Link  FROM ServiceCount
		      WHERE ServiceId = ?\"
		      (list serviceId )
		      '(\"ServiceId\"  \"Name\" \"Comment\" \"Link\"))))
       (accountList (doSel dbObj #`\"SELECT ServiceId , AccountId , LastUseTime , TrialTime , Account , Password
			   , UseAccount , UselessAccount FROM ServiceAccount
		      WHERE ServiceId = ? ORDER BY LastUseTime limit ,(* (- searchNum 1) 10) , 10\"
		      (list serviceId)
		      '(\"ServiceId\"  \"AccountId\" \"LastUseTime\" \"TrialTime\"
			\"UseAccount\" \"UselessAccount\"  \"Account\"  \"Password\")))
       (accountListNum (string->number (car (car (doSel dbObj #`\"SELECT Count(ServiceId) AS COUNT FROM ServiceName
		      WHERE ServiceId = ? \"
		      (list serviceId )
		      '( \"COUNT\" ))))))
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
<DIV id=\"content\">
<h1>
<a class=\"white\" href=\"search.scm\">
Share_Account
</a>
</H1>
<BR>
<div id=\"theme\">
<div id=\"text\">
<form method=\"GET\" action=\"result.scm\">
<div><BR>
<div id=\"jyouken\">
<%  (if (string=? \"serviceName\" searchMethod)
      ((lambda ()
	%>サービス名<%
	))
      ((lambda ()
	%><a href=\"result.scm?searchMethod=serviceName\">サービス名</a><%))
      )
%>　| 

<%  (if (string=? \"tagName\" searchMethod)
      ((lambda ()
	%>タグ<%
	))
      ((lambda ()
	%><a href=\"result.scm?searchMethod=tagName\">タグ</a><%))
      )
%>　</div><br>
<input type=\"hidden\" name=\"searchMethod\" value=\"status\">
<input type=\"text\" name=\"name\" size = \"60\">　<input type=\"submit\" value=\"検索\"></div>
</form>

<DIV id=\"text\">
<%=(getSqlResult 1 name)%><BR>
<a href=\"<%=(getSqlResult 3 name)%>\"><%=(getSqlResult 3 name)%></a>
<BR>
<BR>
</DIV>

<%
(for-each
 (lambda(account)
   (begin%>
    <a href=\"list.scm?id=<%=(getSqlResult 0 account)%>&account=<%=(getSqlResult 1 account)%>\">
    </a>
    <BR>
    アカウント名：<%=(getSqlResult 6 account)%><BR>
    パスワード　：<%=(getSqlResult 7 account)%><BR>
    <BR>
    
   <%)
   )
 accountList)
%>

<div id=\"search\">
<%(if (not (= 1 searchNum)) 
      ((lambda () 
	 (begin %> 
	   <a href=\"list.scm?searchNum=<%=(- searchNum 1)%>\">前へ</a>
	   <%)))
  )
%>
<%
(for-each (lambda (num)
		  (if (= num searchNum) 
		      ((lambda ()
			 (begin
			  %><%=num%> <%)
			 )) 
		      ((lambda () 
			 (begin
			   %><a href=\"list.scm?searchNum=<%=num%>\"><%=num%> </a><%)
			 ))
		      )
	   )
	  (cutOverNum (makeSR searchNum 10 accountListNum) ( ceiling (/ accountListNum 10)))
	  )
%>
<%(if (and (not (= ( ceiling (/ accountListNum 10) ) searchNum)) (> accountListNum 0))
      ((lambda () 
	 (begin %> 
	   <a href=\"list.scm?searchNum=<%=(+ searchNum 1)%>\">次へ</a>
	   <%) ))
  )
%>
</div>

</div>
</div>
<div id= \"footer\"> 
<a href=\"contact.html\">連絡先</a> 
<a href=\"what.html\">これって何？</a> 
<a href=\"tos.html\">利用規約</a>  </div>
</DIV>
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
