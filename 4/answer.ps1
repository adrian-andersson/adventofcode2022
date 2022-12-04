#Get todays input
$in = get-content input1.txt
#Track each pair just in case
$g = 1
#Work everything out in one pass, including things we probably dont need
$res = $in.foreach{
    #Split the pairs
    $split = $_.split(',')
    #Get a range for each pair
    $range1 = $split[0].split('-')[0]..$split[0].split('-')[1]
    $range2 = $split[1].split('-')[0]..$split[1].split('-')[1]
    #Work out where there is some overlap
    #And just in case, work out what rooms overlap at all
    #Starting with assumption, no overlap
    $overlap = $false
    $overlappingRooms = New-Object System.Collections.Generic.List[Int]
    $range1.foreach{if($_ -in $range2){$overlap = $true;$overlappingRooms.Add($_)}}
    #Work out where there is a full overlap to answer part 1
    #Once again starting with assumption, no overlap
    $stats1 = $range1|Measure-Object -AllStats
    $stats2 = $range2|Measure-Object -AllStats
    $fullOverlap = $false
    $description = $null
    #Simple maff should do it
    if($stats1.minimum -ge $stats2.minimum -and $stats1.Maximum -le $stats2.Maximum){$fullOverlap = $true;$description='Range1 in Range2'}
    elseif($stats2.minimum -ge $stats1.minimum -and $stats2.Maximum -le $stats1.Maximum){$fullOverlap = $true;$description='Range2 in Range1'}
    #Return everything we need in an object to then calc the answers later
    [PSCustomObject]@{
        Pair = $g
        range1 = $range1
        range1Start = $stats1.Minimum
        range1End = $stats1.Maximum
        range2 = $range2
        range2Start = $stats2.Minimum
        range2End = $stats2.Maximum
        overlap = $overlap
        fullOverlap = $fullOverlap
        description = $description
        overlappingRooms = $overlappingRooms
        overlappingRoomsCount = $overlappingRooms.Count
    }
    $g++

}

#In how many assignment pairs does one range fully contain the other?
$res.where{$_.fullOverlap -eq $true}.count


#In how many assignment pairs do the ranges overlap?
$res.where{$_.overlap -eq $true}.count