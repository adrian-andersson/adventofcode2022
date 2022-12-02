#Import the input
$in = get-content input1.txt


#Score tables to lookup
$shapeScoreTable = @{
    rock = 1
    paper = 2
    scissors = 3
}

$victoryScoreTable = @{
    win = 6
    loss = 0
    draw = 3
}


#Part1
$opponentkey = @{
    a = 'rock'
    b = 'paper'
    c = 'scissors'
}

$mekey = @{
    x = 'rock'
    y = 'paper'
    z = 'scissors'
}

$rules = @{
    paper = @{paper = 'draw';scissors='loss';rock='win'}
    rock = @{paper = 'loss';scissors='win';rock='draw'}
    scissors = @{paper = 'win';scissors='draw';rock='loss'}
}

#Work out what they played, what we played, the result, the score, in a table
$inTabled = $in.foreach{
    $split = $_.split(' ')
    $opponentPlays = $opponentkey."$($split[0])"
    $responsePlays = $mekey."$($split[1])"
    $result = $rules."$responsePlays"."$opponentPlays"
    $shapeScore = $shapeScoreTable.$responsePlays
    $gameScore = $victoryScoreTable.$result
    [psCustomObject]@{
        opponentInput = $split[0]
        responseInput = $split[1]
        opponentPlays = $opponentPlays
        responsePlays = $responsePlays
        result = $result
        shapeScore = $shapeScore
        gameScore = $gameScore
        totalScore = $shapeScore + $gameScore
    }
}

#part 1 answer
#What would your total score be if everything goes exactly according to your strategy guide?
$inTabled.totalScore |Measure-Object -AllStats


#part 2
#Needs a different lookup for what our input is
$mekey = @{
    x = 'loss'
    y = 'draw'
    z = 'win'
}

#Possible outcomes and responses
$responses = @{
    win = @{paper = 'scissors';scissors='rock';rock='paper'}
    loss = @{paper = 'rock';scissors='paper';rock='scissors'}
    draw = @{paper = 'paper';scissors='scissors';rock='rock'}
}


#Redo making a table of results and stuff
$inTabled2 = $in.foreach{
    $split = $_.split(' ')
    $opponentPlays = $opponentkey."$($split[0])"
    $responseNeeds = $mekey."$($split[1])"
    $responsePlays = $responses."$responseNeeds"."$opponentPlays"
    $result = $rules."$responsePlays"."$opponentPlays"
    $shapeScore = $shapeScoreTable.$responsePlays
    $gameScore = $victoryScoreTable.$result
    [psCustomObject]@{
        opponentInput = $split[0]
        responseInput = $split[1]
        opponentPlays = $opponentPlays
        responseNeeds = $responseNeeds
        responsePlays = $responsePlays
        result = $result
        shapeScore = $shapeScore
        gameScore = $gameScore
        totalScore = $shapeScore + $gameScore
    }
}

#Answer 2
#Following the Elf's instructions for the second column, what would your total score be if everything goes exactly according to your strategy guide?
$inTabled2.totalscore|Measure-Object -AllStats