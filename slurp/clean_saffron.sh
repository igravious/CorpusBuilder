#!/bin/sh

./clean_saffron.rb saffron.insight-centre.org/in_saff_utf8.txt 2> saffron.insight-centre.org/tbd_saff_utf8.txt | sort | uniq --ignore-case > saffron.insight-centre.org/saffron.txt
