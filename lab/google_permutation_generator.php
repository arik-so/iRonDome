<?php
/**
 * Created by IntelliJ IDEA.
 * User: arik-so
 * Date: 7/18/14
 * Time: 4:40 PM
 */

echo '<pre>';

$numbers = [1, 4, 2, 5];


generatePermutations($numbers);

function generatePermutations($numberSet){


    $allPermutations = [];

    for($length = 1; $length <= count($numberSet); $length++){

        $currentPerms = generateFixedLengthPermutations($numberSet, $length);

        $allPermutations = array_merge($allPermutations, $currentPerms);

    }


    print_r($allPermutations);

}


function generateFixedLengthPermutations($numberSet, $length){

    $setIndices = [];

    $necessaryIncrements = [];
    $permutationCount = 1;

    $permutations = [];

    for($indexIndex = 0; $indexIndex < $length; $indexIndex++){
        $setIndices[$indexIndex] = $indexIndex;
        $indexIncrements[$indexIndex] = 0;
    }

    $incrementedIndices = $setIndices;

    $i = 0;
    while(true){

        $currentCombination = [];

        foreach($incrementedIndices as $key =>  $currentIndex){

            $currentCombination[$key] = $numberSet[$currentIndex];

        }

        $currentPermutations = generateReorders($currentCombination);
        $permutations = array_merge($permutations, $currentPermutations);

        // $permutations[] = $currentCombination;

        $modifications = 0;
        for($incrementIndex = $length; $incrementIndex > 0; $incrementIndex--){

            $maximum = (count($numberSet)-$length) + $incrementIndex - 1;

            if($incrementedIndices[$incrementIndex-1] == $maximum){ continue; }

            $modifications++;
            $incrementedIndices[$incrementIndex-1]++;

            break;

        }

        if($modifications == 0){

            break;

        }

        // print_r($incrementedIndices);



    }



    // print_r($permutations);

    return $permutations;

}

function generateReorders($numberSet){

    $length = count($numberSet);

    if($length < 2){ return [$numberSet]; }

    $swapCount = 1;
    for($i = 1; $i <= $length; $i++){
        $swapCount *= $i;
    }
    $swapCount--; // we have combinations, so the swap count needs to be reduces by one

    $permutations = [$numberSet];

    $maxSwapIndex = $length-1; // the penultimate thing is what we have to change
    for($swap = 0; $swap < $swapCount; $swap++){

        $leftIndex = $swap % $maxSwapIndex;
        $rightIndex = $leftIndex+1;

        $leftValue = $numberSet[$leftIndex];
        $rightValue = $numberSet[$rightIndex];

        $numberSet[$leftIndex] = $rightValue;
        $numberSet[$rightIndex] = $leftValue;

        $permutations[] = $numberSet;

    }

    return $permutations;

}

// print_r($convenientLookup);