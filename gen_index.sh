echo '# index' > README.md

for l in `find blog|grep -v "blog$"|sed -e 's/[^\/]*\/\(.*\)\.md/\1/'`;do echo "* [$l](http://yixing.github.io/blog/$l.html)" ;done >> README.md 
