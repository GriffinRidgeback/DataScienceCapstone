Coursera Data Science Specialization - Capstone Presentation
========================================================
author: Kevin E. D'Elia
date: 03/26/2017
autosize: true
font-family: 'Helvetica'

Motivation
========================================================

Ever wonder how companies like **Swiftkey** can suggest words to complete that ever-important text on your mobile phone?  Well, the purpose of this Capstone project is to provide some insight into how Natural Language Processing can be used to accomplish that feat.

Students in this course were asked to analyze large bodies of text (**corpora**), perform data mining and data cleansing on the corpora, and develop an algorithm for predicting words given arbitrary text input.  The final product is a Shiny web application which will attempt to mimic the behavior of keyboards on modern mobile devices.

Datasets
========================================================

<small>The datasets for the initial phase of the project are from a corpus called __HC Corpora__, available [here](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip); information, what little there is, about the corpus can be found at this [site](https://web.archive.org/web/20160522150305/http://www.corpora.heliohost.org/aboutcorpus.html).  The corpora consist of a set of 3 text files, one for each for several languages; only the English set was used.  Within the set are the following files:

* en_US.blogs.txt
* en_US.news.txt
* en_US.twitter.txt

For the final application, pre-computed n-gram files were used.  These files were obtained from the [N-grams data](http://www.ngrams.info/intro.asp) website, a reference provided by the Wiki page on n-grams.  The free datasets contain approximately 1 million of the most frequent 2, 3, 4, and 5-grams.  Once the n-gram data was loaded, the dataframes were mutated to create a column called **ngram** which consisted of the *word_n* columns concatenated with an underscore; the *word_n* columns were then removed.</small>

Algorithm
========================================================

<small>  The data input via the UI is then "sanitized": underscores are replaced by blanks, punctuation and digits are removed, and the entire string converted to lower case.  **Note:** no profane words are scrubbed and stopwords are kept.  The string is then tokenized, blank string possibly resulting from sanitization are removed, the length of the string is calculated, and then the string is formatted with underscores to match the reference data.  Based on the length of the input string, several code blocks are executed, each doing similar work on slightly modified data.  First, the appropriate n-gram table is searched (e.g., the quintgram table is searched for an input quadgram).  If the search returns results (i.e., indices of data which matched the input), those indices are ordered according to frequency.  At most three are selected (the top three) and the data associated with those indices is extracted, the trailing word removed, and that is what is returned to the UI.  If there is no match, the input string is "pruned" (i.e., the first word is removed) and the resulting string is put through the process again.  If no data matches the input string, a message to that effect is returned.</small> 

Shiny Application
========================================================

<small>The Shiny application, hosted [here](https://thedatascientist.shinyapps.io/DataCapstone/), consists of two tab panels:

**Help & Examples**:  This tab briefly describes both the background behind the application and its usage.  Also included is a table which gives the test harness used to validate the functioning of the algorithm.  It consists primarily of the phrases used and the words predicted by the algorithm.  The application will process 1 to 4 word phrases (phrases longer than that can be entered but will be shortened to conform to the 4-gram limit) and return the top predictions (three at most) that complete the phrase.

**Try it!**:  The simple UI to the prediction algorithm consists of an input box for entering a phrase and a button to press to run the prediction algorithm.  Predictions appear below the button.  **Note**: Some inputs, such as _@@@_, are troublesome, i.e., no predicted values are returned.

While it won't put SwiftKey out of business (just yet, anyway), the application is fast and performs reasonably well for relatively normal, everyday input phrases.</small>
