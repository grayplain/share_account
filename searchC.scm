#!/home/munetal/bin/gosh

(add-load-path "/home/munetal/www")

(use www.cgi)
(use gauche.parameter)
(use srfi-27)
(use rfc.sha)
(use cgiTools)
(use text.html-lite)
(use template-engine)
(use rfc.cookie)
(use rfc.uri)
(require "sql")
(import sql-query)

(print "Content-Type: text/html charset=Shift_JIS")

(parameterize ((dbObj (dbStart)) (param (cgi-get-strings)))
(begin
(let* (((param) (cgi-get-strings));変数宣言箇所が何か汚い。もっと綺麗にできないものか・・・
       (usersession (if (equal? #f (cgi-get-parameter "id" (param) ))
			#f 
			(string-scan (cgi-get-parameter "id" (param)) "session=" 'after)))
       (userdata (if (equal? #f  usersession)
		     #f 
		     (doSel dbObj "SELECT UserName , UserTheme FROM UserData WHERE UserKey =?" (list usersession )
			    '("UserName" "UserTheme"))
		     ))
       (addUser (cgi-get-checkbox "addUser" (param)))
       (username (cgi-get-parameter "username" (param)))
       (theme (cgi-get-parameter "theme" (param)))
       (doAction (cgi-get-parameter "doAction" (param)))
       )

  (cond ((equal? #f userdata) (print "Location: ./login.scm?status=1 \n\n") )
	((string=? "insert" doAction ) 
	 ((lambda ()
	       (if (equal? #f (for-each (lambda (x)
					  (doIUD dbObj "INSERT INTO BookMark 
                                               (UserName,BookMarkData) VALUES(?,?)"
						 (list (car (car userdata)) x ))) 
					addUser))
		   (print "Location: ./search.scm?status=4 \n\n")
		   (print "Location: ./search.scm?status=3 \n\n"))
	     )))
	((string=? "search" doAction ) 
	 ((lambda ()
	       (if (= 1 1);後で文字列をなんたらするときに使うかも
		   (print (string-append "Location: ./search.scm?status=2"  
                            (if (or (string=? "" username) (equal? #f username)) 
				""
				(string-append "&username=" (uri-encode-string username)))
                            (if (or (string=? "" theme) (equal? #f theme)) 
				"" 
				(string-append "&theme=" (uri-encode-string theme)))
                              "\n\n"))
		   (print "Location: ./search.scm?status=1 \n\n"))
	     )))
	(else (print "Location: ./search.scm?err=5 \n\n"))
	)
)
(dbClose dbObj)
))
