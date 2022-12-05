#Import todays input
$in = get-content input1.txt

<#
Found todays challenge hard but educational, learnt that I can use stacks in PS

#>
#Figure out the current state vs the moves, programatically
$cLine = 0
$splitLine = $null
while(!$splitLine)
{
    $in.foreach{
        if($_.length -eq 0)
        {
            $splitLine = $cLine
        }

        $cline++
    }
    
}

$state = $in[0..($splitLine-1)]
$moves = $in[($splitLine+1)..$($in.length)]
$rows = ($state[-1].split().where{$_.length -gt 0}|Measure-Object -Maximum).maximum


#Build the initial stack state
$stacks = @{}
$row = 1
while($row -le $rows)
{
    #I've never used stacks in PS before. First attempt was with a generic list but it was too clumsy, then I tried queues but queues were worse, a quick google later revealed I can use a stack
    $stacks.add($row,$(New-Object System.Collections.Generic.Stack[string])) 
    $row++
}

#Add the initial items to the stack
#Need to work backwards to get the stack in the right order
$endColumn = $rows*4-1
$r = $splitLine-2
while($r -ge 0)
{
    $thisRow = $state[$r]
    $currentSelect = 1
    $c = 1
    while($currentSelect -le $endColumn)
    {
        $Item = $($thisRow[$currentSelect]) -replace ' ',''
        if($item.Length -gt 0)
        {
            $stacks[$c].push($item)
        }
        $c++
        $currentSelect = $currentSelect+4
    }
    $r--
    $currentPoint++
}


#Process the moves for part 1
$moves.foreach{
    $split = $_.split(' ')
    $move = [int]$split[1]
    $from = [int]$split[3]
    $to = [int]$split[5]
    $cMove = 1
    while($cMove -le $move)
    {
        $dequeue = $stacks[$from].pop()
        $stacks[$to].push($dequeue)
        $cMove++
    }
}

#Part 1 Answer
#After the rearrangement procedure completes, what crate ends up on top of each stack?
(1..$rows).foreach{$stacks[$_]|Select-Object -First 1} -join ''



##Recreate the initial state for part 2
#Same code as above
$stacks = @{}
$row = 1
while($row -le $rows)
{
    $stacks.add($row,$(New-Object System.Collections.Generic.Stack[string]))
    $row++
}

$endColumn = $rows*4-1
$r = $splitLine-2
while($r -ge 0)
{
    $thisRow = $state[$r]
    $currentSelect = 1
    $c = 1
    while($currentSelect -le $endColumn)
    {
        $Item = $($thisRow[$currentSelect]) -replace ' ',''
        if($item.Length -gt 0)
        {
            $stacks[$c].push($item)
        }
        $c++
        $currentSelect = $currentSelect+4
    }
    $r--

    $currentPoint++
}

#Process the moves for part 2
#Theres probably a way to do this in one go, but i'm not familiar with stacks enough
#So we will just make a new stack, then move the items across from the new stack, that should mirror appropriately
$moves.foreach{
    $split = $_.split(' ')
    $move = [int]$split[1]
    $from = [int]$split[3]
    $to = [int]$split[5]
    $cMove = 1
    $newStack = New-Object System.Collections.Generic.Stack[string]

    while($cMove -le $move)
    {
        $dequeue = $stacks[$from].pop()
        $newStack.push($dequeue)
        $cMove++
    }

    foreach($i in $newStack)
    {
        "put $i in $to"
         $stacks[$to].push($i)
    }
    
}

#Part 2 Answer
#After the rearrangement procedure completes, what crate ends up on top of each stack?
(1..$rows).foreach{$stacks[$_]|Select-Object -First 1} -join ''