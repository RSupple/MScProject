#!/usr/bin/env python3

import mysql.connector

cnx = mysql.connector.connect(user='sr002', database='sr002', host='localhost', password='')

cursor = cnx.cursor(buffered=True)

query = ("SELECT bio_id, sci_name, taxid FROM taxonomy")

cursor.execute(query)

#Print HTML MIME-TYPE header
print ('Content-type:text/html\n')
print()


html ='<!DOCTYPE html>\n'
html += '<html>\n'
html += '<head>\n'
html += '<title>RUDO Database</title>\n'
html += '</head>\n\n'
html += '<body>\n'


    
html += '<table>\n'
html += '<caption><b>Escherichia Coli / Shigella</b></caption>\n'
html += '<tr>\n'
html += '<th>BPID</th>\n'
html += '<th>Name</th>\n'
html += '<th>TaxID</th>\n'


for (bio_id, sci_name, taxid) in cursor:
    html += '</tr>\n'
    html += '<tr>\n'
    html += '<td>' + str(bio_id) + '</td>\n'
    html += '<td>' + str(sci_name) + '</td>\n'
    html += '<td>' + str(taxid) + '</td>\n'
    html += '</tr>\n'
html += '</table>\n'




html += '</body>\n'
html += '</html>\n'
print(html)

cursor.close()

cnx.close()

