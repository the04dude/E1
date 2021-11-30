function GetAllPrimeFactors {
    [CmdletBinding()]
    Param ($n=$(Throw "Specify a number to factorise"))

    $DivisorIncrements=1,2,2,4,2,4,2,4,6,2,6
    $IncrementLength=$DivisorIncrements.Length

    $Root=[Math]::Pow($n,0.5)    # All factors found once divisor is greater than number's square-root

    $Divisor=2        # Initial divisor - try this as first factor
    $Number=$n        # Save original number
    $Answer=""        # Resultant list of factors appended to this string
    $i=0            # Index into increment list

    Write-Verbose ("Finding factors of $n (with root ~{0:0.##})" -f $Root)

    For (;;) {
    Write-Verbose "Trying $Divisor"
    $Remainder=$n/$Divisor
        If ($Remainder -eq [Math]::Truncate($Remainder)) {
            # Remainder is a whole number, found a factor...
            Write-Verbose "Found factor $Divisor"
            If ($Remainder -eq 1) {
                # All factors have been found
                Write-Verbose "Remainder is 1, all factors found"
                Break
            }
            $n=$Remainder        # ...remove this factor and calculate factors of remainder
            $Root=[Math]::Pow($n,0.5)        # ...new end-point
            Write-Verbose ("Remainder is now $Remainder (root ~{0:0.##}), finding factors of this..." -f $Root)
            $Answer+=" $Divisor x"    # ... save list of factors for display
        }
        Else {
            # Current divisor was not a factor
            Write-Verbose "$Divisor is not a factor"
            $Divisor+=$DivisorIncrements[$i]        # Add to the divisor, skipping multiples of 2, 3, 4, 5
            Write-Verbose "Adding $($DivisorIncrements[$i]); divisor is now $Divisor"
            $i++        # Next time add the next increment from the list
            If ($i -ge $IncrementLength) {
                # Got to end of increments list...
                $i=3        # List repeats from the 4th element
                If ($Divisor -gt $Root) {
                    # Check at this point that the divisor isn't too large
                    Write-Verbose "Divisor now greater than Sqrt of remainder... done"
                    Break
                }
            }
        }
    }

    If ($n -eq $Number) { @($n) }
    Else {
        "$Answer $n".Trim() -Split (" x ")
    }
}

Function IsHappy {
    param ($a, $b)

    $aPF = GetAllPrimeFactors $a
    $bPFVals = GetAllPrimeFactors $b
    if (-not ($bPFVals -is [Array])) {
        $bPFVals = @($bPFVals)
    }
    [System.Collections.ArrayList]$bPF = $bPFVals

    $common = @()
    $aPF | ForEach-Object {
        $a = $_
        if ($bPF.Contains($a)) {
            $common += $a
            $bPF.Remove($a)
        }
    }
    $return = $null
    if ($common.Length -eq 0) {
        $return = $false
    }
    $common | Group-Object | Foreach-Object {
        if ($_.Count % 2 -ne 0) { 
            $return = $false
        }
    }
    if ($null -eq $return) {
        $return = $true
    }
    $return

}

for ($k=1; $k -le 2940; $k++) {
    if (IsHappy -a 205800 -b ($k*35)) {
        [System.Collections.ArrayList]$pf = GetAllPrimeFactors $k
        $pf.Remove("7")
        $pf.Remove("5")


        "$k = PF: [5,7] $(($pf) -Join "," )"
    }
}
