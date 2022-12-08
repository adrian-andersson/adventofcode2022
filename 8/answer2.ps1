#Import the input
$in = get-content input1.txt
#Uncomment this to test
#$in = get-content demo.txt

<#
    Thought I'd give this a second pass to see if I could do it cleaner, faster, simpler
    I think I achieved the cleaner, simpler goal, but oddly it isn't faster
#>

class tree {
    [int]$row
    [int]$column
    [ValidateRange(0,9)]
    [int]$height
    [int]$rowLength
    [int]$columnLength
    [bool]$visible
    [bool]$edge


    #Hide this from anything returned
    [object[]]$matches

    #Added for Part 2
    [int]$viewDistanceUp
    [int]$viewDistanceLeft
    [int]$viewDistanceDown
    [int]$viewDistanceRight
    [int]$scenicScore

    #Constructor
    tree($height,$row,$column,$rowLength,$columnLength)
    {
        $this.row = $row
        $this.column = $column
        $this.height = $height
        $this.rowLength = $rowLength
        $this.columnLength = $columnLength
    }

    #[object]match($row,$column,$height)
    [object]match($tree)
    {
        $objBase = @{
            row = $this.row
            column = $this.column
        }
        if($tree.row -eq $this.row -and $tree.column -ne $this.column)
        {
            #Left Right Match
            if($tree.column -lt $this.column )
            {
                $objBase.direction = 'Right'
                $objBase.distance = $this.column - $tree.column
            }else{
                $objBase.direction = 'Left'
                $objBase.distance = $tree.column - $this.column
            }
        }elseIf($tree.column -eq $this.column -and $tree.row -ne $this.row)
        {
            #Up Down Match
            if($tree.row -lt $this.row)
            {
                $objBase.direction = 'Down'
                $objBase.distance = $this.row - $tree.row
            }else{
                $objBase.direction = 'Up'
                $objBase.distance = $tree.row - $this.row
            }
        }

        if($objBase.direction)
        {
            $heightDif =  $this.height - $tree.height
            $objBase.heightDif = $heightDif
            if($heightDif -ge 0){
                $objBase.obfuscates = $true
            }else{
                $objBase.obfuscates = $false
            }

            return [PSCustomObject]$objBase
        }else{
            return $null
        }
        return $string
    }

    [void]getMatches($forest){
        $this.matches = $forest.match($this)
    }

    [void]setClearing(){
        if(!$this.matches)
        {
            write-warning 'Get mathes first'
        }else{
            $groupedMatches = $this.matches|Group-Object -Property 'direction'
            $up = $groupedMatches.where{$_.name -eq 'Up'}.group
            #$up = $this.matches.where{$_.direction -eq 'Up'}
            if($up)
            {
                if($up.where{$_.obfuscates -eq $true})
                {
                    $this.viewDistanceUp = $($up.where{$_.obfuscates -eq $true}|sort-object distance|Select-Object -first 1).distance
                }else{
                    $this.visible = $true
                    $this.viewDistanceUp = $($up|sort-object distance -Descending|Select-Object -first 1).distance
                }
            }else{
                $this.visible = $true
                $this.edge = $true
                $this.viewDistanceUp = 0
            }

            $down = $groupedMatches.where{$_.name -eq 'down'}.group
            #$down = $this.matches.where{$_.direction -eq 'down'}
            if($down)
            {
                if($down.where{$_.obfuscates -eq $true})
                {
                    $this.viewDistanceDown = $($down.where{$_.obfuscates -eq $true}|sort-object distance|Select-Object -first 1).distance
                }else{
                    $this.visible = $true
                    $this.viewDistanceDown = $($down|sort-object distance -Descending|Select-Object -first 1).distance
                }
            }else{
                $this.visible = $true
                $this.edge = $true
                $this.viewDistanceDown = 0
            }

            #$left = $this.matches.where{$_.direction -eq 'left'}
            $left = $groupedMatches.where{$_.name -eq 'left'}.group
            if($left)
            {
                if($left.where{$_.obfuscates -eq $true})
                {
                    $this.viewDistanceLeft = $($left.where{$_.obfuscates -eq $true}|sort-object distance|Select-Object -first 1).distance
                }else{
                    $this.visible = $true
                    $this.viewDistanceLeft = $($left|sort-object distance -Descending|Select-Object -first 1).distance
                }
            }else{
                $this.visible = $true
                $this.edge = $true
                $this.viewDistanceLeft = 0
            }

            #$right = $this.matches.where{$_.direction -eq 'Right'}
            $right = $groupedMatches.where{$_.name -eq 'right'}.group
            if($right)
            {
                if($right.where{$_.obfuscates -eq $true})
                {
                    $this.viewDistanceRight = $($right.where{$_.obfuscates -eq $true}|sort-object distance|Select-Object -first 1).distance
                }else{
                    $this.visible = $true
                    $this.viewDistanceRight = $($right|sort-object distance -Descending|Select-Object -first 1).distance
                }
            }else{
                $this.visible = $true
                $this.edge = $true
                $this.viewDistanceRight = 0
            }

            $this.scenicScore = $this.viewDistanceDown * $this.viewDistanceLeft * $this.viewDistanceRight * $this.viewDistanceUp
        }
    }
}


#Now process our input and create our forest
$row = 1
$rowLength = $in.count
$forest = $in.foreach{
    $columnLength = $_.Length
    $split = ($_ -split '')[1..$($columnLength)]
    $column = 1
    $split.foreach{
        [tree]::new($_,$row,$column,$rowLength,$columnLength)
        $column++
    }
    $row++ 
}


$forest.getmatches($forest)
$forest.setClearing()

$forest[0]

#Part 1 answer
#Consider your map; how many trees are visible from outside the grid?
#For Demo data, answer should be 21
$forest.where{$_.visible -eq $true}.count


#Then just return the tree with the highest scenic score
$forest|Sort-Object -Property scenicScore -Descending |Select-Object -first 1