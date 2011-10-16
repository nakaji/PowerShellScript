
function FizzBuzz($num) {
    if (($num % 3 -eq 0) -and ($num % 5 -eq 0)){
        return "FizzBuzz"
    }elseif ($num % 3 -eq 0){
        return "Fizz"
    }elseif ($num % 5 -eq 0){
        return "Buzz"
    }
    
    return $num
}
