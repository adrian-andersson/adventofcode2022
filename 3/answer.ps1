#Import the data
$in = get-content input1.txt
#Split and organise the data


#Generate our priority lookup stuff
#Generate list of chars a..z then A..Z
$Alphabet = New-Object System.Collections.Generic.List[string]

for ([byte]$c = [char]'a'; $c -le [char]'z'; $c++)  
{  
    $alphabet.add([char]$c)
}
for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
    $alphabet.add([char]$c)
}


#Map to a lookup table
$priority = 1
#Case sensitive hashtable, important since powershell and windows, so need to be very specific
$priorityLookup = [HashTable]::New(0, [StringComparer]::Ordinal)
$Alphabet|ForEach-Object{
    $priorityLookup.add("$_",$priority)
    $priority++
}

#Get details for each sack
$sack = 1
$sackDetails = $in.foreach{
    $length = $_.length
    $half = $length/2
    $side1 = $_[0..($half-1)]
    $side2 = $_[$half..$length]
    $inBoth = New-Object System.Collections.Generic.List[string]
    $side1.ForEach{
        if("$_" -cin $side2)
        {
            $inBoth.add($_)
        }
    }
    $side1Priorities = $side1.ForEach{
        [PSCustomObject]@{
            object = $_
            priority = $priorityLookup."$_"
            compartment = 1
            inBoth = if($_ -cin $inBoth){$true}else{$false}
        }
    }
    $side2Priorities = $side2.ForEach{
        [PSCustomObject]@{
            object = $_
            priority = $priorityLookup."$_"
            compartment = 2
            inBoth = if($_ -cin $inBoth){$true}else{$false}
        }
    }

    $allItems = $side1Priorities+$side2Priorities
    $sumOfPriorities = ($allItems.where{$_.inBoth -eq $true}|Select-Object -Unique|Measure-Object -Property 'priority' -sum).sum
    [PSCustomObject]@{
        sack = $sack
        allItems = $allItems
        itemsInboth = $inBoth
        sumOfDupePriorities = ($allItems.where{$_.inBoth -eq $true}|Select-Object -Unique|Measure-Object -Property 'priority' -sum).sum
    }

    $sack++
}

#Answer 1
#Find the item type that appears in both compartments of each rucksack. What is the sum of the priorities of those item types?
$sackDetails.sumOfDupePriorities|Measure-Object -Sum

#Part 2
#Group sacks by 3
#Step 1. add group number to each sack
$group = 1
$g = 1
$groupCount = 3
$sackDetails.ForEach{
    $_|Add-Member -MemberType NoteProperty -Name Group -Value $group
    if($g -eq $groupCount)
    {
        $g = 1
        $group++
    }else{
        $g++
    }
    
}

#Group by.... group... herpderp... it works
$sackDetailsGrouped = $sackDetails|Group-Object -Property Group

#Create a list of badges
$badges = New-Object System.Collections.Generic.List[object]
foreach($group in $sackDetailsGrouped)
{
    
    $inAllGroups = $group.group[0].allItems.object.where{$_ -cin $group.group[1].allItems.object -and $_ -cin $group.group[2].allItems.object}|Select-Object -Unique -First 1

    #Add the badge to each member of this group, just in case
    $group.group.foreach{
        $_|Add-Member -MemberType NoteProperty -Name Badge -Value $inAllGroups
    }

    #Add this groups badge to the list of badges
    $badges.add(
        [pscustomobject]@{
            badge = $inAllGroups
            group = $group.group[0].Group
            priorityValue = $($priorityLookup."$inAllGroups")
        }
    )
}


#Find the item type that corresponds to the badges of each three-Elf group. What is the sum of the priorities of those item types?

<#
#Disclosure and Note: 
This one took a lot longer to answer than I would have liked, mostly because I didn't realise that there could be duplicate badges


#>
$badges|Measure-Object -Property priorityValue -Sum
