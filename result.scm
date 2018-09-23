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
       (keyword (cgi-get-parameter \"name\" (param) :default \"\"))
       (searchNum (cgi-get-parameter \"searchNum\" (param) :default 1 :convert string->number))
       (tagQuery (if (string=? \"serviceName\" searchMethod)
		      \"Name like ?\" 
		      \"ServiceView.ServiceId in (SELECT ServiceId FROM ServiceTag WHERE Tag like ?)\"))
       (listQuery (if (string=? \"serviceName\" searchMethod)
		      \"Name like ?\" 
		      \"ServiceCount.ServiceId in (SELECT ServiceId FROM ServiceTag WHERE Tag like ?)\"))
       (listNumQuery (if (string=? \"serviceName\" searchMethod)
		      \"Name like ?\" 
		      \"ServiceName.ServiceId in (SELECT ServiceId FROM ServiceTag WHERE Tag like ?)\"))
       (tagList (doSel dbObj #`\"SELECT ServiceId , TagId , Name , Tag , Comment FROM ServiceView
			     WHERE ,tagQuery\"
		      (list (string-append \"%\" keyword \"%\"))
		      '(\"ServiceId\"  \"TagId\"  \"Name\"  \"Tag\"  \"Comment\")))

       (nameList (doSel dbObj #`\"SELECT ServiceId , Name , CNT , Comment  FROM ServiceCount
		      WHERE ,listQuery ORDER BY ServiceId limit ,(* (- searchNum 1) 10) , 10\"
		      (list (string-append \"%\" keyword \"%\"))
		      '(\"ServiceId\"  \"Name\"  \"CNT\" \"Comment\")))
       (nameListNum (string->number (car (car (doSel dbObj 
						     #`\"SELECT Count(ServiceId) AS COUNT FROM ServiceName 
						     WHERE ,listNumQuery\"
		      (list (string-append \"%\" keyword \"%\"))
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
%>
　</div><br>
<input type=\"hidden\" name=\"searchMethod\" value=\"<%=searchMethod%>\">
<input type=\"text\" name=\"name\" size = \"60\" value=\"<%=keyword%>\" >　<input type=\"submit\" value=\"検索\"></div>
</form>

<%
(cond ((= 0 nameListNum) ((lambda ()
       %>
       <%=keyword%>に関して検索結果は1件もありませんでした。
       <BR>
       <BR>
       <%)
     ))
      ((string=? \"\" keyword) ((lambda ()
				  (begin
       %>
       キーワードを入力してください。
       <BR>
       <BR>
       <%(set! nameListNum 0)
       ))
     ))
      (else (for-each
     (lambda (name)
       %>
       <DIV id=\"text\">
       <DIV id=\" result\">
       <a href=\"list.scm?id=<%=(getSqlResult 0 name)%>\"><%=(getSqlResult 1 name)%></a>
       <BR>
   タグ：
   <%
   (for-each
    (lambda (tag)
      %>
      <a href=\"result.scm?searchMethod=tagName&name=<%=(getSqlResult 3  tag)%>\"><%=(getSqlResult 3 tag)%></a>
      <%
      )
    (filterList (getSqlResult 1 name) 2 tagList))
   %><BR>
   現在の共有アカウント数：<%=(getSqlResult 2 name)%>件<BR>
   <BR>
   </DIV>
   </DIV>
   <%
   )
     nameList))
    )


%>


<div id=\"search\">
<%(if (not (= 1 searchNum))
      ((lambda () 
	 (begin %> 
	   <a href=\"result.scm?searchNum=<%=(- searchNum 1)%>&searchMethod=<%=searchMethod%>&name=<%=keyword%>\">前へ</a>
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
			   %><a href=\"result.scm?searchNum=<%=num%>&searchMethod=<%=searchMethod%>&name=<%=keyword%>\"><%=num%> </a><%)
			 ))
		      )
	   )
	  (cutOverNum (makeSR searchNum 10 nameListNum) ( ceiling (/ nameListNum 10)))
	  )
%>
<%(if (and (not (= ( ceiling (/ nameListNum 10) ) searchNum)) (> nameListNum 0))
      ((lambda () 
	 (begin %> 
	   <a href=\"result.scm?searchNum=<%=(+ searchNum 1)%>&searchMethod=<%=searchMethod%>&name=<%=keyword%>\">次へ</a>
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
