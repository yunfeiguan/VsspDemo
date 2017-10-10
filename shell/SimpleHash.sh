#!/bin/bash  
      
      
    Hash(){  
        if [ "$#" -ne "2" ]; then  
            echo "Hash Wrong Paramenters!" >&2  
            return 1  
        fi  
        string=$1  
        length=`echo $string|awk '{printf("%d", length($0))}'`  
        if [ "$length" -eq "0" ]; then  
            echo "Hash: At least one letter should be input!" >&2  
            return 1  
        fi 
        iCount=1 
        letterSum=0  
        while [ "$iCount" -le "$length" ]  
        do  
            letterCur=`expr substr $string $iCount 1`  
            letterNumCur=`printf "%d" "'$letterCur"` 
            letterNumCur=`expr $letterNumCur \* $letterNumCur` 
            #echo "$letterCur $letterNumCur"  
            letterSum=`expr $letterSum + $letterNumCur`  
            iCount=`expr $iCount + 1`  
        done 
        letterSum=`expr $letterSum / $2`
        echo $letterSum  
        return 0 
    }
      
    result=`Hash $1 1`
    echo result is $result
