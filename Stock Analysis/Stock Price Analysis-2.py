#!/usr/bin/env python
# coding: utf-8

# In[43]:


pip install pandas_datareader.data


# In[103]:


import re #Regular Expression library
import json
import csv
from io import StringIO
from bs4 import BeautifulSoup
import requests 
import pandas_datareader.data as reader
import yfinance as yf
import pandas as pd
import datetime as dt
import statsmodels.api as sm
import getFamaFrenchFactors as gff
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np


# In[2]:


stock = 'BK'


# In[89]:


stock_url='https://query1.finance.yahoo.com/v7/finance/download/F?period1=1568483641&period2=1600106041&interval=1d&events=history'
headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15'
}
response = requests.get(stock_url, headers=headers)


# In[90]:


file = StringIO(response.text)
reader = csv.reader(file)
data = list(reader)
for row in data[:5]:
    print(row)


# In[91]:


data1 = pd.DataFrame(data=data)


# In[92]:


print(data1)


# In[7]:


first_row = data1.iloc[0]
print(first_row)


# In[8]:


data1.drop(0, inplace=True)


# In[9]:


print(data1)


# In[10]:


df = data1.rename(columns=dict(zip(data1.columns, first_row)))


# In[11]:


print(df)


# In[12]:


print(type(df["Adj Close"]))


# In[13]:


df["Date"] = pd.to_datetime(df["Date"])
df["Adj_Close"] = (df["Adj Close"])


# In[14]:


adj_close = df['Adj_Close']
Date = df['Date']


# In[15]:


fig, ax = plt.subplots(figsize=(8, 6))
ax.plot(Date, adj_close)
plt.xlabel('Date') 
plt.ylabel('Price') 


# In[ ]:





# In[16]:


print(df)  


# In[17]:


df.drop(columns=['Close'], inplace = True)


# In[18]:


df['pct_change'] = df["Adj_Close"].pct_change()


# In[20]:


df.dtypes


# In[21]:


df['Adj_Close'] = df['Adj_Close'].astype(str).astype(float)
df


# In[22]:


df['pct_change'] = df["Adj_Close"].pct_change()
df


# In[23]:


df['log_ret'] = np.log(df["Adj_Close"]) - np.log(df["Adj_Close"].shift(1))
df


# In[24]:


fig, ax = plt.subplots(figsize=(8, 6))
ax.plot(Date, df['log_ret'])
plt.xlabel('Date') 
plt.ylabel('Log Returns') 


# In[25]:


pip install statsmodels


# In[34]:


df.replace([np.inf, -np.inf], np.nan, inplace=True)
df.dropna()


# In[37]:


count_nan = df.isna().sum().sum()
print(count_nan)
df = df.dropna()


# In[38]:


count_nan = df.isna().sum().sum()
print(count_nan)


# In[39]:


from statsmodels.tsa.stattools import adfuller

#perform augmented Dickey-Fuller test
adfuller(df['log_ret'])


# In[ ]:


# As our P-Value is less than 0.01, our results are highly statistically significant, and we can reject the null hypothesis, meaning that the transformed data is stationary. This is beneficial as we can now be confident that the relationships that our model details are likely to be true.


# In[104]:


yf.pdr_override()


# In[108]:


end = dt.datetime.now()
start = dt.date(end.year - 6, end.month,end.day)
ticker = ['BK']


# In[111]:


stock_prices = pd.DataFrame(reader.get_data_yahoo(ticker, start, end)['Adj Close'])
stock_prices 


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# Market Risk Premium (Market excess returns)
# 

# In[113]:


MRP = pd.DataFrame(gff.famaFrench3Factor(frequency='m'))
MRP 


# In[114]:


MRP.rename(columns={'date_ff_factors':'Date'}, inplace = True)
MRP.set_index('Date',inplace = True)


# In[115]:


MRP


# In[116]:


fdf = MRP.merge(stock_prices, on ='Date')


# In[117]:


fdf


# In[118]:


fdf['log_ret'] = np.log(fdf["Adj Close"]) - np.log(fdf["Adj Close"].shift(1))
fdf


# In[120]:


fdf = fdf.dropna()
fdf


# In[121]:


fdf['BK-RF'] = fdf.log_ret - fdf.RF
fdf


# In[122]:


sns.regplot(x='Mkt-RF', y='BK-RF', data=fdf)


# In[126]:


x = fdf['Mkt-RF']
y = fdf['BK-RF']
a = sm.add_constant(x)
model = sm.OLS(y,a)

results = model.fit()
results.summary()

