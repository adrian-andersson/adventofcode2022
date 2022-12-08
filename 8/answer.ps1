#Import the input
$in = get-content input1.txt
#Uncomment this to test
#$in = get-content demo.txt

<#
    Ok we got a lot of things to process,
    Lets try and brute-force it with a custom class and methods
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
    hidden [object[]]$upNeighbours
    hidden [object[]]$downNeighbours
    hidden [object[]]$leftNeighbours
    hidden [object[]]$rightNeighbours

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

    #Find this trees neighbours
    hidden [void]getNeighbours($forest) {
        
        $this.upNeighbours = $forest.where{$_.column -eq $this.column -and $_.row -lt $this.row}
        $this.downNeighbours = $forest.where{$_.column -eq $this.column -and $_.row -gt $this.row}
        $this.leftNeighbours = $forest.where{$_.row -eq $this.row -and $_.column -lt $this.column}
        $this.rightNeighbours = $forest.where{$_.row -eq $this.row -and $_.column -gt $this.column}
    }

    #Find out if this tree is visible from outside the forest
    [void]setVisible($forest) {
        #If its on the edge, its always visible
        $isEdge = if($this.row -eq 1 -or $this.row -eq $this.rowLength -or $this.column -eq 1 -or $this.row -eq $this.rowLength -or $this.column -eq $this.columnLength){
            $this.visible = $true
            $this.edge = $true
            $true
        }else{
            $this.edge = $false
            $false
        }
        
        #If its not an edge, check each direction until we prove its visible or not
        #If it is visible from one perspective, don't worry about the others
        #Honestly there is probably a better way to do this, because this is really slow and brute-force
        $this.getNeighbours($forest)
        if(!$this.visible){
            if($this.upNeighbours){
                if($($this.upNeighbours|Measure-Object -Property height -Maximum).Maximum -lt $this.height)
                {
                    $this.visible = $true
                    $true
                }else{
                    $false
                }
            }else{
                $false
            }
        }
        

        if(!$this.visible){
            if($this.downNeighbours){
                if($($this.downNeighbours|Measure-Object -Property height -Maximum).Maximum -lt $this.height)
                {
                    $this.visible = $true
                    $true
                }else{
                    $false
                }
            }else{
                $false
            }
        }

        if(!$this.visible){
            if($this.leftNeighbours){
                if($($this.leftNeighbours|Measure-Object -Property height -Maximum).Maximum -lt $this.height)
                {
                    $this.visible = $true
                    $true
                }else{
                    $false
                }
            }else{
                $false
            }
        }

        
        if(!$this.visible){
            if($this.rightNeighbours){
                if($($this.rightNeighbours|Measure-Object -Property height -Maximum).Maximum -lt $this.height)
                {
                    $this.visible = $true
                    $true
                }else{
                    $false
                }
            }else{
                $false
            }
        }

    }

    #Added for part 2
    #Calculate the scenic score depending on visibility of neighbouring trees
    [void]setScenicScore() {

        if($this.edge){
            #Edges always have scenic score of 0
            $this.scenicScore = 0
        }else{
            #Find view distance up
            $viewTreesUp = $this.upNeighbours.where{$_.height -ge $this.height}
            if($viewTreesUp){
                $this.viewDistanceUp = $this.row - $($viewTreesUp|Sort-Object -Property row -Descending |Select-Object -First 1).row
            }else{
                $this.viewDistanceUp = $this.row - 1
            }

            #Find view distance down
            $viewTreesDown = $this.downNeighbours.where{$_.height -ge $this.height}
            if($viewTreesDown){
                $this.viewDistanceDown = $($viewTreesDown|Sort-Object -Property row |Select-Object -First 1).row - $this.row
            }else{
                $this.viewDistanceDown = $this.rowLength - $this.row# - 1
            }

            #Find view distance left
            $viewTreesLeft = $this.leftNeighbours.where{$_.height -ge $this.height}
            if($viewTreesLeft){
                $this.viewDistanceLeft = $this.column -  $($viewTreesLeft|Sort-Object -Property column -Descending |Select-Object -First 1).column
            }else{
                $this.viewDistanceLeft = $this.column - 1
            }

            #Find view distance right
            $viewTreesRight = $this.rightNeighbours.where{$_.height -ge $this.height}
            if($viewTreesRight){
                $this.viewDistanceRight = $($viewTreesRight|Sort-Object -Property column |Select-Object -First 1).column - $this.column
            }else{
                $this.viewDistanceRight = $this.columnLength - $this.column #
            }

            #Calculate our final scenic score
            $this.scenicScore = $this.viewDistanceUp * $this.viewDistanceDown * $this.viewDistanceLeft * $this.viewDistanceRight

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

#Call the setVisible method on our custom class to find what trees are visible
$forest.setVisible($forest)

#Part 1 answer
#Consider your map; how many trees are visible from outside the grid?
#For Demo data, answer should be 21
#For real world, this works, but takes a little bit of time
#About 4 - 8 minutes, depending on your PC
$forest.where{$_.visible -eq $true}.count


#Part 2
#First call the setScenicScore to find the scenic score for each tree
$forest.setScenicScore()

#Then just return the tree with the highest scenic score
$forest|Sort-Object -Property scenicScore -Descending |Select-Object -first 1