ls | grep ipynb | xargs jupyter nbconvert --to html
mv *.html html/
