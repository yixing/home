echo '# index' > README.md

for l in `find blog|grep -v "blog$"|sed -n -e 's/[^\/]*\/\(.*\)\.md/\1/p'`;do echo "* [$l](http://yixing.github.io/blog/$l.html)" ;done >> README.md 
