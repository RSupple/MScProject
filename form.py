#!/usr/bin/env python3

#This file was adapted from the file of the same name orginally created by me for Biocomputing 1.
#file for index page on gene analysis submission
import cgi;

from subprocess import call

#Debugging output
import cgitb

#Send errors to browser
cgitb.enable	

#Grab form contents
form = cgi.FieldStorage()

#Get data from fields:
#Radio button search
if form.getvalue("search_type"):
    search_type = form.getvalue("search_type")
else:
    search_type = "None"


reference =form.getvalue('reference')
query1 =form.getvalue('query1')

if form.getvalue("query2"):
    query2 = form.getvalue("query2")
else:
    query2 = "" #query2 value is optional

#Print HTML MIME-TYPE header
print ('Content-type:text/html\n')
print()
html ='<!DOCTYPE html>\n'
html += '<html>\n'
html += '<head>\n'
html += '<meta charset="utf-8">\n' 
html += '<title>RUDO</title>\n'

#css stylesheet for page
html += '<link type="text/css" rel="stylesheet" href="http://student.cryst.bbk.ac.uk/~sr002/css/rgr3.css">\n'

html += '</head>\n\n'
html += '<body>\n'

#header
html += '<header>\n'
html += '<h1>RUDO</h1>\n'
html +=	'<h2>Retrieve Unique DNA Output</h2>\n' 
html += '</header>\n'

#navigation toolbar
html += '<nav>\n'
html += '<ul>\n'
html +=	'<li><a href="http://student.cryst.bbk.ac.uk/~sr002/index.html">HOME</a></li>\n'
html +=	'</ul>\n'	
html += '</nav>\n'

html += '<h2>RUDO Results</h2>\n'

#search_type value
html += '<p>You searched on: <b>' + search_type + '</b></p>\n'

html += '<p>' + str(reference) + '</p>'
html += '<p>' + str(query1) + '</p>'
html += '<p>' + str(query2) + '</p>'






#send web input to web.sh program
with open('/d/mw8/u/sr002/qod/v1.0.2/bin/webref_data.txt', 'w') as fl:
    fl.write(str(reference))

with open('/d/mw8/u/sr002/qod/v1.0.2/bin/webquery_data.txt', 'w') as f:
    f.write(str(query1))
    f.write('\n')
    f.write(str(query2))

#call RUDO script
call("/d/mw8/u/sr002/qod/v1.0.2/bin/web.sh", shell=True)


html += '<footer>\n'
#CSS level 3 Validated
html += '<p>\n'
html += '<a href="http://jigsaw.w3.org/css-validator/check/referer">\n'
html += '<img style="border:0;width:88px;height:31px" src="http://jigsaw.w3.org/css-validator/images/vcss-blue" alt="Valid CSS!" />\n'
html += '</a>\n'
html += '</p>\n'
html += '</footer>\n'

html += '</body>\n'
html += '</html>\n'

print(html)






