#!/home/munetal/bin/gosh

(add-load-path "/home/munetal/www")

(use www.cgi)
(use gauche.parameter)
(use cgiTools)
(use text.html-lite)
(use template-engine)
(use rfc.cookie)

(define html-form "
<%
(let* (
       (status (cgi-get-parameter \"status\" (param) :default \"0\"))
       )
  (begin
%>
<HTML>
<HEAD>
<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\">
<META http-equiv=\"Content-Style-Type\" content=\"text/css\">
<TITLE></TITLE>
<LINK rel=\"stylesheet\" href=\"main.css\" type=\"text/css\">
</HEAD>
<BODY>
<div id=\"content\">
<div id=\"theme\">
<h1>単語　de　アイディア</H1>
<BR>
<%
(cond ((string=? \"1\" status)%>会員登録に成功しました<%  )
      ((string=? \"2\" status)%>ログインに失敗しました<%  )
      ((string=? \"3\" status)%>ログインをしてください<%  )
      (else '() ))
%>
</div>

<div id=\"left\">
<div id=\"leftbox\">
<h2>ログイン</H2>
<form method=\"POST\" action=\"loginC.scm\">

ユーザ名：<input type=\"text\" name=\"NAME\">
<BR>
<BR>
パスワード：<input type=\"text\" name=\"PASS\">
<BR>
<BR>
<input type=\"submit\" value=\"ログイン\">
</form>
<br>
<a href=\"rege.scm\">新規登録してみる</a>
</div>
</div>

<div id=\"right\">
<h2>何なのこれ？</H2>
<div id=\"text\">
仕事や趣味で何かいいアイディアを出したいと思ったときに<BR>
利用できるwebサイトです。<BR>
<BR>
本webサイトの機能はすごく単純で
<BR>
<BR>
・単語が２つランダムに表示される<BR>
　（表示される単語を自分で用意することもできます）
<BR>
<BR>
・２つの単語からアイディアを考え、記録する
<BR>
<BR>
・過去ログのようにアイディアを管理する
<BR>
<BR>
・他人のアイディアを見て、さらにアイディアを考え出す
<BR>
<BR>
とまあ、こんなことができます。<BR>
<BR>
会員登録は３０秒程度で完了しますので、気軽にご利用ください。
<BR>
</div>
</div>

<div id= \"footer\">
      (c)2010Test
     連絡先
     ヘルプ

</div>
</BODY>
</HTML>
<%
))
%>
")

(print "Content-Type: text/html")
(parameterize ((param (cgi-get-strings)))
(rendering-template html-form)
)

