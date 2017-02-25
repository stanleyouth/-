#!/usr/bin/python 
# -*- coding: utf-8 -*- 

import sys

class N50:
    ### initiate and read in
    def __init__(self,fastafile):
        self.fastafile=fastafile
        self.tlen=0
        self.fasta = {}
        self.length = {}
        fh = open(self.fastafile,"r+")
	#### read fasta files into dic self.fasta   and   record length of each seq in dic self.length
        for line in fh.readlines():
            if line.startswith('>'):
                name=line.replace('>','').split()[0]
		'''print name'''
            else:
		"""print str(line.replace('\n','')) """
                self.fasta[name] = self.fasta.get(name,'') + str(line.replace('\n',''))
                a=len(line.replace('\n',''))
                self.length[name]=self.length.get(name,0) + a
                self.tlen+=a
        fh.close()
    
    ####  kick start analysis
    def len_stat(self,Nn0):
        self.nn0=Nn0
        thisflag=0
        tmplength=0
        tmpnum=0
        self.sortedlength = sorted(self.length.iteritems(),key= lambda l:l[1],reverse=True)
        #### if the term is assigned
        if self.nn0:
            numNn0=0
            lengthNn0=0
            for keys in self.sortedlength:
                tmplength += keys[1]
                tmpnum+=1
                if thisflag == 0 and int(tmplength)/int(self.tlen) >= int(self.nn0)/100 :
                    self.Nn0= keys[1]
                    numNn0+=1
                    lengthNn0= keys[1]
                    thisflag=1
                if thisflag == 1 and keys[1] ==lengthNn0:
                    numNn0+=1
                if thisflag == 1 and keys[1] < lengthNn0:
                    self.NumNn0=numNn0
                    self.Numabove=tmpnum-1
                    break
        #### if not assigned, output a whole summary    
        else:
            numNn02=0
            lengthNn02=0
            thisint=0
	    self.Nn0={}
	    self.NumNn0={}
	    self.Numabove={}
            for keys in self.sortedlength:
                tmplength += keys[1]
                tmpnum+=1
                if thisflag == 0 and int(int(tmplength)*10/int(self.tlen)) - thisint > 0 :
		    thisflag=1
                    thisint=int(int(tmplength)*10/int(self.tlen))
                    self.Nn0[thisint*10]=keys[1]
                    numNn02+=1
                    lengthNn02=keys[1]
                elif thisflag == 1 and keys[1]==lengthNn02:
                    numNn02+=1
                elif thisflag == 1 and keys[1] < lengthNn02:
		    self.NumNn0[thisint*10]=numNn02
		    numNn02=0
                    self.Numabove[thisint*10]=tmpnum-1
                    thisflag=0
		    if int(int(tmplength)*10/int(self.tlen)) - thisint > 0 :
		        thisflag=1
			thisint=int(int(tmplength)*10/int(self.tlen))
			self.Nn0[thisint*10]=keys[1]
			numNn02+=1
			lengthNn02=keys[1]
	    self.NumNn0[thisint*10]=numNn02
	    self.Numabove[thisint*10]=tmpnum
    

    #### generate a report table
    def report(self):
        if not self.sortedlength :
	    self.len_stat()
        print "statistics of "+self.fastafile+"\n"
        if self.nn0 :
            print "N"+self.nn0+":\t"+self.Nn0+"\t"+str(self.NumNn0)+"\t"+str(self.Numabove)
        else:
            sortedNn0=sorted(self.Nn0.iteritems(),key= lambda x:x[0],reverse=False)
            for keys in sortedNn0:
                print "N"+str(keys[0])+":\t"+str(keys[1])+"\t"+str(self.NumNn0[keys[0]])+"\t"+str(self.Numabove[keys[0]])
        print "total length:\t"+str(self.tlen)+"\n"

##################   end of the N50 class


if __name__ == '__main__' :
    genome = sys.argv[1]
    x=N50(genome)
    if len(sys.argv) < 3:
	sta_N=None
    else :
        sta_N=sys.argv[2]
    x.len_stat(sta_N)
    x.report()
	
 
