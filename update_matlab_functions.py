#!/usr/bin/env python3
""" Script to update the syntax definitions of the plugin

MATLAB continuously adds new functions every release. This script simplifies adding new definitions by parsing the
reference list from the MATLAB documentation (https://www.mathworks.com/help/matlab/referencelist.html) and outputing a
syntax file for it.
"""
from bs4 import BeautifulSoup
from os.path import exists

FILE = 'funcs.html'
if not exists(FILE):
    raise Exception('Please manually download the table by visiting'
            'https://www.mathworks.com/help/matlab/referencelist.html, copy the HTML from the developer tools and save'
            f'it to {FILE}'.replace('\n', ''))

with open(FILE) as f:
    print(f'Opening file {FILE}.')
    html = f.read()

print('Parsing HTML: ', end='')
soup = BeautifulSoup(html, "html.parser")
content = soup.find(id='reflist_content')
tables = content.find_all('table')

funcs = []

for table in tables:
    for link in table.find_all('a'):
        text = link.text

        # The isalpha is to exclude operators such as +, ^
        if text != 'Note:' and text[0].isalpha():
            funcs.append(link.text)
print('Found {} functions.'.format(len(funcs)))

# Remove keywords and specific articles
# The function contains needs to be removed because it is also a vim keyword
keywords = {'return', 'function', 'switch', 'case', 'else', 'elseif', 'end', 'if', 'otherwise', 'break', 'continue',
        'do', 'for', 'while', 'classdef', 'methods', 'properties', 'events', 'persistent', 'global', 'try', 'catch',
        'rethrow', 'throw', 'import', 'true', 'false', 'eps', 'Inf', 'NaN', 'pi',
        'Short-circuit &&, ||', 'if, elseif, else', 'try, catch', 'switch, case, otherwise', 'matlab (Windows)',
        'matlab (macOS)', 'matlab (Linux)', 'contains', 'i', 'j'}

OUTPUT = 'matlab-functions-syntax.vim'
with open(OUTPUT, 'w') as f:
    print(f'Writing to {OUTPUT}.')
    s = 'syn keyword matlabFunc'
    for func in funcs:
        if func in keywords:
            continue
        elif len(s) + len(func) + 2 < 120:
            s += ' '
            s += func
        else:
            f.write(s + '\n')
            s = f'syn keyword matlabFunc {func}'

