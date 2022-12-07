#Import the input
$in = get-content input1.txt
#$in = get-content demo.txt

#Lets make a couple classes to just make object iteration easier
class mockFile {

    [string]$location
    [string]$name
    [int32]$size
    [string]$type = 'file'
    [string]$fullName 
    
    mockFile($location,$name,$size)
    {
        $this.location = $location
        $this.name = $name
        $this.size = $size
        if($location[-1] -eq '/' -or $location[-1] -eq '.')
        {
            $this.fullName = "$($location)$($name)"
        }else{
            $this.fullName = "$($location)/$($name)"
        }
    }
}

class mockDir {

    [string]$location
    [string]$name
    [int32]$size = 0
    [string]$type = 'Directory'
    [string]$fullName
    
    mockDir($location,$name)
    {
        $this.location = $location
        $this.name = $name
        if($location[-1] -eq '/' -or $location[-1] -eq '.')
        {
            $this.fullName = "$($location)$($name)"
        }else{
            $this.fullName = "$($location)/$($name)"
        }
    }
}


#Start Location
$currentLoc = '.'
#List to put our output
$output = New-Object System.Collections.Generic.List[object]
#Add the root dir
$output.add([mockDir]::New('.','/'))
$in.foreach{
    #Figure out if we are a commmand line or output line
    $firstChar = $_[0]
    if($firstChar -eq '$')
    {   
        #Command Line, now sort out what command
        $remainder = $($_.split('$ ')[1])
        $commandSplit = $remainder.split(' ')
        $execute = $commandSplit[0]
        if($commandSplit[1]){
            $param = $commandSplit[1]
        }else{
            $param = $null
        }
        
        if($execute -eq 'cd')
        {
            #Change Dir command
            if($param -eq '..')
            {
                # Go back one directory
                #Need to flip dir signs since windows
                $currentLoc = ($currentLoc | split-path -parent).replace('\','/')
            }else{
                #Go up a dir
                #Make sure we dont add a second / with our new location
                if($currentLoc[-1] -eq '/' -or $param -eq '/'){
                    $currentLoc = "$($currentLoc)$($param)"
                }else{
                    $currentLoc = "$($currentLoc)/$($param)"
                }
            }
        }elseIf($execute -eq 'ls')
        {
            #List command, but we can effectively not do anything
        }
        
    }else{
        #Output line, handle depending on file or dir
        $outSplit = $_.split(' ')
        if($outSplit[0] -eq 'dir')
        {
            #Must be a directory
            $item = [mockDir]::New($currentLoc,$outSplit[1])  
        }else{
            $item = [mockFile]::New($currentLoc,$outSplit[1],$outSplit[0])
        }
        #Check for duplicates
        if($item.fullName -notIn $output.fullName)
        {
            $output.Add($item)
        }
    }

}

#Ok so output should be our file structure, lets get sizes for the directories
$directorySizes = $output.where{$_.type -eq 'directory'}.foreach{
    $dirLoc =  $_.fullname
    write-warning "$dirLoc"
    #Work out sizes for this dir, not needed but who knows what part 2 holds
    $files = $output.where{$_.type -eq 'file' -and $_.location -eq $dirLoc}
    $fileStats = $files|Measure-Object -Property size -AllStats
    #Work out sizes for this dir recursively, to answer part 1
    $recurseFiles = $output.where{$_.type -eq 'file' -and $_.location -like "$($dirLoc)*"}
    $recurseFilesStats = $recurseFiles|Measure-Object -Property size -AllStats
    #Return a nice object to do a lookup on later
    [PSCustomObject]@{
        Name = $_.name
        fullname = $_.fullname
        size = $fileStats.sum
        filecount = $fileStats.count
        recurseSize = $recurseFilesStats.sum
        recurseFilecount = $recurseFilesStats.count
    }
}

#And answer part 1
#Find all of the directories with a total size of at most 100000. What is the sum of the total sizes of those directories?
$directorySizes.where{$_.recurseSize -le 100000}|Measure-Object -Property recurseSize -sum


#Part 2 requires some basic disk params
$diskTotalSize = 70000000
$amountToFree = 30000000
#Work out free,used, and required space
$used = $directorySizes.where{$_.fullname -eq './'}.recurseSize
$amountFree = $diskTotalSize - $used
$spaceReq = $amountToFree - $amountFree

#Find the best directory as per part 2 question
#Find the smallest directory that, if deleted, would free up enough space on the filesystem to run the update. What is the total size of that directory?
$directorySizes.where{$_.recurseSize -ge $spaceReq}|Sort-Object -Property recurseSize |Select-Object -first 1