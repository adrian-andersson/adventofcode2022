#Import the data
$in = get-content input1.txt
#Split and organise the data
$i = 1
$Items = New-Object System.Collections.Generic.List[Int]
$elves = $in.foreach{
    if($_.length -eq 0){
        [pscustomobject]@{
            elf = $i
            items = $Items
            itemCount = $items.Count
            itemSum = [int]$($items | Measure-Object -sum).sum
        }
        $Items = New-Object System.Collections.Generic.List[Int]
        $i++
    }else{
        $items.add($_)
    }
    
}

#Select the answer for part 1:
##    Find the Elf carrying the most Calories. How many total Calories is that Elf carrying?
$elves|Sort-Object -Property itemSum -Descending|select-object -First 1


##Select the answer for part 2:
##    Find the top three Elves carrying the most Calories. How many Calories are those Elves carrying in total?
$top3 = $elves|Sort-Object -Property itemSum -Descending|select-object -First 3
$($top3|Measure-Object -Property itemsum -sum).sum