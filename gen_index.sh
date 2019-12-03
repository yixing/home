echo '# index' > README.md

for l in `find blog|grep -v "blog$"|sed -n -e 's/[^\/]*\/\(.*\)\.md/\1/p'|sed -e 's/README//'|sort`;do 
    echo "* [$l](http://yixing.github.io/blog/$l.html)"|sed -e 's/\/\.html/\//' ;
done >> README.md 

CWD=`pwd`
for d in `find blog/i* -type d|sort`; do
    cd $d
    echo '# index' > README.md
    for l in `find . |sed -n -e 's/[^\/]*\/\(.*\)\.md/\1/p'|sed -e 's/README//'|sort`;do 
        echo "* [$l](http://yixing.github.io/blog/$l.html)"|sed -e 's/\/\.html/\//' ;
    done >> README.md 
    cd $CWD
done
