#Import the input
$in = get-content input1.txt
#To test, comment out below, answer should be 7
#$in = get-content demo.txt


#Substring and custom object blugh to find the right result
$currentPos = 0
$substringLength = 4
$marker = $false
$result = While(!$marker)
{
    #Get a substring of the chars it could be
    $substring = $in.Substring($currentPos,$substringLength)
    #Make an array from our chars. since splitting like this includes a head and tail, exclude those from the array
    $split = ($substring -split '')[1..$substringLength]

    #Work out if we have recurrance
    $recurrance = $false
    foreach($char in $split)
    {
        $CharCount = $split.where{$_ -eq $char}.count
        if($CharCount -gt 1)
        {
            $recurrance = $true
        }
    }
    #If no recurrance, we have what we need
    if(!$recurrance)
    {
        $marker = $true
        #Return an object with all the important bits
        [pscustomobject]@{
            markerChars = $substring
            markerCharacter = $substring[0]
            currentPos = $currentPos
            precedingString = $in.split($substring)[0]
            previousChars = ($in.split($substring)[0].length + $substring.Length)
        }
    }
    $currentPos++
        
}

#How many characters need to be processed before the first start-of-packet marker is detected?
$result.previousChars

#To test part 2, comment out below, should be 23
#$in = get-content demo2.txt

#Run it again for part2, only real change is the substring length
$currentPos = 0
$substringLength = 14
$marker = $false
$result2 = While(!$marker)
{
    $substring = $in.Substring($currentPos,$substringLength)
    $split = ($substring -split '')[1..$substringLength]
    $recurrance = $false
    foreach($char in $split)
    {
        $CharCount = $split.where{$_ -eq $char}.count
        if($CharCount -gt 1)
        {
            $recurrance = $true
        }
    }

    if(!$recurrance)
    {
        $marker = $true
        [pscustomobject]@{
            markerChars = $substring
            markerCharacter = $substring[0]
            currentPos = $currentPos
            precedingString = $in.split($substring)[0]
            previousChars = ($in.split($substring)[0].length + $substring.Length)
        }
    }
    $currentPos++
        
}
$result2.previousChars