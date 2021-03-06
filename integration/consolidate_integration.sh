#!/bin/bash

# Integration testing for the consolidate.py script

cd ..

##### Two rows

make spotless > /dev/null
./parse.py -p test/fixtures/xml/ -x ipg120327.two.xml -o .
mkdir -p tmp/integration/ipg120327.two


echo Starting clean...
python clean.py

echo Starting consolidate...
python consolidate.py

echo Starting diffs...
for table in inventor inventor_1
do
  sqlite3 -csv inventor.sqlite3 "select * from ${table}"  > tmp/integration/ipg120327.two/${table}.csv
  diff test/integration/consolidate/ipg120327.two/${table}.csv tmp/integration/ipg120327.two/${table}.csv
done

for table in assignee assignee_1 grp wrd
do
  sqlite3 -csv assignee.sqlite3 "select * from ${table}"  > tmp/integration/ipg120327.two/${table}.csv
  diff test/integration/consolidate/ipg120327.two/${table}.csv tmp/integration/ipg120327.two/${table}.csv
done

for table in patent
do
  sqlite3 -csv patent.sqlite3 "select * from ${table}"  > tmp/integration/ipg120327.two/${table}.csv
  diff test/integration/consolidate/ipg120327.two/${table}.csv tmp/integration/ipg120327.two/${table}.csv
done

for table in invpat
do
  sqlite3 -csv invpat.sqlite3 "select * from ${table}"  > tmp/integration/ipg120327.two/${table}.csv
  diff test/integration/consolidate/ipg120327.two/${table}.csv tmp/integration/ipg120327.two/${table}.csv
done


### 18 rows

make spotless > /dev/null
./parse.py -p test/fixtures/xml/ -x ipg120327.18.xml -o .
mkdir -p tmp/integration/ipg120327.18

echo Starting clean...
python clean.py

echo Starting consolidate...
python consolidate.py

echo Starting diffs...
for table in inventor inventor_1
do
  sqlite3 -csv inventor.sqlite3 "select * from ${table}"  > tmp/integration/ipg120327.18/${table}.csv
  diff test/integration/consolidate/ipg120327.18/${table}.csv tmp/integration/ipg120327.18/${table}.csv
done

for table in assignee assignee_1 grp wrd
do
  sqlite3 -csv assignee.sqlite3 "select * from ${table}"  > tmp/integration/ipg120327.18/${table}.csv
  diff test/integration/consolidate/ipg120327.18/${table}.csv tmp/integration/ipg120327.18/${table}.csv
done

for table in patent
do
  sqlite3 -csv patent.sqlite3 "select * from ${table}"  > tmp/integration/ipg120327.18/${table}.csv
  diff test/integration/consolidate/ipg120327.18/${table}.csv tmp/integration/ipg120327.18/${table}.csv
done

for table in invpat
do
  sqlite3 -csv invpat.sqlite3 "select * from ${table}"  > tmp/integration/ipg120327.18/${table}.csv
  diff test/integration/consolidate/ipg120327.18/${table}.csv tmp/integration/ipg120327.18/${table}.csv
done

## clean up after we're done

make spotless > /dev/null
