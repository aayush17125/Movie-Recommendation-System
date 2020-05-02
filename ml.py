#!/usr/bin/env python
# coding: utf-8


import sys
from sklearn.cluster import KMeans
from sklearn.ensemble import RandomForestClassifier
import numpy as np
from sqlalchemy import create_engine
import pymysql
import pandas as pd
import warnings
from sklearn.exceptions import DataConversionWarning
warnings.filterwarnings(action='ignore', category=DataConversionWarning)

arg = sys.argv
password = arg[1]
database = "project"
db_connection_str = 'mysql+pymysql://root:'+password+'@localhost/'+database
db_connection = create_engine(db_connection_str)
email = arg[2]



# st = ' select * from movie_category where movie_id in( select movie_id from rental where buyer_id in( select buyer_id from buyer where lower(first_name) = lower(\'Maria\') and lower(last_name) = lower(\'Miller\')))'

# sq = 'select title from movie where movie_id in (select movie_id from movie_category where category_id in (select category_id from movie_category where movie_id in(select movie_id from rental where buyer_id in(select buyer_id from buyer where lower(first_name) = lower(\'Maria\') and lower(last_name) = lower(\'Miller\')))))'



# df = pd.read_sql(st, con=db_connection)
# print(df)



watched_sql = "select title from movie where movie_id in (select movie_id from rental where buyer_id in(select buyer_id from buyer where lower(email)= lower('"+email+"')));"
watched = pd.read_sql(watched_sql, con=db_connection)
# print(watched)
movie_genres_sql = "select mov.title, cat.name from movie mov left join movie_category mcat on mov.movie_id = mcat.movie_id left join category cat on mcat.category_id = cat.category_id;"
movie_genres = pd.read_sql(movie_genres_sql,con=db_connection)
cp = movie_genres.copy()
# print("CP", cp)
# print(movie_genres)



movie_genres['title'] = movie_genres['title'].astype('category')
movie_genres['title'] = movie_genres['title'].cat.codes
movie_genres['name'] = movie_genres['name'].astype('category')
movie_genres['name'] = movie_genres['name'].cat.codes
# print(movie_genres)




count_genre_sql = "select count(*) num from category"
count_genre = pd.read_sql(count_genre_sql,con=db_connection)
# count_genre = int(count_genre[0])
count_genre = np.array(count_genre)
count_genre = count_genre[0][0]
# print(count_genre)



y = np.array(watched)
for i in range(len(y)):
    for j in range(len(cp)):
        if (y[i][0]==cp['title'][j]):
            y[i][0]=j

if y.size==0:
    # print("NO MOVIES WATCHED. SOME RANDOM RECOMMENDATIONS-->")
    l = []
    q = np.random.choice(50,size=7,replace=False)
    for i in q:
        l.append(cp['title'][i])
    # print()
    st = "("
    for i in q:
        st+= str(i)+","
    st = st[:-1]
    st = st+")"
    print(st)
else:
    clf = RandomForestClassifier(max_depth=3, random_state=0)
    f = clf.fit(movie_genres['title'].values.reshape(-1,1),movie_genres['name'].values.reshape(-1,1))
    pred = clf.predict(y)
    # print(pred)
    l = []
    ids = []
    # print(watched)
    for i in range(len(movie_genres)):
            if (movie_genres['name'][i] in pred):
                l.append(cp['title'][i])
                ids.append(i+1)
    for i in range(len(watched)):
        if (watched['title'][i] in l):
            a = l.index(watched['title'][i])
            l.remove(watched['title'][i])
            ids.remove(ids[a])
    if l:
        # print("Recommendation-->")
        # print(l)
        # print("movie_id-->")
        # print(*ids)
        st = "("
        for i in ids:
            st+= str(i)+","
        st = st[:-1]
        st = st+")"
        print(st)
    else:
        print("ALL MOVIES OF SIMILAR TYPE ALREADY WATCHED. TRY OTHER GENRES")



