#Import the input
$in = get-content input1.txt

#$in = get-content demo.txt


class tree {
    [int]$row
    [int]$column
    [ValidateRange(0,9)]
    [int]$height
    [int]$rowLength
    [int]$columnLength
    [bool]$visible

    hidden [object[]]$upNeighbours
    hidden [object[]]$downNeighbours
    hidden [object[]]$leftNeighbours
    hidden [object[]]$rightNeighbours

    tree($height,$row,$column,$rowLength,$columnLength)
    {
        $this.row = $row
        $this.column = $column
        $this.height = $height
        $this.rowLength = $rowLength
        $this.columnLength = $columnLength
    }

     hidden [void]getNeighbours($forrest) {
        
        $this.upNeighbours = $forrest.where{$_.column -eq $this.column -and $_.row -lt $this.row}
        $this.downNeighbours = $forrest.where{$_.column -eq $this.column -and $_.row -gt $this.row}
        $this.leftNeighbours = $forrest.where{$_.row -eq $this.row -and $_.column -lt $this.column}
        $this.rightNeighbours = $forrest.where{$_.row -eq $this.row -and $_.column -gt $this.column}
    }

    [void]setVisible($forrest) {
        $isEdge = if($this.row -eq 1 -or $this.row -eq $this.rowLength -or $this.column -eq 1 -or $this.row -eq $this.rowLength -or $this.column -eq $this.columnLength){
            $this.visible = $true
            $true
        }else{
            $false
        }
        
        $this.getNeighbours($forrest)

        if(!$this.visible){
            $isVisibleUp = if($this.upNeighbours){
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
            $isVisibleDown = if($this.downNeighbours){
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
            $isVisibleLeft = if($this.leftNeighbours){
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
            $isVisibleRight = if($this.rightNeighbours){
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
        
        

        <#Testing and Debug
        $obj = [PSCustomObject]@{
            isEdge = $isEdge
            isVisibleUp = $isVisibleUp
            isVisibleDown = $isVisibleDown
            isVisibleLeft = $isVisibleLeft
            isVisibleRight = $isVisibleRight
            isVisible = $this.visible
        }
        return $obj

        #>
    }
}


$row = 1
$rowLength = $in.count
$forrest = $in.foreach{
    $columnLength = $_.Length
    $split = ($_ -split '')[1..$($columnLength)]
    $column = 1
    $split.foreach{
        #write-warning "h: $_; r: $row; c: $column; rl: $rowLength; cl: $columnLength"
        [tree]::new($_,$row,$column,$rowLength,$columnLength)
        
        $column++
    }
    $row++
    
    
}

$forrest.setVisible($forrest)

#Consider your map; how many trees are visible from outside the grid?
#For Demo data, answer should be 21
$forrest.where{$_.visible -eq $true}.count